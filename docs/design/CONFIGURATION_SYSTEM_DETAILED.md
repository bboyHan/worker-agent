

# 系统配置 + 安全细节设计

> 日期: 2026-06-02
> 优先级: 🟡 (建议填补)
> 状态: 完整设计完成

## 一、系统配置详设

### 1.1 配置架构

```
config/
├── workeragent.yaml              # 主配置文件
├── agents/                       # 各Agent配置
│   ├── scheduler.yaml
│   ├── designer.yaml
│   ├── code.yaml
│   ├── test.yaml
│   └── deploy.yaml
├── themes/                       # 主题配置
│   ├── dark.yaml
│   ├── light.yaml
│   └── custom/                   # 用户自定义主题
│       └── my-theme.yaml
├── env/                          # 环境配置
│   ├── default.env
│   ├── production.env
│   └── custom/
├── security/                     # 安全配置
│   ├── encryption.yaml           # 加密设置
│   ├── keys/                     # SSH/API密钥存储
│   │   ├── github_key.enc        # 加密文件
│   │   └── aws_key.enc
│   └── policies.yaml             # 安全策略
├── llm/                          # LLM配置
│   ├── ollama.yaml                # Ollama设置
│   └── providers/                 # 多Provider支持
│       ├── local.yaml            # 本地模型
│       └── anthropic.yaml       # Anthropic API
└── plugins/                       # 插件配置
    └── active/
```

### 1.2 主配置文件示例

```yaml
# workeragent.yaml
version: "1.0"

# 基础设置
general:
  timezone: UTC
  lang: auto
  log_level: info
  auto_save: true
  max_history: 100

# LLM设置
llm:
  provider: ollama
  api:
    base_url: http://localhost:11434
    model: llama3.1:latest
  settings:
    temperature: 0.7
    max_tokens: 4096
    top_p: 0.9
    streaming: true

# 终端设置
terminal:
  rows: 24
  columns: 80
  cursor_style: blink
  font_family: "JetBrains Mono"
  font_size: 14

# 主题设置
theme:
  preset: dark
  custom_colors:
    primary: "#3B82F6"
    surface: "#1E293B"
    text: "#F1F5F9"
    success: "#10B981"
    warning: "#F59E0B"
    error: "#EF4444"
    info: "#60A5FA"
    border: "#475569"
  cursor:
    mode: block
    color: "#F59E0B"

# 安全设置
security:
  encryption:
    type: aes-256-gcm
    passphrase: env:WORKER_AGENT_PASSPHRASE
    key_rotation_days: 90
  ssh_keys:
    auto_add_gitlab: true
    auto_add_github: true
  prompt_injection_protection: true

# Agent设置
agents:
  max_concurrent: 3
  default_timeout: 300  # 5分钟
  retry_policy:
    max_retries: 3
    backoff_base: 2  # seconds
    timeout: 60

# Backup设置
backup:
  interval: 6h       # 备份频率
  max_backups: 7     # 保留数量
  destinations:
    - type: local
      path: ./backups
    - type: remote
      enabled: false
      url: env:REMOTE_BACKUP_URL

# Plugin设置
plugins:
  auto_install: false
  registry_url: https://registry.workeragent.io

# 开发设置 (仅dev模式)
dev:
  debug: false
  mock_llm: false
  hot_reload: true
```

### 1.3 配置验证Schema

```typescript
interface WorkerAgentConfig {
  // schema验证
  schemaVersion: "1.0";
  
  // 必填字段
  llm: {
    provider: "ollama" | "openai" | "anthropic";
    api: {
      base_url: string;
      model: string;
    };
    settings: {
      temperature: number;  // 0-1
      max_tokens: number;   // 100-8192
    };
  };
  
  // 可选字段
  terminal?: {
    rows?: number;
    columns?: number;
    font_family?: string;
    font_size?: number;
  };
  
  theme?: {
    preset?: "dark" | "light" | "system";
    custom_colors?: Record<string, string>;
  };
}
```

## 二、错误恢复与回滚

### 2.1 Undo Stack

```typescript
interface UndoEntry {
  timestamp: number;
  filePath: string;
  before: string | null;    // 修改前内容
  after: string;             // 修改后内容
  action: string;            // 修改原因 (agent/手动)
}

class UndoStack {
  private stack: UndoEntry[] = [];
  private maxDepth = 50;
  
  push(entry: UndoEntry): void {
    this.stack.push(entry);
    if (this.stack.length > this.maxDepth) {
      this.stack.shift();  // 超出最大深度，删除最旧的
    }
  }
  
  undo(): { filePath: string; before: string | null } | null {
    if (this.stack.length === 0) return null;
    
    const entry = this.stack.pop();
    return {
      filePath: entry.filePath,
      before: entry.before
    };
  }
  
  peek(): UndoEntry {
    return this.stack[this.stack.length - 1];
  }
  
  depth(): number {
    return this.stack.length;
  }
}
```

### 2.2 快照系统

```
backups/
├── snapshots/                 # 自动快照
│   ├── 2026-06-02T12:00:00.json  # 快照索引
│   │   {
│   │     "timestamp": "2026-06-02T12:00:00Z",
│   │     "files": ["src/App.tsx", "src/index.tsx"],
│   │     "hash": "sha256:xxx",
│   │     "description": "Design phase complete"
│   │   }
│   └── 2026-06-02T14:00:00.json  # 快照
│       {
│         "timestamp": "2026-06-02T14:00:00Z",
│         "files": ["src/App.tsx", "src/index.tsx", "src/TodoItem.tsx"],
│         "hash": "sha256:yyy",
│         "description": "Code phase complete"
│       }
├── manual/                    # 手动快照
│   └── my-backup-2026-06-03.json
└── latest.json                # 最新快照
```

### 2.3 回滚命令

```bash
# 列出所有快照
> snapshot list
┌─── Timestamp ────────────┬───── Files ───── ├─── Description ──│
│ 2026-06-02T12:00:00Z    │ 2 files    │ Design complete │
│ 2026-06-02T14:00:00Z    │ 3 files    │ Code complete   │
│ 2026-06-03T10:00:00Z    │ 5 files    │ Manual backup   │
└─────────────── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼

# 回滚到指定快照
> snapshot rollback at 2026-06-02T14:00:00Z
▶ 确认回滚: 从 "Code complete" 快照回滚?
[y/N] y
✅ Files restored: 3 files (2026-06-02T14:00:00Z)
```

### 2.4 各阶段的回滚点

| 阶段 | 自动快照 | 手动备份 | 回滚可用 |
|------|------|------|------|--|
| Intent 解析 | ❌ | ✅ | ✅ |
| Scaffold | ✅ | ✅ | ✅ |
| Design | ✅ | ✅ | ✅ |
| Code | ✅ | ✅ | ✅ |
| Test | ✅ | ❌ | ✅ |
| Deploy | ❌ | ❌ | ✅ (手动) |

### 2.5 Undo 快捷键

| 操作 | 快捷键 |
|------|------|
| Undo | `Ctrl+Z` |
| Redo | `Ctrl+Shift+Z` |
| 回到上一个快照 | `Ctrl+R` |
| 撤销当前步骤 | `Alt+Z` |
| 撤销并继续 | `Alt+D` |

## 三、CLI 帮助系统

### 3.1 帮助系统架构

```
> workeragent
Worker Agent v1.0.0

Usage:
  workeragent [command] [options]

Commands:
  new          Create new project
  open         Open existing project
  run          Run design-code-deploy pipeline
  agent        Manage agents
  plugin       Plugin system
  config       Configuration
  deploy       Deploy
  help         Show help
```

### 3.2 帮助查询系统

Help系统支持自然语言查询：

```
# 基础帮助
> agent help
...

# 上下文帮助
> run help
...

# 自然语言查询
> how do I change theme?
...

> show me the available commands
...
```

### 3.3 帮助输出格式

```
> workeragent new help
Create a new project

Usage:
  workeragent new <name> [--tech <stack>] [--template <type>]

Options:
  --tech      技术栈 (react, vue, fastapi, node)
  --template  模板 (default, blog, ecommerce, api)
  --dry       Dry run (只显示规划，不执行)

Examples:
  workeragent new todo-app --tech react
  workeragent new blog-frontend --tech vue --template blog
  workeragent new api --tech fastapi --dry

Agent dispatch:
  New project triggers:
    - Scheduler: analyze intent, create manifest
    - Architecture: recommend tech stack
    - Scaffold: create project structure

Related commands:
  run, open, agent
```

### 3.4 帮助搜索

```
# 搜索帮助
> help search theme
│ config theme                    | 1.2.1 | How to change theme          │
│ theme change                    | 1.0.0 | Quick theme switch           │
│ theme custom                    | 1.1.0 | Custom theme colors          │
```

### 3.5 首次运行引导 (Onboarding)

```
首次运行:
> workeragent

┌── Welcome to Worker Agent ── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┄ │
│                                                        │
│  🎯 Setup Wizard                                        │
│                                                        │
│  Step 1/3: Select LLM Provider                        │
│     [ ] Ollama (local, free)                          │
│     [ ] OpenAI API                                    │
│     [ ] Anthropic API                                 │
│     [ ] Other                                          │
│                                                        │
│  Step 2/3: Default Tech Stack                         │
│     Current: React                                     │
│     Available: React, Vue, FastAPI, Node               │
│                                                        │
│  Step 3/3: Choose Theme                               │
│     [ ] Dark                                          │
│     [ ] Light                                         │
│     [ ] System Default                                 │
│                                                        │
│  [Next] [Skip] [Cancel]                               │
└──────────────────────── ── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

```
首次运行引导后的欢迎信息:
┌──  Welcome to Worker Agent  ── ─ ─ ─ ─ ─ ─ ─ ─ ┄ │
│                                                        │
│  ✅ Setup complete!                                    │
│  📚 Try one of these:                                 │
│  ┌─────────────────────────────┐                      │
│  │ new        Create new project │                    │
│  │ run        Run pipeline          │                    │
│  │ agent      Manage agents      │                      │
│  └─────────────────────────────┘                      │
│  🤖 Or just type what you want to build:              │
│  💡 "A todo list app with React"                      │
│  💡 "A REST API with FastAPI"                         │
│  💡 "A blog with Vue"                                 │
│                                                        │
│  Press Enter to continue...                            │
└────────────────────────────────────────────────┘
```

## 四、测试策略

### 4.1 测试分层

```
┌── Testing Strategy ───────────────── ── ─ ─ ─ ─ ─ ─ ┐
│                                                        │
│  ┌─Unit Tests ── ─ ─ ─ ─ ─ ─ ─ ─ ── ─ ─ ─ ─ ─ ─ ─ ─┤
│  │  - 单元测试: 每个独立函数/方法                       │ │
│  │  - 框架: Vitest                                    │ │
│  │  - 覆盖率目标: 80%                                │ │
│  │  - 示例: prompt_builder.test.ts, config_parser.test.ts     │ │
│  └─ ── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                                        │
│  ┌─ Integration Tests ─── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ├──  │
│  │  - 集成测试: Agent间通信、文件读写、MCP协议        │ │
│  │  - 框架: Vitest (Integration模式)                  │ │
│  │  - 示例: agent_communication.test.ts               │ │
│  └─ ── ── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                                        │
│  ┌─ E2E Tests ── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│  │  - E2E: 端到端验证 (new→run→deploy)                │ │
│  │  - 框架: Ink.js terminal emulator                   │ │
│  │  - 场景: 完整的workflow测试                           │ │
│  └─ ── ─────── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                                        │
│  ┌─ Manual Tests ── ─  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│  │  - 手动测试清单 (无法自动化的场景)                   │ │
│  │  - 示例: UI主题切换、终端渲染、Visual Lock           │ │
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  ┤
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

### 4.2 测试目录结构

```
tests/
├── unit/                              # 单元测试
│   ├── prompt-builder.test.ts
│   ├── config-validator.test.ts
│   ├── intent-parser.test.ts
│   ├── visual-lock.test.ts
│   └── ...
├── integration/                      # 集成测试
│   ├── agent-communication.test.ts
│   ├── file-system.test.ts
│   ├── mcp-protocol.test.ts
│   └── ...
├── e2e/                              # 端到端测试
│   ├── full-pipeline.test.ts        # new→run→deploy
│   ├── terminal-interaction.test.ts
│   └── plugin-system.test.ts
├── utils/                             # 测试工具函数
│   └── test-helpers.ts
├── fixtures/                          # 测试数据
│   ├── sample-code/
│   └── test-configs/
└── vitest.config.ts                   # Vitest配置
```

### 4.3 关键测试场景

| 编号 | 场景 | 类型 | 优先级 |
|------|--|------|--|
| 1 | Intent正确理解 | Unit | P0 |
| 2 | Design tokens正确生成 | Unit | P0 |
| 3 | Visual Lock enforcement | Integration | P0 |
| 4 | 代码生成正确性 | Integration | P0 |
| 5 | Agent间通信 | Integration | P0 |
| 6 | CLI帮助系统 | Unit | P1 |
| 7 | 插件安装/加载 | Integration | P1 |
| 8 | 完整pipeline | E2E | P1 |
| 9 | 终端渲染 | E2E | P1 |
| 10 | 配置加载/保存 | Unit | P1 |
| 11 | Undo/Redo | Unit | P2 |
| 12 | Backup | Integration | P2 |
| 13 | 安全(加密) | Integration | P2 |

## 五、Build/CI/CD流程

### 5.1 构建流程

```bash
# 本地构建
> npm run build
▶ Compiling TypeScript...
▶ Bundling (esbuild)...
▶ Code size: 2.4 MB (minified)
▶ Done!

# 打包
> npm run package
▶ Packaging...
▶ workeragent-linux-x64: 3.1 MB
▶ workeragent-darwin-arm64: 2.8 MB
▶ workeragent-win-x64: 3.2 MB
▶ Done!
```

### 5.2 CI/CD 流程

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run test:unit
      - run: npm run test:integration
      - run: npm run test:e2e

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint

  build:
    runs-on: ubuntu-latest
    needs: [test, lint]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - run: npm run package
      - uses: actions/upload-artifact@v4
        with:
          name: workeragent-builds
          path: dist/

  publish:
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: workeragent-builds
      - uses: JS-DevTools/npm-publish@v3
        with:
          token: ${{ secrets.NPM_TOKEN }}
```

### 5.3 发布流程

```bash
# 版本号管理
> npm version patch
# 1.0.0 → 1.0.1

# 发布
> npm publish
✅ Published workeragent@1.0.1

# Docker发布
> npm run docker:publish
▶ Building Docker image...
▶ Pushing to registry...
✅ workeragent:v1.0.1 published
```

### 5.4 版本号策略

```
SemVer: MAJOR.MINOR.PATCH

MAJOR: 破坏性API变更
MINOR: 新增功能 (向后兼容)
PATCH: bug修复
```
