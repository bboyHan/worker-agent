# Feature 8 — API调试器设计

> 日期: 2026-06-02
> 优先级: 中
> 状态: 完整设计完成

## 1. 模块定位

为开发者提供在终端内直接调试HTTP API的能力，无需打开Postman/cURL等外部工具。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 请求历史 | 保存/浏览所有已发送的请求 |
| 请求编辑 | 可视化构建请求（URL、方法、Headers、Body） |
| 一键发送 | 支持 GET/POST/PUT/PATCH/DELETE/OPTIONS/HEAD |
| 响应展示 | 格式化JSON/XML/HTML，支持语法高亮 |
| 环境变量 | 支持${VAR}模板变量，环境切换 |
| 预设集合 | 请求分组（Collection），一键批量执行 |
| 导出/导入 | 导出请求为文件，支持JSON/Swagger导入 |

### 2.2 排除的功能

- 不支持WebSocket实时调试（预留）
- 不支持OAuth2自动刷新（预留）

## 3. 数据模型

### 3.1 请求记录

```json
{
  "id": "req_001",
  "method": "GET",
  "url": "http://localhost:3000/api/todos",
  "headers": [{"key": "Authorization", "value": "Bearer ${TOKEN}"}],
  "body": null,
  "timestamp": "2026-06-02T12:00:00",
  "status": 200,
  "duration": 45,
  "response_headers": {"content-type": "application/json"},
  "response_body": "[{\"id\":1,\"title\":\"Test\"}]",
  "notes": ""
}
```

### 3.2 环境变量集

```json
{
  "name": "Local",
  "variables": {
    "HOST": "localhost",
    "PORT": "3000",
    "TOKEN": "sk-xxx"
  }
}
```

### 3.3 Collection（请求集合）

```json
{
  "name": "我的API调试",
  "items": [
    {"type": "folder", "name": "TODO端点"},
    {"type": "request", "id": "req_001"},
    {"type": "folder", "name": "用户端点"},
    {"type": "request", "id": "req_024"}
  ]
}
```

## 4. Terminal UI 设计

```
┌── API调试 ──────────────────────────────────────┐
│  [GET▼]  http://localhost:3000/api/todos    [▶]│
│                                                      │
│  Headers (2)                                     │
│  Authorization  Bearer ${TOKEN}          [✏️]│
│  Content-Type   application/json         [✏️]│
│                                                  [+] 添加                               │
│  Body                                                    │
│  {                                                  │
│    "title": "New item",                           │
│    "completed": false                            │
│  }                                                │
│                                                  │
│  ── 响应 (200 OK - 45ms) ────────────┐
│  [{                              }│
│    "id": 1,  "title": "Item 1",  "completed": false    │
│    "id": 2,  "title": "Item 2",  "completed": true    │
│  }]                                        │
│                                                  │
│  [Raw] [Pretty] [History] [Collection]  ─── ─── │
└────────────────────────────────────┘
```

## 5. 实现方案

- 无数据库依赖，请求历史记录在 `data/api-debug/requests.json`
- 环境变量存储在 `data/api-debug/environments.json`
- Collection 存储在 `data/api-debug/collections.json`
- HTTP 请求使用 Node.js 内置 `https`/`http` 模块
- JSON 响应使用 ink-table 格式化显示
