# Feature 15 — 网络管理设计

> 日期: 2026-06-02
> 优先级: 低
> 状态: 完整设计完成

## 1. 模块定位

查看和管理系统的网络状态，包括端口监听、DNS查询、网络连通性测试等。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 端口扫描 | 列出监听端口、连接状态 |
| DNS查询 | DNS记录查询（A/CNAME/MX/TXT/NS） |
| 连通性测试 | ping/traceroute/HTTP检测 |
| 端口转发 | 配置/查看端口转发规则 |
| 网络拓扑 | 查看网络接口/IP/MAC信息 |
| 服务发现 | 局域网内服务发现（UPnP/mDNS） |
| 带宽监控 | 网络接口流量统计（实时/历史） |

### 2.2 排除的功能

- 不涉及防火墙配置（安全模块覆盖）
- 不涉及VPN客户端（与服务器管理解耦）

## 3. 数据模型

数据存储在 `data/network-manager/` 目录：

```json
{
  "ports": [
    {
      "port": 3000,
      "protocol": "tcp",
      "state": "listening",
      "process": "node (my-api)",
      "pid": 1234
    },
    {
      "port": 8080,
      "protocol": "tcp",
      "state": "listening",
      "process": "nginx",
      "pid": 5678
    }
  ],
  "dns_cache": [
    {
      "domain": "api.example.com",
      "records": [{"type": "A", "value": "1.2.3.4"}],
      "queried_at": "2026-06-02T12:00:00",
      "ttl": 300
    }
  ],
  "conntrack": [
    {
      "local": "0.0.0.0:3000",
      "remote": "192.168.1.100:54321",
      "state": "ESTABLISHED"
    }
  ],
  "port_forwards": [
    {
      "name": "api-forward",
      "local_port": 8085,
      "remote_host": "localhost",
      "remote_port": 3000
    }
  ]
}
```

## 4. Terminal UI 设计

```
┌── 网络管理 ──────────────────────────────────────┐
│  [端口] [DNS] [连接] [拓扑] [端口转发] [带宽]    │
│                                                   │
│  ┌── 监听端口 ──────────── ── ── ── ── ── ── ┐
│  │ :3000  tcp  LISTEN  node (my-api)     │
│  │ :8080  tcp  LISTEN  nginx               │
│  │ :5432  tcp  LISTEN  postgres              │
│  │ :6379  tcp  LISTEN  redis                 │
│  │ :22    tcp  LISTEN  sshd                  │
│  └─ ── ── ── ── ── ── ── ── ── ── ── ── ── ┐         │
│                                                   │
│  ┌── 带宽 ── ── ── ── ── ── ── ── ── ── ── ┐
│  eth0  ↑ 1.2 KB/s  ↓ 3.4 KB/s               │
│  lo    ↑ 0.5 KB/s  ↓ 0.5 KB/s               │
│  wlan0 ↑ 0 KB/s   ↓ 0 KB/s                  │
│  └─ ── ── ── ── ── ── ── ── ── ── ── ── ── ┐         │
│                                                │
│  [扫描端口] [DNS查询] [测试连通]               │
└─  ┘── ┘── ┘ ── ┘──  ┘──  ┘  ┘──  ┘──  ┘─