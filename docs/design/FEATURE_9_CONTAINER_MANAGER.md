# Feature 9 — 容器管理器设计

> 日期: 2026-06-02
> 优先级: 中
> 状态: 完整设计完成

## 1. 模块定位

在终端内管理 Docker 容器的生命周期，无需切换到 docker CLI 命令。

**注意**: 本模块依赖 Docker CLI 已安装在目标系统上（这是前提条件，不是功能）。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 容器列表 | ps -a 可视化展示 |
| 容器管理 | start/stop/restart/rm/kill |
| 镜像管理 | images/pull/rm |
| 网络管理 | network ls/connect/disconnect |
| 卷管理 | volume ls/inspect/prune |
| 日志查看 | docker logs -f |
| 执行命令 | docker exec -it |
| compose 支持 | up/down/ps/logs |

### 2.2 排除的功能

- 不提供 Docker 安装引导（假设 Docker 已安装）
- 不提供 K8s/其他编排工具支持（预留）

## 3. 数据模型

数据存储在 `data/container-manager/` 目录：

```json
{
  "containers": [
    {
      "id": "abc123",
      "name": "my-api",
      "image": "node:18-alpine",
      "status": "running",
      "ports": [{"container": 3000, "host": 3000}],
      "volumes": ["/data:/app/data"],
      "network": "webnet",
      "lastCommand": "docker logs -f abc123",
      "favorite": true,
      "tags": ["production", "api"]
    }
  ],
  "favorites": ["abc123"],
  "tags": {"production": ["abc123", "def456"], "api": ["abc123"]}
}
```

## 4. Terminal UI 设计

```
┌── 容器管理 ──────────────────────────────────────┐
│  [运行中] (3)  [已停止] (1)  [所有] (4)          │
│                                                      │
│  ┌────┬──────┬───────┬──────┬──────┬────┐         │
│  │名   │镜像   │状态   │端口   │卷    │操作│         │
│  ├────┼──────┼───────┼──────┼──────┼────┤         │
│  │▶my-api   │node:18│running│3000  │/data│▶️│         │
│  │▶web    │nginx  │running│8080  │/logs│▶️│         │
│  │▶db     │postgres│running│5432  │/db  │▶️│         │
│  │⏸redis   │redis  │exited │6379  │-    │▶️│         │
│  └────┴──────┴───────┴──────┴──────┴────┘         │
│                                                      │
│  ┌── 日志 (my-api) ───────────────────┐
│  [INFO] Server listening on :3000     │
│  [INFO] Connected to postgres         │
│  [WARN] Slow query detected: 2.3s     │
│  > _                                    │
└───┴──────┴───────┴──────┴──────┴────┘
```

## 5. 实现方案

- 通过 child_process exec 调用 docker CLI
- 输出解析后渲染为 terminal 表格
- 容器状态每 5 秒刷新一次
- 日志查看支持流式输出（tail/follow mode）

  