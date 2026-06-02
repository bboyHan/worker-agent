# Feature 16 — 用户管理设计

> 日期: 2026-06-02
> 优先级: 中(可跳过)
> 状态: 完整设计完成

## 1. 模块定位

管理本地用户的账号权限、角色、API密钥和会话。对于单用户场景可跳过，多用户场景提供基础RBAC。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 用户管理 | create/read/update/delete 用户账号 |
| 角色管理 | 预定义角色(Admin/User/Viewer) + 自定义 |
| 权限管理 | 模块级/操作级权限控制 |
| API密钥管理 | 为用户生成/撤销API密钥 |
| 会话管理 | 查看/管理活跃会话 |
| 审计日志 | 用户操作记录 |

### 2.2 排除的功能

- 不涉及OAuth2/OIDC联邦身份（预留）
- 不涉及LDAP/AD集成（预留）

## 3. 数据模型

数据存储在 `data/users/` 目录：

```json
{
  "users": [
    {
      "id": "user_001",
      "username": "developer",
      "email": "dev@example.com",
      "role": "admin",
      "enabled": true,
      "created_at": "2026-06-02T12:00:00",
      "last_login": "2026-06-02T14:00:00"
    }
  ],
  "roles": [
    {
      "name": "admin",
      "permissions": ["*"]
    },
    {
      "name": "user",
      "permissions": [
        "todo.read", "todo.write",
        "terminal.exec",
        "git.read",
        "config.view",
        "api-debugger.*"
      ]
    },
    {
      "name": "viewer",
      "permissions": [
        "todo.read",
        "api-debugger.read",
        "logs.view",
        "container.view"
      ]
    }
  ],
  "api_keys": [
    {
      "id": "key_001",
      "user_id": "user_001",
      "name": "mobile",
      "key_hash": "sha256:abc123...",
      "created": "2026-06-02T12:00:00",
      "last_used": "2026-06-02T13:00:00",
      "expires": "2026-07-02T12:00:00"
    }
  ],
  "audit_log": [
    {
      "id": "audit_001",
      "user_id": "user_001",
      "action": "terminal.exec",
      "resource": "docker ps",
      "timestamp": "2026-06-02T14:00:00",
      "ip": "127.0.0.1"
    }
  ]
}
```

## 4. Terminal UI 设计

```
┌── 用户管理 ──────────────────────────────────────┐
│  [用户] [角色] [API密钥] [会话] [审计日志]         │
│                                                │
│  ┌── 用户列表 ───  ── ── ── ── ── ── ── ── ┐
│  │ 👤 developer    admin    🟢 active   │
│  │ 👤 editor       user     🟢 active   │
│  │ 👤 viewer        viewer   🟢 active   │
│  └─ ── ── ── ── ┐── ── ── ── ── ── ── ┐         │
│                                                │
│  ┌── API密钥 ─── ── ── ── ── ── ── ── ── ┐
│  │ [****xyz]  mobile   活跃    7天      │
│  │ [****abc]  desktop  活跃    30天      │
│  └─ ── ── ── ── ── ── ── ── ┐── ── ┐         │
│                                                  │
│  [添加用户] [生成密钥] [审计日志]                 │
└─ ┐── ┐──   ┘──  ┘──  ┘  ┘──  ┘──  ┘─