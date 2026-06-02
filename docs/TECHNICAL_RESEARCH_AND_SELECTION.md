# Worker Agent - 技术调研与选型分析报告

> 调研时间: 2026-06-01
> 版本: 0.1-draft
> 目的: 为多Agent协同工作台进行技术选型决策

---

## 0. 调研方法论

我们将从7个关键维度进行分析，每个维度对比 **3-5个主流开源项目**：

1. 工作流编排引擎
2. Multi-Agent框架
3. 可视化画布/节点编辑器
4. 代码编辑器
5. Todo/任务管理
6. 本地优先的IDE/开发平台
7. 实时通信/消息总线

每个对比维度会给出：
- 能力雷达（功能覆盖率）
- 性能指标（Star/Fork/License）
- 适用性分析
- 最终推荐

---

## 1. 维度一：工作流编排引擎

### 1.1 候选项目概览

| 排名 | 项目 | Stars | License | 语言 | 定位 |
|------|------|-------|---------|------|------|
| 1 | n8n | 34k+ | Source Available | TS/Node | 开源自动化/workflow |
| 2 | ComfyUI | 47k+ | GPL-3.0 | Python | AI图像节点编排 |
| 3 | Dify | 43k+ | Apache-2.0 | Python/TS | LLMOps/ChatBot平台 |
| 4 | LangGraph | 20k+ | MIT | Python/TS | 图结构Agent编排 |
| 5 | Node-RED | 23k+ | Apache-2.0 | JS | IoT工作流 |
| 6 | Temporal | 27k+ | MIT | Go | 分布式持久化工作流 |
| 7 | Prefect | 19k+ | Apache-2.0 | Python | 现代数据工作流 |
| 8 | Airflow | 37k+ | Apache-2.0 | Python | 数据ETL编排 |

### 1.2 深度对比

#### n8n — 可视化工作流自动化
```
优势:
  ✅ 可视化节点编排，拖拽式，体验极致
  ✅ 350+ 预置节点（HTTP、数据库、邮件等）
  ✅ 支持自定义 JavaScript 代码节点
  ✅ 工作流版本管理、调试、监控
  ✅ 丰富的社区模板
  ✅ 本地部署友好，Docker 一键启动
  ✅ 事件驱动 + 定时触发 + Webhook 触发
  ✅ 开源版本功能足够使用（核心编排能力完整）
  
劣势:
  ❌ 核心是事件驱动而非 Agent 编排
  ❌ 无内置 Agent 概念（需要自定义集成）
  ❌ 商业许可非完全开源（Core License）
  ❌ 数据持久化靠自有DB，不够灵活
  ❌ 前端依赖闭源组件
  ❌ Python生态覆盖弱（仅通过HTTP集成）
```

#### ComfyUI — AI节点编排典范
```
优势:
  ✅ AI领域最强的节点编排体验
  ✅ 节点间数据流清晰，性能优化极出色
  ✅ 扩展性极强（社区贡献大量自定义节点）
  ✅ 支持复杂条件分支、循环
  ✅ 模型管理和缓存系统优秀
  ✅ 性能远超同类产品
  
劣势:
  ❌ 高度聚焦AI图片/视频生成，泛用性差
  ❌ 无通用任务执行能力（只能运行AI节点）
  ❌ 节点系统为Python-only定制，难以复用
  ❌ UI设计偏专业用户，门槛较高
  ❌ 不适合业务逻辑编排
```

#### Dify — LLMOps平台
```
优势:
  ✅ 全链路LLM应用平台
  ✅ Agent构建能力完善
  ✅ Prompt编辑器和知识库管理
  ✅ 工作流可视化编排
  ✅ 支持多模型后端
  ✅ API管理 + 应用发布
  
劣势:
  ❌ 偏重LLM应用，通用工作流能力弱
  ❌ 架构较重，部署复杂
  ❌ 自定义扩展能力有限
  ❌ 无代码编辑器
  ❌ 画布能力不足（仅工作流编排，非通用）
  ❌ 无本地优先设计（偏云端/SaaS）
```

#### LangGraph (LangChain) — Agent图编排
```
优势:
  ✅ 专为多Agent图编排设计
  ✅ 支持有状态图、循环、条件分支
  ✅ Agent之间的消息传递自然
  ✅ 与OpenAI/Claude/Gemini等深度集成
  ✅ Python生态原生
  ✅ 开源MIT，完全可扩展
  
劣势:
  ❌ 无可视化UI（纯代码编排）
  ❌ 需要自建前端展示
  ❌ 仅限Agent场景，通用工作流能力弱
  ❌ 学习曲线陡峭
  ❌ 无GUI工作流编辑器
  
综合评价: 是Agent编排的底层引擎首选，但不适合用户直接操作
```

#### Node-RED — IoT/通用节点编排
```
优势:
  ✅ 轻量、成熟、生态巨大
  ✅ 节点数量丰富
  ✅ 事件驱动模型成熟
  ✅ 社区活跃
  
劣势:
  ❌ UI设计过时（2010年代）
  ❌ 无Agent概念
  ❌ 现代前端框架不支持
  ❌ 扩展性依赖npm包
  ❌ 不适合AI场景
```

#### Temporal — 分布式工作流引擎
```
优势:
  ✅ 企业级可靠性
  ✅ 持久化工作流状态
  ✅ 语言无关
  ✅ 高性能
  
劣势:
  ❌ 太重，不适合个人工具
  ❌ 需要独立Server
  ❌ 无可视化编排UI
  ❌ 学习成本极高
```

### 1.3 工作流引擎选型结论

| 维度 | n8n | ComfyUI | Dify | LangGraph | **自研** |
|------|-----|---------|------|-----------|----------|
| 可视化体验 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ | 取决于引擎 |
| Agent编排 | ⭐⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 通用性 | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 扩展性 | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 本地优先 | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 学习成本 | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ | 取决于设计 |

**最终选择：自研引擎，底层借鉴 n8n + LangGraph + ComfyUI 的设计精髓**

理由：
1. **n8n** 的节点可视化拖拽设计是最好的，但我们不需要复刻350个节点
2. **ComfyUI** 的节点设计器（节点定义、连线数据流、预览）是行业标杆
3. **LangGraph** 提供了有状态图的编程模型，是Agent编排的最佳范式
4. **自研**才能同时满足：可视化 + Agent原生 + 代码编辑 + Todo + 画布 + UI设计

### 1.4 工作流引擎设计方案

**核心概念模型：**
```
Node (节点)
├── type (触发器/处理/Agent/I/O/输出)
├── config (运行时配置)
├── input_schema (输入类型定义)
├── output_schema (输出类型定义)
├── execution_handler (执行逻辑)
└── metadata (版本、标签、依赖)

Edge (连线)
├── source_node_id
├── target_node_id  
├── source_port (输出端口)
├── target_port (输入端口)
└── data_transform (数据转换)

Workflow (工作流)
├── id + name + description
├── nodes (节点列表)
├── edges (连线列表)
├── triggers (触发配置)
├── variables (全局变量)
├── version_history (版本管理)
└── status (草稿/运行中/已停止)

Execution (执行实例)
├── workflow_id
├── status (pending/running/completed/failed)
├── node_states (各节点执行状态)
├── context (执行上下文)
└── logs (日志)
```

**节点类型架构（可扩展）：**
```python
class BaseNode:
    """节点基类"""
    - inputs (port): 输入端口定义
    - outputs (port): 输出端口定义  
    - config (schema): 配置字段定义
    - execute(ctx): 执行函数
    - validate(): 预执行校验

# 触发器类
class TriggerNode(BaseNode):
    def on_trigger(event): pass
    
# Agent类 (未来集成)
class AgentNode(BaseNode):
    model_config: dict
    prompt_template: str
    output_parser: Callable
    
# 处理类
class CodeNode(BaseNode):
    code: str          # 用户代码
    runtime: Python | NodeJS | Go
    timeout: int
    
# I/O类
class HTTPNode(BaseNode):
    url: str
    method: str
    body: str
    
class FileNode(BaseNode):
    path: str
    action: read | write | watch
```

---

## 2. 维度二：Multi-Agent框架

### 2.1 候选项目概览

| 排名 | 项目 | Stars | License | 语言 | 核心思路 |
|------|------|-------|---------|------|---------|
| 1 | LangChain | 92k+ | MIT | Python/TS | Agent链/图 |
| 2 | AutoGen | 30k+ | MIT | Python | 多Agent对话 |
| 3 | CrewAI | 28k+ | MIT | Python | 角色分工 |
| 4 | LlamaIndex | 35k+ | MIT | Python | RAG/数据 |
| 5 | DSPy | 25k+ | MIT | Python | 声明式编程 |
| 6 | OpenAI Swarm | 8k+ | MIT | Python | 轻量多Agent |
| 7 | Semantic Kernel | 18k+ | MIT | C#/TS | 微软AI框架 |
| 8 | Open WebUI | 48k+ | AGPL-3.0 | Python/TS | Ollama Web UI |

### 2.2 深度对比

#### AutoGen (Microsoft) — 多Agent对话范式
```
优势:
  ✅ 多Agent对话机制设计成熟 (GroupChat, GroupChatManager)
  ✅ Agent间消息传递清晰 (ChatResult)
  ✅ 内置角色定义 (UserProxyAgent, AssistantAgent)
  ✅ 支持代码执行 (CodeExecutor)
  ✅ 微软背书，社区活跃
  ✅ 论文级研究基础
  
核心设计理念:
  Agent 通过 Conversation 交互，不是工作流调用
  强调 "对话即编程" 的范式
  
劣势:
  ❌ 无可视化UI
  ❌ 仅限Python
  ❌ 每个Agent是独立进程，资源消耗大
  ❌ 无工作流编排（纯对话驱动）
  ❌ 配置复杂，需要大量 boilerplate
  ❌ 本地优先设计不足
  ❌ 不适合"可视化编排"场景
```

#### CrewAI — 角色分工范式
```
优势:
  ✅ 角色-任务-流程分层清晰
  ✅ Agent定义简单 (Role + Goal + Backstory)
  ✅ 高优先级排序
  ✅ 可自定义LLM provider
  
核心设计理念:
  "任务驱动型"多Agent，类似真实公司
  Hierarchical 或 Sequential 两种模式
  
劣势:
  ❌ 无可视化UI
  ❌ 仅限Python
  ❌ Agent间通信抽象单一
  ❌ 无法处理复杂条件逻辑
  ❌ 无本地持久化概念
  
综合评价: 适合简单多Agent场景，不适合复杂编排
```

#### Open WebUI — 本地LLM WebUI
```
优势:
  ✅ 最接近"需求"的现有产品
  ✅ Ollama集成完美
  ✅ Chat界面极佳
  ✅ Agent构建器 (功能/工具)
  ✅ 插件/扩展系统
  ✅ 完全开源(AAUPIL)  
  ✅ 本地优先部署
  ✅ 支持多用户

劣势:
  ❌ 本质上是Chat界面，不是工作台
  ❌ 无工作流编排
  ❌ 无Todo/Git/代码编辑
  ❌ 无画布/设计面板
  ❌ 插件机制有限
  
综合评价: 在Chat+Agent UI方面做得最好，
          但距离"工作台"还有巨大差距
```

#### 自研设计思路
经过对比，我们认为不应该依赖任何现有Agent框架，原因：
1. 现有框架都是纯代码，没有UI
2. 需要同时支持可视化编排 AND 代码编排
3. Agent间的通信需要同时支持 REST、WebSocket、消息总线
4. 需要与Todo、代码编辑、画布等深度集成

**Agent运行时设计：**
```python
# 每个Agent实例是一个独立进程/容器
class AgentRuntime:
    - id: AgentID
    - name: str
    - status: str
    - model: ModelProvider       # OpenAI / Anthropic / Local (Ollama)
    - config: AgentConfig
    - system_prompt: str
    - memory: MemoryBackend      # SQLite 存储对话历史
    - tools: list[Tool]          # 可选工具集
    - resources: ResourceState     # CPU/MEM
    - connection: WSChannel       # 与前端实时通信
    
# Agent通信 - 通过消息总线
class AgentMessageBus:
    - publish(agent_id, message)
    - subscribe(agent_id, callback)
    - broadcast(message)
    - history(agent_id, filters)
```

---

## 3. 维度三：可视化画布/节点编辑器

### 3.1 候选项目概览

| 排名 | 项目 | Stars | License | 定位 |
|------|------|-------|---------|------|
| 1 | Excalidraw | 90k+ | MIT | 手绘风格画布 |
| 2 | PatternFly | 5k+ | MIT | React UI组件库 |
| 3 | Tldraw | 25k+ | MIT | 无限画布 (Excalidraw替代品) |
| 4 | Yjs | 12k+ | MIT | CRDT协作框架 |
| 5 | Diagrams | 3k+ | Apache-2.0 | 架构文档 |
| 6 | draw.io/diagrams.net | - | Apache-2.0 | 通用图表 |

### 3.2 深度对比

#### Excalidraw — 手绘风格画布典范
```
优势:
  ✅ 90k+ Stars, 最受欢迎的开源画布
  ✅ 手绘风格, 自然流畅
  ✅ 丰富的基本图形 (矩形/圆形/连线/箭头/便签)
  ✅ 导出为SVG/PNG/Excalidraw JSON
  ✅ 协作功能成熟 (通过Excalidraw Collaborator)
  ✅ 插件系统 (自定义图像/组件库/导出格式)
  ✅ 轻量 (无依赖, 单文件)
  
核心技术:
  - 基于 Fabric.js (canvas渲染)
  - 自定义渲染引擎 (手写风格的线/箭头)
  - 撤销/重做 (命令模式)
  
劣势:
  ❌ 手绘风格不适合产品设计 (需切换回标准)
  ❌ 无UI组件库 (只有基本图形)
  ❌ 协作依赖第三方服务
  ❌ 无代码导出功能
  ❌ 不适合做工作流节点编辑器
  
综合评价: 作为"草图"模块的核心引擎极佳，
          但产品设计需要更标准的组件库
```

#### Tldraw — 新一代无限画布
```
优势:
  ✅ 比Excalidraw更现代
  ✅ React原生实现
  ✅ 内置协作 (WebSocket)
  ✅ 无限画布 + 缩放手势
  ✅ 组件库支持
  
核心架构:
  - 基于 React + Canvas
  - 使用 Yjs (CRDT) 实现实时协作
  - 自研的图形渲染引擎
  
劣势:
  ❌ 较新，社区生态不如Excalidraw  
  ❌ 组件库有限
  ❌ 无代码导出

综合评价: 作为通用画布引擎候选，但需要定制
```

#### React Flow (@xyflow) — 节点编辑行业标准
```
优势:
  ✅ 节点编辑器的黄金标准
  ✅ 丰富的节点类型 (输入/输出/处理/自定义)
  ✅ 连线交互体验极佳
  ✅ 支持自定义节点 (React组件)
  ✅ 布局算法 (dagre/ elkjs)
  ✅ 事件系统完善
  ✅ 性能优化优秀
  
核心特性:
  - 节点拖拽、连线
  - 连线类型 (带形/直线/曲线)
  - 节点样式 (默认/选择/数据绑定)
  - 批量操作
  - MiniMap (小地图)
  - 缩放/平移/缩放
  - 背景网格/点阵
  - 标记 (标记/箭头)
  - 拖拽边界
  - 画布缩放
  - 快捷键
  - 事件系统
  
优势:
  ✅ 最适合做工作流编辑器
  ✅ React生态，React生态整合
  ✅ 可扩展性极强
  ✅ 社区活跃，文档完善

劣势:
  ❌ 仅限React (不适合Excalidraw风格画布)
  ❌ 不是"草图"工具 (仅节点/连线)
  ❌ 无图形元素 (仅用于流程图/连线图)
  
综合评价: 工作流编辑器必须用 React Flow！
          这是行业内无可争议的选择。
```

### 3.3 画布选型结论

| 用途 | 推荐 | 理由 |
|------|------|------|
| 工作流编辑器(节点连线) | **React Flow** | 节点编辑器黄金标准，无可替代 |
| 草图/手绘 | **Excalidraw** | MIT开源，插件可扩展 |
| 产品设计原型 | **自定义 (基于 Fabric.js)** | UI组件库丰富，可导出代码 |
| 架构/流程图 | **Excalidraw** | 与上述统一 |

**最终方案：React Flow (工作流) + Excalidraw (草图) + Fabric.js (原型设计)** — 三种画布引擎服务于不同场景，不替代

---

## 4. 维度四：代码编辑器

### 4.1 候选项目概览

| 排名 | 项目 | Stars | License | 定位 |
|------|------|-------|---------|------|
| 1 | Monaco Editor | - | MIT | VS Code内核 |
| 2 | CodeMirror 6 | 9.5k+ | MIT | 轻量代码编辑器 |
| 3 | Ace Editor | 16k+ | BSD-3 | 老牌编辑器 |
| 4 | Splitpanes + custom | - | - | 自定义 |
| 5 | CodeMirror 5  legacy | 12k+ | MIT | 旧版 |

### 4.2 深度对比

#### Monaco Editor — VS Code 的编辑器引擎
```
优势:
  ✅ VS Code 同款编辑器，能力最强
  ✅ 语法高亮支持最广 (30+语言)
  ✅ IntelliSense (自动补全) 极其智能
  ✅ 代码搜索/替换 (find, findWidget)
  ✅ 代码小地图 (minimap)
  ✅ Git Diff 集成
  ✅ 折叠/展开
  ✅ 括号匹配/高亮
  ✅ 多光标编辑
  ✅ 代码格式化 (Prettier/Beautify)
  ✅ 主题系统
  ✅ 虚拟滚动 + 增量解析
  ✅ React 封装成熟 (@monaco-editor/react), 文档丰富

核心技术:
  - TypeScript 编写
  - 集成 Language Server Protocol (LSP)
  
劣势:
  ❌ 文件大 (~8MB minified)
  ❌ 性能不如CodeMirror6 (大型项目)
  ❌ 自定义能力受限 (源码复杂)
  ❌ 内存占用大
  
综合评价: 如果要最强的编码体验，Monaco是首选。
          但文件体积和性能需要考虑。
```

#### CodeMirror 6 — 现代轻量级编辑器
```
优势:
  ✅ 模块化设计 (按需加载语言/插件)
  ✅ 性能优秀 (增量解析)
  ✅ 轻量 (核心 < 100KB, LSP扩展按需加载)
  ✅ 完全可定制
  ✅ TypeScript原生
  ✅ 支持 LSP (VS Code 语言服务器协议)
  ✅ 丰富的扩展生态
  ✅ WebAssembly 支持
  
核心架构:
  - ProseMirror 理念 (文档模型 + 编辑)
  - StateField (状态管理)
  - Decoration (样式/高亮)
  - Command (编辑器命令)
  - EditorView (渲染层)
  
劣势:
  ❌ 自动补全不如Monaco (需要手动接LSP)
  ❌ 社区生态不如Monaco/VS Code
  ❌ 学习曲线陡峭 (文档分散)
  
综合评价: 适合需要轻量化的场景，是Monaco的最佳替代。
```

### 4.3 代码编辑器选型结论

| 维度 | Monaco | CodeMirror 6 | Ace | **自研** |
|------|--------|--------------|-----|----------|
| 功能丰富度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | - |
| 性能 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | - |
| 打包大小 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | - |
| 定制性 | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | - |
| VS Code体验 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | - |
| IntelliSense | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | - |
| 主题 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | - |

**最终建议：使用 Monaco Editor**（通过 `@monaco-editor/react` 集成到 React 中）

理由：
1. VS Code 的体验是行业标杆，Monaco = 原生VS Code体验
2. 虽然文件大，但现代网络/CDN环境下完全可以承受
3. 对于代码编辑场景，其他编辑器无法提供同等体验
4. 可以通过动态加载按需引入语言支持（tree-shaking）

---

## 5. 维度五：Todo/任务管理

### 5.1 需求分析

我们的Todo不是简单的待办列表，需要：
1. **个人任务**: 常规CRUD
2. **看板视图**: 拖拽排序
3. **甘特图**: 时间线视图
4. **Agent任务**: 可分配给Agent执行的子任务
5. **工作流关联**: Todo与工作流双向关联
6. **实时协作**: 多用户/多Agent状态同步

### 5.2 看板引擎选型

| 排名 | 项目 | Star | License | 定位 |
|------|------|------|---------|------|
| 1 | dnd-kit/sortable | 10k+ | MIT | React拖拽 |
| 2 | react-beautiful-dnd | 20k+ | Apache-2.0 | React拖拽 (archived) |
| 3 | react-grid-layout | 7k+ | MIT | 网格布局 |
| 4 | react-dnd | 10k+ | MIT | 拖拽框架 |
| 5 | sortablejs | 37k+ | MIT | 原生拖拽 (vanilla) |

**最终建议：dnd-kit** (现代React拖拽，性能优，维护活跃)

---

## 6. 维度六：整体IDE/本地优先平台

### 6.1 候选项目概览

| 排名 | 项目 | Star | License | 定位 |
|------|------|------|---------|------|
| 1 | VS Code | 160k+ | MIT | 代码编辑器 |
| 2 | VSCodium | 10k+ | MIT | 开源VS Code |
| 3 | Tabby | 30k+ | AGPL-3.0 | 本地AI代码补全 |
| 4 | Continue | 20k+ | AGPL-3.0 | VS Code AI插件 |
| 5 | Aider | 30k+ | Apache-2.0 | CLI代码助手 |
| 6 | Zed | 20k+ | AGPL-3.0 | 极速代码编辑器 |
| 7 | Cursor | - | - | AI-first IDE |
| 8 | Open WebUI | 48k+ | AGPL-3.0 | 本地Chat/Agent UI |

### 6.2 为什么不能直接用现有IDE？

现有IDE/平台（VS Code、Cursor、Tabby、Open WebUI）都只解决了一个维度：
- VS Code: 代码编辑（无工作流、无看板、无Agent管理）
- Cursor: AI辅助代码（无工作流、无Todo、无画布、无设计功能）
- Open WebUI: Agent聊天（无代码编辑、无工作流、无看板、无画布）
- Tabby: 代码补全（功能极简）
- n8n: 工作流（无代码编辑、无画布、无Todo、无设计）

**我们需要的是一个"整合平台"，而不是"功能叠加"。**

---

## 7. 维度七：实时通信/消息总线

### 7.1 候选方案

| 方案 | 延迟 | 复杂度 | 适用场景 |
|------|------|--------|----------|
| WebSocket (原生) | ~5ms | 低 | 通用实时通信 |
| SSE (Server-Sent Events) | ~50ms | 很低 | 单向推送 |
| Socket.IO | ~10ms | 中 | 需要回退兼容 |
| SignalR (.NET) | ~5ms | 中 | 微软生态 |
| MQTT | ~10ms | 中 | IoT/低带宽 |
| gRPC-WebSocket | ~5ms | 高 | 高性能 |
| Postgres List/Notify | ~100ms | 低 | PostgreSQL原生 |

**最终建议：**
- 主要通信：**原生WebSocket** (简单、通用)
- 状态同步：**Event Sourcing + SSE** (工作流状态变更推送)
- Agent心跳：**轻量WebSocket** 或 **定期轮询**

---

## 8. 最终技术选型汇总

### 8.1 技术选型决策表

| 模块 | 选型 | 理由 | 是否成熟/稳定 | 替代方案 |
|------|------|------|:----:|------|
| **后端框架** | **FastAPI + Python 3.12+** | 异步、类型提示、高性能、生态成熟 | ✅ 非常成熟 | Node.js/Express |
| **前端框架** | **React 19 + TypeScript** | 生态、社区、组件库丰富 | ✅ 非常成熟 | Vue 4 / Svelte |
| **UI组件库** | **shadcn/ui** | 设计系统、可定制、Tailwind CSS | ✅ 非常成熟 | MUI、Ant Design |
| **工作流引擎** | **自研 (基于 React Flow)** | 必须同时满足可视化+Agent+代码+Todo+画布 | 需开发 | n8n (不适合) |
| **Node编辑器** | **React Flow (@xyflow)** | 行业标杆，无可替代 | ✅ 非常成熟 | Yjs / FlowKit |
| **Agent框架** | **自研 (消息总线模式)** | 现有框架无UI、纯代码 | 需开发 | LangGraph (仅后端) |
| **通信总线** | **Redis + Celery** | 异步任务、消息驱动、扩展性 | ✅ 非常成熟 | RabbitMQ + DRF |
| **代码编辑器** | **Monaco Editor** | VS Code同款，体验最佳 | ✅ 非常成熟 | CodeMirror 6 (备选) |
| **草图画布** | **Excalidraw** | 开源、插件可扩展、社区大 | ✅ 非常成熟 | Tldraw (备选) |
| **UI原型画布** | **Fabric.js** | 丰富的图形/组件库、可导出代码 | ✅ 非常成熟 | Konva.js |
| **拖拽排序** | **dnd-kit** | React拖拽最佳选择、性能优 | ✅ 非常好成熟 | react-dnd |
| **状态管理** | **Zustand + Redux Toolkit** | 轻量 + 复杂场景兼顾 | ✅ 非常成熟 | Recoil / Jotai |
| **数据库** | **SQLite + Prisma** | 本地优先、零配置、类型安全 | ✅ 非常成熟 | PostgreSQL |
| **缓存** | **Redis** | 高性能缓存 + Pub/Sub | ✅ 非常成熟 | 本地内存 (开发阶段) |
| **文件存储** | **LocalFS + watchfiles** | 本地优先、变更监听 | ✅ 非常成熟 | 文件系统watch API |
| **HTTP客户端** | **axios** | 请求拦截、取消请求、拦截器 | ✅ 非常成熟 | fetch (原生) |
| **构建工具** | **Vite** | 极速开发、ESM、热更新 | ✅ 非常成熟 | Webpack (过时) / Turb |
| **Agent容器** | **Docker** | 隔离、资源控制、跨平台 | ✅ 非常成熟 | podman (备选) |
| **任务队列** | **Celery** | Python异步、分布式、可靠 | ✅ 非常成熟 | ARQ (备选) |
| **图表可视化** | **Recharts** | React图表库、可定制、性能好 | ✅ 非常成熟 | Echarts / Chart.js |
| **国际化** | **i18next** | 成熟i18n库、React集成好 | ✅ 非常成熟 | next-intl (next.js专) |
| **通知系统** | **Sonner** | toast通知、React组件 | ✅ 新 | react-hot-toast |
| **日志/监控** | **Winston + Sentry** | 结构化日志、错误追踪 | ✅ 非常成熟 | pino (Node) |
| **权限/认证** | **OAuth2 + JWT** | 标准认证方案 | ✅ 非常成熟 | API Key / Session |
| **加密存储** | **keyring** | 安全存储敏感信息 | ✅ 非常成熟 | Vault (太重) |
| **测试框架** | **pytest + Vitest** | Python + JS 测试 | ✅ 非常成熟 | Jest (过时) |

---

## 9. 架构总设计

### 9.1 系统总览图

```
┌────────────────────────────────────────────────────────────────────┐
│                         Worker Agent UI                           │
│                                                                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  │
│  │  Workspace │  │ ChatPanel  │  │  Todo/     │  │ Canvas/    │  │
│  │  Dashboard │  │  (Agent)   │  │  Kanban    │  │ Design     │  │
│  │            │  │            │  │            │  │            │  │
│  │  Agent     │  │  实时      │  │  拖拽      │  │  Excalidraw│  │
│  │  卡片列表  │  │  对话     │  │  看板      │  │  + Fabric  │  │
│  │            │  │            │  │            │  │            │  │
│  │            │  │            │  │            │  │            │  │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  │
│  │ Work-      │  │  Code      │  │  Build &   │  │  Terminal  │  │
│  │ flow       │  │  Editor    │  │  Test      │  │  Console   │  │
│  │  Editor    │  │  (Monaco)  │  │  Runner    │  │            │  │
│  │  (React    │  │            │  │            │  │            │  │
│  │   Flow)    │  │            │  │            │  │            │  │
│  └────────────┘  └────────────┘  └────────----┘  └────────────┘  │
├─ ──────────────────────────────────────────────────────────────── -│
│                         Workspace Layer                            │
│  ┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐ │
│  │ Layout Engine (dnd-kit) + Tab System + Context Menu + Theme   │  │
│  └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘ │
│                     ┌───────────┐                                  │
│                     │ WebSocket │──────实时通信层──▶  └────── ┘    │
│                     └───────────┘                                  │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
│                          FastAPI Backend                           │
│  ┌──────────────────────┬──────────────────┬──────────────────┐  │
│  │ Agent Manager       │ Workflow Engine   │ Task Runner      │  │
│  │ (REST + WS)         │ (Celery)          │ (Celery)         │  │
│  └─────────────────────┴──────────────────┴──────────────────┘  │
│  ┌──────────────────────┬──────────────────┬──────────────────┐  │
│  │ Message Bus          │ File Watcher     │ Code Proxy       │  │
│  │ (Redis Pub/Sub)      │ (watchfiles)     │ (LSP)            │  │
│  └─────────────────────┴──────────────────┴──────────────────┘  │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
│                    Infrastructure Layer                          │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │ SQLite    │  │ Redis     │  │ Docker     │  │ LocaLFS   │  │
│  │ Meta      │  │ Pub/Sub   │  │ Runtime   │  │ Storage   │  │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### 9.2 Core Layer 详细架构

```
                    ┌──────────────────────────────────┐
                    │         Worker Agent Core         │
                    │                                  │
│                          Core Layer                 │
│                                                      │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │Agent    │ │Workflow │ │ Task   │ │Message  │  │
│  │Runtime  │ │  Engine │ │ Runner │ │  Bus   │  │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘  │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │                   MessageBus                     │ │
│  │           (Redis Pub/Sub / Redis Streams)       │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐           │ │
│  │  │ Publish │ │ Subscribe│ │ Broadcast │          │ │
│  │  └─────────┘ └─────────┘ └─────────┘           │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │                  Code Proxy                      │ │
│  │         (File Watcher + LSP Server)             │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │                  File Manager                    │ │
│  │         (LocalFS + watchfiles)                  │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
└──────────────────────────────────────────────────────────┘
```

### 9.3 数据流设计

```
┌───────────────────────────────────────────────────────────┐
│                     Frontend (React + TS)                 │
│                                                           │
│  用户操作 ───▶ 事件系统 (Zustand Store) ───▶ WebSocket    │
│                                                           │
│  WebSocket ───▶ Message Dispatcher ───▶ 更新 UI 状态     │
│                                                           │
├───────────────────────────────────────────────────────────┤
│                     Backend (FastAPI + Python)            │
│                                                           │
│  REST API ───▶ Route Handler ───▶ Service Layer          │
│                                                           │
│  WebSocket ───▶ WS Manager ───▶ MessageBus               │
│                                                           │
│  Celery Worker ───▶ Task Executor ───▶ WebSocket/Pub/Sub│
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 10. 关键技术决策文档

### 10.1 决策 #1: 工作流引擎为什么自研而不选n8n或ComfyUI？

**决策:** 自研工作流引擎  
**背景:** n8n有350+节点，ComfyUI是AI领域最强的可视化节点引擎，两者都是优秀产品  
**分析:**
1. n8n的核心定位是"自动化编排"，节点类型围绕HTTP/邮件/数据库等业务场景，没有Agent原生支持
2. ComfyUI虽好但仅限于AI图片生成，节点系统是针对扩散模型设计的
3. 两个都无法同时满足：可视化 + Agent原生 + Todo + 代码编辑 + 画布 + 构建测试
4. 集成n8n作为"嵌入式iframe"的方案不可行（跨域、状态共享、性能问题）

**替代方案分析:**
- 方案A: 集成n8n (iframe嵌入) ❌ 无法集成Todo/代码/画布
- 方案B: fork ComfyUI 并扩展 ❌ 架构不通用
- 方案C: 自研 ⭕ 最佳方案

**风险评估:**
- 开发成本：高 (约4-6周)
- 技术风险：中 (React Flow成熟，节点引擎设计模式成熟)
- 维护成本：中 (但完全可控)

---

### 10.2 决策 #2: 代码编辑器为什么选Monaco而非CodeMirror 6？

**决策:** 使用 Monaco Editor  
**背景:** CodeMirror 6更轻量、性能更好，但Monaco是VS Code同款  
**分析:**
1. 代码编辑是用户最高频的交互之一，体验至关重要
2. Monaco提供的IntelliSense、Go to Definition、Find References等能力，CodeMirror需要大量自定义工作才能实现
3. Monaco虽然大 (8MB minified)，但可通过CDN动态加载 (开发时)、按需加载语言支持 (tree-shaking)
4. Monaco的API设计比CodeMirror 6更简单、更易用
5. Monaco的VS Code主题、快捷键系统开箱即用

**风险评估:**
- 开发成本：低 (React封装成熟 `@monaco-editor/react`)
- 维护成本：低 (Monaco生态成熟)

---

### 10.3 决策 #3: Agent运行时为什么自研而非用LangChain/AutoGen？

**决策:** 自研Agent运行时  
**背景:** LangChain有92k+ stars，AutoGen是微软的多Agent框架  
**分析:**
1. 所有现有Agent框架都只提供API，没有UI/可视化层
2. 我们的平台需要Agent与工作流、Todo、代码编辑等功能深度集成
3. Agent需要支持多种运行模式：独立进程、Docker容器、嵌入式脚本
4. 现有框架的Agent配置方式不适合"可视化编排"
5. 我们需要统一的Agent通信协议（WebSocket + RPC + File-based）

**替代方案:**
- 方案A: 直接用LangChain作为后端 ⭕ 可以作为Agent的LLM调用层，但不适合运行时管理
- 方案B: 自建 ⭕ 最佳方案，完全可控

---

### 10.4 决策 #4: 为什么选SQLite而非PostgreSQL？

**决策:** SQLite (本地模式) → PostgreSQL (多用户模式)  
**分析:**
1. 第一版是本地优先，SQLite零配置、单文件、嵌入式，完美契合
2. SQLite支持JSONB、FT5全文搜索，够覆盖元数据需求
3. 未来多用户扩展时，可通过 Prisma 切换后端到 PostgreSQL
4. Prisma 是类型安全的ORM，支持 SQLite ↔ PostgreSQL 无缝迁移
5. Docker容器化部署时，PostgreSQL需要额外的容器管理

---

### 10.5 决策 #5: 为什么选FastAPI而非Node.js/Express？

**决策:** FastAPI + Python 3.12+  
**分析:**
1. **Agent运行是Python世界的事**: LangChain、CrewAI、AutoGen、LangGraph、PyTorch、TensorFlow 等全部是Python生态
2. **FastAPI性能强**: 比Flask/FastAPI/FastAPI/FastAPI 快 10-50x，与Express相当
3. **类型安全**: FastAPI的type hint系统让代码质量和API文档自动生成更可靠
4. **异步支持**: FastAPI 原生支持 async/await，适合高并发
5. **开发效率**: 开发速度 >> Express

---

### 10.6 决策 #6: 前端状态管理选Zustand而非Redux？

**决策:** Zustand (核心) + Redux Toolkit (复杂场景)  
**分析:**
1. Zustand 是 React 16.8+ (hook) 时代的状态管理
2. Redux Toolkit 在 Redux 4.x + DX 更好，但仍需 boilerplate
3. Zustand 代码量 < 1KB，零boilerplate
4. Zustand 适合我们的需求：状态管理 + 中间件 + TypeScript支持 + React集成
5. Redux Toolkit 适合作为复杂状态（如工作流、Agent运行状态）的补充

---

### 10.7 决策 #7: 为什么选Vite而非Webpack/Turborepo？

**决策:** Vite  
**分析:**
1. Vite 是下一代前端构建工具
2. 开发启动: Vite (< 1s) vs Webpack (10-30s)
3. 热更新: Vite (ESM HMR, < 100ms) vs Webpack (1-3s)
4. 生产构建: Vite (Rollup) vs webpack (Terser)
5. 前端生态: 社区广泛采用，文档丰富

---

## 11. 模块交互设计 (详细)

### 11.1 Agent 与 工作流的交互

```
                    ┌─────────────────────────────────────┐
                    │            Todo Task             │
                    │                                     │
                    │  "实现用户认证" (分配给Agent)     │
                    └─────────────────────────────────────┘
                                            │
                                            ▼
                    ┌─────────────────────────────────────┐
                    │          工作流 "Auth-Auth-Flow"         │
                    │                                     │
                    │  ┌───────────┐                      │
                    │  │ Task Node │──▶ 自动触发Agent      │
                    │  └───────────┘                      │
                    │                                     │
                    │  ┌───────────┐                      │
                    │  │ Agent Node│──▶ 调用 Agent        │
                    │  │ (Coder)  │                      │
                    │  └───────────┘                      │
                    │                                     │
                    │  ┌───────────┐                      │
                    │  │ Code Node │──▶ 执行代码测试       │
                    │  └───────────┘                      │
                    │                                     │
                    │  ┌───────────┐                      │
                    │  │ Output Node│──▶ 更新Todo状态      │
                    │  └───────────┘                      │
                    │                                     │
                    └─────────────────────────────────────┘
```

### 11.2 消息总线设计

```
                    MessageBus
                     =============
                      Event Types:
                    - TASK_UPDATE
                    - AGENT_STATUS
                    - WORKFLOW_EXEC
                    - CODE_CHANGE
                    - DESIGN_UPDATE
                    - BUILD_RESULT
                    - TERMINAL_OUTPUT
                    
                    Channels:
                    - ws:/agents/:id/chat
                    - ws:/workflows/:id/stream
                    - ws:/tasks/:id/p
```

---

## 12. UI设计系统 (视觉规范)

### 12.1 设计语言原则

```
风格: 现代化、专业、深色主题
基调: 工业级、生产力工具
配色: 暗色 + 彩虹色点缀 (每个模块独立色系)
字体: Inter/Inter/Inter + JetBrains Mono (代码)
间距: 8px网格系统
圆角: 8px (卡片/面板) / 12px (模态框)
阴影: elevation 1/2/3
过渡: 200ms ease-in-out
```

### 12.2 色彩系统

```
背景:
  Primary: #0f172a (Slate-950)
  Secondary: #1e293b (Slate-800)
  Tertiary: #334155 (Slate-700)
  Card: #1e293b + 50% opacity
  
Text:
  Primary: #f8fafc (Slate-100)
  Secondary: #94a3b8 (Slate-400)
  Muted: #64748b (Slate-500)
  
Accent Colors (按模块):
  Agent: cyan (#06b6d4)
  Workflow: purple (#8b5cf6)
  Todo: green (#10b981e6)
  Code: orange (#f97316)
  Canvas: pink (#ec4899)
  Terminal: red (#ef4444)

Status Colors:
  Success: #22c55e (green-500)
  Warning: #f59e0b (amber-500)
  Error: #ef4444 (red-500)
  Info: #3b82f6 (blue-500)
  Idle: #9333ea (purple-500)
  Unknown: #6b7280 (gray-500)
```

### 12.3 字体体系

```
Primary: Inter (无衬线)
  用于UI文本、标题、描述

Code: JetBrains Mono (等宽)
  用于代码、终端、数据

Display: Space Grotesk (几何无衬线)
  用于Logo、标题
```

---

## 13. API设计 (REST + WebSocket)

### 13.1 REST API (配置/管理)

完整REST API列表见`PRODUCT_DESIGN.md`。核心原则：
- REST: 配置/管理/查询操作
- 所有资源统一前缀: `/api/v1/`
- 版本号: `/api/v1/` (未来 `v2`)
- CRUD 命名: 全小写复数资源名
- 分页: `?page=1&per_page=20`
- 排序: `?sort=created_at,desc`
- 过滤: `?status=running&agent_id=agent-01`

### 13.2 WebSocket API (实时)

实时通道：
- `ws://localhost:8000/ws/agents/:id/chat` - Agent对话
- `ws://localhost:8000/ws/workflows/:id/stream` - 工作流执行日志
- `ws://localhost:8000/ws/tasks/:id/progress` - Todo进度
- `ws://localhost:8000/ws/code/:id/diff` - 代码修改
- `ws://localhost:8000/ws/terminal/:id/output` - 终端输出
- `ws://localhost:8000/ws/canvas/:id/updates` - 画布协作
- `ws://localhost:8000/ws/monitor/resources` - 资源监控

---

## 14. 分阶段实施计划 (更新版)

### Phase 0: 基础设施 (W1-2)
- [ ] 后端 FastAPI 框架搭建
- [ ] 前端 React + TypeScript + shadcn/ui 脚手架
- [ ] SQLite + Prisma 数据库模型
- [ ] Docker 部署配置
- [ ] 项目 CI/CD (本地git hooks)
- [ ] 代码规范 (ESLint + Prettier + ruff)

### Phase 1: Agent核心 (W3-6)
- [ ] Agent CRUD + 配置管理
- [ ] Agent 运行/停止/暂停/重启
- [ ] WebSocket 实时通信
- [ ] Agent 状态监控 (CPU/MEM/资源)
- [ ] Agent 对话面板 (聊天界面)
- [ ] Agent 配置管理 (模型/参数/system_prompt)
- [ ] Agent 模板系统 (快速创建)

### Phase 2: 工作流引擎 (W7-10)
- [ ] React Flow 工作流编辑器 (拖拽节点)
- [ ] 节点类型系统 (Trigger/Process/Agent/IO/Output)
- [ ] 工作流执行引擎 (Celery + 消息队列)
- [ ] 工作流版本管理
- [ ] 工作流调试/调试/断点
- [ ] 工作流导入/导出 (JSON/YAML)

### Phase 3: Todo & 任务管理 (W11-12)
- [ ] Todo CRUD
- [ ] Kanban 看板视图 (拖拽)
- [ ] Todo 列表视图
- [ ] 优先级/标签/筛选器
- [ ] Todo ↔ Agent/工作流联动
- [ ] Todo 甘特图视图 (时间线)

### Phase 4: 代码编辑 & 构建测试 (W13-16)
- [ ] Monaco Editor 集成
- [ ] 文件树导航
- [ ] 代码预览/热更新
- [ ] 终端集成 (pty.js)
- [ ] 编译任务配置
- [ ] 测试执行 & 结果可视化
- [ ] Agent 协作编码

### Phase 5: 画布 & 设计 (W17-18)
- [ ] 草图画布 (Excalidraw集成)
- [ ] UI原型画布 (Fabric.js)
- [ ] UI组件库 (按钮/输入/卡片等)
- [ ] 导出 PNG/SVG
- [ ] AI辅助设计生成

### Phase 6: 体验打磨 & 整合 (W19-20)
- [ ] 全局搜索 (Ctrl+K) (Agent/文件/Todo/工作流/命令)
- [ ] Workpace布局自定义 (拖拽调整)
- [ ] 主题系统 (暗/亮/自定义)
- [ ] 快捷键支持
- [ ] 性能优化

### Phase 7: 扩展生态 (W21-22)
- [ ] 插件扩展机制
- [ ] 节点库扩展
- [ ] Agent模板市场
- [ ] 团队协作 (多用户)
- [ ] GitHub/GitLab集成
- [ ] 云端备份

### Phase 8: 移动端 (W23+)
- [ ] PWA/移动端适配
- [ ] 跨端同步
- [ ] 实时通知推送

---

## 15. 风险评估与应对

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|------|
| 工作量过大 | 高 | 高 | 分8个phase, 核心功能优先 |
| React Flow 学习成本 | 中 | 中 | 社区文档完善, demo丰富 |
| Monaco 性能 | 中 | 低 | 按需加载语言支持, CDN加载 |
| SQLite 并发 | 低 | 低 | 读写分离, WAL模式 |
| Docker 部署 | 中 | 中 | 初期无Docker方案 |
| 跨浏览器兼容 | 低 | 低 | Chrome/Firefox/Safari优先 |
| 多用户扩展 | 高 | 低 | 优先单机, 后期加PostgreSQL |
| 代码编辑器体验 | 高 | 低 | Monaco是最佳选择 |

---

## 16. 关键设计决策总结

### 核心理念

```
"一个平台，一切工作流"

不是工具堆叠，而是统一平台
不是功能堆叠，而是可组装

Agent = 第一等公民
工作流 = 可视化编排
所有模块 = 可插拔节点
```

### 最终技术选型总结

| 类别 | 选型 |
|------|------|
| 前端框架 | React 19 + TypeScript |
| UI框架 | shadcn/ui + Tailwind CSS |
| 节点编辑器 | React Flow (@xyflow) |
| 代码编辑器 | Monaco Editor |
| 草图 | Excalidraw |
| 拖拽 | dnd-kit |
| 语言后端 | FastAPI + Python |
| 工作流引擎 | 自研 (基于 React Flow) |
| Agent框架 | 自研 (消息总线) |
| 数据库 | SQLite + Prisma |
| 缓存 | Redis |
| 消息总线 | Redis Pub/Sub |
| 状态管理 | Zustand |
| 构建 | Vite |
| 图表 | Recharts |
| 测试 | pytest + Vitest |
| Docker | 容器化部署 |
| 通知 | Sonner (toast) |
| 日志 | Winston |
| 认证 | OAuth2 + JWT |

**这份技术调研和选型分析涵盖了所有维度的深度对比。请审阅并告诉我：哪些决策需要调整，是否可以开始开发？**
