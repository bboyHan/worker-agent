

# 三层确认交互设计

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 设计目标

产品核心理念之一：**"一条命令从idea到产品"**。但AI生成可能出错，所以需要**三层确认机制**确保每一步的正确性。

三层确认 = **Intent确认 → Plan确认 → Execute确认**

### 1.1 用户交互理念

- **最小化输入，最大化控制**: 用户只需说出想要的东西，然后确认/拒绝每一步
- **渐进式披露**: 每一步只显示当前的关键信息，不过度打扰
- **非阻塞确认**: 用户说"全部批准"后，后续所有步骤自动通过
- **可视化反馈**: 每一步的状态变化都实时可见

## 2. 三层确认流程设计

### 2.1 整体流程

```
┌───────────意图接收──────────────┐
│  用户输入: "做一个Todo App用React"         │
│                                        │
│  [Intent确认]                           │
│  ┌────── Intent ────────────────────┐ │
│  │ 分析意图: 创建一个Todo Web应用      │ │
│  │ 技术栈: React + TypeScript        │ │
│  │ 阶段: Scaffold → Design → Code →  │ │
│  │       Test → Deploy               │ │
│  │                                  │ │
│  │  [确认] [修改] [取消]             │ │
│  └──────────────────────────────────┘ │
│                                        │
│  用户说: "确认"                         │
│  [Plan确认]                            │
│  ┌────── Plan ──────────────────────┐ │
│  │ Step 1: Scaffold (5 min)          │ │
│  │   - 创建React项目结构              │ │
│  │   - 安装依赖 (React/TypeScript)   │ │
│  │                                  │ │
│  │ Step 2: Design (10 min)           │ │
│  │   - 生成设计令牌                   │ │
│  │   - 生成全局样式                   │ │
│  │   - 生成组件库规范                 │ │
│  │                                  │ │
│  │ Step 3: Code (15 min)             │ │
│  │   - 生成代码 (20个组件)            │ │
│  │   - 代码审查                       │ │
│  │   - Visual Lock检查                │ │
│  │                                  │ │
│  │ Step 4: Test (5 min)              │ │
│  │   - 生成测试用例                   │ │
│  │   - 运行测试                       │ │
│  │                                  │ │
│  │ Step 5: Deploy (5 min)            │ │
│  │   - Docker容器化                   │ │
│  │   - 部署到本地                     │ │
│  │                                  │ │
│  │ ⏱️ 预计总耗时: 40 分钟             │ │
│  │ [批准全部] [修改] [取消]            │ │
│  └──────────────────────────────────┘ │
│                                        │
│  用户说: "批准全部"                      │
│  [逐步骤执行 + 自动确认剩余]             │
│                                        │
│  ⏳ Scaffold 进行中...           [▶]    │
│  ◼ Design 等待中                        │
│  ◻ Code 等待中                          │
│  ◻ Test 等待中                          │
│  ◻ Deploy 等待中                        │
│                                        │
│  ✅ 全部完成!                           │
│  [预览] [修改] [导出]                  │
└────────────────────────────────────────┘
```

### 2.2 确认的3个层次

```
Layer 1 ── intent 确认 ── ── ── ── ─ ─ ─ ─ ─ → 用户理解AI是否正确理解需求
   │
Layer 2 ── plan 确认 ── ── ─ ─ ─ ─ ─ ─ → 用户理解AI的计划是否合理
   │
Layer 3 ── execute 确认 ── ── ── ─ ─ → 用户理解每一步执行结果
```

## 3. 交互模式

### 3.1 UI 组件 (终端内)

```typescript
// Intent确认UI
interface IntentConfirm {
  type: 'intent';
  intent: ParsedIntent;
  analysis: string;
  options: ['confirm', 'modify', 'cancel'];
  keyboardShortcuts: { confirm: 'y', modify: 'm', cancel: 'n' };
  defaultAction: 'cancel';
}

// Plan确认UI
interface PlanConfirm {
  type: 'plan';
  steps: PlanStep[];
  estimatedTimeMs: number;
  options: ['approve_all', 'modify', 'cancel'];
  keyboardShortcuts: { approve_all: 'a', modify: 'm', cancel: 'n' };
  defaultAction: 'approve_all';
}

// Execution result UI
interface ExecutionResult {
  type: 'execution_result';
  stepName: string;
  status: 'success' | 'failed' | 'warning';
  output: string;
  options: ['continue', 'rollback', 'modify'];
}
```

### 3.2 确认流程状态机

```
┌─── User Input ───▶ Parsing ──▶ IntentReady ──▶ 
   │                    │             │
   │               [Analysis]     [WaitConfirm]
   │                         │        │
   │                   [IntentOK]   │
   │                         │        │
   │                    [PlanReady]  │
   │                         │        │
   │                   [WaitApprove] │
   │                         │        │
   └── [AllApproved] ──▶ Executing ──▶ [StepComplete] ──▶ ... ──▶ [AllDone] ──▶ 
   │                    │
   │               [RejectStep] │
   │                    │        │
   │               [ModifyPlan] │
   └── [Cancel] ──▶  CancelMode ─▶ Exit
```

## 4. 确认UI渲染

### 4.1 Intent确认渲染

```tsx
function renderIntentConfirm({ intent, analysis, options }) {
  return (
    <Box border="line" title="🎯 Intent Confirmation">
      <Text bold color="green">Intent Analysis</Text>
      <Box border="double">
        <Text color="gray">Purpose: {intent.purpose}</Text>
        <Text color="gray">Tech Stack: {intent.techStack.join(', ')}</Text>
        <Text color="gray">Core Features: {intent.features.join(', ')}</Text>
        <Text color="gray">Constraints: {String(intent.constraints)}</Text>
        <Text color="gray">Estimated Steps: {steps.length}</Text>
        <Text color="gray">Est. Time: {formatDuration(estimatedTime)}</Text>
      </Box>
      
      <Box border="line">
        <Text color="yellow">💡 How to respond:
        {'  '}[y/N] Confirm / [m]odify / [c]ancel
        {`  `}Default (5s): cancel
        </Text>
      </Box>
      
      <Spinner text="Waiting for your response..."/>
    </Box>
  );
}
```

### 4.2 Plan确认渲染

```tsx
function renderPlanConfirm({ steps, options }) {
  return (
    <Box border="line" title="📋 Plan Confirmation">
      {steps.map((step, i) => (
        <Box border="single" key={step.id}>
          <Text bold>{i+1}. {step.name} (<{step.durationMin}min>)</Text>
          {step.details.map((detail, j) => (
            <Text color="gray">   - {detail}</Text>
          ))}
          <Text color="blue">   Status: {step.status}</Text>
        </Box>
      ))}
      
      <Box border="line">
        <Text color="yellow">🎯 Total time: {formatDuration(totalTime)}
        {`  `}Reply: [a]pprove all / [m]odify / [c]ancel
        {`  `}(5s timeout → auto-cancel)
        </Text>
      </Box>
    </Box>
  );
}
```

### 4.3 Execution结果渲染

```tsx
function renderExecutionResult(step: PlanStep) {
  const statuses = {
    success: { color:  'green', icon: '✅' },
    failed: { color: 'red', icon: '❌' },
    warning: { color: 'yellow', icon: '⚠️' }
  };
  
  const icon = statuses[step.status];
  
  return (
    <Box border="line">
      <Text color={icon.color} bold>
        {icon.icon} Step {step.order}: {step.name} {icon.color}
      </Text>
      <Box border="double" maxHeight={5}>
        <Preformatted>{step.output}</Preformatted>
      </Box>
      
      {step.status === 'failed' ? (
        <Text  color="yellow">
          
          [e]rror details / [c]ontinue anyway / [r]etry
        </Text>
      ) : (
        <Text color="gray">
          Next step will auto-execute...
        </Text>
      )}
     
    </Box>
  );
}
```

### 4.4 实时状态监控

```
┌─── Progress Monitor ───────────────────────┐
│                                              │
│  [Step 2/5] Design in progress...        [▶] │
│                                              │
│  ◼ Scaffold:  ✅ complete                    │
│  ▶  Design:   ⏳ in progress                 │
│  ◻ Code:      ⏸️ waiting                     │
│  ◻ Test:      ⏸️ waiting                     │
│  ◻ Deploy:    ⏸️ waiting                     │
│                                              │
│  ───────────────────────────────── ───── ── │
│  Estimated time: 10 min remaining            │
│  Speed limit: 1 item per second              │
│                                              │
│  [pause] [step] [cancel]                     │
└──────────────────────────────────────────────┘
```

## 3. 用户交互API

### 3.1 确认请求格式

```typescript
interface ConfirmRequest {
  type: 'intent' | 'plan' | 'execution';
  context: {
    stage: string;         // scaffold, design, code, test, deploy
    details: Record<string, any>;
    alternatives?: string[]; // 备选方案（如果available）
  };
  timeoutSeconds: number;       // 确认超时时间
  defaultOnTimeout: 'approve' | 'reject' | 'ask';  // 超时时默认操作
  keyboardShortcuts: {
    [action: string]: string;   // action → key
  };
}
```

### 3.2 用户响应格式

```typescript
interface ConfirmResponse {
  action: 'confirm' | 'modify' | 'reject' | 'partial' | null;
  modify?: {
    [key: string]: any;     // 修改内容
  };
    reject?: string;      // 拒绝原因
  partial?: {
    approve: string[];    // 批准步骤ID列表
    reject: string[];      // 拒绝步骤ID列表
  };
}
```

## 4. 自动确认机制

### 4.1 `--auto` 模式

用户可以在首次回复时选择"全部批准"，后续所有步骤自动确认：

```
> workeragent "做一个博客系统, React + GraphQL"
🎯 Intent confirmed: Blog system 
📋 Plan:  scaffold→Design→Code→Test→Deploy (45 min total)
> [y/N] y  → 自动批准全部
▶ All steps will auto-approve. Monitor progress.
⏳ Scaffold complete. ▶ Design in progress...
▶ Code complete. ▶ Running tests...
▶ Tests passed. ▶ Deploying...
▶ Deployment complete.
✅ All steps successful
```

### 4.2 安全确认

某些操作永远需要确认(不可自动批准):

| 操作 | 确认类型 | 是否可自动 |
|------|------|--|
| **部署到生产环境**| 用户确认 | ❌ |
| **删除数据**    | 用户确认 | ❌ |
| **修改系统配置**    | 用户确认 | ❌ |
| **安装系统级依赖**    | 用户确认 | ❌ |
| Scaffold 项目 | 自动批准 | ✅ |
| 生成设计令牌 | 自动批准 | ✅ |
| 生成代码 | 自动批准 | ✅ |
| 运行测试 | 自动批准 | ✅ |
| **部署到开发环境**| 用户确认 | ❌ |

### 4.3 超时处理

| 超时时长 | 行为 |
|------|------|
| **3s** | Intent确认 → 自动取消 |
| **5s** | Plan确认 → 自动取消 |
| **10s** | 步骤执行确认 → 自动continue (除非步骤失败) |
| **30s** | 错误提示 → 自动continue |

## 5. 修改流程

```
用户在确认时 say "修改":
  
[当前计划状态]
  Step 1: Scaffold ✅ 完成
  Step 2: Design ⏳ 进行中
  
[用户修改请求]
  "设计用Vue而非React"
  
[系统响应]
  🔄 Re-analyzing intent...
  ✅ Updated plan:
  Step 1: Scaffold ✅ 完成
  ▶ Step 2: Design (Vue) ⏳ [新计划]
  ⏸ Step 3: Code (Vue components)
  ⏸ Step 4: Test (Vue tests)
  ⏸ Step 5: Deploy (Docker)
  
  [批准新计划] [修改] [取消]
```

## 6. 设计原则

1. **最小化打扰**: 只在关键节点显示确认框
2. **自动批准为默认**: 大多数情况下用户希望"全部批准"
3. **清晰可见**: 每一步都要显示当前状态
4. **可逆**: 每一步都可回滚/撤销
5. **非阻塞**: 用户可在后台运行确认
