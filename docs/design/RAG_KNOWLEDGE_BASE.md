

# RAG Knowledge Base Structure Design

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 为什么需要 RAG?

AI Agent 需要理解项目上下文才能生成正确的代码/设计。RAG知识库是Agent的"记忆"：

- 项目结构/文件布局
- 已有代码模式和规范
- 用户偏好/历史修改
- 设计令牌和样式规范
- 技术选型/框架文档

## 2. 架构总览

```
┌── RAG Knowledge Base ── ── ── ── ── ── ── ── ────┐
│                                                     │
│  ┌─ Vector Store (SQLite FTS5) ──────────────┐    │
│  │  chunks/                              │││││    ││││    │
│  │  doc-index.json                       │││││    ││││    │
│  │  query-history.json                   │││││    ││││    │
│  └─ ── ── ── ── ── ── ── ── ── ── ─── ──┘    │    │
│                                                     │
│  ┌─ Document Store ── ── ── ── ── ── ── ── ── ──┐    │
│  │  /knowledge/                                    │    │
│  │  ├── project-structure.md                       │    │
│  │  ├── coding-guidelines.md                      │    │
│  │  ├── user-preferences.md                       │    │
│  │  ├── design-tokens/                            │    │
│  │  │   └── tokens-2026-06-02.json                │    │
│  │  ├── tech-stack-docs/                          │    │
│  │  │   ├── react-docs.md                         │    │
│  │  │   ├── tailwind-docs.md                      │    │
│  │  │   └── fastapi-docs.md                       │    │
│  │  └── history/                                  │    │
│  │      └── chat-context.json                     │    │
│  └─ ── ── ── ── ── ── ── ── ── ── ── ─ ─ ─ ─ ─ ─ ├──    │
│                                                     │
│  ┌─ Chunking Engine ── ── ── ── ── ── ── ── ── ──     │
│  │  text → chunks (max 500 tokens each)              │    │
│  │  hash(chunk) → index                             │    │
│  └─ ── ── ── ── ── ── ── ── ── ── ── ──────┘     │
│                                                     │
│  ┌─ Query Engine ── ── ── ── ── ── ── ── ── ── ──    │
│  │  query → top-K relevant chunks                    │    │
│  │  → context window → Agent prompt                  │    │
│  └─ ── ── ── ──────── ── ─── ──────── ─── ── ───  ┘     │
└─────── ─── ── ── ── ─ ─ ── ─ ─────── ─ ─ ─ ─ ─ ─┘
```

## 3. 知识库文件结构

### 3.1 目录布局

```
knowledge/
├── project.md                 # 项目概述/架构总览
├── structure.md               # 文件树/模块结构
├── coding-guidelines.md        # 代码规范/style-guide
├── design-tokens/             # Design tokens 历史版本
│   ├── v1-2026-06-02.json     # tokens 版本1
│   ├── v2-2026-06-05.json     # tokens 版本2
│   └── current.json           # 当前tokens
├── tech-stack/                # 技术栈文档
│   ├── react.md               # React相关约定
│   ├── tailwind.md            # Tailwind相关约定
│   ├── fastapi.md             # FastAPI相关约定
│   ├── nodejs.md              # Node.js相关约定
│   └── common-patterns.md     # 通用模式
├── user-preferences/          # 用户偏好/习惯
│   ├── defaults.yaml          # 默认偏好
│   ├── project-specific.md    # 项目级偏好
│   └── style-preferences.md   # 代码风格偏好
├── history/                   # 历史记录（仅索引）
│   ├── chat-context.json      # 对话历史摘要
│   └── changes.json           # 文件变更历史
└── index.json                 # 向量索引 (SQLite FTS5 + 元数据)
```

### 3.2 project.md 结构

```markdown
# Project Overview

## Summary
{{project name}}, built with {{tech stack}}.

## Architecture
{{architecture description}}

## Module Structure
├── src/
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   └── app/
├── backend/
│   ├── api/
│   ├── models/
│   └── db/
└── tests/

## Key Decisions
- State management: X
- CSS framework: Y
- Auth: Z

## Constraints
- No database (files-only architecture)
- Tailwind + CSS variables hybrid
- TypeScript strict mode
```

### 3.3 structure.md 结构

```markdown
# File Structure Index

## src/components/
| File | Purpose | Dependencies |
|------|---------|-------------|
| App.tsx | Root component | None |
| TodoList.tsx | Todo list | hooks/useTodos |
| TodoItem.tsx | Todo item | components/TodoList |
| ... | ... | ... |

## src/hooks/
| Hook | Purpose | Returns |
|------|---------|---------|
| useTodos() | Todo state management | { todos, add, remove, update } |
| useAuth() | Authentication | { user, login, logout } |
| ... | ... | ... |

## src/utils/
| File | Purpose | Exports |
|------|---------|---------|
| formatDate.ts | Format date | formatDate(date: Date) → string |
| validators.ts | Form validation | isEmail, isRequired |
| ... | ... | ... |
```

### 3.4 tech-stack/*.md 结构

```markdown
# Tailwind CSS Guidelines

## Conventions
- Use `var(--color-*)` for all colors (never hard-code)
- Use `var(--spacing-*)` instead of `px` values
- Tailwind classes for layout (flex/grid)
- CSS variables for design tokens (spacing/color/typography)

## Color Usage
- primary → brand elements (buttons, links)
- secondary → accent elements
- surface → backgrounds
- text → body text
- success/error/warning → status

## Spacing System
- xs(4px), sm(8px), md(16px), lg(24px), xl(32px)
- Never use `px` directly for layout

## Component Patterns
<!-- TodoItem -->
<div class="flex items-center justify-between px-4 py-3 bg-surface-100">
  <span class="text-body font-body">{{ text }}</span>
  <button class="p-2">❌</button>
</div>

<!-- Button -->
<button class="px-4 py-2 bg-primary text-surface-300 rounded-lg hover:opacity-80">
  {{ children }}
</button>
```

### 3.5 user-preferences/defaults.yaml

```yaml
# User preferences
code:
  language: TypeScript
  formatter: prettier
  linter: eslint
  indent: 2
  quote: single
  trailingComma: es5
  semi: true

design:
  primaryColor: '#3B82F6'
  fontFamily: 'Inter'
  borderRadius: '8px'

project:
  defaultBackend: fastapi
  defaultFrontend: react
  testing: vitest
  cssFramework: tailwind

agent:
  verbosity: detailed
  autoCommit: true
  visualLock: strict
  confirmBeforeExecute: true
```

## 4. 向量化引擎 (SQLite FTS5)

### 4.1 表结构

```sql
-- chunks表 (存储分块内容)
CREATE TABLE chunks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  source_file TEXT NOT NULL,      -- 来源文件
  chunk_hash TEXT NOT NULL,       -- 内容哈希
  content TEXT NOT NULL,          -- 分块内容
  metadata JSON,                  -- 元数据 (行号/标题/类型等)
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 全文索引
CREATE VIRTUAL TABLE chunks_fts USING fts5(
  content,
  source_file,
  metadata,
  content=`chunks`,
  content_rowid=`id`
);

-- query_history表
CREATE TABLE query_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  query TEXT NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  top_k_results JSON
);
```

### 4.2 分块算法 (Chunking)

```python
def chunk_document(content, source_file, chunk_size=500):
    """
    将文档内容切分成 500-token  chunks
    """
    chunks = []
    
    # 按标题/章节分块
    sections = re.split(r'(?=^#+ |^===+)', content, flags=re.MULTILINE)
    
    for section in sections:
        section_chunks = []
        tokens = tokenizer.encode(section)
        
        if len(tokens) <= chunk_size:
            section_chunks.append(section)
        else:
            # 大段进一步按段落分块
            paragraphs = re.split(r'\n\n+', section)
            current_chunk = []
            current_tokens = 0
            
            for para in paragraphs:
                para_tokens = len(tokenizer.encode(para))
                if current_tokens + para_tokens > chunk_size:
                    chunks.append((current_chunk, source_file))
                    current_chunk = [para]
                    current_tokens = para_tokens
                else:
                    current_chunk.append(para)
                    current_tokens += para_tokens
            
            if current_chunk:
                chunks.append((current_chunk, source_file))
    
    return chunks
```

### 4.3 查询 (Query)

```python
def query_knowledge_base(query, top_k=10):
    """
    查询知识库，返回最相关的 top-k chunks
    """
    query_tokens = tokenizer.encode(query)
    
    # FTS5 全文搜索
    results = execute_query(f"""
        SELECT 
            c.source_file,
            c.content,
            c.metadata,
            snippet(chunks_fts, '▸', '◂', '...', 200) as excerpt
        FROM chunks c
        JOIN chunks_fts fts ON c.id = fts.rowid
        WHERE chunks_fts MATCH '{query}'
        ORDER BY rank 
        LIMIT {top_k}
    """)
    
    # BM25 相关度排序
    for r in results:
        r.score = compute_bm25_score(query, r.content)
    
    return sorted(results, key=lambda x: x.score, reverse=True)[:top_k]
```

## 5. Knowledge Base 维护

### 5.1 自动索引

```javascript
// 文件变更时自动重新索引
watchProjectFiles = (pattern: string) => {
  chokidar.watch(pattern, {
    ignored: /node_modules|\.git|dist|build/,
    followSymlinks: true,
  })
  .on('change', async (filepath) => {
    await reindex_file(filepath);
    notify('Knowledge base updated');
  });
};
```

### 5.2 手动更新

```
> /kb rebuild
▶ Rebuilding knowledge base index...
  src/ (34 files) → 128 chunks
  tests/ (12 files) → 42 chunks
  knowledge/ (8 files) → 23 chunks
✅ Index rebuilt: 193 chunks (took 2.3s)
```

### 5.3 手动添加知识

```
> /kb add "Our project uses FastAPI for all backend routes, with Pydantic v2 models"
✅ Added custom knowledge (87 tokens)
```

## 6. 知识检索示例 (Agent 视角)

```
Agent: Code Agent needs project context for /generate component

[Step 1] Query RAG
  query: "Todo component structure and styling guidelines"
  
[Step 2] RAG 返回 top-K
  [1] src/structure.md: TodoItem.tsx → "TodoItem组件结构..." (score: 0.92)
  [2] src/coding-guidelines.md: "Tailwind class patterns..." (score: 0.87)
  [3] knowledge/tech-stack/tailwind.md: "Color usage..." (score: 0.82)
  [4] knowledge/user-preferences/defaults.yaml: style preferences (score: 0.76)
  [5] src/components/TodoItem.tsx: current implementation (score: 0.71)

[Step 3] RAG 整合 → 注入 Agent 的 context window
  context: "[1] + [2] + [3] + [4]" (最多保留4096 tokens)
  
[Step 4] Agent 基于 context 生成代码
```

## 7. Context Window 优化

```javascript
// RAG结果限制
const MAX_CONTEXT_TOKENS = 4096;  // 最大注入token数

class ContextManager {
  addChunk(chunk, score): void {
    if (this.totalTokens + chunk.tokens > MAX_CONTEXT_TOKENS) {
      return; // 超出预算，截断或移除
    }
    this.chunks.push({ chunk, score });
    this.totalTokens += chunk.tokens;
  }
  
  // 优先保留高分数chunk
  trim(): void {
    this.chunks.sort((a, b) => b.score - a.score);
    this.chunks = this.chunks.slice(0, 4);  // 保留top-K
  }
}
```

## 8. Knowledge Base 版本管理

```
knowledge/
├── index.json                    # 当前索引
├── index-v1/                     # 历史索引 (每次重建备份)
│   ├── 2026-06-02T12:00:00.json
│   └── 2026-06-03T12:00:00.json
├── .kbignore                   # 排除索引的文件
└── KB_MANIFEST.json            # KB元数据
```

```json
{
  "lastRebuilt": "2026-06-02T12:00:00Z",
  "totalFiles": 54,
  "totalChunks": 193,
  "totalTokens": 96500,
  "version": "1.0"
}
```

## 9. 性能基准

| 指标 | 目标 |
|------|------|
| Index rebuild | < 3s (1000文件) |
| Query latency | < 100ms (top-K) |
| Memory | < 50MB (全量索引) |
| Disk | < 50MB (chunks + metadata) |
| Concurrent queries | Unlimited (SQLite FTS5原生支持) |
