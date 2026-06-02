# Feature 14 — 代码库管理设计

> 日期: 2026-06-02
> 优先级: 低
> 状态: 完整设计完成

## 1. 模块定位

管理和浏览已打开的工作区代码仓库（非Git操作层面，而是架构层面的代码库管理），包括代码片段库、模板库、工具函数库等。

## 2. 功能边界

### 2.1 包含的功能

| 功能 | 描述 |
|------|------|
| 库浏览 | 分类浏览代码库中的代码片段 |
| 库搜索 | 全文搜索代码库 |
| 库插入 | 将代码片段插入到当前编辑位置 |
| 库管理 | 添加/编辑/删除代码库条目 |
| 模板管理 | 项目模板的创建/使用/管理 |
| 代码统计 | 库的代码行数/语言分布统计 |

### 2.2 排除的功能

- 不涉及代码克隆/下载（已有Git集成负责）
- 不涉及代码仓库的同步/推送

## 3. 数据模型

数据存储在 `data/code-lib/` 目录：

```json
{
  "libraries": [
    {
      "id": "lib_001",
      "name": "React Hooks",
      "description": "常用 React hooks 集合",
      "language": "typescript",
      "tags": ["react", "hooks"],
      "version": "1.0",
      "items": [
        {
          "id": "item_001",
          "title": "useDebounce",
          "code": "export function useDebounce<T>(value: T, delay: number)...",
          "language": "typescript",
          "created": "2026-06-02",
          "favorites": true
        }
      ]
    }
  ],
  "templates": [
    {
      "name": "react-tailwind-starter",
      "description": "React + Tailwind 项目模板",
      "files": ["src/App.tsx", "src/index.css", "tailwind.config.js"],
      "preview": "..."
    }
  ]
}
```

## 4. Terminal UI 设计

```
┌── 代码库 ──────────────────────────────────────┐
│  [代码片段] [模板] [统计]                         │
│                                                    │
│  ┌─ 库列表 ─────── ────── ─── ────── ─── ──┐
│  │ 📚 React Hooks  (24 items)            │
│  │ 📚 Node.js Utils  (18 items)            │
│  │ 📚 UI Components  (32 items)            │
│  │ 📚 API Patterns  (12 items)             │
│  └────────── ── ──────── ─── ─────── ─── ──┘            │
│  [筛选: 全部 ▼] [语言: ALL] [搜索 ▼]          │
│                                                      │
│  ┌── useDebounce ─── ── ── ── ── ── ── ── ┐
│  export function useDebounce<T>(             │
│    value: T,                                  │
│    delay: number                              │
│  ): T {                                       │
│    const [debounced, setDebounced]...        │
│    useEffect(() => {                         │
│      const t = setTimeout(...);              │
│      return () => clearTimeout(t);           │
│    }, [value, delay]);                        │
│    return debounced;                          │
│  }                                            │
│  ── ─── ── ── ── ── ── ── ── ── ── ── ── ── ┐           │
│                                                │
│  [插入光标处] [复制] [收藏] [编辑]             │
└───  ┘──  ┘─── ┘─── ┘  ┘── ┘──  ┘ ┴──  ┘─