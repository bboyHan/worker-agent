# Worker Agent v4.0 执行摘要

## 核心宗旨
打造方便你自己的一站式工作平台。

## 核心设计要点

### 一、跨平台一键部署
- **目标平台**: Windows / macOS / Linux / Ubuntu / CentOS
- **部署方式**: Docker 一键部署 / 平台化安装
- **核心能力**: 在任何一台电脑上、几秒内跑起来

### 二、Agent 管理平台（不限 Hermes）
- **不局限于 Hermes**：兼容 Claude / DeepSeek / GPT / Ollama 等业界主流 Agent
- **统一管控**: 一个平台管理所有 Agent（状态/能力/模型）
- **Agent 生态**: 可扩展的 Agent 接入框架，未来支持更多平台

### 三、右侧 Chat 抽屉（核心 UI）
- 三态：5px折叠 → 380px小窗 → 50%全宽
- 拖拽边界实时调整比例

### 四、类 VSCode 分屏 + 标签页
- 最多 4 面板，拖拽边界/辅助线/标签页系统

### 五、远程控制
- 企微 / 飞书 / 微信远程对话分派 Agent 工作

### 六、Agent 运行监控
- 时间线 + 实时状态 + 资源卡片

---

## 六大核心板块
1. Agent 管理（全平台 Agent 接入）
2. 会话管理
3. 右侧 Chat 抽屉（核心 UI 组件）
4. 类 VSCode 分屏 + 标签页
5. 远程控制（企微/飞书/微信）
6. Agent 运行监控

## 跨平台部署
| 平台 | 部署方式 | 兼容性 |
|------|---------|--------|
| Windows | Docker / 脚本 | 100% |
| macOS | Docker / 脚本 | 100% |
| Linux/Ubuntu | Docker / 脚本 | 100% |
| CentOS | Docker | 100% |

## Agent 生态
- **默认**: Hermes Agent
- **扩展**: Claude / DeepSeek / GPT / Ollama / LangChain / AutoGPT 等
- **统一接口**: 标准化 Agent 接入协议

## Top 5 参考源
| 项目 | Stars | 参考 |
|------|------|------|
| Zed | 84k | 多面板分屏 |
| VS Code | 185k | 标签页系统 |
| Docker | 85k+ | 跨平台部署 |
| n8n | 85k | 远程工作流 |
| Raycast | 20k | 全局快捷键 |
