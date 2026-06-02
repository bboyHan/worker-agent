# Visual Lock 实现方案

> 日期: 2026-06-02
> 优先级: 🔴 最高
> 状态: 完整设计完成

## 1. 架构总览

```
[Designer Agent] ──▶ design_tokens.json ──▶ [锁定令牌]
     │                                                  │
     │  生成 CSS tokens                          [Visual Lock Checker]
     │       │                                          │
     │       ▼                                          ▼
  design_tokens.json                              扫描生成代码
       │                                          检查是否遵守锁定令牌
       ▼                                          │
  global.css (var(--primary))                     │
       │                                          │
       ↓                                          ↓
  [Code Agent 生成代码] ←── 约束 ─────── [通过/拒绝/警告]
       │
       ▼
  [Visual Lock Checker 验证]
       │
       ├──✅ 通过 → 直接写入项目
       ├──⚠️ 警告  → 用户确认 → 写入
       └──❌ 拒绝 → 自动修复/回退 → 用户选择
```

## 2. Design Tokens 数据结构

### 2.1 tokens.json (事实源)

```json
{
  "version": "1.0",
  "generated": "2026-06-02T12:00:00Z",
  "colors": {
    "primary": {
      "hex": "#3B82F6",
      "rgb": "59, 130, 246",
      "hsl": "217, 91%, 59%",
      "locked": true,
      "use": ["button background", "link color", "header bg"],
      "autoLockThreshold": 0.9  // AI 生成代码中 match score > 0.9 自动锁定
    },
    "secondary": {
      "hex": "#10B981",
      "locked": false
    },
    "surface": {
      "hex": "#F9FAFB",
      "locked": false
    },
    "text": {
      "hex": "#1F2937",
      "locked": true,
      "use": ["body text", "title color"]
    },
    "success": {
      "hex": "#22C55E",
      "locked": false
    },
    "error": {
      "hex": "#EF4444",
      "locked": false
    }
  },
  "fonts": {
    "heading": {
      "family": "'Inter', sans-serif",
      "weight": 700,
      "locked": true
    },
    "body": {
      "family": "'Inter', sans-serif",
      "weight": 400,
      "locked": true
    },
    "mono": {
      "family": "'JetBrains Mono', monospace",
      "locked": false
    }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px",
    "xxl": "48px",
    "locked": true
  },
  "borderRadius": {
    "sm": "4px",
    "md": "8px",
    "lg": "16px",
    "full": "9999px",
    "locked": true
  },
  "shadows": {
    "sm": "0 1px 2px rgba(0,0,0,0.05)",
    "md": "0 4px 6px rgba(0,0,0,0.1)",
    "lg": "0 10px 15px rgba(0,0,0,0.1)",
    "locked": true
  }
}
```

## 3. 生成 CSS 变量

```css
/* src/styles/design-tokens.css */
:root {
  /* Colors */
  --color-primary: #3B82F6;
  --color-primary-rgb: 59, 130, 246;
  --color-secondary: #10B981;
  --color-surface: #F9FAFB;
  --color-text: #1F2937;
  --color-success: #22C55E;
  --color-error: #EF4444;

  /* Fonts */
  --font-heading: 'Inter', sans-serif;
  --font-body: 'Inter', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-xxl: 48px;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 16px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
}
```

## 4. Visual Lock Checker - 检查引擎

### 4.1 扫描范围

```
Scan targets:
✅ 所有 .css/.scss/.less 文件
✅ 所有 .tsx/.jsx/.vue 内联 style={...}
✅ 所有 tailwind.config.js
❌ 不检查 node_modules/
❌ 不检查 .git/
```

### 4.2 检查规则

```typescript
interface LockCheckResult {
  filePath: string;
  line: number;
  token: string;       // 被违反的 token 名称，如 "--color-primary"
  originalValue: string; // tokens.json 中的锁定值
  generatedValue: string; // 代码中生成的值
  matchScore: number;   // 相似度 (0-1)
  action: 'pass' | 'warn' | 'reject' | 'auto_fix';
  description: string;
  autoFix?: string;     // 自动修复建议
}

function checkLock(filePath, content): LockCheckResult[] {
  const results = [];
  
  for (const token of lockedTokens) {
    // 1. 检查 CSS 变量
    // ⚠️ 代码中使用了 --color-primary: #FF0000 ❌ 被锁定为 #3B82F6
    const cssVars = extractCSSVars(content);
    
    // 2. 检查 Hex/RGB/HSL 色值
    // ⚠️ background: #3B82F7 接近锁定值 #3B82F6 但不同 → auto_fix
    const hexMatches = extractHexValues(content);
    for (const match of hexMatches) {
      const score = compareColors(match.value, token.hex);
      if (score > 0.9 && score < 1.0) {
        results.push({
          action: 'warn',
          autoFix: token.hex
        });
      }
      if (score < 0.5) {
        results.push({
          action: 'reject',
          autoFix: token.hex
        });
      }
    }
    
    // 3. 检查 Tailwind 色名映射
    // ⚠️ bg-blue-600 应映射到 --color-primary
    const tailwindColors = extractTailwindColors(content);
    
    // 4. 检查 font-family
    const fonts = extractFontFamilies(content);
  }
  
  return results;
}
```

### 4.3 CSS 颜色相似度

```javascript
// 颜色比对容差
const TOLERANCE = {
  hex: 0.01,  // 0.01 的 Hex 差异被认为是近似
  rgb: 5,     // +/- 5 的 RGB 差异
  hsl: 10,    // +/- 10 度的色相差异
};

function compareColors(generated, locked): number {
  const gen = hexToRgb(generated);
  const ref = hexToRgb(locked);
  
  const delta = Math.sqrt(
    Math.pow(gen.r - ref.r, 2) +
    Math.pow(gen.g - ref.g, 2) +
    Math.pow(gen.b - ref.b, 2)
  ) / Math.sqrt(3 * 255 * 255); // normalize 0-1
  
  return 1 - delta; // 1 = perfect match, 0 = totally different
}
```

## 5. 生成代码时的 Token 注入

### 5.1 React 组件 Token 注入

```tsx
// 生成前 (AI 生成的未检查代码):
const Button = ({ children }) => (
  <button style={{ background: '#3B82F6', color: '#fff' }}>
    {children}
  </button>
);

// Visual Lock Checker 检查:
// ✅ background: #3B82F6 matches --color-primary (lock: true) → PASS
// ✅ color: #fff matches --color-surface (lock: false) → PASS

// 生成后 (注入 CSS 变量):
const Button = ({ children }) => (
  <button style={{ 
    background: 'var(--color-primary)',   // ← 已注入 token
    color: 'var(--color-text)'            // ← 已注入 token
  }}>
    {children}
  </button>
);
```

### 5.2 Tailwind 生成约束

```javascript
// tailwind.config.js (自动注入 token)
module.exports = {
  theme: {
    extend: {
    colors: {
      primary: 'var(--color-primary)',    // ← 锁定
      secondary: 'var(--color-secondary'),
      surface: 'var(--color-surface)',
      text: 'var(--color-text)',
    },
    fontFamily: {
      heading: ['Inter', 'sans-serif'],    // ← 锁定
      body: ['Inter', 'sans-serif'],        // ← 锁定
      mono: ['JetBrains Mono', 'monospace'],
    },
    },
  // },
};
```

### 5.3 错误处理

```
用户收到 Visual Lock 检查结果:

🔒 Visual Lock 检查结果 (生成的 2 个文件中):

⚠️ Warning (1):
  File: src/components/Header.tsx, Line: 12
  Token: --color-primary (#3B82F6, locked: true)
  Generated: #3B82F7 (similarity: 0.998)
  → AI 生成值接近锁定值但不精确
  Auto-fix: #3B82F6

❌ Rejected (1):
  File: src/styles/Button.css, Line: 4
  Token: --font-heading (Inter, locked: true)
  Generated: Roboto (similarity: 0.0)
  → AI 生成了不同的字体家族
  Auto-fix: font-family: var(--font-heading)

🟢 Options:
  [A] Apply auto-fix (recommended, 2 fixes pending)
  [Y] Approve both changes
  [N] Reject both changes
  [E] Edit manually
  [S] Skip this check
```

## 6. 自动修复算法

```python
def auto_fix(check_result):
    """自动修复 Visual Lock 违例"""
    
    match (check_result.action):
        case "warn":
            return {
                "type": "warning",
                "message": "Approximation detected",
                "fix": check_result.autoFix
                "confidence": 0.95
            }
        case "reject":
            return {
                "type": "conflict",
                "message": f"Rejected: {check_result.generatedValue} vs locked {check_result.originalValue}",
                "fix": check_result.autoFix,
                "confidence": 1.0
            }
        case "pass":
            return None  # No fix needed
            
        case "auto_fix":
            # 生成 CSS 变量替换硬编码值
            return apply_css_token(
                file_path=check_result.filePath,
                line=check_result.line,
                token=check_result.token
                generated_value=check_result.generatedValue,
                locked_value=token.hex,
            )
```

## 7. 运行时 Visual Lock 保护

### 7.1 CSS !important 注入

```css
/* 被锁定的 CSS 变量，在所有生成文件自动添加 !important */
.btn-primary {
  background: var(--color-primary) !important;
  color: var(--color-text) !important;
  font-family: var(--font-heading) !important;
}

/* AI 仍然可以添加新属性（不被 !important 影响） */
.btn-primary:hover {
  opacity: 0.8;  /* ← AI 可以添加新属性 */
  transition:  ...;  /* ← but not override locked */
}
```

### 7.2 CSS-in-JS @apply 约束

```javascript
// 在 CSS-in-JS 中，生成的值通过 CSS tokenizer 解析
// 所有锁定 token 自动转换为 var(--xxx)
const styles = {
  button: {
    background: 'var(--color-primary)', // ← 自动转换！
    // AI: "请用绿色" → 不会改变 #3B82F6, 因为被锁定
    // AI: "请添加阴影" → background 不变, 添加 boxShadow ✅
  }
}
```

## 8. Visual Lock Override 机制

当用户确实想要打破锁定时：

```
🔒 Visual Lock Override

You want to override locked token:
  --color-primary: #3B82F6 → #22C55E

🟡 WARNING: This will unlock the token temporarily.
  It will be re-locked after the next full run.

[1] Change token globally (all references updated)
[2] Change locally (this component only)
[3] Change and skip re-locking (permanent)
[4] Cancel

> 2
✅ Token unlocked locally for src/components/Button.tsx
```
