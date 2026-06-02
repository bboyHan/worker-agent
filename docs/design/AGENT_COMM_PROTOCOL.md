
# Agent 间通信协议设计

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 架构总览

```
                ┌────────────────┐
                │  Scheduler Agent│
                │  (Orchestrator) │
                └──┬───┬──┬──┬──┘
                   │   │   │   │
                MCP  WS  WS  WS
                   │   │   │   │
                   ▼   ▼   ▼   ▼
              ┌──┐ ┌─┐ ┌─┐ ┌──┐
              │D │ │C│ │T│ │V│  ← Agent Layer
              └──┘ └─┘ └─┘ └──┘
              
通信协议:
- Scheduler ↔ Agent: WebSocket (status updates) + MCP (task dispatch)
- Agent ↔ Agent (optional): 共享文件系统 (project.json 为事实源)
- Agent ↔ Worker Agent (UI): 事件流 (EventStream)
```

### 1.1 为什么用 WebSocket + 文件共享，不用消息队列?

| 方案 | 优点 | 缺点 | 结论 |
|------|------|------|------|
| WebSocket + 文件 | 零依赖/单用户无需MQ | 无法水平扩展 | ✅ 符合纯文件理念 |
| Redis Pub/Sub | 成熟/可靠 | Redis 依赖，增加复杂度 | ❌ 不符合纯文件 |
| 共享内存 | 最快 | 单进程，不支持并发Agent | ❌ 不适用 |
| MCP + FS | MCP已选型 | MCP主要用于外部工具调用 | ✅ 作为task dispatch |

### 1.2 最终选型

- **Task dispatch (Scheduler → Agent):** MCP protocol (调用外部工具/执行特定任务)
- **Status updates (Agent → Scheduler):** WebSocket (实时推送)
- **Data sharing (Agent ↔ Agent):** Shared file system (通过 `project.json`).

## 2. WebSocket 消息格式

### 2.1 消息结构

```json
{
  "id": "msg_001",
  "timestamp": "2026-06-02T12:00:00Z",
  "type": "status_update",
  "from": "designer",
  "to": "scheduler",
  "payload": {
    "phase": "design",
    "status": "in_progress",
    "progress": {
      "task": "Generate color tokens",
      "currentTask": 2,
      "totalTasks": 5,
      "taskProgress": {
        "colors": 72,
        "typography": 0,
        "spacing": 0,
        "borders": 0,
        "shadows": 0
      }
    },
    "alerts": [],
    "artifacts": [
      {
        "type": "design_tokens",
        "path": "/tmp/project/design_tokens.json",
        "status": "draft"
      }
    ]
  }
}
```

### 2.2 消息类型枚举

```typescript
type MessageType =
  | 'status_update'      // Agent 状态更新 (每2秒)
  | 'task_dispatch'      // Scheduler → Agent 分发任务
  | 'artifact_ready'     // Agent 产物就绪通知
  | 'error_alert'        // Agent 错误预警
  | 'confirm_request'    // Agent → 用户确认请求
  | 'user_response'      // 用户 ← Agent 确认回复
  | 'heartbeat'          // Agent 心跳 (每10秒)
  | 'phase_complete'     // 阶段完成通知
  | 'phase_change'       // 阶段切换通知
  | 'deployment_ready';  // 部署完成通知
```

### 2.3 消息处理流程

```
[S0] Scheduler 发送 task_dispatch
     → Designer Agent 收到
     → Designer Agent 开始执行
     → Designer Agent 发送 status_update (每2秒)
     → Designer Agent 发送 artifact_ready
     → Designer Agent 发送 phase_complete
     
[S1] Scheduler 收到 phase_complete
     → 更新 project.json 状态
     → 发送 task_dispatch 给 Code Agent
     
[S2] Code Agent 收到 task_dispatch
     → 读取 project.json 中的 design_tokens
     → Code Agent 开始生成代码
     → ... 同上
```

## 3. MCP (Model Context Protocol) Task Dispatch

### 3.1 MCP 工具注册表

每个 Agent 向 MCP 注册自己的工具：

**Designer Agent 注册:**
```
designer.generate_tokens   — 生成设计令牌
designer.lock_token        — 锁定设计令牌
designer.export_design     — 导出设计系统
designer.visual_check      — 视觉一致性检查
```

**Code Agent 注册:**
```
code.generate_file         — 生成/修改文件
code.review_code           — 代码审查
code.run_lint              — ESLint/TSC 检查
code.run_tests             — 运行测试
code.exec_cmd              — 执行 shell 命令
```

**Deploy Agent 注册:**
```
deploy.docker_build        — Docker 构建
deploy.docker_deploy       — Docker 部署
deploy.vercel_deploy       — Vercel 部署
deploy.health_check        — 健康检查
```

### 3.2 MCP Dispatch 格式

Scheduler 通过 MCP 分发任务：

```javascript
dispatch(agentId, toolName, params) → Promise<result>

// Example: Scheduler → Designer Agent
const result = await scheduler.dispatch('designer', 'generate_tokens', {
  intent: { primaryColor: 'blue', font: 'Inter' },
  constraints: ['accessibility: AA'],
  outputDir: '/tmp/project/styled/'
});
// result = {
//   tokens: {...},
//   cssFile: '/tmp/project/styles/design-tokens.css',
//   status: 'success'
// }
```

## 4. Agent 通信矩阵

| Source | Target | Protocol | Frequency | 用途 |
|--------|--------|----------|-----------|------|
| Scheduler | All Agents | MCP dispatch | 事件驱动 | 分发任务 |
| Agent A | Scheduler | WebSocket | 每2秒推 | 状态更新 |
| Agent B | Scheduler | WebSocket | 事件驱动 | 完成/错误 |
| Agent A | Agent B | FS (project.json) | 写产物文件 | 数据传递 |
| Scheduler | UI (Worker Agent) | EventStream | 实时 | 状态刷新 |
| Agent A | User UI | WebSocket | 事件驱动 | 确认请求 |

## 5. WebSocket 连接管理

### 5.1 连接模型

```
Worker Agent (主进程)
   │
   ├── ws://localhost:8787/agents/designer
   ├── ws://localhost:8787/agents/code
   ├── ws://localhost:8787/agents/test
   └── ws://localhost:8787/agents/deploy
```

### 5.2 心跳机制

```javascript
// Agent 发送心跳 (每10秒)
{
  "id": "hb_001",
  "type": "heartbeat",
  "from": "designer",
  "timestamp": "2026-06-02T12:00:10Z",
  "state": {
    "cpu": 15,
    "memory": 42,
    "uptime": 120
  }
}

// Scheduler 判定 Agent 失联
if (lastHeartbeat + 30s < now) {
  // Agent 已失活
  // 自动重启 Agent
  restartAgent(agentId);
}
```

## 6. 错误重试与容错

### 6.1 重试策略

| 错误类型 | 重试次数 | 退避间隔 | 说明 |
|----------|----------|----------|------|
| Network error | 3 | 1s/5s/30s | 网络不稳定 |
| Parse error | 1 | - | 数据格式问题，不可重试 |
| Tool timeout | 2 | 2s/10s | 工具执行超时 |
| Resource limit | 1 | - | 磁盘满等，必须人工介入 |
| Validation error | 5 | 1s | 自动修复尝试 |

### 6.2 任务超时

```javascript
const DEFAULT_TIMEOUTS = {
  design_phase: '15m',    // 设计阶段最长15分钟
  code_phase: '30m',      // 代码阶段最长30分钟  
  test_phase: '5m',       // 测试/验证阶段5分钟
  deploy_phase: '10m',    // 部署阶段10分钟
  single_tool_call: '2m', // 单个工具调用2分钟超时
};
```
