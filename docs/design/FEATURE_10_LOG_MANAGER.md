# Feature 10 — 日志管理器设计

> 日期: 2026-06-02
> 优先级: 中
> 状态: 完整设计完成

## 1. 模块定位

集中管理多源日志（文件、容器、系统），提供实时过滤和高亮能力。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 日志源管理 | 添加/删除/编辑日志源（文件路径、docker容器、syslog） |
| 实时流 | tail -f 实时显示新日志行 |
| 关键词过滤 | 正则/全文关键字过滤（高亮匹配行） |
| 级别标注 | ERROR/WARN/INFO/DEBUG 颜色区分 |
| 时间范围 | 按时间范围检索历史日志 |
| 聚合搜索 | 跨多个日志源同时搜索 |
| 导出 | 过滤后的日志导出为文件 |
| 告警关联 | 匹配规则触发告警通知 |

### 2.2 排除的功能

- 不涉及 ELK/Grafana 等重型日志平台
- 不处理二进制日志格式

## 3. 数据模型

数据存储在 `data/log-manager/` 目录：

```json
{
  "sources": [
    {
      "id": "src_001",
      "name": "api-server",
      "type": "file",
      "path": "/var/log/app/api.log",
      "enabled": true
    },
    {
      "id": "src_002",
      "name": "my-api container",
      "type": "docker",
      "containerId": "abc123",
      "enabled": true
    }
  ],
  "filters": [
    {
      "id": "flt_001",
      "name": "ERROR only",
      "pattern": "\\[ERROR\\]",
      "highlight": "red",
      "enabled": true
    }
  ],
  "saved_searches": [
    {
      "id": "ss_001",
      "name": "Recent errors",
      "pattern": "error|fail|exception",
      "sources": ["src_001", "src_002"],
      "savedAt": "2026-06-02T14:00:00"
    }
  ]
}
```

## 4. Terminal UI 设计

```
┌── 日志管理 ──────────────────────────────────────┐
│  源: [api-server(247)] [my-api(12)] [所有(259)]    │
│                                                      │
│  ┌─ 过滤 ─────────────────────────────┐
│  │ Regex: \[ERROR\]|Warning       [✏️]│
│  │ 匹配颜色: 🔴 red                  │
│  │ [启用]                         │
│  └────────────────────────────────────┘       │
│  ── 日志流 ──── 15 条/分钟 ──             │
│  12:30:01 [INFO] Server started on :3000  0 │
│  12:30:02 [INFO] Connected to db           │
│  12:30:15 [ERROR] Failed to connect API ❌  │
│  12:30:18 [WARN] Retrying connection...  🟡   │
│  12:30:20 [INFO] Connection restored      │
│  > _                                       │
│  ──── [实时] [聚合] [历史] [告警] ────────────┘
└───┴────┴────┴────┴───────┴───────┴─────┘
```

## 5. 实现方案

- 使用 `tail -f` 或 readline 实现实时日志流
- 正则过滤通过后缀树算法（Aho-Corasick）实现
- 日志来源通过 FIFO 或 socket 注入
- 存储使用 JSON 文件（data/log-manager/logs.json）
