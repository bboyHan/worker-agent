

# Core System Flow: Intent to Product

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 整体架构

```
[User Input]
     |
     ▼
┌─────────┐
│  Intent  │  (Parse intent → create project.json)
└────┬────┘
     │
     ▼
[Manifest] (project.json: 状态机, 任务清单, 设计令牌)
     │
     ▼
[Scheduler Agent distributes tasks]
┌───────────────┼──────────────────────┐
│               │                       │
▼               ▼                       ▼
▶ Designer     ▶ Code Agent        ▶ Deploy Agent
│   │             │                      │
▼   │             ▼                      │
[Design]    [Code Gen]                [Docker]
     │             │                      │
     └──────┬──────┘                      │
            ▼                             │
    ▶ Test Agent                     [Output]
            │                             │
    [Review & Diff]                     [Preview]
            │
            ▼
       [Confirmation]
            │
            ▼
       [Execute]
```

## 2. 数据核心：Manifest (`project.json`)

整个流程的状态由 `project.json` 驱动：

```json
{
  "meta": {
    "name": "my-todo-app",
    "version": "0.1.0",
    "created": "2026-06-02T12:00:00",
    "modified": "2026-06-02T12:02:30"
  },
  "intent": {
    "raw": "帮我做一个待办事项应用，蓝色主题，支持添加/删除/完成功能",
    "parsed": {
      "features": ["add", "delete", "complete"],
      "design": { "primary_color": "#3B82F6", "font": "Inter" },
      "tech_stack": { "frontend": "React+Tailwind", "backend": "FastAPI" }
    }
  },
  "design_tokens": { ... },  // 从 Designer Agent 产出
  "phases": [
    {
      "id": "phase_1",
      "name": "design",
      "agent": "designer",
      "status": "complete",
      "output": "generated design tokens"
    },
    {
      "id": "phase_2", 
      "name": "frontend",
      "agent": "code",
      "status": "in_progress",
      "tasks": [
        {"id": "t1", "desc": "Create React project", "status": "done"},
        {"id": "t2", "desc": "Generate Todo components", "status": "done"},
        {"id": "t3", "desc": "Generate TodoForm", "status": "pending"}
      ]
    }
  ],
  "current_phase": "phase_2",
  "status": "planning", // or "reviewing", "reviewed", "deploying", "complete"
  "git": {
    "initialCommit": true,
    "branch": "main",
    "autoCommit": true
  }
}
```

## 3. 流程阶段详解

### 阶段 0: Intent 解析 (`parseIntent`)

**输入:** 用户自然语言
**输出:** `project.json` (intent 部分)
**Agent:** 🧠 Scheduler + LLM

```
> 帮我做一个待办事项应用，蓝色主题
▶ 解析意图...
📋 理解的需求:
  ✅ 功能: add/delete/complete todo
  ✅ 主题: 蓝色 (#3B82F6) → 自动生成色值
  ✅ 技术栈: React + Tailwind (默认前端) + FastAPI (默认后端)

是否同意? [Y/N/Edit]
```

**状态转换:** `idle` → `intent_resolved`

---

### 阶段 1: 项目脚手架 (`scaffoldProject`)

**动作:**
1. 创建目录 `project_name/`
2. `cd project_name && npm init -y`
3. 安装依赖 (React, FastAPI等)
4. 生成基础文件结构
5. 创建 `project.json`

**目录结构 (示例):**
```
my-todo-app/
├── project.json        # Manifest
├── package.json
├── src/
│   ├── components/     # 存放生成的UI组件
│   ├── styles/         # 存放全局样式/design tokens
│   └── index.tsx
├── backend/
│   └── main.py
└── tests/
    └── todo.test.ts
```

**状态转换:** `intent_resolved` → `scaffolded`

---

### 阶段 2: 设计阶段 (`runDesignPhase`)

**Agent:** 🎨 Designer Agent (使用 Design Tokens API)

**任务清单:**
1. 分析 `intent` 中的设计需求
2. 生成 `design_tokens.json`
3. 生成 `src/styles/global.css` (通过设计令牌自动编译)
4. 生成 `src/styles/design-tokens.css` (CSS变量文件)

**输出文件:**

`design_tokens.json`:
```json
{
  "colors": {
    "primary": { "hex": "#3B82F6", "locked": true, "use": "Primary UI elements" },
    "secondary": { "hex": "#10B981", "locked": false },
    "text": { "hex": "#111", "locked": true }
  },
  "fonts": {
    "heading": { "family": "Inter", "weight": 700, "locked": true },
    "body": { "family": "Inter", "weight": 400, "locked": true }
  }
}
```

**状态转换:** `scaffolded` → `design_complete`

---

### 阶段 3: 代码生成阶段 (`runCodePhase`)

**Agents:** 💻 Code Agent (并行)

**任务清单:**
1. Designer → Code: 传递 `design_tokens.json` 作为约束
2. Code Agent 生成组件代码时使用 `tokens.json`
3. 每次生成后执行自检验:
   - TypeScript 编译检查 (`tsc`)
   - ESLint 检查
   - **Visual Lock 检查** (检查生成的代码是否遵守令牌约束)

**状态转换:** `design_complete` → `code_complete` → `reviewing`

---

### 阶段 4: 代码审查 (`reviewDiff`)

**展示:**

```
📋 Git Diff 预览 — 4 个文件已修改

┌─── diff --git a/src/components/TodoList.tsx b/src/components/TodoList.tsx ───┐
│@@ -1,10 +1,37 @@                                                             │
│+import React from 'react';                                                   │
│+interface TodoItem { id: number; text: string; completed: boolean; }          │
│                                                                                │
│+export const TodoList: React.FC = () => {                                    │
│+  const { todos } = useTodos();                                              │
│+                                                                              │
│+  return (                                                                   │
│+    <div style={{                                                        │
│+      background: 'var(--color-primary)', ← 自动注入!                      │
│+      fontFamily: 'var(--font-heading)',                                  →     │
│+    }}>                                                               │
│+      <h1>My Todos</h1>                                                     │
│+      {/* ... component code ... */}                                        │
│+    </div>                                                                  │
│+  );                                                                         │
│+}                                                                             │
└────────────────────────────────────────────────────────────────────────┘

✅ Visual Lock: 通过 (所有变量使用设计令牌)
✅ TypeScript: 编译通过
✅ ESLint: 无问题

🟢 Apply to code? [Y/N/Inspect]
```

**状态转换:** `code_complete` → `reviewing` → `reviewed`

---

### 阶段 5: 预览阶段 (`startPreview`)

**Agent:** ▶️ Preview Agent

**流程:**
1. 启动开发服务器 (`npm run dev`)
2. 自动打开 `http://localhost:3000` (或在终端内渲染 HTML)
3. 展示预览状态

```
✅ Preview launched: http://localhost:3000

┌── Live Preview ── ── ── ── ── ── ── ── ── ── ── ── ┐
│ ⚠ Click a component to inspect/edit                   │
│                                                        │
│ 🟢 TodoList (selected)                                │
│    → background: var(--color-primary)                  │
│    → font: var(--font-heading)                         │
│                                                        │
│ Actions: [Open in Browser] [Edit] [Add Component]     │
└──────────── ── ── ── ── ── ── ── ── ── ── ── ── ── ┘
```

**状态转换:** `reviewed` → `preview_active`

---

### 阶段 6: 迭代 (`iterate`)

**循环交互:**

```
> Change buttons to green
▶ Visual Lock detected!
  Current primary: #3B82F6
  Requested: green (#22C55E)
  
  🔒 This token is locked
  [Y] Update and lock (propagate to all components)
  [N] Override lock (just this once)
  [S] Skip
  
> y
✅ Primary: #3B82F6 → #22C55E
✅ All components updated
✅ Preview refreshed!
```

**状态转换:** `preview_active` → `iteration` → `preview_active`

---

### 阶段 7: 部署 (`deploy`)

**Agent:** 🚀 Deploy Agent (可选)

```
> deploy to docker
▶ Generating Dockerfile...
✅ Base image: node:18-alpine
✅ Install commands: npm ci
✅ Build command: npm run build
✅ Start command: npm run start
✅ Expose port: 3000

▶ Running: docker build -t my-todo-app .
...
✅ Build successful!

▶ Running: docker run -p 3000:3000 my-todo-app
✅ Container started
🌐 http://your-server:3000
```

**状态转换:** `preview_active` → `deployed` → `complete`
