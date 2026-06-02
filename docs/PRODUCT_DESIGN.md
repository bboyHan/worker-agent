# Worker Agent - 多Agent协同工作台

> 统一的多Agent管理、工作流编排与可视化创作平台
> Version: 0.1.0-draft
> Date: 2026-06-01

---

## 1. 项目概览

### 1.1 愿景

构建一个以 **Agent** 为第一等公民的本地化工作平台。将开发工具、协作工具、创作工具统一在一个界面中，用**可视化编排**替代碎片化切换。

### 1.2 核心诉求

| 序号 | 诉求 | 说明 |
|------|------|------|
| 1 | 多Agent集中管理 | 启动/停止/监控/配置多个Agent本地服务实例 |
| 2 | 可视化工作流编排 | 拖拽节点、连线、组合任务流 |
| 3 | Todo List 管理 | 个人任务跟踪、看板、优先级 |
| 4 | 代码生成+实时预览 | AI辅助编码、热更新预览 |
| 5 | 交互对话界面 | Multi-Agent聊天、上下文管理 |
| 6 | 编译+测试一键执行 | 构建、运行测试、查看结果 |
| 7 | 草图原型与产品设计 | 内嵌画布、wireframe、prototyping |

### 1.3 设计原则

- **本地优先**: 所有数据默认本地存储，网络是可选补充
- **模块化**: Agents、工作流、工具都是可插拔模块
- **可组合**: 任何功能都可以作为节点拼接到工作流中
- **无厂商锁定**: 支持多种LLM后端、多种Agent框架

---

## 2. 系统架构

### 2.1 整体架构图

```

### 2.2 分层架构

系统分为四层，数据自下而上流动，控制权自上而下派生。

**1. Infrastructure层**
- SQLite (元数据) + Redis (缓存/消息) + Docker (Agent容器) + LocalFS (文件)
- 职责：持久化、消息路由、进程隔离

**2. Core层**
- FastAPI (Python) + WebSocket + Celery
- 职责：Agent运行时调度、工作流引擎、代码代理、文件监听

**3. Workspace层**
- React 19 + TypeScript + React Flow + dnd-kit
- 职责：标签页管理、拖拽布局、状态路由、主题切换

**4. UI层**
- shadcn/ui + Tailwind CSS + Monaco/Excalidraw/Fabric.js
- 职责：各面板组件、交互反馈、可视化呈现

---

## 3. 功能模块详细设计

### 3.1 Workspace（工作区）— 总览视图

**功能：**
- 全屏仪表盘，展示所有Agent的状态卡片
- 自定义面板布局（拖拽调整大小/位置）
- 左侧导航栏：Agent、工作流、Todo、文件、设置
- 底部状态栏：系统资源、网络、当前激活Agent

**UI布局：**

左侧导航栏（宽64px，可折叠）：Agent、工作流、Todo、笔记、文件、设计、设置

主区域：Agent状态卡片网格，每张卡片显示Agent名称、运行状态图标、资源占用进度条

底部状态栏：CPU / MEM / DISK 使用率、当前激活Agent、快捷键提示

顶部：全局搜索栏 (Ctrl+K)，右侧为帮助按钮

---

### 3.2 Agent Manager（Agent管理器）

**功能清单：**

| 功能 | 优先级 |
|------|--------|
| Agent实例创建/销毁 | P0 |
| 配置管理（模型、参数、API Key | P0 |
| 运行状态监控（CPU/MEM/Token/时间） | P0 |
| 对话历史查看/搜索 | P1 |
| 日志实时流 | P1 |
| Agent模板/快照 | P2 |
| Agent间通信配置 | P3 |

**Agent实例卡片数据模型：**
```yaml
agent:
  id: "agent-coder-01"
  name: "coder-pro"
  status: "running"        # running/paused/stopped/error
  model: "anthropic/claude-sonnet-4"
  config:
    temperature: 0.7
    max_tokens: 4096
    system_prompt: |
      You are a senior developer...
  resources:
    cpu_percent: 23.5
    memory_mb: 512
    tokens_used: 128456
    uptime: "2h 34m 12s"
  channels:
    - name: "main"
      messages_count: 45
    - name: "debug"
      messages_count: 12
  actions: [start, stop, pause, configure, delete]
```

**Agent面板（展开后）：**
```

---

### 3.3 Visual Workflow Editor（可视化工作流引擎编辑器）

**功能清单：**
- 拖拽式节点编辑器（类似n8n/ComfyUI）
- 节点类型：输入/输出/处理/条件/循环/Agent调用/HTTP/代码执行
- 连线数据传递（带类型检查）
- 工作流导入/导出（JSON/YAML）
- 版本管理
- 实时调试/断点

**画布交互设计：**
```

**节点类型系统（可扩展）：**
```

---

### 3.4 Todo List & Kanban Todo看板管理器

**功能清单：**
- 待办事项 CRUD
- 看板视图（待办/进行中/已完成）
- 甘特图视图
- 优先级标签
- 子任务/依赖关系
- 与Agent工作流联动（Todo→自动Agent执行）

**数据模型：**
```yaml
task:
  id: "tsk-001"
  title: "实现用户认证接口"
  status: "in_progress"     # todo/in_progress/review/done
  priority: "high"          # low/medium/high/urgent
  assignee: "agent-coder-01"  # 可分配给Agent
  tags: ["backend", "auth", "security"]
  subtasks:
    - id: "sub-001"
      title: "JWT生成"
      done: true
    - id: "sub-002"
      title: "中间件实现"
      done: false
  dependencies: ["tsk-000"]
  due_date: "2026-06-10"
  estimated_hours: 4
  actual_hours: 2.5
  workflow_id: "wf-003"       # 关联工作流
```

---

### 3.5 Code Editor & Live Preview（代码编辑器 + 实时预览面板）

**功能清单：**
- 内嵌CodeMirror编辑器（语法高亮、自动补全）
- 多文件树导航
- 与Agent协作编码（Agent修改代码 → 实时预览更新）
- 终端集成
- 热重载/预览iframe
- 代码diff对比

**编辑面板布局：**
```

---

### 3.6 Build & Test Runner（编译 + 测试运行器）

**功能清单：**
- 自定义编译命令配置
- 一键构建/启动
- 测试用例执行 & 结果可视化
- 实时日志输出
- 构建历史 & 对比

**测试面板：**
```

---

### 3.7 Canvas & Design（画布 + 产品设计面板）

**功能清单：**
- 类Excalidraw的无限画布
- 形状工具（矩形/圆形/连线/箭头/便签）
- UI组件库（按钮/输入框/卡片/导航栏/模态框）
- 导出PNG/SVG
- AI辅助设计（用描述生成原型）
- Wireframe到代码生成

**画布面板：**
```

---

### 3.8 全局搜索 & 快捷栏

```

---

## 4. 技术栈选型

### 4.1 前端技术栈

| 组件 | 技术 | 理由 |
|------|------|------|
| 框架 | React 19 + TypeScript | 生态成熟、类型安全 |
| UI库 | shadcn/ui + Tailwind CSS | 设计系统、灵活 |
| 画布/工作流 | React Flow / @xyflow/react | 节点编辑、连线、拖拽 |
| 编辑器 | CodeMirror 6 | 语法高亮、自动补全、轻量 |
| 画布设计 | Excalidraw API / custom SVG | 原型设计、草图 |
| 状态管理 | Zustand | 轻量、React友好 |
| WebSocket | native ws + eventemitter3 | 实时通信 |
| 图表 | Recharts / D3 | 资源监控 |
| 拖拽 | dnd-kit | 面板布局拖拽 |
| HTTP | axios | API调用 |

### 4.2 后端技术栈

| 组件 | 技术 | 理由 |
|------|------|------|
| Web框架 | FastAPI (Python) | 高性能、异步、类型提示 |
| 异步任务 | Celery + Redis | 工作流执行、异步调度 |
| 消息总线 | Redis Pub/Sub | 低延迟、事件驱动 |
| 数据库 | SQLite (Django ORM) | 本地优先、零配置 |
| 文件存储 | LocalFS + watchfiles | 文件系统监听 |
| Agent框架 | LangChain / 自定义 | Agent编排 |
| 容器管理 | Docker SDK / podman | Agent隔离 |

### 4.3 基础设施

| 组件 | 方案 |
|------|------|
| 通信 | WebSocket (实时) + REST (配置) |
| 认证 | OAuth2 (local mode = tokenless) |
| 数据存储 | SQLite (元数据) + Redis (缓存/消息) |
| Agent运行 | Docker容器 / 独立进程 |
| 构建 | Vite (前端) |
| CI/CD | 本地git hooks（未来可加GitHub Actions） |

---

## 5. 项目目录结构

```

---

## 6. API Design

### 6.1 REST API（配置/管理）

```
# Agent管理
GET    /api/v1/agents              # 列出所有Agent
POST   /api/v1/agents              # 创建Agent
GET    /api/v1/agents/:id          # 获取Agent详情
PUT    /api/v1/agents/:id          # 更新Agent
DELETE /api/v1/agents/:id          # 删除Agent
POST   /api/v1/agents/:id/start    # 启动Agent
POST   /api/v1/agents/:id/stop     # 停止Agent
POST   /api/v1/agents/:id/pause    # 暂停/恢复

# 工作流
GET    /api/v1/workflows           # 列出工作流
POST   /api/v1/workflows           # 创建工作流
GET    /api/v1/workflows/:id       # 工作流详情
PUT    /api/v1/workflows/:id       # 更新工作流
DELETE /api/v1/workflows/:id       # 删除工作流
POST   /api/v1/workflows/:id/run   # 运行工作流
POST   /api/v1/workflows/:id/status# 工作流状态

# Todo
GET    /api/v1/tasks               # 列表Todo
POST   /api/v1/tasks               # 创建Todo
PUT    /api/v1/tasks/:id           # 更新Todo
DELETE /api/v1/tasks/:id           # 删除Todo
GET    /api/v1/tasks/:id/subtasks  # 子任务

# 代码
POST   /api/v1/code/execute        # 执行代码
GET    /api/v1/code/file/:path     # 获取文件内容
PUT    /api/v1/code/file/:path     # 保存文件
GET    /api/v1/code/files          # 文件列表
GET    /api/v1/code/open-files     # 打开的文件
GET    /api/v1/code/symbols        # 代码符号

# 测试
POST   /api/v1/tests/run           # 运行测试
GET    /api/v1/tests/results/:id   # 测试结果
GET    /api/v1/tests/history       # 测试历史

# 设计
POST   /api/v1/canvas/data         # 保存画布数据
GET    /api/v1/canvas/data/:id     # 获取画布数据
POST   /api/v1/design/from-text    # AI生成设计

# Setting
GET    /api/v1/settings            # 获取配置
PUT    /api/v1/settings            # 更新设置
```

### 6.2 WebSocket API（实时）

```
WS /ws/agents/:id/chat            # Agent实时对话
WS /ws/workflows/:id/stream        工作流实时执行日志
WS /ws/tasks/:id/progress         Todo进度实时更新
WS /ws/code/:id/diff              代码修改实时推送
WS /ws/terminal/:id/output       终端实时输出
WS /ws/build/:id/build            编译实时日志
WS /ws/canvas/:id/updates        画布协作更新
WS /ws/monitor/resources         资源使用实时监控
```

---

## 7. 分阶段实施计划

### Phase 0: 项目初始化 & 基础设施 (Week 1-2)
- [x] 项目结构设计
- [ ] 后端 FastAPI 框架搭建
- [ ] 前端 React + TypeScript 脚手架
- [ ] SQLite数据库模型定义
- [ ] 通信协议定义
- [ ] Docker部署配置

### Phase 1: Agent 核心功能 (Week 3-6)
- [ ] Agent Manager（创建/启动/停止/监控）
- [ ] Agent 配置管理（模型/参数/prompt）
- [ ] 多实例并行支持
- [ ] 实时状态监控
- [ ] 对话面板 & 消息历史

### Phase 2: Todo & 工作流引擎 (Week 7-10)
- [ ] Todo List CRUD
- [ ] Kanban看板视图
- [ ] 可视化工作流编辑器（拖拽节点）
- [ ] 工作流引擎 & 执行
- [ ] Agent调用节点

### Phase 3: 代码 & 测试 (Week 11-14)
- [ ] 代码编辑器集成
- [ ] 文件树 & 实时预览
- [ ] 终端集成
- [ ] 编译 & 测试运行器
- [ ] 实时日志

### Phase 4: 画布 & 产品设计 (Week 15-16)
- [ ] 基础画布（形状/连线）
- [ ] UI组件库
- [ ] AI辅助原型生成
- [ ] 导出功能（PNG/SVG/SVG）

### Phase 5: ✨ 体验打磨 & 整合 (Week 17-18)
- [ ] 全局搜索（Agent/文件/任务/工作流）
- [ ] 工作区布局自定义
- [ ] 主题系统（暗/亮/自定义）
- [ ] 快捷键系统
- [ ] 性能优化

### Phase 6: 扩展生态 (Week 19-20)
- [ ] 插件系统 & 节点库扩展
- [ ] Agent模板市场
- [ ] 团队协作（多用户）
- [ ] 云端备份
- [ ] GitHub集成

---

## 8. 交互设计系统

### 8.1 布局规范

- **最小化窗口**: 1200x800
- **间距**: 8px网格
- **圆角**: 8px / 12px
- **阴影**: elevation 1/2/3 三级

### 8.2 组件尺寸

| 元素 | 尺寸 |
|------|------|
| 按钮（默认） | 40px (min) |
| 输入框 | 36px 高度 |
| 面板标题栏 | 40px 高度 |
| 标签页高度 | 36px |
| 面板边框 | 1px solid 2px |
| 面板内边距 | 16px |
| 面板间间距 | 8px |

### 8.3 交互反馈

- 点击：微缩放动画 (0.95)
- 拖拽：半透明拖浮层 + 目标高亮
- 错误：红色抖动 + tooltip
- 加载：骨架屏 + spinner
- 成功：绿色脉冲 → 消失

---

## 9. 安全设计

| 层面 | 措施 |
|------|------|
| Agent | 每个Agent独立容器/进程 |
| 存储 | 本地优先，可选加密 |
| 网络 | 仅限 localhost，默认 127.0.0.1 |
| 文件 | 沙箱隔离，限制访问范围 |
| Key | 本地密钥环存储（keyring） |

---

## 10. 未来规划

| 阶段 | 功能 |
|------|------|
| 短期 (1个月) | 核心功能完整，本地可用 |
| 中期 (3个月) | 插件系统、模板市场 |
| 长期 (6个月) | 多用户协作、云端同步 移动端 app |
| 愿景 | 个人AI工作操作系统 |

---

*本文档由 Worker Agent 项目团队编写*
*如需修改或补充，请联系项目负责人*
