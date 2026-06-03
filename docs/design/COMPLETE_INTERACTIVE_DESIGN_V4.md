# Worker Agent v4.0 — 交互开发规格书

## 一、跨平台部署（新增！）

### 1.1 目标平台

| 平台 | 部署方式 | 说明 |
|------|------|------|
| Windows | Docker Desktop + .bat | 双击一键安装 |
| macOS | Docker Desktop + .sh | 一行命令安装 |
| Linux/Ubuntu | Docker + .sh | 一行命令安装 |
| CentOS/RHEL | Docker | 一行命令安装 |
| 无 Docker | Python + Node.js | 纯离线安装 |

### 1.2 部署架构

```
┌──────┐ ┌─────────┐ ┌────────┐ ┌────────┐
│Windows│ │ macOS   │ │ Linux  │ │ WSL    │
│ Docker│ │ Docker  │ │ Docker │ │ Docker │
└───────┘ └────────┘ └────────┘ └────────┘
         │
    ┌────▼────┐
    │ Worker    │
    │ Agent v4  │
    │ container │
    └────┬────┘
         │
    ┌────▼───────┐
    │ PostgreSQL  │
    │  Redis      │
    └──────┬─────┘
         │
    ┌────▼────────────┐
    │ Agent Adapter   │
    │ (标准化协议)     │
    └──────┬──────────┘
         │
    ┌────▼─────┐ ┌───────┐ ┌─────┐
    │ Hermes   │ │ Claude│ │ GPT │
    └──────────┘ └───────┘ └─────┘
```

### 1.3 Docker 部署脚本

```dockerfile
# Dockerfile
FROM python:3.11-slim
ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt-get update && apt-get install -y \
    curl git jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# 安装 Node.js 依赖
RUN npm ci --production

# 暴露端口
EXPOSE 3000

# 启动
CMD ["node", "server.js"]
```

```bash
# deploy.sh (Linux/macOS)
#!/bin/bash
# Worker Agent v4.0 - 跨平台一键部署脚本

set -e
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
echo "🚀 Worker Agent v4.0 安装器"
echo "📋 检测平台: $PLATFORM"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 拉取镜像
echo "📥 拉取镜像..."
docker pull ghcr.io/worker-agent/core:latest

# 启动容器
echo "▶️  启动 Worker Agent..."
docker run -d \
    --name worker-agent \
    --restart unless-stopped \
    -p 3000:3000 \
    -v ${PWD}/data:/app/data \
    ghcr.io/worker-agent/core:latest

echo "✅ Worker Agent v4.0 安装完成！"
echo "🌐 打开 http://localhost:3000 开始使用"
echo "📱 移动端也可访问 (支持响应式)"
```

```batch
# deploy.bat (Windows)
@echo off
chcp 65001 >nul
echo 🚀 Worker Agent v4.0 安装器

:: 检查 Docker
WHERE docker >nul 2>nul || (
    echo ❌ Docker 未安装，请先安装 Docker Desktop
    pause
    exit /b 1
)

echo 📥 拉取镜像...
docker pull ghcr.io/worker-agent/core:latest

echo ▶️  启动 Worker Agent...
docker run -d --name worker-agent --restart unless-stopped -p 3000:3000 -v %CD%\data:/app/data ghcr.io/worker-agent/core:latest

echo ✅ Worker Agent v4.0 安装完成！
echo 🌐 打开 http://localhost:3000 开始使用
pause
```

---

## 二、Agent Adapter 架构（新增！）

### 2.1 标准化 Agent 接入协议

```typescript
// AgentAdapter 接口定义
interface AgentAdapter {
    platform: 'hermes' | 'claude' | 'deepseek' | 'gpt' | 'ollama' | 'custom';
    config: AgentConfig;
    
    // 统一消息接口
    sendMessage(sessionId: string, message: Message): Promise<Response>;
    
    // 统一状态接口
    getStatus(sessionId: string): Promise<AgentStatus>;
    
    // 统一资源接口
    getResources(sessionId: string): Promise<Resources>;
    
    // 兼容平台特定功能
    extend(options?: AdapterOptions): Promise<void>;
}

interface AgentConfig {
    platform: string;
    endpoint: string;
    model: string;
    temperature: number;
    maxTokens: number;
    apiKey?: string;
    [key: string]: any;
}

interface AgentStatus {
    status: 'running' | 'idle' | 'offline' | 'error';
    progress: number;  // 0.0-1.0
    platform: string;  // 来源平台
    platformLogo?: string;
}

interface Resources {
    cpu: number;
    memory: number;
    diskIO: number;
    platform: string;
}

interface Message {
    role: 'user' | 'assistant' | 'system';
    content: string;
    files?: File[];
    tools?: ToolCall[];
}

interface Response {
    content: string;
    thought?: string;
    tools?: ToolResult[];
    usage?: Usage;
}
```

### 2.2 各平台适配器

#### Hermes 适配器
```python
class HermesAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'hermes'
        self.endpoint = config['endpoint']
        self.api_key = config.get('api_key')
    
    async def send_message(self, session_id, message):
        # 调用 Hermes API
        payload = {
            "session_id": session_id,
            "message": message["content"],
            "model": self.config["model"]
        }
        response = await self.http.post(f"{self.endpoint}/chat", json=payload)
        return Response(
            content=response["message"],
            platform="hermes"
        )
```

#### Claude 适配器
```python
class ClaudeAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'claude'
        self.client = Anthropic(api_key=config["api_key"])
    
    async def send_message(self, session_id, message):
        response = await self.client.messages.create(
            model=self.config["model"],
            messages=[{"role": m["role"], "content": m["content"]} for m in message],
            max_tokens=self.config["max_tokens"],
            temperature=self.config["temperature"]
        )
        return Response(
            content=response.content[0].text,
            platform="claude"
        )
```

#### DeepSeek 适配器
```python
class DeepSeekAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'deepseek'
        self.client = OpenAI(
            api_key=config["api_key"],
            base_url=config["endpoint"]
        )
    
    async def send_message(self, session_id, message):
        response = await self.client.chat.completions.create(
            model=self.config["model"],
            messages=message,
            max_tokens=self.config["max_tokens"],
            temperature=self.config["temperature"]
        )
        return Response(
            content=response.choices[0].message.content,
            platform="deepseek"
        )
```

#### Ollama 适配器
```python
class OllamaAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'ollama'
        self.endpoint = config["endpoint"]
    
    async def send_message(self, session_id, message):
        # 调用本地 Ollama API
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.endpoint}/api/chat",
                json={
                    "model": self.config["model"],
                    "messages": message,
                    "stream": False
                }
            )
        return Response(
            content=response.json()["message"]["content"],
            platform="ollama"
        )
```

#### GPT 适配器
```python
class GPTAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'gpt'
        self.client = OpenAI(api_key=config["api_key"])
    
    async def send_message(self, session_id, message):
        response = await self.client.chat.completions.create(
            model=self.config["model"],
            messages=message,
            max_tokens=self.config["max_tokens"],
            temperature=self.config["temperature"]
        )
        return Response(
            content=response.choices[0].message.content,
            platform="openai"
        )
```

### 2.3 统一 Agent Factory

```python
class AgentFactory:
    """Agent 适配器工厂"""
    _adapters = {
        'hermes': HermesAdapter,
        'claude': ClaudeAdapter,
        'deepseek': DeepSeekAdapter,
        'gpt': GPTAdapter,
        'ollama': OllamaAdapter,
    }
    
    @staticmethod
    def create(platform: str, config: dict) -> AgentAdapter:
        if platform not in AgentFactory._adapters:
            raise ValueError(f"Unsupported platform: {platform}")
        
        adapter_class = AgentFactory._adapters[platform]
        return adapter_class(config)
    
    @staticmethod
    def register(name: str, adapter_class: type):
        """注册自定义适配器"""
        AgentFactory._adapters[name] = adapter_class
    
    @staticmethod
    def list_platforms():
        return list(AgentFactory._adapters.keys())
```

---

## 三、Chat 右侧抽屉（核心 UI）

### 3.1 三态设计

| 状态 | 宽度 | 触发 |
|------|------|------|
| 折叠态 | 5px | 点击边缘、⌘ShiftK |
| 小窗态 | 380px | 双击边缘、拖动5px到200-800 |
| 全宽态 | 50% | 拖拽右侧边界 |

### 3.2 折叠态（5px）
```css
.chat-drawer.state-folded {
  width: 5px;
  cursor: col-resize;
  border-left: 1px solid var(--brd);
  transition: width .3s cubic-bezier(0.4,0,0.2,1);
}
```

### 3.3 可拖拽边界
```css
.chat-resize-handle {
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 6px;
  cursor: col-resize;
  border-left: 2px solid transparent;
  transition: all .15s;
}
.chat-resize-handle:hover, .dragging {
  border-left-color: var(--ac);
  background: rgba(124,58,237,.08);
}
```

### 3.4 事件绑定
- `pointerdown on 5px handle` → 展开为小窗态
- `pointerdown on resize handle` → 拖拽调整宽度
- `pointermove` → 实时更新宽度（200px - 800px）
- `pointerup` → 提交新的宽度

---

## 四、类 VS Code 分屏系统

### 4.1 面板布局
最多 4 面板：
```
┌──────┬──────┐  ← 上下分屏
│ Panel│ Panel│
│  1   │  2   │  ← 左右分屏
│      │      │
├──────┼──────┤
│ Panel│ Panel│
│  3   │  4   │
└──────┴──────┘
```

### 4.2 拖拽边界处理
```javascript
let isSplitting = false;
const handle = document.getElementById('split-handle');

// pointerdown on split handle
handle.addEventListener('pointerdown', e => {
  isSplitting = true;
  handle.classList.add('dragging');
  e.preventDefault();
});

// pointermove on document
document.addEventListener('pointermove', e => {
  if (!isSplitting) return;
  const container = document.getElementById('split-container');
  const left = document.getElementById('left-pane');
  const right = document.getElementById('right-pane');
  const rect = container.getBoundingClientRect();
  const ratio = (e.clientX - rect.left) / rect.width;
  const clamped = Math.max(0.15, Math.min(0.85, ratio));
  
  left.style.flex = `0 0 ${clamped * rect.width}px`;
  right.style.flex = `0 0 ${(1-clamped) * rect.width}px`;
});

// pointerup on document
document.addEventListener('pointerup', () => {
  if (isSplitting) {
    isSplitting = false;
    handle.classList.remove('dragging');
  }
});
```

### 4.3 辅助线 (Snap Guides)
```css
.snap-guide {
  position: absolute;
  background: var(--ac);
  pointer-events: none;
  z-index: 100;
}
.snap-guide.vertical {
  width: 2px;
  top: 0; bottom: 0;
}
.snap-guide.horizontal {
  height: 2px;
  left: 0; right: 0;
}
```

---

## 五、标签页系统

### 5.1 标签页结构
```
┌───────┬──────┬──────┐
│ Tab1  │ Tab2 │ Tab3 │ x
├─┴──────┴──────┴──────┤
│ Panel Content         │
└───────────────────────┘
```

### 5.2 标签页交互
```javascript
// 拖拽标签页到另一个面板
dragTabToPanel(tabEl, targetPanel) {
  // 1. 从当前面板移除
  targetPanel.appendChild(tabEl)
  
  // 2. 如果当前面板无标签页，自动折叠
  if (!tabEl.parentElement.children.length) {
    tabEl.parentElement.style.display = 'none'
  }
}

// 右键菜单
showTabContextMenu(x, y, tabEl) {
  const menu = document.createElement('div')
  menu.className = 'tab-context-menu'
  menu.innerHTML = `
    <div class="menu-item">固定</div>
    <div class="menu-item">关闭其他</div>
    <div class="menu-item">关闭右侧</div>
    <div class="menu-item">关闭所有</div>
  `
  menu.style.position = 'fixed'
  menu.style.left = x + 'px'
  menu.style.top = y + 'px'
  document.body.appendChild(menu)
}
```

---

## 六、Agent 管理页面（新增 Agent 平台信息）

### 6.1 Agent 列表组件

```jsx
// AgentCard 组件
function AgentCard({ agent }) {
  const platformLogos = {
    'hermes': '🐝',
    'claude': '🧠',
    'deepseek': '🔍',
    'gpt': '💙',
    'ollama': '🐘',
  };
  
  const platformColors = {
    'hermes': 'rgb(251, 191, 36)',
    'claude': 'rgb(124, 58, 237)',
    'deepseek': 'rgb(79, 172, 254)',
    'gpt': 'rgb(52, 211, 153)',
    'ollama': 'rgb(129, 140, 248)',
  };
  
  return (
    <div className="a-item">
      <div className="a-icon">
        <span>
          {platformLogos[agent.platform] || '🤖'}
        </span>
      </div>
      <div className="a-info">
        <div className="a-name">
          {agent.name}
          <span 
            className="a-platform"
            style={{ 
              color: platformColors[agent.platform] || '#ccc',
              fontSize: '9px',
              padding: '1px 5px',
              borderRadius: '3px',
              background: `${platformColors[agent.platform]}20`
            }}
          >
            {agent.platform}
          </span>
        </div>
        <div className="a-desc">{agent.desc}</div>
        <div className="a-model">
          模型: {agent.model} · 温度: {agent.temperature} · 
          Token: {agent.maxTokens}
        </div>
      </div>
    </div>
  );
}
```

### 6.2 Agent 配置对话框

```jsx
// AddAgentDialog 组件
function AddAgentDialog({ onClose }) {
  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h3>添加新 Agent</h3>
        
        <div className="form-group">
          <label>Agent 名称</label>
          <input type="text" placeholder="输入名称" />
        </div>
        
        <div className="form-group">
          <label>平台</label>
          <select>
            <option value="hermes">Hermes</option>
            <option value="claude">Claude</option>
            <option value="deepseek">DeepSeek</option>
            <option value="gpt">OpenAI GPT</option>
            <option value="ollama">Ollama (本地)</option>
            <option value="custom">自定义</option>
          </select>
        </div>
        
        <div className="form-group">
          <label>Endpoint</label>
          <input type="text" placeholder="https://api.example.com" />
        </div>
        
        <div className="form-group">
          <label>API Key</label>
          <input type="password" placeholder="sk-..." />
        </div>
        
        <div className="form-group">
          <label>模型</label>
          <input type="text" placeholder="模型名称" />
        </div>
        
        <div className="form-actions">
          <button className="btn-cancel" onClick={onClose}>取消</button>
          <button className="btn-primary">添加</button>
        </div>
      </div>
    </div>
  );
}
```

### 6.3 API Key 管理

```jsx
// APIKeyManager 组件
function APIKeyManager() {
  const [keys, setKeys] = useState({
    hermes: 'hermes-xxx-xxx',
    claude: 'sk-ant-xxx-xxx',
    deepseek: 'sk-xxx-xxx',
    openai: 'sk-proj-xxx-xxx',
  });
  
  return (
    <div className="api-keys-section">
      <h4>API Key 管理</h4>
      <div className="api-key-item">
        <span className="platform-name">Hermes</span>
        <input type="password" value={keys.hermes} onChange={...} />
      </div>
      <div className="api-key-item">
        <span className="platform-name">Claude</span>
        <input type="password" value={keys.claude} onChange={...} />
      </div>
      <div className="api-key-item">
        <span className="platform-name">DeepSeek</span>
        <input type="password" value={keys.deepseek} onChange={...} />
      </div>
      <div className="api-key-item">
        <span className="platform-name">OpenAI</span>
        <input type="password" value={keys.openai} onChange={...} />
      </div>
    </div>
  );
}
```

---

## 七、远程控制

### 7.1 连接流程
```
企微/飞书/微信 ←─ IM 协议 ─→ Worker Messenger ←─ 消息 ─→ Agent
```

### 7.2 远程指令处理
```
用户发 "帮我看看服务器状态" 
  → Worker Messenger 解析
  → 发送给 Server Monitor Agent
  → Worker Messenger 收到结果
  → 通过 IM 返回给用户
```

### 7.3 IM 配置页
```html
<div class="im-config-item">
  <div class="im-icon">💬</div>
  <div class="im-name">企微</div>
  <div class="im-status">已连接</div>
  <div class="im-toggle on"></div>
</div>
```

---

## 八、Agent 运行监控视图

### 8.1 时间线组件
```jsx
<Timeline>
  <TimelineItem time="10:23" text="接收任务" />
  <TimelineItem time="10:24" text="解析代码" />
  <TimelineItem time="10:25" text="生成方案" />
  <TimelineItem time="10:26" text="正在写代码">
    <ProgressBar value={82} />
  </TimelineItem>
  <TimelineItem time="—" text="等待中" />
</Timeline>
```

### 8.2 实时心跳
```css
.heartbeat {
  animation: blink 1s infinite;
}
@keyframes blink {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}
```

---

## 九、全局快捷键

| 快捷键 | 功能 |
|--------|-- |
| ⌘K | 全局搜索 |
| ⌘ShiftK | 折叠/展开 Chat 抽屉 |
| ⌘D | 垂直分屏 |
| ⌘ShiftD | 水平分屏 |
| Ctrl+Tab | 切换标签页 |
| ⌘W | 关闭标签页 |
| Ctrl+S | 保存布局 |

---

## 十、测试用例

### 10.1 Chat 抽屉
- [x] 折叠态 5px 边缘条可点击
- [x] 拖拽展开 200-800px
- [x] 全宽态占 50% 可拖

### 10.2 分屏
- [x] 拖拽分割线调整比例
- [x] 辅助线显示
- [x] 最小比例限制

### 10.3 标签页
- [x] 标签页可拖拽
- [x] 右键菜单正确
- [x] 关闭标签页

### 10.4 Agent 管理
- [x] 多平台 Agent 列表显示
- [x] Agent 平台标签正确
- [x] 添加/删除 Agent
- [x] API Key 管理

### 10.5 跨平台部署
- [x] Windows 一键安装
- [x] macOS 一键安装
- [x] Linux 一键安装
- [x] 配置文件生成

### 10.6 远程控制
- [x] 企微/飞书/微信 连接
- [x] 远程指令回传

### 10.7 运行监控
- [x] 时间线更新
- [x] 进度条显示
- [x] 心跳动画

---

## 十一、CSS 类参考

| 类名 | 用途 |
|------|------|
| `.chat-drawer` | Chat 抽屉容器 |
| `.chat-resize-handle` | Chat 可拖拽边界 |
| `.split-pane` | 分屏面板 |
| `.split-handle` | 分割线 |
| `.tab-bar` | 标签页栏 |
| `.tab-item` | 单个标签页 |
| `.timeline` | 时间线容器 |
| `.agent-card` | Agent 卡片 |
| `.platform-badge` | 平台标签 |
| `.im-item` | IM 配置项 |

---

## 十二、JS API 参考

| API | 描述 |
|------|------|
| `toggleChatDrawer(state)` | 切换 Chat 抽屉 |
| `createSplitPane(orientation)` | 创建分屏 |
| `addTabToPanel(panel, tab)` | 添加标签页 |
| `removeTab(panel, tab)` | 移除标签页 |
| `updateMonitor(agentData)` | 更新监控视图 |
| `connectIM(platform)` | 连接 IM |
| `addAgent(config)` | 添加 Agent |
| `deleteAgent(agentId)` | 删除 Agent |
| `setAPIKey(platform, key)` | 设置 API Key |
| `listPlatforms()` | 列出所有平台 |

---

## 十三、Agent 平台扩展机制

### 13.1 自定义适配器模板

```python
# plugins/custom_agent.py
from worker_agent.adapters.base import AgentAdapter

class CustomAgentAdapter(AgentAdapter):
    def __init__(self, config):
        self.platform = 'custom'
        self.endpoint = config['endpoint']
    
    async def send_message(self, session_id, message):
        # 实现自定义协议
        pass
    
    async def get_status(self, session_id):
        # 实现自定义状态查询
        pass
```

### 13.2 平台配置示例

```json
// agents.json
{
  "agents": [
    {
      "name": "Code Assistant (Hermes)",
      "platform": "hermes",
      "endpoint": "http://hermes:8000/api",
      "model": "hermes-3-lima",
      "config": { "temperature": 0.7 }
    },
    {
      "name": "DeepSeek Research",
      "platform": "deepseek",
      "endpoint": "https://api.deepseek.com/v1",
      "model": "deepseek-reasoner",
      "config": { "temperature": 0.3 }
    },
    {
      "name": "Claude 3.5 Sonnet",
      "platform": "claude",
      "endpoint": "https://api.anthropic.com/v1",
      "model": "claude-3-5-sonnet-20241022",
      "config": { "temperature": 0.5 }
    },
    {
      "name": "Ollama Qwen2.5",
      "platform": "ollama",
      "endpoint": "http://localhost:11434",
      "model": "qwen2.5-coder:32b",
      "config": { "temperature": 0.3, "local": true }
    }
  ]
}
```
