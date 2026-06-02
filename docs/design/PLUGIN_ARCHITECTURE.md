

# 插件开发架构规范

> 日期: 2026-06-02
> 优先级: 🟡 (建议填补)
> 状态: 完整设计完成

## 1. 架构总览

```
┌── Worker Agent Plugin System ── ── ── ─ ─ ─ ─ ─ ─ ───┐
│                                                        │
│  ┌─ Plugin Registry ── ──────────────── ── ── ─ ─ ───│
│  │  plugins/                                          ││
│  │  ├── agent-ai-chat/                               ││
│  │  ├── theme-dark-blue/                             ││
│  │  ├── deploy-cloudflare/                           ││
│  │  └── ...                                          ││
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
│                                                        │
│  ┌─ Plugin Loader ── ──────────── ── ── ─ ─ ─ ─ ─ ───│
│  │  - discovery (glob pattern)                        ││
│  │  - validation (manifest.schema.json)              ││
│  │  - installation (npm/git/local)                    ││
│  │  - activation (hook lifecycle)                     ││
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
│                                                        │
│  ┌─ Plugin API ── ─ ── ── ─ ─── ── ── ─ ─ ─ ─ ─ ─ ──│
│  │  - core: terminal, config, notify                  ││
│  │  - agent: dispatch, status, tools                  ││
│  │  - ui: theme, render, components                   ││
│  │  - data: store, cache, index                       ││
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
│                                                        │
│  ┌─ Plugin Manifest ── ── ───────────── ── ── ─ ── ─ ─│
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
└───── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─────┘
```

## 2. 插件类型

| 类型 | 扩展能力 | 示例 |
|------|--|------|
| **Agent插件** | 注册新Agent | `plugin-git-operations`, `plugin-ssh-manager` |
| **UI插件** | 渲染组件/主题/面板 | `theme-monokai`, `panel-terminal-extra` |
| **Tool插件** | 注册MCP Tools | `deploy-vercel`, `monitor-prometheus` |
| **Prompt插件** | 自定义提示词模板 | `prompt-react-best-practice` |
| **Config插件** | 自定义配置项 | `config-kubernetes-mode` |
| **Event插件** | 监听/响应事件 | `event-deploy-notifier`, `event-backup` |

## 3. Plugin Manifest 规范

```json
{
  "name": "deploy-docker-aws",
  "version": "1.0.0",
  "type": "deploy",
  "description": "Docker deployment to AWS ECS",
  "author": "YourName",
  "license": "MIT",
  "engine": "worker-agent@>=1.0.0",
  "main": "dist/index.js",
  "manifest": {
    "type": "deploy",
    "tools": [
      "deploy.aws.upload_to_ecs",
      "deploy.aws.create_service"
    ],
    "events": [
      "deploy.completed"
    ],
    "config": {
      "required": ["aws_region", "aws_access_key"],
      "optional": ["max_retries"]
    },
    "terms": {
      "requires_confirmation": ["deploy.aws.upload_to_ecs"],
      "auto_exec": ["deploy.aws.create_service"]
    }
  },
  "dependencies": [],
  "peerDependencies": {},
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  }
}
```

## 4. 插件安装/发现/管理

### 4.1 安装方式

```bash
# Install from worker-plugin registry
> plugin install deploy-docker-aws

# Install from git
> plugin install https://github.com/user/worker-plugin-deploy-docker-aws.git

# Install from local directory
> plugin install ./path/to/plugin

# Install from npm package
> plugin install @worker/deploy-docker-aws
```

### 4.2 插件列表

```
> plugin list
┌─── Name ────────────────┬─── Type ───┬───── Version ───── ───────────┐
│ theme-monokai           │ ui         │ 1.2.0              │
│ deploy-vercel           │ deploy     │ 2.1.0              │
│ agent-chat-enhanced     │ agent          │ 0.5.3              │
│ event-backup-notifier   │ event │ 1.0.1              │
└────── ──────────── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
Total: 4 plugins active
```

### 4.3 插件启用/禁用

```bash
# Enable a plugin
> plugin enable deploy-vercel

# Disable a plugin
> plugin disable theme-monokai

# Uninstall a plugin
> plugin uninstall deploy-vercel
```

## 5. 插件API

### 5.1 Core API (所有插件可用)

```typescript
// --- Core API ---

interface IWorkerAgentPlugin {
  
  // 终端渲染
  terminal: {
    render(panel: Panel): void;
    updatePanel(panelId: string, content: string): void;
    removePanel(panelId: string): void;
    createTab(name: string): Tab;
  };
  
  // 配置
  config: {
    get(key: string): any;
    set(key: string, value: any): void;
    on(key: string, callback: (value: any) => void): void;
  };
  
  // 通知
  notify: {
    info(message: string): void;
    warn(message: string): void;
    error(message: string): void;
    confirm(title: string, message: string): Promise<boolean>;
  };
  
  // 文件操作
  file: {
    readFile(path: string): string;
    writeFile(path: string, content: string): void;
    exists(path: string): boolean;
  };
  
  // Storage (key-value store in knowledge/)
  storage: {
    get(key: string): any;
    set(key: string, value: any): void;
    delete(key: string): void;
    list(): string[];
  };
  
  // Event system
  events: {
    emit(event: string, data: any): void;
    on(event: string, callback: (data: any) => void): void;
    off(event: string, callback: (data: any) => void): void;
  };
  
  // Agent communication (read-only for non-agent plugins)
  agent: {
    isAgent(): boolean;
    getAgentStatus(): AgentStatus;
  };
}
```

### 5.2 Agent API (仅Agent插件可用)

```typescript
// --- Agent API (only for Agent plugins) ---

interface IWorkerAgentPlugin extends IWorkerAgentCore {
  
  // Agent 功能
  scheduler: {
    dispatch(agentId: string, tool: string, params: any): Promise<any>;
    createAgent(name: string, tools: Tool[]): AgentSpec;
  };
  
  // 注册 MCP Tool
  mcp: {
    registerTool(tool: {
      name: string;
      description: string;
      parameters: Schema;
      handler: (params: any) => Promise<any>;
    }): void;
    
    unregisterTool(name: string): void;
  };
  
  // Agent 状态更新
  status: {
    update(status: 'active' | 'idle' | 'error'): void;
    
    // Agent 间状态变更
    broadcast(event: string, payload: any): void;
  };
  
  // Agent 生命周期
  lifecycle: {
    onBeforeStart(): void | Promise<void>;
    onAfterStart(): void | Promise<void>;
    onBeforeStop(): void | Promise<void>;
    onAfterStop(): void | Promise<void>;
    onError(error: Error): void | Promise<void>;
  };
}
```

### 5.3 UI API (仅UI插件可用)

```typescript
// --- UI API (only for UI plugins) ---

interface IWorkerAgentUIPlugin extends IWorkerAgentCore {
  
  // Theme
  theme: {
    registerColor(colorName: string, color: string): void;
    registerFont(fontName: string, font: FontConfig): void;
    setActive(): void;
  };
  
  // Panel 组件
  panel: {
    create(type: 'text' | 'table' | 'chart' | 'form'): PanelConfig;
    registerComponent(comp: ReactComponent, name: string): void;
  };
}
```

## 6. 插件安全

### 6.1 安全沙箱

```
┌─ Plugin Security Sandbox ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ────┐
│                                                        │
│  1. Permission model (按功能分级)                       │
│     ├── 读取(文件)：   所有插件                         │
│     ├── 写入文件：     只允许写入 knowledge/ 目录         │
│     ├── 执行命令:      仅 Agent 插件, 需用户确认        │
│     ├── 访问网络:      仅 Agent 插件, 需用户确认        │
│     ├── 调用Llm:       所有插件 (API key限制)          │
│     └── 系统修改:     不可用 (需用户确认+root)        │
│                                                        │
│  2. 验证 (加载时)                                   │
│     ├── 签名验证 (如果发布到registry)                   │
│     ├── 沙箱检测 (恶意行为模式检测)                    │
│     └── 依赖审查 (npm 包的已知漏洞)                    │
│  3. 运行隔离 (运行时)                                │
│     ├── 内存限制 (最大 100MB/plugin)                    │
│     ├── 网络限制 (DNS白名单)                           │
│     └── 文件系统限制 (chroot 或类似)                   │
└────── ─────── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

### 6.2 权限检查示例

```python
def check_permission(plugin: Plugin, action: str):
    if action == 'read_file':
        return 'allowed'
    elif action == 'write_file':
        if file.path.startswith('knowledge/'):
            return 'allowed'
        else:
            return 'prompt_user'
    elif action == 'exec_command':
        if plugin.type == 'agent':
            return 'prompt_user'
        else:
            return 'denied'
    elif action == 'network_request':
        if plugin.type == 'agent':
            return 'prompt_user'
        else:
            return 'denied'
```

## 7. 插件生命周期

```
┌─ Plugin Lifecycle ───────────────────────── ─ ─ ─ ─ ─ ─┐
│                                                          │
│  Discover ───▶ Validate ───▶ Install ───▶ Activate │
│      │           │             │              │         │
│   glob pattern   manifest      copy to       call
│   扫描 plugins/  检查schema     plugins/     onActivate
│      │           │             │              │         │
│      ▼           ▼             ▼              ▼         │
│  [OK]      [OK]        [OK]        [OK] ─▶ [Running]   │
│      │           │             │              │         │
│      ▼           ▼             ▼              ▼         │
│  加载       注册       安装       注册MCP  ─▶ [Active]   │
│  到缓存     到registry  到磁盘     Tool        │         │
│                                                          │
│  [Stop / Update / Uninstall]                           │
│      │           │             │                       │
│      ▼           ▼             ▼                       │
│  卸载        升级        卸载                      │
└───── ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

### 7.1 插件激活事件

```typescript
// 在激活时调用的事件
interface PluginLifecycleEvents {
  onActivate(plugin: Plugin): void;
  onDeactivate(plugin: Plugin): void;
  onUpdate(plugin: Plugin, oldVersion: string, newVersion: string): void;
  onUninstall(plugin: Plugin): void;
  
  onSystemStart(): void;       // Worker Agent启动时
  onSystemStop(): void;       // Worker Agent停止时
  
  // 注册自定义事件处理器
  on(event: string, handler: (data: any) => void): void;
}
```

## 8. 插件开发示例

### 8.1 简单插件 (Deploy to Vercel)

```javascript
// plugin/vercel-deploy/index.js
'use strict';

module.exports = {
  name: 'deploy-vercel',
  version: '1.0.0',
  
  activate(api) {
    // Register MCP Tool
    api.mcp.registerTool({
      name: 'deploy.vercel.deploy',
      description: 'Deploy project to Vercel',
      parameters: {
        type: 'object',
        properties: {
          projectDir: { type: 'string' },
          vercelToken: { type: 'string' },
          teamId: { type: 'string' },
        },
      required: ['projectDir', 'vercelToken'],
      },
      handler: async (params) => {
        const deploy = require('./vercel-cli');
        return deploy(params);
      }
    });
    
    api.notify.info('Vercel Deploy plugin enabled');
  },
  
  deactivate(api) {
    api.mcp.unregisterTool('deploy.vercel.deploy');
    api.notify.info('Vercel Deploy plugin disabled');
  }
};
```

### 8.2 主题插件

```javascript
// plugin/theme-dark-blue/index.js
'use strict';

module.exports = {
  name: 'theme-dark-blue',
  version: '1.0.0',
  
  activate(api) {
    api.theme.registerColor('primary', '#3B82F6');
    api.theme.registerColor('surface', '#1E293B');
    api.theme.registerColor('text', '#F1F5F9');
    api.theme.registerColor('border', '#475569');
    api.theme.setActive();
  }
};
```

## 9. 插件市场 (Registry)

### 9.1 注册表格式

```json
{
  "name": "worker-agent-plugins",
  "description": "Community plugins for Worker Agent",
  "version": "1.0.0",
  "lastUpdated": "2026-06-02T12:00:00Z",
  "plugins": {
    "deploy-vercel": {
      "version": "1.2.0",
      "downloadUrl": "https://registry.workeragent.io/plugins/deploy-vercel",
      "description": "Deploy to Vercel",
      "author": "workeragent",
      "license": "MIT"
    },
    "deploy-aws-ecs": {
      "version": "0.8.0",
      "downloadUrl": "https://registry.workeragent.io/plugins/deploy-aws-ecs",
      "description": "Deploy to AWS ECS",
      "author": "aws-community",
      "license": "MIT"
    }
  }
}
```

### 9.2 注册/发布插件

```bash
# Publish plugin to registry
> plugin publish
✅ Published deploy-vercel@1.2.0 to registry

# Search registry
> plugin search deploy
│ deploy-vercel │ 1.2.0 │ Deploy to Vercel     │
│ deploy-aws-ecs │ 0.8.0 │ Deploy to AWS ECS    │
```

## 10. 安全性注意事项

1. **插件仅运行在沙箱中** - 网络/文件系统受限
2. **用户可见权限请求** - 所有需要权限的操作都需要用户确认
3. **插件签名验证** - 安装时可验证插件签名
4. **依赖审查机制** - 自动扫描安装的npm包的漏洞
5. **版本锁定** - 锁定插件版本，避免破坏性更新
