# 核心流程设计 — Design → Code → Preview → Deploy

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 整体状态机

```
用户输入 ("Make a todo app")

[INPUT] ──▶ [PARSING] ──▶ [INTENT_CONFIRMED] ──▶ [PLAN_GENERATED]
                                    │                      │
                                    ▼                      ▼
                            (用户编辑)              [PLAN_CONFIRMED]
                                                     │
                                                     ▼
                                              [PHASE_1: DESIG