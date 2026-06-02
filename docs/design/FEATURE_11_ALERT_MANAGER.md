# Feature 11 — 告警规则设计

> 日期: 2026-06-02
> 优先级: 中
> 状态: 完整设计完成

## 1. 模块定位

定义基于条件触发的告警规则，将告警发送到指定渠道（terminal/IM/邮箱/钉钉等）。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 规则创建 | 可视化创建/编辑告警规则 |
| 条件类型 | 阈值/模式匹配/频率/定时 |
| 通知渠道 | terminal弹窗/邮箱/Slack/钉钉/Telegram/Webhook |
| 告警历史 | 记录所有触发过的告警事件 |
| 告警抑制 | 防抖、频率限制、静默期 |
| 测试模拟 | 模拟条件触发测试告警是否正常 |

### 2.2 排除的功能

- 不涉及复杂告警路由（如PagerDuty级别的路由）
- 不提供 Prometheus/Grafana 集成（仅规则引擎）

## 3. 数据模型

数据存储在 `data/alert-manager/` 目录：

### 3.1 告警规则

```json
{
  "id": "alert_001",
  "name": "CPU 过高",
  "enabled": true,
  "condition": {
    "type": "threshold",
    "metric": "system.cpu",
    "operator": ">",
    "value": 90,
    "duration": "5m"
  },
  "notification": {
    "channels": ["terminal", "telegram"],
    "frequency": "15m",
    "cooldown": "1h"
  },
  "action": {
    "type": "shell",
    "command": "echo 'High CPU detected' | wall"
  },
  "created_at": "2026-06-02T12:00:00"
}
```

### 3.2 告警历史

```json
[
  {
    "id": "event_001",
    "rule_id": "alert_001",
    "triggered_at": "2026-06-02T13:00:00",
    "value": 95.2,
    "resolved_at": "2026-06-02T13:05:00",
    "notified_channels": ["terminal", "telegram"]
  }
]
```

## 4. Termimal UI 设计

```
┌── 告警规则 ──────────────────────────────────────┐
│  [所有规则(5)] [触发(2)] [静默(3)]                │
│                                                    │
│  ┌─ 规则列表 ───────────────────────────┐
│  │ [ON]  CPU > 90% (5min)    [🔴13:00] │
│  │ [ON]  内存 > 85%           [🟡09:30] │
│  │ [OFF] 磁盘 < 10GB           [🟢]     │
│  │ [ON]  日志 error 模式     [🔴12:15] │
│  │ [ON]  容器重启 > 3次/小时  [🟢]     │
│  └──────────────────── ──────────────────┘        │
│                                                    │
│  ┌── 最近触发 ──────── ──────────────────┐
│  │ CPU > 90% — 13:00 — 值: 95.2%       │
│  │ → terminal (13:00:01)                 │
│  │ → telegram  (13:00:15)                │
│  │ 已解决 (13:05:00)                    │
│  └────────────────────────── ─────────────┘        │
│                                                    │
│  [测试触发] [编辑] [新建]                          │
└┴───  ┘───┴─────┴────────┴─────┴─────┘ ┴────┘
```

## 5. 实现方案

- 条件检测：通过 node-cron 定时执行检测
- 告警去重：在 `data/alert-manager/dedup.json` 中使用滑动窗口
- 通知渠道：各渠道通过插件接口统一处理（terminal/HTTP webhook/email）
- 告警历史：`data/alert-manager/history.json`
