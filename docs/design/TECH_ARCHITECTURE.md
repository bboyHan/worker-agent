# Worker Agent — 技术架构与选型方案（V2）

> 版本: 2.0 | 日期: 2026-06-02
> 原则：每个模块追求最优解，本地优先，永远免费

---

## 一、核心选型决策

### 1.1 工作流画布 — AntV X6 + 自研节点

| 维度 | 备选（LangFlow） | 我们最优解（AntV X6） |
|------|-----------------|------|
| 定位 | 独立SaaS | 嵌入式组件 |
| 协议 | MCP Server | Canvas渲染引擎 |
| 包体 | 重（全栈） | 轻（仅UI渲染层） |
| 定制性 | 固定节点 | 完全自定义 |

### 1.2 本地AI推理 — Ollama（已有）

| 维度 | CSV推荐（Continue.dev） | 我们最优解（Ollama） |
|------|--------- |------|
| 定位 | IDE编码插件 | 本地推理服务 |
| 部署 | IDE侧 | 独立服务 |
| 适用 | 编码辅助 | Agent能力 |

### 1.3 Agent编排 — MCP协议层 + 渐进式引入

| 维度 | CSV推荐（LangFlow+LangGraph） | 我们最优解 |
|------|------------------|-----|
| 阶段 | 一步到位 | 渐进演进 |
| 语言 | Python | Node.js/MCP |
| 复杂度 | 重框架 | 协议栈 |

### 1.4 任务管理 — Tiptap + dnd-kit 自研

| 维度 | CSV推荐（Plane 2.0） | 我们最优解（自研） |
|------|------|------|
| 定位 | 独立项目管理平台 | 嵌入式任务组件 |
| 包体 | 重（全栈） | 轻（必要UI组件） |

### 1.5 草图/原型 — Tldraw 2.0+

| 维度 | 决策 |
|------|------|
| 推荐 | 直接采纳 |
| 理由 | React SDK可嵌入、MIT、Canvas渲染、MCP支持 |
| 集成 | npm install，React组件直接导入 |

### 1.6 全局搜索 — FlexSearch + 自研索引

| 维度 | CSV推荐（Wox 2.0） | 我们最优解（FlexSearch） |
|------|-----|------|
| 定位 | 系统级全局搜索 | 平台内部搜索 |
| 平台 | Rust桌面应用 | JavaScript |
| 范围 | 全系统 | 文件/任务/Agent/知识库 |

---

## 二、技术栈总览

### 2.1 前端

| 组件 | 技术 | 版本 |
|------|------|------|
| UI | React 19 + TypeScript | ^19.0.0, ^5.0.0 |
| 构建 | Vite 6 | ^6.0.0 |
| 画布 | AntV X6 | ^5.0.0 |
| 草图 | Tldraw 2.0+ | ^2.0.0 |
| 看板 | dnd-kit | ^7.0.0 |
| 富文本 | Tiptap | ^8.0.0 |
| 编辑器 | Monaco Editor | ^0.52.0 |
| 搜索 | FlexSearch | ^0.7.32 |
| UI组件 | 轻量级按需 | - |
| 路由 | React Router 7 | ^7.0.0 |
| 状态 | Zustand | ^5.0.0 |

### 2.2 后端

| 组件 | 技术 | 版本 |
|------|------|------|
| 运行时 | Node.js 22 | ^22.0.0 |
| Web | Fastify 5 | ^5.0.0 |
| ORM/存储 | Better-SQLite3 | ^11.0.0 |
| 文件 | fs-extra | ^11.0.0 |
| SSH | ssh2 | ^1.16.0 |
| MCP | @modelcontextprotocol/sdk | ^1.0.0 |
| CLI | commander ^12.0.0 + inquirer ^9.0.0 |
| 实时 | WebSocket | ^8.0.0 |
| 日志 | Pino | ^9.0.0 |

### 2.3 本地推理

| 组件 | 技术 | 版本 |
|------|------|------|
| AI | Ollama | latest |
| 模型 | qwen3.6 + codestral | 本地 |
| 提示工程 | 自研模板系统 | - |
| RAG | 自建向量索引 | - |

### 2.4 通信协议

| 协议 | 技术 | 用途 |
|------|------|------|
| MCP | @modelcontextprotocol/sdk | Agent间工具调用 |
| WebSocket | ws + React WebSocket | 实时状态同步 |
| HTTP | Fastify | REST API / IM网关 |
| SSH | ssh2 | 远程控制 |
| IPC | Node.js IPC | 进程间通信 |

---

## 三、项目目录结构（精简版）

```
worker-agent/
├── docs/
│   ├── design/                    # 设计文档
│   │   ├── FINAL_PRODUCT_DESIGN.md
│   │   ├── COMPLETE_PRODUCT_DESIGN.md
│   │   ├── FINAL_UI_REDESIGN.md
│   │   ├── COMPLETE_INTERACTIVE_DESIGN.md
│   │   ├── TECH_ARCHITECTURE.md
│   │   ├── FEATURE_AUDIT.md
│   │   └── INTERACTIVE_PROTO_*.html
│   ├── tech/
│   └── research/
├── src/
│   ├── main/
│   │   ├── index.ts
│   │   ├── app.ts
│   │   └── gateway/
│   ├── agents/
│   │   ├── scheduler.ts
│   │   ├── task-agent.ts
│   │   ├── code-agent.ts
│   │   ├── deploy-agent.ts
│   │   └── ...
│   ├── core/
│   │   ├── store.ts              # 文件/JSON存储
│   │   ├── config.ts
│   │   ├── logger.ts
│   │   └── events.ts
│   ├── ui/
│   │   ├── terminal/
│   │   └── components/
│   └── lib/
├── data/
│   ├── config.json
│   ├── tasks.json
│   ├── servers.json
│   ├── knowledge/
│   └── cache/
├── scripts/
├── package.json
└── tsconfig.json
```

---

## 四、Agent系统架构

| Agent | 职责 | 技术实现 |
|-------|------|------|
| 🧠 Scheduler | 全局调度、状态机 | 核心引擎 |
| 📋 Task | 看板、队列 | 自研 |
| 💻 Code | 代码生成/审查 | MCP+Ollama |
| 🧪 Test | 测试 | Jest+自研 |
| 🚀 Deploy | 部署 | ssh2+child_process |
| 📁 File | 文件浏览 | 文件系统 |
| 🔍 Search | 全局搜索 | FlexSearch |
| 📚 Knowledge | 知识库管理 | 文件系统 |
| 🎨 Design | 原型设计 | Tldraw |
| 🔧 Work | 工作流 | X6画布 |
| 📧 IM | 远程控制 | HTTP API |
| 🖥️ Server | 监控 | SSH+HTTP |

---

## 五、核心模块实现

### 5.1 工作流画布（AntV X6）
- 节点：代码/任务/部署/测试/条件
- 连线：单向/双向，条件标注
- 交互：拖拽、缩放、连线、右键、快捷键
- 布局：自动（Tree/DAG/Force）

### 5.2 草图画布（Tldraw）
- 手绘/标注/连线/文本
- React组件直接嵌入
- MCP支持（Agent绘图）

### 5.3 看板（Tiptap + dnd-kit）
- 列流转、拖拽、Sprint
- SQLite → 实时同步

### 5.4 全局搜索（FlexSearch）
- 范围：文件、任务、Agent状态、知识库
- 索引方式：增量构建
- 全文检索、模糊匹配、优先级排序

### 5.5 代码编辑器（Monaco Editor）
- 语法高亮/代码补全/Go-to-Definition
- AI集成：Ollama API

### 5.6 数据存储（纯文件 + SQLite）
- 表结构：tasks、agents、servers、knowledge、search_index、config、im_config
- 文件：tasks.json、config.json、servers.json、knowledge/**、keys/**

---

## 六、部署与运行

### 开发
```bash
npm install
npm run dev        # CLI + Web
npm run build
npm start
```

### 本地推理
```bash
ollama pull qwen3.6   # 下载模型
ollama run qwen3.6    # 运行推理
# 端口: localhost:11434
```

### 生产
- 方案：单二进制分发
- 工具：pkg / ncc
- 自包含，零外部依赖（仅需本地Ollama）

---

## 七、选型决策总结

| 模块 | 选型 | 理由 |
|------|------|------|
| 画布 | AntV X6 | 轻量嵌入 |
| 推理 | Ollama（已有） | 直接可用 |
| 编排 | MCP协议层 | 渐进式 |
| 任务 | Tiptap+dnd-kit | 轻量 |
| 草图 | Tldraw 2.0+ | React SDK最优 |
| 搜索 | FlexSearch | 零依赖 |
| UI | React + Vite | 生态最好 |
| 后端 | Fastify + TS | 已有基础 |
| 存储 | 纯文件+SQLite | 可选 |
| 通信 | WebSocket + MCP | 实时+Agent |

---

> **下一步：整理核对所有功能模块，识别缺失功能。**
> **下一步：整理核对所有功能，识别缺失功能。**
