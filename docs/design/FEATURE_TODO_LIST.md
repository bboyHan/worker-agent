# Worker Agent — TODO列表模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：轻量级个人待办管理，独立于任务看板

---

## 一、功能定位

### 1.1 与任务看板的区别

| 维度 | TODO列表 | 任务看板 |
|------|---------|--|
| 粒度 | 个人待办（小、快、即时） | 项目管理（大、慢、复杂） |
| 场景 | 日常琐事、临时想法、快速记录 | 复杂项目、跨模块协作 |
| 状态 | 未开始/进行中/已完成 | 待处理/进行中/审核中/已完成/已关闭 |
| 复杂度 | 极简（标题+备注+截止日期） | 丰富（标签/Sprint/子任务） |
| 创建方式 | 快捷方式/键盘快捷键/命令行 | UI操作 |

### 1.2 核心价值

- **快速记录**：3秒内记录一个待办（Ctrl+T 或 /todo 指令）
- **轻量管理**：不需要看板的复杂度，但需要结构化
- **多场景**：支持按场景分组（工作/生活/学习/开发）

---

## 二、核心需求

### 2.1 数据模型

```typescript
interface TodoItem {
  id: string;              // UUID v4
  title: string;           // 标题（必填）
  description?: string;    // 备注/描述（可选）
  completed: boolean;      // 是否完成
  priority: 'low' | 'normal' | 'high' | 'urgent'; // 优先级
  tags: string[];          // 标签（可选）
  createdAt: Date;         // 创建时间
  updatedAt: Date;         // 更新时间
  dueDate?: Date;          // 截止日期（可选）
  reminderDate?: Date;     // 提醒时间（可选）
  category: string;        // 分类（工作/生活/学习/开发）
  projectId?: string;      // 关联项目ID（可选，关联到看板任务）
  assignedTo?: string;     // 分配给（Agent名或用户名）
  recurring?: {
    type: 'daily' | 'weekly' | 'monthly' | 'yearly';
    interval: number;      // 间隔（如：every 2 days）
    until?: Date;          // 循环直到日期
  } | null;                // 是否循环
  reminderDate?: Date;     // 提醒时间（可选）
  reminderSent: boolean;   // 提醒是否已发送
  repeatDays?: number;     // 重复天数
  repeatTimes?: string;    // 重复时间
  repeatRule?: string;     // 重复规则（如：every 2 days）
  repeatUntil?: Date;      // 循环直到日期
  recurrence?: string;     // 重复规则（如：rrule）
  recurrenceUntil?: Date;  // 重复直到日期
};

interface TodoCategory {
  id: string;
  name: string;            // 分类名称
  icon: string;            // 分类图标
  color: string;           // 分类颜色
  sortOrder: number;       // 排序
  collapsed: boolean;      // 是否折叠
}

interface TodoList {
  name: string;            // 列表名称
  icon: string;            // 列表图标
  color: string;           // 列表颜色
  sortOrder: number;       // 排序
  collapsed: boolean;      // 是否折叠
}

interface TodoList {
  name: string;            // 列表名称
  icon: string;            // 列表图标
  color: string;           // 列表颜色
  sortOrder: number;       // 排序
  itemIds: string[];       // 列表中的待办ID
  visibleItems: number;    // 可见待办数
  completedItems: number;  // 已完成数
}

interface TodoSettings {
  displayMode: 'list' | 'board' | 'calendar'; // 显示模式
  sortBy: 'priority' | 'dueDate' | 'name' | 'createdAt' | 'completedAt';
  sortOrder: 'asc' | 'desc';
  showCompleted: boolean;  // 是否显示已完成的
  autoArchiveDays: number; // 完成后自动归档天数（0=不归档）
  remindersEnabled: boolean; // 是否开启提醒
  reminderChannel: 'notification' | 'webhook' | 'email' | 'im'; // 提醒渠道
}
```

### 2.2 存储方案

```json
// data/todos.json
{
  "categories": [
    {"id": "cat_work", "name": "工作", "icon": "💼", "color": "#3B82F6"},
    {"id": "cat_personal", "name": "个人", "icon": "🏠", "color": "#10B981"},
    {"id": "cat_dev", "name": "开发", "icon": "💻", "color": "#8B5CF6"},
    {"id": "cat_learning", "name": "学习", "icon": "📚", "color": "#F59E0B"}
  ],
  "lists": [
    {
      "id": "list_default",
      "name": "我的待办",
      "icon": "📋",
      "color": "#6B7280",
      "itemCount": 15
    }
  ],
  "items": [
    {
      "id": "todo_20260602_001",
      "title": "更新API文档",
      "description": "补充OAuth2接口的参数说明",
      "completed": false,
      "priority": "high",
      "tags": ["文档", "API"],
      "category": "cat_work",
      "listId": "list_default",
      "createdAt": "2026-06-02T10:00:00Z",
      "dueDate": "2026-06-03T18:00:00Z",
      "reminderDate": "2026-06-03T10:00:00Z",
      "reminderSent": false
    }
  ],
  "settings": {
    "displayMode": "list",
    "sortBy": "priority",
    "sortOrder": "desc",
    "showCompleted": true,
    "autoArchiveDays": 7,
    "remindersEnabled": true,
    "reminderChannel": "notification"
  }
}
```

---

## 四、交互设计

### 4.1 创建待办

```
快捷键: Ctrl+T
命令行: /todo 创建待办

输出:
> 快速创建待办
┌─────────────────────────────────────────────────────────────┐
│ 📋 创建待办                                                 │
│ ─────────────────────────────────────────────────────────── │
│ 标题: ___________________________________________________ │
│ 描述: ___________________________________________________ │
│ 优先级:  [●低]  [中]  [●高]  [急]                         │
│ 截止: [2026-06-03] [18:00]                               │
│ 分类: ●工作  个人  开发  学习                             │
│ 标签: [输入并回车添加标签]                                │
│                                                             │
│ 操作:                                                       │
│   [创建并新建]  [仅创建]  [取消]                          │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 列表视图

```
> /todo list

📋 我的待办 (15)                          [按优先级降序]  [显示已完成: ✅]
──────────────────────────────────────────────────────────────
🔴 紧急 (3)
  □ 更新API文档 - 补充OAuth2接口说明          截止: 明天 18:00  [📋 工作 | 📝 文档]
  □ 修复登录Bug - 用户反馈授权失败            截止: 今天 20:00  [📋 开发]
  □ 提交周报                                  截止: 今天 23:59  [📋 工作]

🟡 高 (4)
  □ 审查PR #123 - 验证代码质量                截止: 明天 12:00  [📋 开发]
  □ 编写测试用例 - 用户认证模块               截止: 后天 18:00  [📋 开发]
  □ 设计数据库索引优化方案                    截止: 3天后       [📋 开发]
  □ 更新README.md                             截止: 5天后       [📋 文档]

🔵 中 (5)
  □ 调研Rust异步框架                          截止: 本周五      [📋 学习]
  □ 整理Agent配置文档                         截止: 下周一      [📋 工作]
  ...

🟢 低 (3)
  □ 清理缓存文件                              截止: 本周末      [📋 个人]
  □ 更新依赖包                              截止: 下周        [📋 开发]
  □ 整理桌面文件                              截止: 本周末      [📋 个人]

──────────────────────────────────────────────────────────────
[快速命令] Ctrl+T:新建  Esc:返回  /:搜索  @:按标签  #/按分类
```

### 4.3 快捷键

| 快捷键 | 功能 |
|--------|--|
| Ctrl+T | 新建待办 |
| Esc | 返回列表 |
| ↑/↓ | 上下移动 |
| Enter | 编辑选中 |
| Space | 完成/取消完成 |
| / | 搜索 |
| + | 添加标签 |
| Del | 删除选中 |
| Ctrl+Shift+T | 快速创建（无UI） |

---

## 五、Agent集成

### 5.1 Agent

```typescript
interface TodoAgent {
  createTodo(title: string, options?: TodoOptions): TodoItem;
  updateTodo(id: string, updates: Partial<TodoItem>): void;
  completeTodo(id: string): void;
  getTodos(filter: TodoFilter): TodoItem[];
  deleteTodo(id: string): void;
   getPendingCount(): number;
  getOverdueCount(): number;
  getTodayTodos(): TodoItem[];
  getUpcoming(count: number): TodoItem[];
  
  // 提醒功能
  checkReminders(): void;
  sendReminder(todo: TodoItem, channel: ReminderChannel): void;
  
  // 自动提醒
  checkReminders(): void;
  sendReminder(todo: TodoItem, channel: ReminderChannel): void;
}
```

### 5.2 自动提醒

```typescript
interface TodoReminderAgent {
    提醒渠道 | 说明 | 支持场景
    |:-------|------|------|
    | 系统通知 | 桌面通知 | 所有场景 |
    | IM推送 | 飞书/企微/微信消息 | 所有场景 |
    | Webhook | 自定义Webhook | 支持Webhook的渠道 |
    | 邮件 | SMTP发送邮件 | 重要待办 |
    | 本地提醒 | 终端内弹出 | 仅终端模式 |
}
```

---

## 六、与现有模块的集成

### 6.1 与任务看板的集成

- TODO列表创建后可一键转换为看板任务
- 看板任务可反向导入为长期TODO
- TODO作为看板的补充（轻量待办 vs 复杂项目）

### 6.2 Agent集成

```typescript
interface TodoAgent {
  createTodo(title: string, options?: TodoOptions): TodoItem;
  updateTodo(id: string, updates: Partial<TodoItem>): void;
  completeTodo(id: string): void;
  getTodos(filter: TodoFilter): TodoItem[];
  getPendingCount(): number;
  getTodayTodos(): TodoItem[];
  getUpcoming(count: number): TodoItem[];
}
```

### 6.2 与Agent的集成

- Scheduler Agent 根据任务优先级调度Agent工作
- IM Agent 接受远程TODO指令（如：/todo 创建待办）
- IM Agent 向用户推送提醒（通过IM通道）

---

## 七、实施计划

### 阶段一（基础）
1. 数据模型设计 ✅
2. TODO列表CRUD API
3. 列表/完成/删除/编辑功能
4. 快捷键支持
5. 优先级/截止日期/分类
6. 基础UI（列表视图+分类组）

### 阶段二（增强）
1. 搜索/过滤/排序
2. 标签/分类
3. 提醒功能
4. 与看板的集成

### 阶段三（高级）
1. 日历视图
2. 循环待办
3. Agent自动创建待办
