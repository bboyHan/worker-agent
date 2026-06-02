# DesignFlow CLI v1.0 — Complete Interactive Design

## 终端界面

- `designflow start`: 启动项目
- `designflow stop`: 停止项目
- `designflow agents`: 查看 Agent 状态
- `designflow plan`: 查看计划
- `designflow status`: 查看状态
- `designflow diff save`: 暂存代码差异
- `designflow diff discard`: 放弃代码差异
- `designflow deploy`: 自动化部署
- `designflow deploy docker`: Docker 部署
- `designflow deploy vercel`: Vercel 部署

## Agent 管理命令

- `agent start [name]`: 启动 Agent
- `agent stop [name]`: 停止 Agent
- `agent restart [name]`: 重启 Agent
- `agent status [name]`: 查看状态
- `agent logs [name]`: 查看日志

## 可视化设计命令

- `design save`: 保存设计系统
- `design export`: 导出设计系统
- `design import`: 导入设计系统
- `design show`: 查看当前设计系统
- `design tokens`: 查看所有设计令牌
- `design lock`: 锁定设计

## 部署管理命令

- `deploy docker`: Docker 部署
- `deploy vercel`: Vercel 部署
- `deploy netlify`: Netlify 部署
- `deploy preview`: 预览部署

## 工作流管理命令

- `workflow start`: 启动工作流
- `workflow stop`: 停止工作流
- `workflow status`: 查看工作流状态
- `workflow history`: 查看工作流历史

---

## Architecture Diagram

```
                    ┌─────────┐
                    │  User   │
                    │Terminal │
                    └─┬───┬──┘
                      │   │
                    ┌──┴───┴──┐
                    │  CLI    │
                    │  Layer  │
                    └───┬───┬─┘
                        │   │
                    ┌───┴───┴───┐
                    │  Agent    │
                    │Orchestration│
                    │───┬───┬───┬─┐
                    │   │   │   │   │
                    │  Scheduler  │   │
                    │    │        │   │
                    │  ┌───┴────┴──┐ │
                    │  │          │   │
                    │  │  Agent   │  │
                    │  │ System  │  │
                    │  └───┬───┬─┘  │
                    │     │     │    │
                    │    ┌┴┐  ┌┴┐ ┌┴┐│
                    │    │D│  │C│ │T││
                    │    └┬┘  └┬┘ └┬┘│
                    │  ┌──┴── ┴── ┴──┐
                    │  │    Agent    │
                    │  │   Layer     │
                    │  │  ┌─┬─┬─┐   │
                    │  │  │ │ │ │   │
                    │  │  └─┴─┴─┘   │
                    │  └──────┬─────┘
                    │         │
                    │  ┌─────┴──┐
                    │  │  Deploy │
                    │  │ Service │
                    │  └────────┘
                    └─────┬───┬──────┘
                        │   │
                    ┌───┴───┴───┐
                    │   Docker   │
                    │   Runtime  │
                    └─────────────┘
```

## Agent Communication

| Source | Target | Method | Frequency |
|--------|--------|--------|---------||
| Scheduler | All agents | MCP dispatch | On-demand |
| Scheduler | Agent | WebSocket push | Every 2s |
| Agent | Scheduler | WebSocket push | Every 2s |
| Agent | Agent | WebSocket push | On event |
| Agent | Scheduler | WebSocket push | Error alert |

## Status Dashboard

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  Agent   │  Status  │ Progress │  Tasks   │ Alerts   │
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ Scheduler│  Ready   │ 100%     │ 4/4 done │    0     │
│  Designer│  Busy    │ 64%      │ 47/72    │    0     │
│   Code   │  Busy    │ 70%      │ 25/36    │    0     │
│   Test   │  Idle    │ 0%       │ 0/0      │    0     │
│  Deploy  │ Idle     │ 0%       │ 0/0      │    0     │
└────────────┴──────────┴──────────┴──────────┴──────────┘
```

## Visual Lock System

```
┌──────────────────────────────────────┐
│ Visual Lock System                   │
│ - Design tokens are LOCKED           │
│ - Cannot override locked tokens      │
│ - Must update via design system      │
│ - Cannot override locked designs     │
│ - Visual lock is enforced            │
└──────────────────────────────────────┘
```

## Three-Tier Confirmation

- **Tier 1: Intent** — Understand user intent
- **Tier 2: Plan** — Show execution plan
- **Tier 3: Execute** — Execute with confirmation

## Deployment Flow

### Docker Deploy

- Generate Dockerfile
- Generate docker-compose.yml  
- Build images
- Start services
- Open preview

### Vercel Deploy

- Generate vercel.json
- Build frontend
- Start backend
- Deploy to Vercel
- Open preview

### Netlify Deploy

- Generate netlify.toml
- Build frontend
- Deploy to Netlify
- Open preview

## User Iteration Flow

```
> / Make the buttons green
```

## Error Handling

```
── 400: UI validation
── 403: Permission denied  
── 500: Runtime error
── 502: Network error
── 504: Timeout
── 507: Insufficient storage
```

### Summary

```
DesignFlow CLI v1.0
── Design → Code → Preview → Deploy
── One command: designflow start
── All local, free, open-source
── 100% privacy, no cloud calls
── Visual lock to maintain design integrity
── Multi-agent system for robust execution
── Deploy with confidence
── Iterate effortlessly
── Built for developers, by developers
```

---

*— End of Interactive Design Document —*
