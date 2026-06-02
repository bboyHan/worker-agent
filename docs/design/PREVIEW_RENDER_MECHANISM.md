# Preview 渲染机制设计

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 架构总览

```
┌──────────────────────────────────────────────────────┐
│                  Worker Agent (Your CLI)                │
│                                                     │
│  ┌─ 用户终端 ── ── ── ── ── ── ── ── ── ── ── ── ├──┐
│  │  Option A: Browser Preview (推荐)                      │
│  │  - 启动 dev server → localhost:3000                    │
│  │  - 自动打开系统默认浏览器                            │
│  │  - 实时 HMR (Hot Module Replacement)                 │
│  └────── ── ── ── ── ── ── ── ── ── ── ── ── ──── ───┘
│
│  ┌── Option B: Terminal Preview (备选)                    │
│  │  - 使用 xterm.js 渲染 HTML preview                     │
│  │  - 适用于无浏览器环境 (SSH/WSL)                        │
│  └────── ── ── ── ── ── ── ── ── ── ── ── ── ──── ───┘
│
│  ┌── Option C: Inline Terminal (最小)                    │
│  │  - ASCII/Unicode 渲染基础 UI                           │
│  │  - 仅用于快速验证，非完整预览                         │
│  └─────── ── ── ── ── ── ── ── ── ── ── ──────── ───┘
└──────────────────────────────────────────────────────┘
```

## 2. Option A: 浏览器预览（推荐方案）

### 2.1 启动流程

```
1. 检测目标技术栈
   - React/Vue/Angular/纯HTML/Svelte 等
   
2. 执行启动命令
   - React:  npm run dev           (Vite)
   - Next.js: npm run dev          (Next.js dev)
   - 纯HTML: npx serve ./dist      (静态服务器)
   - FastAPI: python -m uvicorn main:app --reload
   
3. 等待 server 就绪
   - 轮询 http://localhost:3000/health
   - 最长等待 30s
   
4. 自动打开浏览器
   - macOS: open http://localhost:3000
   - Windows: start http://localhost:3000
   - Linux: xdg-open http://localhost:3000
   
5. 在 Worker Agent 终端显示状态
   ┌── Preview Status ── ── ── ── ── ── ── ── ── ── ── ── ┐
   │ 🟢 Preview Active: http://localhost:3000              │
   │    Server: Vite  (react)                              │
   │    HMR: enabled (hot reload)                          │
   │    Inspect: click a component to edit                 │
   │    [Stop Preview] [Open in Browser] [Config]         │
   └─────── ── ── ── ── ── ── ── ── ── ── ── ── ───────┘
```

### 2.2 端口分配策略

为防止端口冲突，使用动态端口分配：

```javascript
// port_allocator.js
const PORT_START = 3000;
const PORT_END = 3200;
let currentPort = PORT_START;

function findAvailablePort() {
  for (let port = currentPort; port <= PORT_END; port++) {
    if (!isPortInUse(port)) {
      currentPort = port + 1;
      return port;
    }
  }
  throw new Error('No available port (3000-3200)');
}
```

### 2.3 HMR (Hot Reload) 状态同步

```
浏览器修改代码 ──▶ Vite HMR ──▶ File system watch
     │                                       │
     │                                       ▼
     │                              Worker Agent 检测到变更
     │                                       │
     │                                       ▼
     │                              [Auto-preview refresh]
     │                                       │
     │                                       ▼
     └── Browser 自动刷新 (HMR 内部)
```

**自动刷新策略:**
```javascript
// 文件 watcher 配置
{
  watchPaths: ['./src'],
  debounce: 300,     // 300ms 防抖,避免多次刷新
  maxRetries: 3,     // HMR断开后自动重试
  restartCmd: 'npm run dev',  // 如果HMR失败,自动重启dev server
}
```

## 3. Option B: 终端内预览（备选）

当无法打开浏览器时，使用 terminal 内渲染预览。

### 3.1 实现方案

```
┌── 终端内预览 ── ─── ── ── ── ── ── ── ── ── ── ── ── ┐
│  [Component Tree]                              │        │
│  ├── TodoList                                   │        │
│  │   ├── TodoHeader (h1)                        │        │
│  │   ├── TodoList (ul)                          │        │
│  │   │   ├── TodoItem #1                        │        │
│  │   │   ├── TodoItem #2                        │        │
│  │   └── TodoInput (form)                       │        │
│  ────── ─── ── ── ── ── ── ── ── ── ── ── ── ── ┐        │
│                                                    │
│  ┌── Visual Preview ── ── ── ── ── ── ── ── ── ┐│
│  │ ┌────────────────────────────────────────────┐ │
│  │ │ 🎨 My Todo List                          │  │
│  │ │                                        │  │
│  │ │  ├── Read a book          [✓]      [✏️] │  │
│  │ │  ├── Buy groceries      [✓]      [✏️]  │  │
│  │ │  └── Write code        [ ]        [✏️] │  │
│  │ │                                        │  │
│  │ │  ┌─ Input field ─────────────────┐ └─ ── │
│  │ │  │ [   Add todo ...     ]   [Add]     │     │
│  │ │  └─ ──────────────── ── ── ── ── ── ┘   │
│  │ └────────────────────────────────────────────┘ │
│  └─ ─── ── ── ── ── ── ── ── ── ── ── ── ── ── ┘        │
│                                                    │
│  ── 组件编辑 ── │ ── ── ── ── ── ── ── ── ── ┐        │
│  │ 编辑 TodoInput 组件:                                    │
│  │ className: "mb-4"                             │
│  │ style:         { padding: '16px' }             │
│  > onChange: (e) => setInput(e.target.value)       │
│  ──────── ── ── ── ── ─�─ ── ──── ── ─── ── ┘       │
└───────────────── ── ── ── ── ── ── ── ── ── ┄────  ┴─────┘
```

### 3.2 渲染引擎选择

```
┌──────────────────────────────────────────────────────┐
│  Terminal Render Engine Selection                       │
├───────────────────┬─────────────────────────────────┤
│  方案             │ 说明                            │
├───────────────────┼─────────────────────────────────┤
│  html-to-text     │ 服务器渲染 HTML,终端内显示文本│
│  ink-react        │ Ink 库在终端内渲染 React 组件 │
│  ink-table        │ 表格/表单等结构化内容            │
│  ansi-html         │ 带颜色的HTML预览               │
├───────────────────┼─────────────────────────────────┤
│  推荐: hybrid     │ 结构化内容用 ink-table             │
│                   │ 视觉内容用 html-to-text + 色     │
└───────────────────┴─────────────────────────────────┘
```

## 4. Option C: ASCII Quick Preview（最小预览）

快速查看基本效果：

```
┌── Quick Preview (ASCII) ── ── ── ── ── ── ── ── ── ┐
│  ┌────────────────────────────────────────────┐   │
│  │  My Todo List                              │   │
│  │  ┌─ Todo Item 1    ✓   [edit]          │   │
│  │  │  ┌─ Todo Item 2    ?   [edit]      │   │
│  │  │ ┌─ Todo Item 3    ?   [edit]       │   │
│  │  └────────────────────────────────────────┘
...
└── ┐── ┐── ┘  ┘──  ┘──  ┘─