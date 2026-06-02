# Worker Agent v2.0 — 完整 UI/UX 设计规范

> 修订版本: 2.0 | 设计日期: 2026-06-02
> 设计参考: VS Code + Trae SOLO + GPT/Claude/DeepSeek

---

## 一、设计目标与设计哲学

### 1.1 核心设计原则

| 原则 | 说明 |
|------|------|
| **工作区最大化** | 导航元素占屏比 ≤ 5%，所有导航可通过全局搜索完成 |
| **渐进式披露** | 默认隐藏次要信息，需要时按需展开 |
| **键盘优先** | 所有功能均可通过键盘快捷键完成，鼠标仅作为辅助 |
| **上下文感知** | UI 根据当前功能模块动态调整，减少不相关元素 |
| **视觉一致性** | 暗色主题、统一色板、一致的图标风格和交互反馈 |
| **可访问性** | 色盲友好配色、键盘导航支持、屏幕阅读器兼容 |

### 1.2 设计参考矩阵

| 参考产品 | 借鉴元素 | 原因 |
|------|------|------|
| VS Code | 左侧图标栏（50px 窄栏）、颜色主题、状态栏 | 极简导航、高信息密度 |
| Trae SOLO | Agent 交互流（Thought → Code Change → Product Summary） | 结构化展示 AI 工作过程 |
| GPT/Claude | 聊天面板布局、消息气泡 | 自然语言交互的成熟模式 |
| Raycast | 全局搜索体验 | 高效、无层级导航 |

### 1.3 设计令牌（Design Tokens）

```css
/* 色板 */
--bg-primary: #0d1117;          /* 主背景 */
--bg-secondary: #161b22;        /* 侧栏背景 */
--bg-surface: #21262d;          /* 悬浮表面 */
--text-primary: #e6edf3;        /* 主文本 */
--text-secondary: #8b949e;      /* 次要文本 */
--text-muted: #484f58;          /* 弱化文本 */
--accent-brand: #7c3aed;        /* 品牌色（紫色） */
--accent-success: #3fb950;      /* 成功（绿色） */
--accent-warning: #d29922;      /* 警告（黄色） */
--accent-error: #f85149;        /* 错误（红色） */
--border-default: #30363d;      /* 默认边框 */
--border-focus: #58a6ff;        /* 聚焦边框 */

/* 字体 */
--font-system: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
--font-mono: "JetBrains Mono", "Fira Code", "Cascadia Code", monospace;
--font-size-xs: 11px;
--font-size-sm: 12px;
--font-size-base: 14px;
--font-size-lg: 16px;
--font-size-xl: 20px;

/* 间距 */
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 16px;
--spacing-lg: 24px;
--spacing-xl: 32px;

/* 圆角 */
--radius-sm: 4px;
--radius-md: 8px;
--radius-full: 9999px;

/* 阴影 */
--shadow-md: 0 4px 6px rgba(0,0,0,0.3);
--shadow-lg: 0 10px 15px rgba(0,0,0,0.3);

/* 动画 */
--duration-fast: 150ms;
--duration-normal: 200ms;
--duration-slow: 300ms;
```

---

## 二、界面布局规范

### 2.1 整体布局结构

```
┌───────────────────────────────────────────────┐
│ [🔍 搜索命令、文件、Agent...              ]    │  ← 顶部搜索栏
├───┬───────────────────────────────────────────┤
│   │                                           │
│ 📄│ ┌── 当前模块内容 ────────────────┐        │
│ 📋│ │                                   │        │
│ 🤖│ │         主工作区                  │        │
│ ⚙️│ │                                   │        │
│ 🖥│ │ ──── 面板分界线（可拖拽） ──── │        │
│ 📚│ │ ┌── 面板内容（Agent/CLI 等） ─┐  │        │
│ 🔌│ │ │                                    │  │        │
│ ⚡│ │ │  Agent 聊天 / CLI 交互区           │  │        │
│ ⚙ │ │ └──────────────────────────────┘  │        │
│ ⇕ │ └───────────────────────────────────┘        │
├───┴───────────────────────────────────────────┤
│ [Agent: 就绪] [worker-agent] [15:42]          │  ← 状态栏
└───────────────────────────────────────────────┘
```

### 2.2 顶部全局搜索栏

| 属性 | 值 |
|------|------|
| 高度 | 48px |
| 宽度 | 最大 600px，水平居中 |
| 背景 | 透明（点击后变为 bg-surface） |
| 文字 | text-primary |
| placeholder | "搜索命令、文件、Agent..." |
| 激活 | Ctrl+P / Cmd+P |

**搜索类型前缀:**
| 前缀 | 含义 | 示例 |
|------|------|------|
| `>` | 命令 | `>deploy` |
| `#` | 文件 | `#index.ts` |
| `@` | Agent | `@coding-agent` |
| `/` | 操作 | `/kill` |

### 2.3 左侧图标栏

| 属性 | 值 |
|------|------|
| 宽度 | 50px（固定） |
| 高度 | 视口（减去状态栏） |
| 背景 | `var(--bg-secondary)` |
| 边框 | 右侧 1px `var(--border-default)` |

**图标列表:**

| 图标 | 名称 | 快捷键 | Tooltip |
|------|------|--------|-----------|
| 📄 | 文件 | `Ctrl+E` | "文件" |
| 📋 | 任务 | `Ctrl+Shift+E` | "任务" |
| 🤖 | Agent | `Ctrl+Shift+A` | "Agent 控制台" |
| ⚙️ | 工作流 | `Ctrl+Shift+W` | "工作流" |
| 🖥 | 服务器 | `Ctrl+Shift+M` | "服务器" |
| 📚 | 知识库 | `Ctrl+Shift+K` | "知识库" |
| 🔌 | 插件 | `Ctrl+Shift+P` | "插件" |
| ⚡ | 搜索 | - | "全局搜索" |
| ⚙ | 设置 | `Ctrl+,` | "设置" |
| ⇕ | 面板 | `Ctrl+\`` | "折叠/展开面板" |

**图标交互:**
- 默认: `text-muted`
- 悬停: `text-primary` + `bg-surface` 背景
- 激活: `accent-brand` + 左侧 2px `accent-brand` 竖线
- 禁用: `text-muted`, `opacity: 0.5`

### 2.4 主工作区

- **位置**: 图标栏 + 面板之间的剩余区域
- **内容**: 根据当前激活的图标显示不同模块
- **空状态**: 项目欢迎面板（logo + 快速开始按钮 + 最近项目列表）

### 2.5 面板（Agent/CLI）

| 属性 | 值 |
|------|------|
| 默认宽度 | 40%（最小 300px，最大 800px） |
| 背景 | `var(--bg-primary)` |
| 边框 | 左侧 1px `var(--border-default)` |
| 分隔线 | 2px 正常 / 4px 悬停（`accent-brand`） |

### 2.6 状态栏

| 属性 | 值 |
|------|------|
| 高度 | 24px |
| 背景 | `var(--bg-secondary)` |
| 文字 | `var(--text-secondary)` |
| 内容 | 左: Agent状态 中: 项目信息 右: 时间/通知 |

---

## 三、Agent 交互界面规范

### 3.1 聊天面板完整结构

```
┌─ Agent 聊天面板 ────────────────────────────────── [✕] ──┐
│                                                           │
│  ───── 用户消息 ─────                                   │
│  帮我生成一个待办列表组件，支持 CRUD 和拖拽排序              │
│                                                           │
│  ──── Thought 进程 ────────────────────────── [▼] ──    │
│  • 分析需求：待办列表 CRUD + 拖拽                         │
│  • 技术选型：React + DnD + SQLite                       │
│  • 实现方案：TodoList 组件 + useTodo Store               │
│                                                           │
│  ───── Code Changes ────────────────────────────────── ─ │
│  📄 TodoList.tsx  +12/-3  [查看变更 ▸]                  │
│  📄 TodoList.test.ts  +25/-0  [查看变更 ▸]               │
│  📄 useTodoStore.ts  +18/-0  [查看变更 ▸]                │
│                                                           │
│  ──── 产物汇总 ─────────────────────────────────────── ─ │
│  ✓ 任务完成  📦 3个文件  ⏱️ 用时 2m15s                 │
│  [全部撤销]  [全部保留]  [查看详情 →]                     │
│                                                           │
│  ── 输入区域 ─────────────────────────────────────── ──  │
│  > 输入消息或 / 命令...                              [发送]│
│  [📎] [🎤] [Auto ▼] [✦]                                │
└───────────────────────────────────────────────────────────┘
```

### 3.2 Thought Process 模块规范

| 属性 | 值 |
|------|------|
| 背景 | `rgba(33,38,45,0.6)` |
| 边框 | 1px `var(--border-default)` |
| 圆角 | 4px |
| 默认状态 | 折叠（显示摘要） |
| 动画 | `var(--duration-fast)` ease-out |
| 图标 | 🤖 |

### 3.3 Code Changes 模块规范

| 属性 | 值 |
|------|------|
| 背景 | 透明 |
| 文件行 | `var(--bg-surface)`，悬停 `rgba(124,58,237,0.1)` |
| 变更统计 | `+N`: `accent-success` `-N`: `accent-error` |
| 操作按钮 | `var(--border-default)` 背景，悬停 `text-primary` |
| 批量操作 | 行末对齐，`var(--border-default)` 边框 |

### 3.4 Product Summary 模块规范

| 属性 | 值 |
|------|------|
| 背景 | `rgba(63,185,80,0.1)` |
| 边框 | 1px `accent-success` |
| 图标 | ✓ 绿色 |
| 统计文字 | `var(--text-secondary)` |
| 操作按钮 | `accent-brand` 背景 |

---

## 四、色彩规范

### 4.1 完整色板

```css
/* 背景 */
--bg-primary: #0d1117;
--bg-secondary: #161b22;
--bg-surface: #21262d;
--bg-hover: rgba(255,255,255,0.05);

/* 文字 */
--text-primary: #e6edf3;
--text-secondary: #8b949e;
--text-muted: #484f58;

/* 品牌 */
--accent-brand: #7c3aed;
--accent-brand-hover: #6d28d9;

/* 功能 */
--accent-success: #3fb950;
--accent-warning: #d29922;
--accent-error: #f85149;
--accent-info: #58a6ff;

/* 边框 */
--border-default: #30363d;
--border-focus: #58a6ff;

/* 阴影 */
--shadow-sm: 0 2px 4px rgba(0,0,0,0.2);
--shadow-md: 0 4px 6px rgba(0,0,0,0.3);
--shadow-lg: 0 10px 15px rgba(0,0,0,0.4);
```

### 4.2 组件色板

| 组件 | 颜色 |
|------|------|
| 主按钮 | `accent-brand` |
| 主按钮悬停 | `accent-brand-hover` |
| 成功标签 | `accent-success` |
| 警告标签 | `accent-warning` |
| 错误标签 | `accent-error` |
| 信息标签 | `accent-info` |

---

## 五、交互协议

### 5.1 动画规范

| 动画 | 时长 | 缓动 | 场景 |
|------|------|------|------|
| 快速 | 150ms | ease-out | tooltip、hover 反馈 |
| 标准 | 200ms | ease-out | 面板折叠/展开 |
| 慢速 | 300ms | ease-out | 页面过渡 |
| 慢速回弹 | 400ms | cubic-bezier(0.175, 0.885, 0.32, 1.275) | 新通知 |

### 5.2 拖拽交互

```
初始: 2px 细线 [cursor: col-resize]
悬停: 4px 半透明 `accent-brand`
拖拽: 2px `accent-brand` + 显示宽度的 tooltip
范围: 300px - 800px
```

### 5.3 折叠/展开

```
折叠: translateX(100%), 200ms ease-out
展开: translateX(0), 200ms ease-out
```

### 5.4 全局搜索

1. `Ctrl+P` → 搜索栏聚焦
2. 输入 → 自动过滤
3. `↑/↓` → 导航
4. `Enter` → 执行
5. `Escape` → 关闭

---

## 六、组件规范

### 6.1 按钮

```css
.btn {
  padding: 8px 16px;
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  font-weight: 500;
  transition: all var(--duration-fast) ease-out;
}

.btn-primary {
  background: var(--accent-brand);
  color: white;
  border: none;
}
.btn-primary:hover {
  background: var(--accent-brand-hover);
}
```

### 6.2 输入框

```css
.input {
  height: 40px;
  padding: 10px 12px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  font-size: var(--font-size-base);
  color: var(--text-primary);
  background: var(--bg-primary);
}
.input:focus {
  border-color: var(--accent-brand);
  outline: none;
  box-shadow: 0 0 0 3px rgba(124,58,237,0.1);
}
```

### 6.3 面板

```css
.panel {
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
}
```

---

## 七、快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+P` | 全局搜索 |
| `Ctrl+E` | 文件管理 |
| `Ctrl+Shift+E` | 任务看板 |
| `Ctrl+Shift+A` | Agent 控制台 |
| `Ctrl+Shift+W` | 工作流编排 |
| `Ctrl+Shift+M` | 服务器监控 |
| `Ctrl+Shift+K` | 知识库 |
| `Ctrl+,` | 设置 |
| `Ctrl+\`` | 折叠/展开面板 |
| `Escape` | 关闭当前面板 |

---

## 八、响应式设计

| 断点 | 设备 | 图标栏 | 面板最小/最大 |
|------|------|--------|------|
| `< 768px` | 手机 | 隐藏为汉堡菜单 | 全屏抽屉 |
| `768-1024px` | 平板 | 50px | 250px / 60% |
| `1024-1440px` | 笔记本 | 50px | 300px / 50% |
| `> 1440px` | 桌面 | 50px | 300px / 70% |

---

## 九、无障碍规范

### 9.1 ARIA

| 元素 | ARIA |
|------|------|
| 图标栏 | `role="navigation" aria-label="主导航"` |
| 面板 | `role="complementary" aria-label="Agent 面板"` |
| 按钮 | `aria-label="折叠面板"` |
| 进度条 | `role="progressbar" aria-valuenow="85"` |

### 9.2 焦点样式

```css
:focus-visible {
  outline: 2px solid var(--accent-brand);
  outline-offset: 2px;
}
```

---

> **设计完成。下一步: INTERACTIVE_PROTOTYPE.html — 可交互原型实现**
