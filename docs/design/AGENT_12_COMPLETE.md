

# 12-Agent 系统完整设计

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. Agent 系统总览

```
                        ┌──────────────┐
                        │  Scheduler   │
                        │  Agent #1    │
                        └──┬───┬───┬──┘
                           │   │   │
                    ┌──────┐  │   │
                    │Dispatch│ │  │
                    └──┬───┘  │  │
                       │      │   │
              ┌────────┘  ┌──┘   │
              │           │       │
        ┌─────┘    ┌────┘  ┌───┘
        ▼          ▼       ▼
   ┌────┐   ┌────┐   ┌────┐
   │ #2 │   │ #3 │   │ #4 │
   │Desk│   │Code│   │Test│
   └──┬─┘   └──┬─┘   └──┬─┘
      │        │        │
      │   ┌────┴─┐   ┌──┴──┐
      │   │#5    │   │#6   │
      │   │Deploy│   │Sec  │
      │   └──────┘   └─────┘
      │
      │ (其余7个由Scheduler按需创建)
      │
      ▼
┌──────┐ ┌──────┐ ┌──────┐
│ #7  │ │ #8  │ │ #9  │
│Arch │ │UI   │ │Data │
└┬─────┘ └┬─────┘ └┬─────┘
 │        │        │
 ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐
│#10   │ │#11   │ │#12   │
│Build │ │Monit │ │Deploy│
└──────┘ └──────┘ └──────┘
```

## 2. Agent 12 个完整清单

### Agent #1: Scheduler (调度器)

| 属性 | 描述 |
|------|------|
| **名称** | Agent Scheduler / Orchestrator |
| **职责** | 整个平台的总指挥官，负责任务分解、分发、调度、错误处理 |
| **MCP资源** | scheduler.analyze_intent, scheduler.create_manifest, scheduler.dispatch_task, scheduler.monitor_progress, scheduler.resolve_error |
| **启动时机** | 用户输入任何指令时自动启动 |
| **关键算法** | intent parser (LLM), task dependency graph |
| **数据依赖** | project.json (读写), manifest (读) |
| **状态** | active / idle / error |
| **超时** | 无 (持续监听用户输入) |

### Agent #2: Designer (设计器)

| 属性 | 描述 |
|------|------|
| **名称** | Visual Designer Agent |
| **职责** | 1. 根据需求/design tokens生成设计系统 2. 创建design token manifest 3. 生成CSS/样式 4. Visual Lock enforcement |
| **MCP资源** | designer.create_tokens, designer.apply_tokens, designer.check_visual_lock, designer.export_design_system |
| **启动时机** | 需求确认后立即启动 |
| **关键算法** | token-to-CSS compiler, visual lock checker (delta E color comparison) |
| **输出** | design_tokens.json, design-tokens.css, tailwind.config 样式扩展 |
| **输入** | 用户需求描述、项目规范、design tokens |
| **状态** | idling / generating / reviewing / complete |
| **超时** | 5 min |

### Agent #3: Code Agent (代码生成器)

| 属性 | 描述 |
|------|------|
| **名称** | Code Builder Agent |
| **职责** | 1. 根据design tokens + 需求生成代码 2. Visual Lock遵守 3. 代码自验 (lint/typecheck) |
| **MCP资源** | code.generate_code, code.read_file, code.write_file, code.search_code, code.run_lint, code.run_tsc |
| **启动时机** | design_complete 后自动启动 |
| **关键算法** | 模板填充 (根据design tokens), code generation (LLM), lint/typecheck |
| **输出** | 完整的项目代码 |
| **输入** | design_tokens.json, requirements |
| **状态** | idling / generating / reviewing / complete |
| **超时** | 10 min |

### Agent #4: Test Agent (测试验证器)

| 属性 | 描述 |
|------|------|
| **名称** | Test Inspector Agent |
| **职责** | 1. 生成测试用例 2. 运行已有测试 3. 生成测试覆盖率报告 4. 代码review |
| **MCP资源** | test.generate_tests, test.run_tests, code_review.review |
| **启动时机** | code_complete 后自动启动 |
| **关键算法** | test case generation (LLM), coverage report parsing |
| **输出** | test results, code review report |
| **输入** | 项目代码 |
| **状态** | idling / testing / complete |
| **超时** | 3 min |

### Agent #5: Deploy Agent (部署器)

| 属性 | 描述 |
|------|------|
| **名称** | Deployment Agent |
| **职责** | 1. 生成Dockerfile/docker-compose 2. 推送部署到平台 3. 健康检查 |
| **MCP资源** | deploy.create_dockerfile, deploy.push_to_platform, deploy.health_check, deploy.rollback |
| **启动时机** | 用户触发"deploy"或测试通过后自动部署 |
| **关键算法** | docker image build, health check verification |
| **输出** | running service URL, deployment logs |
| **输入** | 完整的代码库 |
| **状态** | idling / building / testing / deploying / complete |
| **超时** | 15 min |

### Agent #6: Security Agent (安全检查器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | Security Inspector Agent |
| **职责** | 1. 扫描代码安全漏洞 (硬编码密码/SPI/SQL注入/XSS) 2. 检查密钥管理 3. 验证加密配置 4. 安全审计报告 |
| **MCP资源** | security.scan_code, security.check_env, security.audit_access, security.review_encryption |
| **启动时机** | code_complete 后并行启动 (与Test Agent同时) |
| **关键算法** | AST扫描、硬编码检测 (正则+语义分析)、加密配置验证 |
| **输出** | security-audit.md (漏洞报告), recommendations |
| **输入** | 生成代码 + 配置 |
| **状态** | idling / scanning / complete |
| **超时** | 5 min |

### Agent #7: Architecture Agent (架构设计器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | Architecture Design Agent |
| **职责** | 1. 根据需求选择技术栈 2. 生成架构图 (Mermaid/PlantUML) 3. 技术选型建议 4. 架构一致性检查 |
| **MCP资源** | architecture.analyze_project, architecture.recommend_stack, architecture.generate_diagram, architecture.validate_consistency |
| **启动时机** | user_intent 解析后立即启动 (与Scheduler并行) |
| **关键算法** | 技术栈推荐(基于项目类型), architecture validation (对比设计文档) |
| **输出** | architecture-recommendation.md, diagrams/|
| **输入** | 用户需求、现有代码库 |
| **状态** | idling / analyzing / complete |
| **超时** | 3 min |

### Agent #8: UI Agent (UI组件生成器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | UI Component Agent |
| **职责** | 1. 根据design tokens生成UI组件 2. 维护design system组件库 3. 组件文档生成 4. 组件可视化预览 |
| **MCP资源** | ui.generate_component, ui.create_component_library, ui.preview_component, ui.update_component |
| **启动时机** | design_tokens生成后立即启动 |
| **关键算法** | token → component compiler, component preview rendering |
| **输出** | components/*.tsx, design-system-doc.md |
| **输入** | design_tokens.json, 用户需求 |
| **状态** | idling / generating / complete |
| **超时** | 5 min |

### Agent #9: Data Migration Agent (数据迁移器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | Data Migration Agent |
| **职责** | 1. 数据格式转换/迁移 2. 配置升级 3. 数据备份/恢复 |
| **MCP资源** | data.migrate_format, data.backup_config, data.restore_config, data.validate_migration |
| **启动时机** | 配置版本变更/数据格式变更时 |
| **关键算法** | data format converter (JSON → MD/CSV/TXT), backup/restore |
| **输出** | 迁移后的数据文件 |
| **输入** | 源数据文件 + 目标格式 |
| **状态** | idling / migrating / complete |
| **超时** | 2 min |

### Agent #10: Build Agent (构建器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | Build & Optimization Agent |
| **职责** | 1. 代码构建优化 2. 依赖分析 3. Bundle优化 4. 性能分析 |
| **MCP资源** | build.optimize, build.analyze_deps, build.bundle_analysis, build.performance_check |
| **启动时机** | 生产构建时 (deploy前的build阶段) |
| **关键算法** | bundle analyzer, dependency tree analysis, build optimization |
| **输出** | optimized build + build report |
| **输入** | 代码库 |
| **状态** | idling / building / optimizing / complete |
| **超时** | 10 min |

### Agent #11: Monitor Agent (监控器) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | System Monitor Agent |
| **职责** | 1. 实时监控服务健康 2. 性能指标收集 3. 自动告警 4. 资源使用分析 |
| **MCP资源** | monitor.collect_metrics, monitor.analyze_health, monitor.trigger_alert, monitor.generate_report |
| **启动时机** | 服务部署后自动启动，周期性运行 |
| **关键算法** | metrics aggregation (CPU/MRAM/DISK/BW), health check (HTTP ping), anomaly detection (简单的阈值) |
| **输出** | health report, alert notifications |
| **输入** | 部署的服务URL + 系统指标 |
| **状态** | idling / monitoring / alerting / complete |
| **超时** | 持续运行 (每30s检查一次) |

### Agent #12: Assistant Agent (日常助手) - 新增

| 属性 | 描述 |
|------|------|
| **名称** | General Assistant Agent |
| **职责** | 1. 回答一般问题 2. 知识检索 3. 文件搜索/查找 4. 文件搜索/查找|
| **MCP资源** | assistant.answer_question, assistant.search_files, assistant.read_doc, assistant.learn_from_docs |
| **启动时机** | 用户输入"/ask"或自然语言问题时 |
| **关键算法** | intent classification (区分是设计/代码/构建/部署/还是知识查询) |
| **输出** | 文本回答 |
| **输入** | 用户问题 + 当前项目上下文 |
| **状态** | idling / processing / complete |
| **超时** | 1 min |

## 3. Agent 优先级与执行顺序

```
Phase 1 (并行启动):
  Scheduler #1 ──▶ 解析intent
  Architecture #7 ──▶ 推荐技术栈 (与Scheduler并行)

Phase 2 (依赖Phase 1完成):
  Designer #2 ──▶ 生成tokens
  UI #8 ──▶ 生成UI组件 (依赖tokens)

Phase 3 (依赖Phase 2):
  Code #3 ──▶ 生成代码 (依赖tokens + UI组件)

Phase 4 (并行):
  Test #4 ──── 运行测试
  Security #6 ── 安全检查

Phase 5 (依赖Phase 4):
  Build #10 ── 构建优化

Phase 6 (Phase 5完成):
  Deploy #5 ── 部署服务

Phase 7 (Phase 6完成):
  Monitor #11 ── 启动监控

Phase 8 (持续):
  Assistant #12 ── 日常助手 (始终可触发)
```

## 4. Agent 通信矩阵

| Agent | Designer | Code | Test | Deploy | Security | Architecture | UI | Data | Build | Monitor | Assistant |
|-------|--|------|------|--------|---------|------------|--|------|------|-------|--------|--------|
| Scheduler | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Designer | --- | tokens | - | - | - | - | - | - | - | - | - |
| Code | token input | --- | source | - | source | - | component | source | source | - | - |
| Test | - | test source | --- | - | - | - | - | - | - | - | - |
| Deploy | - | source | test report | --- | - | - | - | - | build | - | - |
| Security | - | source | - | - | --- | - | - | - | - | - | - |
| Architecture | - | - | - | - | - | --- | - | - | - | - | - |
| UI | token input | component | - | - | - | - | --- | - | - | - | - |
| Data | - | - | - | - | - | - | - | --- | - | - | - |
| Build | - | source | - | - | - | - | - | - | --- | - | - |
| Monitor | - | - | - | service | - | - | - | - | - | --- | - |
| Assistant | - | - | - | - | - | - | - | - | - | - | --- |
