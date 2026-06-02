# Worker Agent v4.0 — 终端交互规格

## 一、浮动Chat面板交互规格

### 1.1 面板生命周期

```
状态机转换：
  
  [气泡态] → (点击) → [半展开] → (再次点击) → [展开] → (拖拽) → [最大化]
     ↑              |
     └──────────────┴── (5s无操作 / 点击面板外 / ESC)
```

### 1.2 面板DOM结构

```
FloatChatPanel (fixed position)
├── FAB (触发按钮)
│   └── Badge (未读数量)
├── ChatHeader (拖拽区域)
│   ├── Avatar (🤖)
│   ├── Title ("Agent Chat)
│   ├── Minimize按钮 (−)
│   ├── Maximize/Restore (□)
│   ├── Pin (📌)
│   └── Close (×)
├── ChatBody (消息区域)
│   └── MessageList (可滚动)
│       └── Message (user/assistant/tool)
├── ChatInput
│   ├── Input (textarea)
│   ├── Attach button (📎)
│   └── Send button (▶)
└── AgentPicker (Agent列表/切换)
```

### 1.3 交互事件规范

| 事件 | 触发方式 | 处理逻辑 |
|------|------|------|
| 呼出面板 | 点击FAB / ⌘+Shift+K | 状态机切换至展开态 |
| 折叠面板 | 点击× / 5s无操作 / ESC | 状态机切换至气泡态 |
| 半展开 | 双击气泡 / 点击半展开面板 | 状态机切换至展开态 |
| 拖拽面板 | 拖拽ChatHeader | 移动面板位置，限制在Viewport内 |
| 拖拽resize | 拖拽右下角handle | 调整面板宽高（300-600px） |
| 切换Agent | 点击AgentPicker | 更新currentAgent，清空ChatBody |
| 发送消息 | 点击Send / Enter | 发送消息，显示loading动画 |
| 收到消息 | Assistant回复 | 自动滚动到最新消息，Badge+1 |

### 1.4 CSS动画规范

```css
/* 气泡态 → 展开态 */
@keyframes float-chat-expand {
  0% {
    transform: translateY(200px) scale(0.15);
    opacity: 0;
  }
  100% {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}
@duration: 0.3s;
@easing: cubic-bezier(0.4, 0, 0.2, 1);

/* 收起动画（反向） */
@keyframes float-chat-collapse {
  0% {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
  100% {
    transform: translateY(200px) scale(0.15);
    opacity: 0;
  }
}

/* FAB Badge呼吸动画 */
@keyframes badge-breathe {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.2); }
}
```

---

## 二、拖拽分割窗口交互规格

### 2.1 SplitPane组件结构

```
SplitPane (container)
├── Pane (primary)
│   ├── Content
│   └── ── SPLIT HANDLE ── ← draggable
└── Pane (secondary)
    ├── Content (可以嵌套另一个SplitPane)
    └── ...
```

### 2.2 拖拽分割线事件流

```
pointerdown on SPLIT HANDLE
  → startDrag(e) {
      initialMouseX = e.clientX
      initialWidth = currentWidth
      isDragging = true
      showHeatline()      ← 显示热力线
    }

pointermove (document)
  → onDragMove(e) {
      deltaX = e.clientX - initialMouseX
      newRatio = initialWidth / containerWidth + deltaX / containerWidth
      if maxMinLimit(0.15, 0.85, newRatio)
        updateRatio(newRatio)
        showRatio(newRatio)     ← 显示实时比例
      }
    }

pointerup (document)
  → endDrag() {
      isDragging = false
      hideHeatline()      ← 隐藏热力线
      saveCurrentRatio()    ← 保存
      snapToGrid()          ← 自动吸附到最近的snap位置
    }
```

### 2.3 Snap Layout热力图

```
拖拽窗口到边缘时显示6个布局位置：

┌──────┬──────┐
│      │      │
│      │ snap │
│ snap │  E   │          ← 上下左右
│------|------|
│      │      │
│ snap │snap  │          ← 四角
└──────┴──────┘

热力图显示规则：
- hover目标区域 → 高亮+虚线边框
- 拖入目标 → 目标区域填充色（#7c3aed/30%）
- 松开 → 自动调整为目标布局
```

### 2.4 拖入拆分事件流

```
当拖拽窗口进入SplitPane容器：

1. pointerenter container
   → showSplitIndicator()     ← 显示"拆分"热力线（十字）
      显示4个拖入区域提示：
      ├─ 上方 → 垂直分割（当前在下方）
      ├─ 下方 → 垂直分割（当前在上方）
      ├─ 左侧 → 水平分割（当前在右侧）
      └─ 右侧 → 水平分割（当前在左侧）

2. pointerover 某个区域
   → highlightDropZone(zone)  ← 高亮对应区域

3. pointerup 在某个zone
   → splitPane(zone) {     ← 执行拆分
      newLayout = createSplit(currentPane, zone)
      updateLayout(newLayout)
    }
```

---

## 三、全局快捷键系统规格

### 3.1 快捷键注册机制

```
HotkeyManager {
  bindings: Map<String, Action>,  // key → action
  priority: number,               // 快捷键优先级（1-100）
  
  register(key, action, priority) {
    if (bindings.has(key)) {
      if (priority > bindings.get(key).priority) {
        // 高优先级覆盖低优先级
        bindings.set(key, action)
      }
    } else {
      bindings.set(key, action)
    }
  }
  
  handle(keyEvent) {
    key = normalize(keyEvent)    // ⌘→meta, Ctrl→ctrl, Shift→shift
    if (bindings.has(key)) {
      // 检查是否在当前面板内有效
      if (checkScope(key)) {
        event.preventDefault()
        bindings.get(key)()
      }
    }
  }
}
```

### 3.2 快捷键分组

| 分组 | 前缀 | 范围 | 说明 |
|------|--|------|------|
| 系统 | ⌘+X | 全局 | 系统级快捷键 |
| 导航 | ⌘+1-9 | 面板内 | 快速切换面板 |
| 窗口 | ⌘+D / ⌘+Shift+D | 面板内 | 窗口分割 |
| Chat | ⌘+Shift+K | 全局 | Chat面板 |
| 编辑 | Ctrl+Enter | 输入框内 | 发送消息 |
| 搜索 | ⌘+K | 全局 | 全局搜索 |
| 快照 | Ctrl+S | 面板内 | 保存当前布局 |

---

## 四、布局快照系统规格

### 4.1 快照数据结构

```
LayoutSnapshot {
  id: string          // "snap-001"
  name: string        // "开发布局"
  timestamp: Date
  layout: {
    split: string       // "horizontal" | "vertical" | "grid"
    panels: Panel[]     // 面板列表
    ratios: number[]    // 各面板比例
    positions: Position[] // 各面板位置
  }
}

Panel {
  id: string          // "agent-panel"
  type: string        // "agent" | "chat" | "server" | "setting" | "custom"
  content: string     // 内容标识
  size: Size          // { width, height }
  position: Position  // { x, y }
}
```

### 4.2 快照操作流程

```
1. 保存快照
   Hotkey: Ctrl+S
   → snapshot = currentLayout.toJSON()
   → snapshot.name = prompt("保存为：")
   → snapshot.timestamp = now()
   → saveToIndexedDB(snapshot)
   → showNotification("布局已保存: " + snapshot.name)

2. 恢复快照
   方式：面板列表选择 / 快捷键 Alt+L
   → snapshots = loadFromIndexedDB()
   → showSnapshotPicker(snapshots)
   → userSelect(snapshot)
   → currentLayout.restoreFrom(snapshot)
   → showNotification("已恢复: " + snapshot.name)

3. 删除快照
   方式：面板列表右键删除
   → removeFromIndexedDB(snapshot.id)
```

### 4.3 布局持久化

```
保存策略：
- 布局变化 → debounced save（300ms）→ localStorage
- 布局快照 → IndexedDB
- 面板状态 → sessionStorage（当前会话有效）

恢复策略：
- 页面加载 → 优先读取localStorage的当前布局
- 有localStorage → restore()
- 无localStorage → 读取最近快照的布局
- 无快照 → 默认：单面板（Agent管理）
```

---

## 五、数据流图

```
┌─────────────┐     ┌───────────────┐     ┌───────────────┐
│   用户操作     │     │   状态管理     │     │   持久化层     │
│             │     │               │     │               │
│ FAB点击      │───→│ ChatPanel     │───→│ sessionStorage│
│ 拖拽分割线   │───→│ SplitPane     │───→│ localStorage  │
│ 快捷键       │───→│ HotkeyManager │───→│ IndexedDB     │
│ 拖入拆分     │───→│ LayoutManager │───→│ IndexedDB     │
└─────────────┘     └───────────────┘     └───────────────┘
```

---

## 六、CSS/JS API参考

### 6.1 核心CSS类

```css
/* 面板容器 */
.split-pane { display: flex; position: relative; }
.split-pane.vertical { flex-direction: row; }
.split-pane.horizontal { flex-direction: column; }

/* 分割线 */
.split-handle {
  position: absolute;
  background: var(--brd);
  transition: background .15s;
}
.split-handle:hover { background: var(--ac); }
.split-handle.dragging { background: var(--ac); }

/* 浮动Chat */
.float-chat {
  position: fixed;
  z-index: 1000;
  transform-origin: bottom right;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 气泡态 */
.float-chat.state-1 { transform: translate(24px, 24px) scale(0.15); }

/* Snap热力图 */
.snap-indicator {
  border: 2px dashed var(--ac);
  background: rgba(124, 58, 237, 0.1);
}
```

### 6.2 核心JS方法

```javascript
// SplitPane
splitPane.create(container, { type: 'horizontal', ratio: 0.5 })
splitPane.addPanel(id, size)
splitPane.removePanel(id)
splitPane.resize(ratio)
splitPane.restore(ratio)
splitPane.toJSON() → Layout

// FloatChat
floatChat.show(state=2)       // 展开
floatChat.collapse()          // 折叠
floatChat.restore()           // 恢复位置和状态
floatChat.sendMessage(agentId, message)
floatChat.addEventListener('stateChange', handler)

// LayoutManager
layoutManager.create(name)
layoutManager.save(name)
layoutManager.restore(id)
layoutManager.toJSON()
layoutManager.fromJSON(layout)
layoutManager.delete(id)

// HotkeyManager
hotkeyManager.register(key, handler, scope=default)
hotkeyManager.unregister(key)
hotkeyManager.reset()
```

---

## 七、测试用例

### 7.1 浮动Chat面板测试
- [ ] FAB呼出面正常（展开态）
- [ ] 折叠动画流畅（0.3s）
- [ ] 拖拽边界不超出Viewport
- [ ] 跨页面会话保持
- [ ] 固定模式面板不消失
- [ ] Badge数量正确

### 7.2 拖拽分割测试
- [ ] 分割线拖拽调整比例正常
- [ ] 比例范围15%-85%
- [ ] Snap热力图正确显示
- [ ] 拖入拆分功能正常
- [ ] 拖入合并功能正常

### 7.3 快捷键测试
- [ ] ⌘+K呼出搜索面板
- [ ] ⌘+Shift+K呼出Chat面板
- [ ] 快捷键冲突检测
- [ ] 自定义快捷键生效

### 7.4 布局快照测试
- [ ] 保存快照到IndexedDB
- [ ] 恢复快照正确
- [ ] 删除快照正确
- [ ] 布局变化自动save（debounced 300ms）

---

*本文档与 INTERACTIVE_PROTOTYPE_V4.html 配套使用。原型实现了本文档所有交互规格。*
