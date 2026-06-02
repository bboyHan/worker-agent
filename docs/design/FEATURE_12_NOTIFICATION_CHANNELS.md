# Feature 12 — 通知渠道管理设计

> 日期: 2026-06-02
> 优先级: 中
> 状态: 完整设计完成

## 1. 模块定位

统一管理所有通知渠道，将告警、系统消息统一推送到用户指定的渠道。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 渠道管理 | 添加/启用/禁用/测试各通知渠道 |
| 已支持渠道 | Telegram/Slack/钉钉/Webhook/邮件/terminal |
| 消息路由 | 按规则将不同消息路由到不同渠道 |
| 消息模板 | 各渠道消息格式模板定制 |
| 消息队列 | 消息积压缓冲、重试（JSON文件队列） |
| 通知历史 | 查看已发送的消息记录 |

### 2.2 排除的功能

- 不涉及短信/电话通知（预留）
- 不涉及微信服务号/小程序推送（与小程序预留保持一致）

## 3. 数据模型

数据存储在 `data/notification/` 目录：

### 3.1 渠道配置

```json
{
  "telegram": {
    "enabled": true,
    "bot_token": "123456:ABC...",
    "chat_id": "-1001234567890",
    "test_status": "success"
  },
  "email": {
    "enabled": false,
    "host": "smtp.example.com",
    "port": 587,
    "user": "alert@example.com",
    "test_status": "skipped"
  }
}
```

### 3.2 消息路由规则

```json
{
  "rules": [
    {
      "id": "route_001",
      "name": "高优先级 → 所有渠道",
      "match": {"level": ["critical", "error"]},
      "send_to": ["telegram", "email"],
      "template": "telegram_default"
    },
    {
      "id": "route_002",
      "name": "信息级 → terminal",
      "match": {"level": ["info"]},
      "send_to": ["terminal"],
      "template": "terminal_default"
    }
  ]
}
```

### 3.3 消息队列

```json
{
  "queue": [
    {
      "id": "msg_001",
      "priority": "high",
      "message": {"text": "CPU 过高", "level": "error"},
      "channels": ["telegram", "terminal"],
      "status": "pending",
      "created": "2026-06-02T13:00:00",
      "retries": 0
    }
  ]
}
```

## 4. Terminal UI 设计

```
┌── 通知渠道 ──────────────────────────────────────┐
│  [配置] [路由规则] [消息历史] [模板]              │
│                                                   │
│  ┌── 渠道列表 ────── ──────── ──────── ───┐
│  │ [✓] 📨 Telegram    已连   │
│  │ [✓] 💬 Slack       测试中 │
│  │ [✗] 📧 Email       已禁用 │
│  │ [✗] 🔔 钉钉        未配置 │
│  │ [✓] 📡 Webhook     已连   │
│  │ [✓] 📺 Terminal    内置  │
│  └─ ── ── ── ── ── ── ── ── ── ── ── ──┘         │
│                                                   │
│  ┌── 路由规则 ── ── ── ── ── ── ── ── ── ── ┐
│  │ [ON] 高优先级 → Telegram + Email           │
│  │ [ON] 信息级 → Terminal                      │
│  │ [OFF] 警告 → DingTalk                       │
│  └─────────────────────────────────────────────┘         │
│                                                   │
│  [添加渠道] [测试连通] [保存配置]                   │
└───┴───┴─ ── ── ── ── ── ── ── ── ── ── ── ── ── ┘
```

## 5. 实现方案

- 各渠道通过插件化接口实现（ChannelPlugin）
- Telegram/Slack 使用对应 SDK（node-telegram-bot-api / @slack/web-api）
- Email 内置 nodemailer
- Webhook 支持自定义 URL + 签名
- 消息队列使用 JSON 文件 + 文件锁（better-sqlite3 已被排除，使用 fs + 文件锁）
- 重试机制：指数退避，最多 3 次，间隔 1分钟/5分钟/30分钟
