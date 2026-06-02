# Worker Agent — 功能模块核对清单（V2.0）

> 日期: 2026-06-02
> 约束条件确认:
> - 不需要在线文档/协作/白板
> - 小程序/App次要，先预留扩展性
> - IM=仅远程指令控制（类似微信操作QCLaw），非完整IM客户端
> - 平台范围相对全面（个人效率为核心）
> - 数据库需分析必要性

---

## 一、已设计且完善的功能 ✅

| # | 功能模块 | 文档 | 状态 | 待补 |
|---|---|--|--|
|1|任务看板|COMPLETE_UI_SPEC|设计完整(看板/Sprint/标签)|
|2|工作流画布|TECH_ARCHITECTURE|AntV X6选型|节点类型/连线规范|
|3|Agent控制台|FINAL_PRODUCT_DESIGN|12个专用Agent |Agent间通信协议|
|4|代码编辑器|TECH_ARCHITECTURE|Monaco选型|代码提示/语言包|
|5|AI辅助编程|TECH_ARCHITECTURE|Ollama选型|提示词系统/RAG|
|6|草图/原型|TECH_ARCHITECTURE|Tldraw选型|Agent集成方式|
|7|全局搜索|TECH_ARCHITECTURE|FlexSearch选型|搜索结果展示|
|8|服务器管理|FINAL_PRODUCT_DESIGN|概念层设计|分组/证书/批量操作|
|9|监控告警|FINAL_PRODUCT_DESIGN|概念层设计|指标/规则/渠道|
|10|部署管理|FINAL_PRODUCT_DESIGN|概念层设计|环境/历史/回滚|
|11|知识库|FINAL_PRODUCT_DESIGN|概念层设计|版本/权限/格式|
|12|文件管理|FINAL_PRODUCT_DESIGN|概念层设计|预览/分类/操作|
|13|IM指令控制|FINAL_PRODUCT_DESIGN |概念层设计 |适配器/权限|
|14|多端适配|FINAL_PRODUCT_DESIGN |概念层设计 |各端功能差异|
|15|日历/邮件|FINAL_PRODUCT_DESIGN|降级为预留|接口设计|

---

## 二、已明确排除的功能

| 功能 | 原状态 | 现状态 | 原因 |
|---|---|--|
| 在线文档/协作 | 概念层 | ❌ 清除 |
| 白板/头脑风暴 | 概念层 | ❌ 清除 |
| 邮件客户端 | 概念层 | ❌ 清除 |
| 任务看板Sprint | 功能层 | ❌ 降级(可选非必需)|
| 小程序 | 核心平台 | ⚠️ 降级(预留扩展)|
| App独立版 | 核心平台 | ⚠️ 降级(预留扩展)|

---

## 三、从CSV推荐中选出的最优解（已更新到TECH_ARCHITECTURE.md）

| CSV推荐方案 | 我们最优解 | 选型理由 |
|---|--|
| **LangFlow/Semantic Kernel(独立SaaS)** | AntV X6嵌入式画布 | 轻量嵌入，按需定制 |
| **Continue.dev/CoW/Codeium(IDE编码辅助)** | Ollama直接API调用 | 已有，不需新引入 |
| **LangGraph/PureLang(Agent编排框架)** | MCP协议层+渐进引入 | 降低复杂度 |
| **Plane 2.0/Linear/API** | Tiptap+dnd-kit自研 | 轻量可控 |
| **Flowise.ai/ragflow/Chatchat** | Tldraw 2.0+直接嵌入 | React SDK嵌入最优 |
| **Wox 2.0/Everything/Spotlight** | FlexSearch平台内 | 仅平台内维度 |

---

## 四、功能核对与缺失清单

| # | 功能 | 优先级 | 阶段 | 说明 | 数据库依赖 |
|---|------|------|--|--|--|
| N1 | TODO列表 | 高 | ✅ 设计完成 | FEATURE_1_TODO_LIST.md | ❌ |
| N2 | 内置终端/Shell | 高 | ✅ 设计完成 | FEATURE_2_TERMINAL.md | ❌ |
| N3 | Git集成 | 高 | ✅ 设计完成 | FEATURE_3_GIT_INTEGRATION.md | ❌ |
| N4 | 配置管理 | 高 | ✅ 设计完成 | FEATURE_4_CONFIGURATION.md | ❌ |
| N5 | 安全/加密 | 高 | ✅ 设计完成 | FEATURE_5_SECURITY.md | ✅ |
| N6 | 数据备份 | 高 | ✅ 设计完成 | FEATURE_6_BACKUP.md | ❌ |
| N7 | 多仓库管理 | 中 | ✅ 设计完成 | FEATURE_7_MULTI_REPO.md | ❌ |
| N8 | API调试 | 中 | 设计中 | JSON | ❌ |
| N9 | 容器管理 | 中 | 设计中 | JSON | ❌ |
| N10 | 日志管理 | 中 | 设计中 | JSON | ✅ |
| N11 | 告警规则 | 中 | 设计中 | JSON | ✅ |
| N12 | 通知渠道 | 中 | 设计中 | JSON | ❌ |
| N13 | 容器监控 | 低 | 设计中 | JSON | ❌ |
| N14 | 代码库管理 | 低 | 设计中 | JSON | ❌ |
| N15 | 网络管理 | 低 | 设计中 | JSON | ❌ |
| N16 | 用户管理 | 中(可跳过) | 设计中 | JSON | ✅ |

---

## 五、第二批功能 ✅ 已完成设计（N14补充）

| # | 功能 | 设计文档 | 核心内容 |
|---|------|---------|--|
| N1 | TODO列表 | FEATURE_1_TODO_LIST.md | 列表/分类/标签/提醒/优先级 |
| N2 | 内置终端/Shell | FEATURE_2_TERMINAL.md | xterm.js+SSH/多会话/Tab/命令补全 |
| N3 | Git集成 | FEATURE_3_GIT_INTEGRATION.md | 提交/分支/PR/Diff/Merge/自动安装 |
| N4 | 配置管理 | FEATURE_4_CONFIGURATION.md | 主题/快捷键/编辑器/terminal/AI设置 |
| N5 | 安全/加密 | FEATURE_5_SECURITY_ENCRYPTION.md | AES-256-GCM/SSH加密存储/凭证管理 |
| N6 | 数据备份 | FEATURE_6_BACKUP.md | 本地/远程/自动备份策略 |
| N7 | 多仓库管理 | FEATURE_7_MULTI_REPO.md | 发现/列表/同步/快速切换 |
| N8 | API调试 | FEATURE_8_API_DEBUGGER.md | 请求历史/变量/Collection/表单构建 |
| N9 | 容器管理 | FEATURE_9_CONTAINER_MANAGER.md | 容器/镜像/网络/卷/lcompose日志/执行 |
| N10 | 日志管理 | FEATURE_10_LOG_MANAGER.md | 多源实时流/过滤/级别/聚合搜索 |
| N11 | 告警规则 | FEATURE_11_ALERT_MANAGER.md | 阈值/模式/频率/抑制/测试 |
| N12 | 通知渠道 | FEATURE_12_NOTIFICATION_CHANNELS.md | Telegram/Slack/邮件/Webhook/路由器 |
| N13 | 容器监控 | FEATURE_13_CONTAINER_MONITOR.md | CPU/内存/网络/历史图表/阈值 |
| N14 | 代码库管理 | FEATURE_14_CODE_LIB.md | 代码片段/模板/搜索/插入/统计 |
| N15 | 网络管理 | FEATURE_15_NETWORK_MANAGER.md | 端口/DNS/连通性/转发/拓扑/带宽 |
| N16 | 用户管理 | FEATURE_16_USER_MANAGEMENT.md | RBAC/API密钥/会话/审计日志 |

> **第二批设计已完成。下一步：实现核心平台骨架 + 逐步实现第一批功能。**

---

## 六、数据库必要性分析

### 5.1 各场景数据量估算

| 场景 | 数据量|查询复杂度|更新频率 |纯文件方案 | SQLite必要性 | 结论 |
|------|--|----|
| 配置 | <10KB | ❌ | ✅ JSON | ❌ | 无需 |
| 任务看板 | 100-500条 | 低 | 中 | ✅ JSON | ❌ | 无需 |
| 知识库 | <1000篇 | 低 | 低 | ✅ Markdown | ❌ | 无需 |
| 文件索引 | <10MB | 中 | 中 | ✅ FlexSearch | ❌ |
| SSH密钥 | <20条 | 低 | 低 | ❌ 明文不安全 | ⚠️ 需加密 |
| IM凭证 | <10条 | 中 | 中 | ❌ 明文不安全 | ⚠️ 需加密 |
| 服务器配置 | 5-50条 | 中 | 低 | ✅ JSON | ❌ |
| 告警历史 | 持续 | 高 | 高 | ❌ 大 | ❌ |
| Agent状态 | 12个 | 高 | ❌ | 无需 |
| 任务日志 | 持续 | 高 | 中 | ❌ JSON | ⚠️ 慢 |

### 5.2 纯文件 vs SQLite对比

| 维度 | ⚪ Pure files(JSON+FS) | SQLite | 优劣 |
|---|---|------|
| 安装依赖 | ✅ 无需 | ❌ Better-SQLite3 | 🔴纯文件胜 |
| 包体积 | ✅ ~0KB额外 | ⚠️ +2-3MB | 🔴纯文件胜|
| 复杂度 | ✅ 无需 | ❌ 迁移 | 🔴 纯文胜|
| 连接池 | ✅ 无需 | ❌ 需管理 | 🔴纯文件胜 |
| 用户可编辑 | ✅ 直接打开JSON | ❌ 需工具 | 🟢SQL |
| 版本控制 | ✅ git diff友好 | ⚠️ 二进制 |
| bug概率 | ✅极低 | ⚠️ 有版本/权限风险 | 🟢纯文件胜 |
| 查询性能 | ✅ 小数据量够快 | ✅ 大数据量快 | ⚪ |
| 并发安全 | ✅ 无并发问题(单用户) | ✅ 原生 | ⚪ |
| 安全加密 | ✅ 简单加密 | ✅ 成熟方案 | ⚪ |
| bug概率 | ✅极低 | ⚠️ 有版本/权限风险 | 🟢纯文件胜 |

### 5.3 结论：不需要引入数据库

**全部数据总量预计 < 3MB，单表/单文件 < 1000条。纯文件方案完全可行且更简单。**

**理由：**
1. **数据量不在量级上** — SQLite的优势(百万/千万条数据、复杂JOIN)在本平台毫无用武之地
2. **所有场景都有纯文件方案** — config.json(配置)、tasks.json(任务看板)、snippets.json(代码片段)、keys/** (SSH密钥加密)、servers.json(服务器配置)、knowledge/**(知识库Markdown)等
3. **纯文件方案优势明显** — 零依赖/零部署/无需迁移脚本/用户可直接打开文件查看编辑/版本控制友好
4. **SQLite带来的额外成本远超其收益** — Better-SQLite3依赖+迁移脚本+连接池+版本风险+打包体积

### 5.4 结论

**不需要引入数据库。** 平台基于纯文件方案完全可以流畅运行。

如果未来真的需要(如数据量>10万条记录)，再引入SQLite的成本也远比现在引入的试错成本低。

---

---

## 六、设计完成汇总

### 第一批功能 ✅ 已完成设计

| # | 功能 | 设计文档 | 核心内容 |
|---|---|--|--|
| N1 | TODO列表 | FEATURE_1_TODO_LIST.md | 列表/分类/标签/提醒/优先级 |
| N2 | 内置终端/Shell | FEATURE_2_TERMINAL.md | xterm.js+SSH/多会话/Tab/命令补全 |
| N3 | Git集成 | FEATURE_3_GIT_INTEGRATION.md | 提交/分支/PR/Diff/Merge/自动安装 |
| N4 | 配置管理 | FEATURE_4_CONFIGURATION.md | 主题/快捷键/编辑器/terminal/AI设置 |
| N5 | 安全/加密 | FEATURE_5_SECURITY.md | AES-256-GCM/SSH加密存储/凭证管理 |
| N6 | 数据备份 | FEATURE_6_BACKUP.md | 本地/远程/自动备份策略 |
| N7 | 多仓库管理 | FEATURE_7_MULTI_REPO.md | 发现/列表/同步/快速切换 |

> **第一批已设计 + 核心流程 + V2已废弃。下一步：实现核心平台骨架 + 逐步实现第一批功能。**

---

## 六、核心流程设计 ✅ 新增完成

### 6.1 Core System Flow (完整状态机)

文档: `CORE_SYSTEM_FLOW.md`

| 阶段 | 状态机 | 输出 | Agent |
|------|--|--|--|
| 0. Intent 解析 | parseIntent | project.json (intent部分) | Scheduler+LLM |
| 1. 脚手架 | scaffoldProject | 目录结构/依赖/基础文件 | 手动 |
| 2. 设计阶段 | runDesignPhase | design_tokens.json/global.css | Designer |
| 3. 代码生成 | runCodePhase | 组件代码/样式/tailwind.config | Code Agent |
| 4. 代码审查 | reviewDiff | Git Diff/Visual Lock检查 | Visual Lock Checker |
| 5. 预览启动 | startPreview | dev server/HMR/浏览器自动打开 | Preview Agent |
| 6. 迭代循环 | iterate | 用户修改→令牌更新→代码刷新 | 循环 |
| 7. 部署交付 | deploy | Dockerfile/Vercel deploy/URL | Deploy Agent |

核心数据: `project.json` (Manifest) — 所有Agent共享的事实源。

### 6.2 Visual Lock 实现方案

文档: `VISUAL_LOCK_IMPL.md`

| 环节 | 方案 |
|------|--|
| Token存储 | JSON (fact source) |
| CSS输出 | CSS变量 (--xxx) |
| Checker引擎 | CSS parser + Regex |
| 颜色比对 | 容差算法 (delta E) |
| 自动修复 | 硬编码→var()自动替换 |
| Override | 局部unlock+临时 |

### 6.3 Preview 渲染机制

文档: `PREVIEW_RENDER_MECHANISM.md`

| 方案 | 说明 | 推荐 |
|------|--|--|
| A: 浏览器预览 | dev server → 自动开浏览器 → HMR | ⭐⭐⭐⭐⭐ |
| B: 终端内预览 | Ink.js + html-to-text ASCII渲染 | ⭐⭐⭐ |
| C: ASCII Quick Preview | 字符串/Unicode字符渲染 | ⭐⭐ |

### 6.4 Agent间通信协议

文档: `AGENT_COMM_PROTOCOL.md`

| 协议 | 用途 | 频率 |
|------|--|--|
| WebSocket | Agent↔Scheduler状态推送 | 每2秒推送 |
| MCP | Scheduler→Agent任务分发 | 事件驱动 |
| 文件系统 | Agent→Agent数据传递 | project.json |

---

## 七、数据库必要性分析
