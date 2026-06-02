# Worker Agent — 配置管理模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：平台全局配置管理，支持主题/快捷键/界面/功能开关

---

## 一、功能定位

### 1.1 核心价值

| 价值 | 说明 |
|------|------|
| 集中管理 | 所有配置集中存储，单文件管理 |
| 主题切换 | 支持暗色/亮色/自定义主题 |
| 快捷键自定义 | 用户自定义快捷键方案 |
| 界面定制 | 侧边栏/顶栏/底部面板布局定制 |
| 功能开关 | 按需启用/禁用功能模块 |

### 1.2 设计约束

- 所有配置存储在 `~/.config/worker-agent/settings.json`
- JSON格式，用户可直接编辑
- 支持环境变量覆盖（如：`WORKER_AGENT_THEME=dark`）
- 无需重启，实时生效

---

## 二、配置结构

### 2.1 整体结构

```json
// ~/.config/worker-agent/settings.json
{
  "version": "1.0",
  "updatedAt": "2026-06-02T00:00:00Z",
  "global": {
    "theme": "dark",           // dark | light | custom
    "accentColor": "#3B82F6",   // 主色调
    "locale": "zh-CN",          // 语言
    "fontSize": 14,             // 全局字体大小
    "fontFamily": "Inter, sans-serif",
    "maxLogs": 1000,           // 日志保留条数
    "autoSave": true,          // 自动保存
    "checkUpdate": "weekly",   // 更新检查频率 | never
    "showWelcome": true,       // 欢迎页面
    "showStatusBar": true,     // 状态栏
    "showSidebar": true,       // 侧边栏
    "sidebarPosition": "left", // left | right
    "showTabs": true,          // Tab栏
    "tabHeight": 42,           // Tab高度
    "terminalHeight": 200,      // 终端面板高度
    "autoStart": false,        // 是否开机自启
    "runAsService": false      // 是否作为服务运行
  },
  "display": {
    "theme": "dark",
    "accentColor": "#3B82F6",
    "sidebarWidth": 280,
    "sidebarPosition": "left",
    "fontSize": 14,
    "fontFamily": "Inter, sans-serif",
    "compactMode": false,
    "showStatusBar": true,
    "showTerminal": true,
    "terminalHeight": 200,
    "panelLayout": "default"   // default | top-bottom | left-right | none
  },
  "editor": {
    "fontFamily": "Fira Code, monospace",
    "fontSize": 14,
    "lineHeight": 1.5,
    "tabSize": 2,
    "wordWrap": "on",
    "minimap": {
      "enabled": true,
      "size": "fill",
      "showLines": true
    },
    "autoSave": "onFocusChange", // never | onFocusChange | afterDelay
    "autoSaveDelay": 1000,
    "autoIndent": "full",
    "formatOnSave": true,
    "showLineNumbers": true,
    "cursorBlink": true,
    "cursorStyle": "line",     // block | underline
    "smoothScrolling": true,
    "renderWhitespace": "selection",
    "bracketMatching": true,
    "colorDecorators": true,
    "quickSuggestions": true,    // 快速建议
    "suggestOnTriggerCharacters": true, // 触发字符建议
    "suggestOnTyping": true, // 打字时建议
    "lineNumbers": "on",     // on | off | relative | interval
    "lineHeight": 1.5,
    "codeLens": true,    // 代码大纲
    "folding": true,   // 代码折叠
    "minimap": {
      "enabled": true,
      "size": "fill",
      "showLines": true
    },
    "minimap": {
      "enabled": true,
      "size": "fill",
      "showLines": true
    },
    "autoSave": "afterDelay", // never | onFocusChange | afterDelay
    "autoSaveDelay": 1000, // autoSaveDelay | afterDelay
    "autoIndent": "full", // none | keep | insert | full
    "formatOnSave": true, // 保存时格式化
    "showLineNumbers": true, // 显示行号
    "cursorBlink": true, // 光标闪烁
    "cursorStyle": "line", // block / underline
    "smoothScrolling": true, // 平滑滚动
    "renderWhitespace": "selection", // selection / none / all
    "bracketMatching": true, // 括号匹配
    "colorDecorators": true, // 颜色装饰器
    "quickSuggestions": true, // 快速建议
    "suggestOnTriggerCharacters": true, // 触发字符建议
    "lineNumbers": "on", // on / off / relative / interval
    "lineHeight": 1.5,
    "codeLens": true, // 代码大纲
    "folding": true // 代码折叠
  },
  "editor": {
    "fontFamily": "Fira Code, monospace",
    "fontSize": 14,
    "lineHeight": 1.5,
    "tabSize": 2,
    "wordWrap": "on",
    "autoSave": "afterDelay",
    "autoSaveDelay": 1000,
    "autoIndent": "full",
    "formatOnSave": true,
    "showLineNumbers": true,
    "cursorBlink": true,
    "cursorStyle": "line",
    "smoothScrolling": true,
    "renderWhitespace": "selection",
    "bracketMatching": true,
    "codeLens": true,
    "folding": true,
    "minimap": {
      "enabled": true,
      "size": "fill",
      "showLines": true
    }
  },
  "editor": {
    "fontFamily": "Cascadia Code, monospace",
    "fontSize": 14,
    "lineHeight": 1.6,
    "tabSize": 2,
    "wordWrap": "on",
    "minimap": {
      "enabled": true,
      "size": "fill",
      "showLines": true
    },
    "autoSave": "afterDelay",
    "autoSaveDelay": 500,
    "autoIndent": "full",
    "formatOnSave": true
  },
  "terminal": {
    "theme": "dracula",       // default | dracula | nord | tokyonight | custom
    "cursorStyle": "block",   // block | underline
    "cursorBlink": true,
    "fontSize": 14,
    "fontFamily": "JetBrains Mono, monospace",
    "bell": "none",           // none | sound | visual
    "scrollback": 10000,
    "padding": 8,
    "quickCopy": true,     // 自动复制
    "autoOpen": "none"    // "none" | "bottom" | "side" | "float"
  },
  "terminal": {
    "theme": "dark",
    "cursorStyle": "block",
    "bell": "none",
    "scrollback": 10000,
    "padding": 8,
    "cursorStyle": "block",
    "bell": "none",
    "scrollback": 100000,
    "padding": 12,
    "cursorColor": "#FFFFFF",
    "selectionBackground": "#444444",
    "ansiColors": {
      "black": "#1e1e1e",
      "red": "#ff5555",
      "green": "#50fa7b",
      "yellow": "#f1fa8c",
      "blue": "#6272a4",
      "magenta": "#ff79c6",
      "cyan": "#8be9fd",
      "white": "#f8f8f2"
    }
  },
  "ai": {
    "provider": "ollama",         // ollama | openai | anthropic | custom
    "model": "qwen3.6",         // AI模型
    "temperature": 0.3,
    "maxTokens": 4096,
    "systemPrompt": "You are a helpful coding assistant...",
    "autoSuggest": true,
    "autoCompleteInterval": 500,
    "enableCodeActions": true,
    "enableChat": true,
    "enableAgentMode": true,
    "temperature": 0.3,
    "maxTokens": 4096,
    "autoSuggest": true,
    "autoComplete": true,
    "chatPosition": "right",   // right | left | bottom
    "chatWidth": 400,
    "autoGenerateChatTitle": true,
    "enableCodeActions": true,
    "enableChat": true,
    "enableAgentMode": true,
    "maxConversations": 50
  },
  "security": {
    "encryptSensitiveData": true,   // 自动加密敏感数据
    "autoLockMinutes": 30,   // 自动锁定时
    "requirePassword": false,   // 需要密码
    "sshKeyDir": "~/.ssh",
    "sshAgent": true,
    "sshAgentTimeout": 3600,
    "vpnAutoConnect": false,
    "autoLockMinutes": 30,
    "maxFailedAttempts": 5,
    "lockoutMinutes": 15
  },
  "extensions": {
    "autoUpdate": true,
    "updateCheckInterval": "weekly",
    "marketplaceUrl": "https://marketplace.worker-agent.com",
    "enabled": true
  },
  "advanced": {
    "logLevel": "info",
    "logDir": "~/.config/worker-agent/logs",
    "enableDevTools": false,
    "enableDebugMode": false,
    "enableProfiling": false,
    "dataDir": "~/.config/worker-agent/data"
  },
  "shortcuts": {
   },
  "shortcuts": {
    "global": {
      "newWindow": "Ctrl+N",
      "quit": "Ctrl+Q",
      "preferences": "Ctrl+,",
      "toggleDevTools": "Ctrl+Shift+I",
      "toggleFullScreen": "F11",
      "toggleTerminal": "Ctrl+`",
      "undo": "Ctrl+Z",
      "redo": "Ctrl+Shift+Z",
      "find": "Ctrl+F",
      "replace": "Ctrl+H",
      "selectAll": "Ctrl+A",
      "copyPath": "Ctrl+Shift+C"
    },
    "editor": {
      "save": "Ctrl+S",
      "saveAll": "Ctrl+K",
      "cut": "Ctrl+X",
      "undo": "Ctrl+Z",
      "redo": "Ctrl+Shift+Z",
      "cut": "Ctrl+X",
      "copy": "Ctrl+C",
      "paste": "Ctrl+V",
      "selectAll": "Ctrl+A",
      "save": "Ctrl+S",
      "format": "Ctrl+Shift+F",
      "toggleWordWrap": "Alt+Z",
      "toggleMinimap": "Ctrl+\\",
      "goToLine": "Ctrl+G",
      "toggleTodo": "Ctrl+Shift+T",
      "newFile": "Ctrl+Shift+N",
      "newWindow": "Ctrl+Shift+Alt+N",
      "commandPalette": "Ctrl+Shift+P",
      "quickOpen": "Ctrl+P",
      "toggleTerminal": "Ctrl+Shift+T",
      "splitEditor": "Ctrl+\\"
    },
    "editor": {
      "openFile": "Ctrl+O",
      "newFile": "Ctrl+N",
      "closeFile": "Ctrl+W",
      "save": "Ctrl+S",
      "saveAll": "Ctrl+Shift+S",
      "toggleFullscreen": "F11",
      "commandPalette": "Ctrl+Shift+P",
      "quickOpen": "Ctrl+P",
      "toggleSidebar": "Ctrl+B",
      "toggleTerminal": "Ctrl+`"
    },
    "git": {
      "commit": "Ctrl+Shift+Enter",
      "push": "Ctrl+Shift+P",
      "pull": "Ctrl+Shift+G",
      "createPR": "Ctrl+Shift+A",
      "toggleTerminal": "Ctrl+`"
    },
    "default": {
      "commit": "Cmd+Enter",
      "push": "Cmd+Shift+P",
      "pull": "Cmd+Shift+G",
      "createPR": "Cmd+Shift+A",
      "toggleSidebar": "Cmd+B",
      "undo": "Cmd+Z",
      "redo": "Cmd+Shift+Z",
      "find": "Cmd+F",
      "replace": "Cmd+H"
    },
    "vim": {
      "mode_normal": {
        "h": "moveLeft",
        "j": "moveDown",
        "k": "moveUp",
        "l": "moveRight",
        "w": "moveToNextWord",
        "b": "moveToPreviousWord",
        "^": "moveToLineStart",
        "$": "moveToLineEnd",
        "0": "moveToLineStart",
        "D": "deleteToLineEnd",
        "dd": "deleteLine",
        "yy": "copyLine",
        "p": "paste",
        "Ctrl+r": "undo",
        "u": "redo",
        "Cmd+Enter": "commit",
        "Esc": "exit",
        "Cmd+Shift+P": "toggleTerminal",
        "Cmd+Shift+G": "pull",
        "a": "enterInsertMode",
        "i": "enterInsertMode",
        "o": "insertBelow",
        "A": "enterInsertModeToEnd"
      }
    },
    "vim": {
      "mode_normal": {
        "h": "left",
        "j": "down",
        "k": "up",
        "l": "right",
        "w": "nextWord",
        "b": "prevWord",
        "$": "endOfLine",
        "0": "home",
        "D": "deleteToEnd",
        "dd": "deleteLine",
        "yy": "copyLine",
        "p": "paste",
        "u": "undo",
        "Cmd+r": "redo",
        "a": "insertAfter",
        "i": "insertBefore",
        "o": "openBelow",
        "A": "insertAtEnd",
        "Esc": "escape"
      }
    }
  },
  "extensions": {},
}
```

### 2.2 预设主题

```typescript
interface Theme {
  name: string;            // 主题名称
  display: "dark" | "light" | "auto";
  palette: {
    background: string;    // 主背景
    sidebar: string;       // 侧边栏
    tabInactive: string;   // 未激活Tab
    tabActive: string;     // 激活Tab
    statusBar: string;     // 状态栏
    text: string;          // 主文字
    muted: string;         // 次要文字
    primary: string;       // 主色
    success: string;       // 成功
    warning: string;       // 警告
    danger: string;       // 错误
    editor: {
      background: string;
      foreground: string;
      gutter: string;
      lineHighlight: string; // 行高亮
      selection: string;
      caret: string;     // 光标
      indentGuide: string;
    };
  };
}
```

---

## 五、配置管理API

### 5.1 主配置管理器

```typescript
interface ConfigurationManager {
  // 获取设置
  get<T>(key: string, fallback?: T): T;
  getSection(section: string): Record<string, any>;
  
  // 设置属性
  set(key: string, value: any): void;
  setSection(section: string, values: Record<string, any>): void;
  
  // 重载配置
  reload(): void;
  
  // 监听变化
  onChange(key: string, callback: (newValue: any) => void): () => void;
  onReload(callback: () => void): () => void;
  
  // 持久化
  save(): Promise<void>;
  
  // 导入/导出
  export(): string;         // 导出为JSON字符串
  import(data: string): Promise<boolean>;  // 导入JSON字符串
  
  // 验证
  validate(): ValidationResult;
}

type ConfigurationValidationError = {
  key: string;
  message: string;
  severity: 'error' | 'warning';
};

class ValidationResult {
  isValid: boolean;
  errors?: ValidationErrors[];
}
```

### 5.1 配置验证器

```typescript
interface ConfigurationValidator {
  validate(schema: ConfigurationSchema, data: any): ValidationResult;
  validateSection(schema: any, section: string, data: any): ValidationResult;
  getDefaults(): Record<string, ConfigurationDefault>;
}

interface ConfigurationDefault {
  type: 'string' | 'number' | 'boolean' | 'object' | 'array';
  value: any;
  description: string;
}
```

### 5.2 快捷键管理器

```typescript
interface ShortcutRegistry {
  register(commandId: string, binding: string | string[]): void;
  unregister(commandId: string): void;
  getBinding(commandId: string): string;
  getAllBindings(): Record<string, string>;
  isValid(binding: string): boolean;
  isDuplicate(binding: string): string;  // 返回冲突的commandId
  getCommandsForBinding(binding: string): string[];  // 获取绑定的命令
}
```

---

## 六、主题

### 6.1 预设主题

```
dark    Dark（暗色）
light   Light（亮色）
custom  Custom（自定义）
```

```typescript
interface Theme {
  name: string;
  display: 'dark' | 'light' | 'auto';
  
  palette: {
    background: string;      // 主背景
    sidebar: string;          // 侧边栏
    tabInactive: string;    // 未激活Tab
    tabActive: string;      // 激活Tab
    statusBar: string;      // TabActive | statusBar | muted
    primary: string;
    success: string;
    warning: string;
    danger: string;
    text: string;
    muted: string;
    editor: {
      background: string;
      foreground: string;
      gutter: string;
      lineHighlight: string;
      selection: string;
      caret: string;
      indentGuide: string;
    };
  };
  
  rules: Array<{
    scope: string[];  // CSS scope
    styles: string;     // CSS styles
  }>;
  
  syntaxColors: {
    keyword: string;
    constant: string;
    string: string;
    comment: string;
    function: string;
    type: string;
    operator: string;
    punctuation: string;
  };
}
```

---

## 八、配置文件的优先级

| 优先级 | 源 | 说明 |
|--------|---- |
| 1 | 命令行参数 | `worker-agent --theme dark` |
| 2 | 环境变量 | `WORKER_AGENT_THEME=dark` |
| 3 | 用户配置 | `~/.config/worker-agent/settings.json` |
| 4 | 默认配置 | 内置默认值 |

---

## 九、实施计划

### 阶段一（基础）
1. 配置数据结构定义
2. 配置加载/保存
3. 基础配置UI（主题/快捷键/语言）

### 阶段二（增强）
1. 高级配置（编辑器/终端/AI）
2. 快捷键管理器
3. 验证器

### 阶段三（高级）
1. 配置同步（跨设备）
2. 配置备份/恢复
3. 配置导入/导出

---

> **下一步：设计安全/加密模块（FEATURE_5_SECURITY.md）**
