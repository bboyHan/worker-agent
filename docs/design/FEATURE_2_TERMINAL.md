# Worker Agent — 内置终端/Shell模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：平台内嵌终端，支持本地+SSH远程命令执行

---

## 一、功能定位

### 1.1 核心价值

| 价值 | 说明 |
|------|------|
| 平台内直接操作 | 无需切换终端，在平台内直接执行Shell命令 |
| SSH远程管理 | 一键登录服务器，免密码（SSH密钥） |
| 多服务器终端 Tab | 切换不同服务器终端 Tab |
| 命令历史 | 搜索历史命令（本地JSON存储） |
| 命令补全 | Tab自动补全 + 智能推荐 |

### 1.2 技术选型

| 组件 | 选型 | 理由 |
|------|------|--|
| 终端渲染 | xterm.js | 成熟、跨平台、VT100兼容、React组件 |
| Shell进程 | node-pty | 跨平台伪终端、多平台支持 |
| SSH连接 | ssh2 | 轻量、高效、纯JS实现 |
| 命令历史 | 本地JSON文件 | 纯文件存储，无需数据库 |

---

## 二、数据模型

### 2.1 终端会话

```typescript
interface TerminalSession {
  id: string;                  // 会话ID（UUID）
  type: 'local' | 'ssh';      // 会话类型
  name: string;                // 会话名称
  host?: string;               // SSH主机地址
  port?: number;               // SSH端口（默认22）
  username?: string;           // SSH用户名
  password?: string;           // SSH密码（加密存储）
  keyPath?: string;            // SSH私钥路径
  cwd: string;                 // 当前工作目录
  shell: string;               // Shell类型（bash/zsh/fish/cmd.exe）
  theme: TerminalTheme;        // 主题配置
  fontSize: number;            // 字体大小
  fontFamily: string;          // 字体家族
  isActive: boolean;           // 是否活跃
  createdAt: Date;
  lastActiveAt: Date;
}

interface TerminalTheme {
  background: string;          // 背景色
  foreground: string;          // 前景色
  cursor: string;              // 光标色
  selection: string;           // 选中文本色
  black: string;               // 标准色
  red: string;
  green: string;
  yellow: string;
  blue: string;
  magenta: string;
  cyan: string;
  white: string;
  brightBlack: string;
  brightRed: string;
  brightGreen: string;
  brightYellow: string;
  brightBlue: string;
  brightMagenta: string;
  brightCyan: string;
  brightWhite: string;
}
```

### 2.2 命令历史

```typescript
interface CommandHistory {
  id: string;                  // 历史ID
  sessionId: string;           // 关联的会话ID
  command: string;             // 命令文本
  outputPreview: string;       // 输出预览（前500字符）
  exitCode: number | null;     // 退出码（null=命令未完成）
  duration: number;            // 执行时长（ms）
  cwd: string;                 // 执行时的工作目录
  timestamp: number;           // 时间戳
  tags: string[];              // 标签（用户手动）
  favorite: boolean;           // 是否收藏
}
```

---

## 三、交互设计

### 3.1 终端界面

```
🖥 嵌入式终端
Tab 栏: [ 本地:workstation ] [ SSH:192.168.1.100 ] [ SSH:10.0.0.50 ] [+ New] [-] [×]
───────────────────────────────────────────────────────────────────────────────────────
user@workstation: ~/project $ npm run dev

> worker-agent@1.0.0 dev
> vite serve

  VITE v6.0.0  ready in 240ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.1.200:5173/
  ➜  Press h+enter to show help

user@workstation: ~/project $ █
───────────────────────────────────────────────────────────────────────────────────────
[Status: Ready] [Scroll: 0/150] [Encoding: UTF-8] [Zoom: 100%]
───────────────────────────────────────────────────────────────────────────────────────
[快捷键 Ctrl+R:搜索历史 | Ctrl+C:中断 | Ctrl+W:关闭窗口]
```

### 3.2 SSH连接管理

```
> /terminal ssh-connect 192.168.1.100 --port 22 --user admin --key ~/.ssh/id_rsa

SSH Connection Details:
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ 🔗连接SSH服务器                                                  │
│ ────────────────────────────────────────────────────────────────────── ─────────────── │
│ 主机: 192.168.1.100                                               │
│ 端口: [22]                                                         │
│ 用户名: [admin]                                                    │
│ 私钥路径: [~/.ssh/id_rsa]                                       │
│ 连接测试: [● 已通过]                                                   │
│                                                                  │
│ 操作: [连接并打开]  [仅测试连接]  [取消]                       │
└──────────────────────────────────────────────────────────────────────────────────────────── ─ ────── ────── ──────

✅ Connected!
```bash
Welcome to Ubuntu 22.04.3 LTS
* Documentation:  https://help.ubuntu.com
* Management:     https://landscape.canonical.com
* Support:        https://ubuntu.com/advantage

Last login: Fri Jun  2 10:30:00 2026 from 192.168.1.200

admin@server:~$ _
────────────────────────────────────────────────────────────────────────────────────────────
```

3.3 **会话面板**

```
> /terminal sessions

Active Sessions:
┌────────────────────────────────────────────────────────────────────────────────│
│ 📋 会话管理                                                  │
│ ───────────────────-──────────────────────────────────────────────────────── │
│ ───────────────────-──────────────────────────────────────────────────────── │
│ 🏠 Local (workstation)           Active     [切换]        [分屏]     [×]     │
│ 🌐 SSH:192.168.1.100 (admin)   Active     [切换]        [分屏]     [×]     │
│ 🌐 SSH:10.0.0.50 (root)        Disconn.   [重连]      [删除]     [×]     │
│ ──────────────────────────────────────────────────────────────────────────────── │
│ [+ 新建SSH会话]  [新建本地会话]                          [清空已断开会话]       │
└──────────────────────────────────────────────────────────────────────────────── ─
```

---

## 四、核心Agent

### 4.1 终端管理Agent

```typescript
interface TerminalManagerAgent {
  // 会话CRUD
  createSession(options: SessionOptions): Promise<TerminalSession>;
  destroySession(sessionId: string): void;
  updateSession(sessionId: string, updates: Partial<TerminalSession>): void;
  getSession(sessionId: string): TerminalSession | null;
  getAllSessions(): TerminalSession[];
  // 连接管理
  connectSSH(options: SSHOptions): Promise<SSHConnection>;
  disconnectSSH(sessionId: string): void;
  reconnectSSH(sessionId: string): Promise<boolean>;
  // 状态管理
  getSessionStatus(sessionId: string): 'connecting' | 'connected' | 'disconnected' | 'error';
  isBusy(sessionId: string): boolean;
  // 输出处理
  sendToSession(sessionId: string, data: string): void;
  onDataReceived(sessionId: string, data: Buffer): void;
  onCommandEnd(sessionId: string, exitCode: number): void;
  // 事件
  on(event: 'session:start', listener: (sessionId: string) => void): this;
  on(event: 'session:end', listener: (sessionId: string, exitCode: number) => void): this;
  on(event: 'session:error', listener: (sessionId: string, error: Error) => void): this;
}
```

### 4.2 命令历史Agent

```typescript
interface CommandHistoryAgent {
  // 命令历史存储（JSON文件）
  saveCommand(command: string, output: string, duration: number, exitCode: number): CommandHistory;
  getHistory(query: string, limit: number): CommandHistory[];
  getHistoryRange(start: number, end: number): CommandHistory[];
  deleteHistory(historyId: string): void;
  exportHistory(): string; // JSON字符串（导出）
  importHistory(data: string): boolean;
  // 命令行内的历史记录功能
  autocompleteInput(input: string): string[];
}
```

### 4.3 命令补全Agent

```typescript
interface CommandCompletionAgent {
  // 命令补全引擎
  getCommands(prefix: string): string[];
  getOptions(command: string): string[];
  getFiles(path: string): string[];
  getEnvVariables(prefix: string): string[];
  getAliases(): string[];
  getAliases(prefix: string): string[];
  // 智能补全
  suggestBasedOnHistory(command: string): string;
  suggestBasedOnOutput(output: string): string[];
}
```

---

## 五、与现有模块的集成

### 5.1 与Agent的集成

- **Scheduler Agent** 可通过终端Agent执行系统命令（如：监控CPU/内存）
- **Deploy Agent** 可通过终端Agent执行部署脚本
- **Server Agent** 可通过终端Agent执行服务器管理命令
- **IM Agent** 可将终端输出实时推送到IM

### 5.2 与代码编辑器的集成

- 代码编辑器内嵌终端（Terminal Panel）
- 终端内直接打开文件（:open filename）

### 5.3 IM推送

- IM Agent可将终端输出实时推送到IM，方便远程监控

### 5.4 与代码编辑器的集成

- 代码编辑器**内嵌**终端（Terminal Panel）
- 终端内直接打开文件（**:open filename**）

---

## 七、安全考虑

| 维度 | 保护措施 |
|------|------|
| SSH连接 | 密钥文件存储加密、连接超时、失败次数限制 |
| 命令执行 | 命令白名单、输出过滤（敏感信息脱敏） |
| 终端输入 | 命令长度限制、特殊字符转义 |
| 会话管理 | 自动断开空闲会话、会话隔离 |
| 日志记录 | 所有命令日志、失败记录 |

## 八、实施计划

### 阶段一（MVP）
1. xterm.js + node-pty集成
2. 本地Shell支持
3. SSH连接功能
4. Tab栏切换多会话

### 阶段二（增强）
1. 命令历史存储/搜索
2. 命令补全
3. SSH密钥管理

### 阶段三（高级）
1. SFTP客户端
2. 命令别名系统
3. 终端内文件编辑器
