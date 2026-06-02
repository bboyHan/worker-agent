# Worker Agent — TODO列表模块设计

## 一、功能定位

与任务看板的区别：
- TODO列表：个人轻量待办，快速记录，3秒创建
- 任务看板：项目管理，复杂协作（已设计，独立）

核心场景：日常琐事、临时想法、快速记录、按场景分组管理

## 二、数据模型

```typescript
interface TodoItem {
  id: string;              // UUID v4
  title: string;           // 标题（必填）
  description?: string;    // 备注/描述（可选）
  finished: boolean;       // 是否完成
  priority: 'low' | 'normal' | 'high' | 'urgent'; // 优先级
  tags: string[];          // 标签（可选）
  createdAt: Date;         // 创建时间
  updatedAt: Date;         // 更新时间
  dueDate?: Date;          // 截止日期（可选）
  reminderDate?: Date;     // 提醒时间（可选）
  category: string;        // 分类（工作/生活/学习/开发）
  listId?: string;         // 关联的待办列表ID
  assignedTo?: string;     // 分配给（Agent名或用户名）
  parentId?: string;       // 主项ID（子待办）
};

interface TodoList {
  id: string;
  name: string;            // 列表名称
  icon: string;            // 列表图标
  color: string;           // 列表颜色
  sortOrder: number;       // 排序
  itemIds: string[];       // 列表中的待办ID
  collapsed: boolean;      // 是否折叠
}
```

## 三、存储方案

纯文件JSON存储（不需要数据库）

```json
// data/todos.json
{
  "lists": [
    {
      "id": "list_work",
      "name": "工作",
      "icon": "📋",
      "color": "#3B82F6",
      "itemCount": 5
    }
  ],
  "items": [
    {
      "id": "todo_001",
      "title": "更新API文档",
      "description": "补充OAuth2接口的参数说明",
      "finished": false,
      "priority": "high",
      "tags": ["文档", "API"],
      "category": "work",
      "listId": "list_work",
      "createdAt": "2026-06-02T10:00:00Z",
      "dueDate": "2026-06-03T18:00:00Z",
      "reminderDate": "2026-06-03T10:00:00Z",
      "reminderSent": false
    }
  ],
  "settings": {
    "displayMode": "list|board|calendar",
    "sortBy": "priority|dueDate|name|createdAt|finishedAt",
    "sortOrder": "asc|desc",
    "showFinished": true,
    "autoArchiveDays": 7
  }
}
```

## 四、交互设计

### 4.1 创建待办

```
快捷键: Ctrl+T
命令行: /todo create <标题> --due '2026-06-03' --priority high

> 快速创建待办
┌───────────────────────────────────────────────────────────────────────────────┐
│ 📋 创建待办                                                                   │
│ ───────────────────────────────────────────────────────────────────────────── │
│ 标题: ________________________________________________________________________ │
│ 描述: ________________________________________________________________________ │
│ 优先级: [●低]  [中]  [●高]  [急]                                            │
│ 截止: [2026-06-03] [18:00]                                                 │
│ 分类: ●工作  个人  开发  学习                                                │
│ 标签: [输入并回车添加标签]                                                    │
│                                                                              │
│ 操作:                                                                        │
│   [创建并新建]  [仅创建]  [取消]                                            │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 列表视图

```
> /todo list

📋 我的待办 (15)                           [按优先级降序]  [显示已完成: ✅]
────────────────────────────────────────────────────────────────────────────────
🔴 紧急 (3)
  □ 更新API文档 - 补充OAuth2接口说明          截止: 明日 18:00  [📋 工作 | 📝 文档]
  □ 修复登录Bug - 用户反馈授权失败            截止: 今日 20:00  [📋 开发]
  □ 提交周报                                  截止: 今日 23:59  [📋 工作]

🟡 高 (4)
  □ 审查PR #123 - 验证代码质量                截止: 明日 12:00  [📋 开发]
  □ 编写测试用例 - 用户认证模块               截止: 后日 18:00  [📋 开发]
  □ 设计数据库索引优化方案                    截止: 3天后       [📋 开发]
  □ 更新README.md                             截止: 5天后       [📋 文档]

🔵 中 (5)
  □ 调研Rust异步框架                          截止: 本周五      [📋 学习]
  □ 整理Agent配置文档                         截止: 下周一      [📋 工作]
  ...

🟢 低 (3)
  □ 清理缓存文件                              截止: 本周末      [📋 个人]
  □ 更新依赖包                                截止: 下周        [📋 开发]
  □ 整理桌面文件                              截止: 本周末      [📋 个人]
────────────────────────────────────────────────────────────────────────────────
[快速命令] Ctrl+T:新建  Esc:返回  /:搜索  @:按标签  #分类
```

## 五、快捷键

| 快捷键 | 功能 |
|--------|------|
| Ctrl+T | 新建待办 |
| Esc | 返回列表 |
| ↑/↓ | 上下移动 |
| Enter | 编辑选中 |
| Space | 完成/取消完成 |
| / | 搜索 |
| + | 添加标签 |
| Del | 删除选中 |
| Ctrl+Shift+T | 快速创建（无UI） |

## 六、Agent集成

```typescript
interface TodoAgent {
  // CRUD
  createTodo(title: string, options?: TodoOptions): TodoItem;
  updateTodo(id: string, updates: Partial<TodoItem>): void;
  completeTodo(id: string): void;
  getTodos(filter: TodoFilter): TodoItem[];
  deleteTodo(id: string): void;
  // 统计
  getPendingCount(): number;
  getOverdueCount(): number;
  getTodayTodos(): TodoItem[];
  getUpcoming(count: number): TodoItem[];
  // 提醒
  checkReminders(): void;
  sendReminder(todo: TodoItem, channel: ReminderChannel): void;
}
```

## 七、提醒通知

| 提醒渠道 | 说明 | 支持场景 |
|---------|------|---------|
| 系统通知 | 桌面通知 | 所有场景 |
| IM推送 | 飞书/企微/微信消息 | 所有场景 |
| Webhook | 自定义Webhook | 支持Webhook的渠道 |
| 邮件 | SMTP发送邮件 | 重要待办 |
| 本地提醒 | 终端内弹出 | 仅终端模式 |

## 八、实施计划

### 阶段一（基础）
1. 数据模型设计 ✅
2. TODO列表CRUD API

### 阶段二（增强）
1. 搜索/过滤/排序
2. 标签/分类
3. 提醒功能
4. 与看板的集成

### 阶段三（高级）
1. 日历视图
2. 循环待办
3. Agent自动创建待办
