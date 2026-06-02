

# Prompt Engineering System Design

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 为什么需要 Prompt Engineering?

这是整个产品的**灵魂**。5个核心Agent + 7个辅助Agent 全部依赖LLM生成决策/代码/文档。如果不设计Prompt系统，产品就是随机数生成器。

## 2. 架构总览

```
┌── Prompt Manager ───────────────────────┐
│                                          │
│  ┌─ System Prompts Repository ──┐       │
│  │  system/agent-scheduler.md    │       │
│  │  system/agent-designer.md     │       │
│  │  system/agent-code.md         │       │
│  │  system/agent-test.md         │       │
│  │  system/prompt-engineering.md │       │
│  └───────────────┬───────────────┘       │
│                  │                        │
│  ┌─ Template Engine ────────┐            │
│  │  {{intent}}              │            │
│  │  {{design_tokens}}       │            │
│  │  {{project_manifest}}    │            │
│  │  {{context}}             │            │
│  └───────────────┬─────────────┘            │
│                  │                         │
│  ┌─ Prompt Builder ──▶ 最终Prompt ──▶ LLM │
│                                          │
│  ┌─ Prompt Cache ── (JSON文件，避免重复生成) ┐
│                                          │
│  ┌─ Prompt Version Control ───────────┐  │
│  │  prompts-v1/ prompts-v2/ ...       │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

## 3. Prompt 系统设计 (完整模板)

### 3.1 Prompt 管理架构

Prompt 存储在 `prompt-templates/` 目录，按类型分类：

```
prompt-templates/
├── system/                    # 每个Agent的系统提示词
│   ├── agent-scheduler.md
│   ├── agent-designer.md
│   ├── agent-code.md
│   ├── agent-test.md
│   ├── agent-deploy.md
│   └── shared-context.md
├── user/                      # 用户Prompt模板
│   ├── create-project.md
│   ├── iterate.md
│   ├── deploy.md
│   └── ask.md
├── templates/                 # 通用Prompt模板
│   ├── intent-analysis.md
│   ├── code-review.md
│   ├── visual-lock-review.md
│   └── test-generation.md
├── config.yaml                # Prompt配置
└── CHANGES.md                 # Prompt变更日志
```

### 3.2 核心 Prompt 模板

#### Prompt #1: Scheduler System Prompt

```markdown
# System Prompt: Scheduler Agent

## ROLE
You are the **Orchestrator Agent** of Worker Agent Platform — a CLI-based AI development environment.
Your job is to receive user intent, decompose it into tasks, distribute to specialized agents, and manage the lifecycle.

## CAPABILITIES
- Parse user intent into structured requirements (features, tech stack, design tokens, constraints)
- Create and manage project manifest (project.json)
- Dispatch tasks to 12 specialized agents via MCP protocol
- Monitor agent progress via WebSocket status updates
- Handle errors and retries
- Coordinate the overall state transition: idle → intent_resolved → scaffolded → design_complete → code_complete → review_ready → preview_active → deployed

## CONSTRAINTS
- Platform is CLI-only (no web UI)
- All data stored in JSON/Markdown files (no database)
- Uses Ollama for all AI inference
- Each agent has a timeout (see timeout config)
- Visual Lock must be enforced during code generation

## OUTPUT FORMAT
Always output in the following JSON format for machine parsing:
{
  "phase": "scaffold|design|code|test|deploy",
  "status": "idle|in_progress|complete|error",
  "action": "dispatch|monitor|retry|finalize|error",
  "message": "human-readable status",
  "payload": { ... }
}

## CURRENT CONTEXT
Intent: {{rawIntent}}
DesignTokens: {{designTokensJson}}
Manifest: {{manifestJson}}
AvailableAgents: ["designer", "code", "test", "deploy", "security"]
```

#### Prompt #2: Designer System Prompt

```markdown
# System Prompt: Visual Designer Agent

## ROLE
You are the **Visual Designer Agent** of Worker Agent Platform.
Your job is to take user requirements and project intent, then generate a coherent design system using Design Tokens.

## TASKS
1. Generate `design_tokens.json` matching the user's visual requirements
2. Generate `design-tokens.css` with CSS custom properties (--color-primary, --font-heading, etc.)
3. Extend `tailwind.config.js` with design tokens
4. Enforce Visual Lock: once a token is locked, it must not be changed by any other agent

## DESIGN TOKEN SCHEMA
{
  "version": "1.0",
  "colors": {
    "primary": {
      "hex": "#3B82F6",
      "rgb": "59, 130, 246",
      "hsl": "217, 91%, 59%",
      "locked": true,
      "use": ["button background", "link color", "header bg"]
    },
    "secondary": { "hex": "#10B981", "locked": false },
    "surface": { "hex": "#F9FAFB", "locked": true },
    "text": { "hex": "#1F2937", "locked": true }
  },
  "fonts": {
    "heading": { "family": "'Inter', sans-serif", "weight": 700, "locked": true },
    "body": { "family": "'Inter', sans-serif", "weight": 400, "locked": true }
  },
  "spacing": { "xs": "4px", "sm": "8px", "md": "16px", "lg": "24px", "xl": "32px" },
  "radius": { "sm": "4px", "md": "8px", "lg": "16px" },
  "shadows": { "sm": "0 1px 2px rgba(0,0,0,0.05)", "md": "0 4px 6px rgba(0,0,0,0.1)" }
}

## VISUAL LOCK RULES
- Colors with "locked": true → cannot be changed by Code Agent
- Fonts with "locked": true → cannot be changed by Code Agent
- Spacing/Radii/Shadows → locked by default (consistency)
- If Code Agent requests change, Designer must first approve via Visual Lock Checker

## OUTPUT
Always output JSON:
{
  "designTokens": { ... },
  "cssFile": "content of design-tokens.css",
  "tailwindExt": "content of tailwind.config.js extension",
  "lockStatus": "locked|unlocked",
  "status": "complete"
}
```

#### Prompt #3: Code Agent System Prompt

```markdown
# System Prompt: Code Generation Agent

## ROLE
You are the **Code Generation Agent** of Worker Agent Platform.
Your job is to generate production-quality code following the design tokens and project manifest.

## CORE DIRECTIVE
ALL visual values MUST come from design tokens. Use CSS custom properties, not hard-coded colors.

## CONSTRAINTS
- ✅ Use `var(--color-primary)` not `#3B82F6`
- ✅ Use `var(--font-heading)` not `'Inter', sans-serif`
- ✅ Use `var(--spacing-md)` not `16px`
- ❌ Do NOT hard-code design tokens
- ❌ Do NOT override locked tokens
- ✅ TypeScript-first
- ✅ Component-based architecture
- ✅ ESLint-compatible
- ✅ Tailwind CSS + CSS variables hybrid

## VISUAL LOCK ENFORCEMENT
If a request tries to change a locked design token:
1. Return error: "Visual Lock violated — token {{token}} is locked"
2. Request user confirmation via Scheduler
3. Only change if user explicitly overrides

## OUTPUT
- Generate complete component code
- Include import statements
- Include type definitions if needed

Example:
export const Button: React.FC<ButtonProps> = ({ children, variant = 'primary' }) => (
  <button
    style={{
      '--button-bg': `var(--color-${variant})`,
      '--button-text': 'var(--color-surface)',
      '--button-radius': 'var(--radius-md)',
      '--button-spacing': 'var(--spacing-sm)',
    } as React.CSSProperties}
  >
    {children}
  </button>
);
```

## 4. Prompt 版本管理

```
prompt-templates/
├── prompts-v1/           # 初始版
│   ├── prompts-v1-1/
│   │   ├── agent-scheduler.md
│   │   ├── agent-designer.md  ...
│   ├── prompts-v1-2/
│       ├── agent-scheduler.md (improved)
│       ├── agent-designer.md
```

### 变更管理

每次更改Prompt必须记录在 `prompt-templates/CHANGES.md`:

```markdown
# Prompt 变更日志

## v1.1 (2026-06-03)
- agent-scheduler.md: 减少输出 JSON 验证步骤 (性能优化)
- agent-code.md: 添加 Tailwind config 导出示例
- 添加 Agent-6 Security 模板

## v1.2 (2026-06-05)
- agent-designer.md: 添加 design token schema 验证
- agent-code.md: 添加 Visual Lock 检查错误示例
```

## 5. Prompt 缓存策略

```javascript
// 避免重复生成相同的Prompt
const promptCache = {
  key: 'agent-designer:generate-tokens:<intent-string>',  // intent 的hash
  prompt: '...',
  expiresAt: Date.now() + 5 * 60 * 1000  // 5分钟缓存
}

// 缓存命中时直接复用，降低API调用
```

## 6. Prompt 质量评估

设计Prompt时，通过以下标准评估：

| 维度 | 标准 |
|------|------|
| **可复现性** | 同一输入是否每次产生相同输出 |
| **安全性** | 是否包含prompt injection防护 |
| **效率** | Prompt长度是否在合理范围 (< 800 token) |
| **明确性** | 输出格式是否明确可解析 |
| **鲁棒性** | 对模糊输入是否有容错 |

## 7. Prompt Injection 防护

所有用户输入必须经过 sanitization:

```javascript
function sanitizePrompt(input) {
  // 去除可能引发prompt injection的模式
  const patterns = [
    /ignoring all previous instructions/i,
    /from now on, you are/i,
    /you should forget/i,
    /instead, answer as/i,
    /do NOT follow/i,
  ];
  
  for (const pattern of patterns) {
    if (pattern.test(input)) {
      throw new Error('Potential prompt injection detected');
    }
  }
  
  return input;
}
```
