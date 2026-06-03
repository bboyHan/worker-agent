# Worker Agent v4.0 — 交互开发规格书

## 一、Chat 右侧抽屉（核心 UI）

### 1.1 三态设计

| 状态 | 宽度 | 触发 |
|------|------|------|
| 折叠态 | 5px | 点击边缘、⌘ShiftK |
| 小窗态 | 380px | 双击边缘、拖动5px到200-800 |
| 全宽态 | 50% | 拖拽右侧边界 |

### 1.2 折叠态（5px）
```css
.chat-drawer.state-folded {
  width: 5px;
  cursor: col-resize;
  border-left: 1px solid var(--brd);
  transition: width .3s cubic-bezier(0.4,0,0.2,1);
}
```

### 1.3 可拖拽边界
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

### 1.4 事件绑定
- `pointerdown on 5px handle` → 展开为小窗态
- `pointerdown on resize handle` → 拖拽调整宽度
- `pointermove` → 实时更新宽度（200px - 800px）
- `pointerup` → 提交新的宽度

## 二、类 VS Code 分屏系统

### 2.1 面板布局
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

### 2.2 拖拽边界处理
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

### 2.3 辅助线 (Snap Guides)
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

## 三、标签页系统

### 3.1 标签页结构
```
┌───────┬──────┬──────┐
│ Tab1  │ Tab2 │ Tab3 │ x
├─┴──────┴──────┴──────┤
│ Panel Content         │
└───────────────────────┘
```

### 3.2 标签页交互
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

## 四、远程控制

### 4.1 连接流程
```
企微/飞书/微信 ←─ IM 协议 ─→ Worker Messenger ←─ 消息 ─→ Agent
```

### 4.2 远程指令处理
```
用户发 "帮我看看服务器状态" 
  → Worker Messenger 解析
  → 发送给 Server Monitor Agent
  → Worker Messenger 收到结果
  → 通过 IM 返回给用户
```

### 4.3 IM 配置页
```html
<div class="im-config-item">
  <div class="im-icon">💬</div>
  <div class="im-name">企微</div>
  <div class="im-status">已连接</div>
  <div class="im-toggle on"></div>
</div>
```

## 五、Agent 运行监控视图

### 5.1 时间线组件
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

### 5.2 实时心跳
```css
.heartbeat {
  animation: blink 1s infinite;
}
@keyframes blink {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}
```

## 六、全局快捷键

| 快捷键 | 功能 |
|--------|--|
| ⌘K | 全局搜索 |
| ⌘ShiftK | 折叠/展开 Chat 抽屉 |
| ⌘D | 垂直分屏 |
| ⌘ShiftD | 水平分屏 |
| Ctrl+Tab | 切换标签页 |
| ⌘W | 关闭标签页 |
| Ctrl+S | 保存布局 |

## 七、测试用例

### 7.1 Chat 抽屉
- [x] 折叠态 5px 边缘条可点击
- [x] 拖拽展开 200-800px
- [x] 全宽态占 50% 可拖

### 7.2 分屏
- [x] 拖拽分割线调整比例
- [x] 辅助线显示
- [x] 最小比例限制

### 7.3 标签页
- [x] 标签页可拖拽
- [x] 右键菜单正确
- [x] 关闭标签页

### 7.4 远程控制
- [x] 企微/飞书/微信 连接
- [x] 远程指令回传

### 7.5 运行监控
- [x] 时间线更新
- [x] 进度条显示
- [x] 心跳动画

## 八、CSS 类参考

| 类名 | 用途 |
|------|------|
| `.chat-drawer` | Chat 抽屉容器 |
| `.chat-resize-handle` | Chat 可拖拽边界 |
| `.split-pane` | 分屏面板 |
| `.split-handle` | 分割线 |
| `.tab-bar` | 标签页栏 |
| `.tab-item` | 单个标签页 |
| `.timeline` | 时间线容器 |
| `.im-item` | IM 配置项 |

## 九、JS API 参考

| API | 描述 |
|------|------|
| `toggleChatDrawer(state)` | 切换 Chat 抽屉 |
| `createSplitPane(orientation)` | 创建分屏 |
| `addTabToPanel(panel, tab)` | 添加标签页 |
| `removeTab(panel, tab)` | 移除标签页 |
| `updateMonitor(agentData)` | 更新监控视图 |
| `connectIM(platform)` | 连接 IM |
