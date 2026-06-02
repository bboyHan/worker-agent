# Worker Agent — Git集成模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：平台内Git管理，免安装Git CLI依赖（自动下载/安装Git）

---

## 一、功能定位

### 1.1 核心价值

| 价值 | 说明 |
|------|------|
| 平台内Git操作 | 无需命令行，通过UI管理Git仓库 |
| 自动Git管理 | 自动下载/安装Git，用户无感知 |
| 可视化操作 | 提交、分支、PR、Diff、Merge |
| 远程仓库管理 | 克隆、推送、拉取、Fork |

### 1.2 与现有模块的关系

- **核心Git引擎**：内部Git包装器
- **内置终端**：通过终端执行高级命令
- **代码编辑器**：文件级操作（diff查看/代码审查）
- **Agent控制台**：Agent通过Git引擎执行操作

---

## 二、技术选型

| 组件 | 选型 | 理由 |
|------|------|------|
| Git引擎 | 子进程调用git CLI | 兼容所有Git特性 |
| Git自动安装 | git-updater | 自动下载Git |
| Diff展示 | diff-match-patch | 轻量、快速 |
| PR管理 | GitHub/GitLab API | REST API |
| Git钩子 | fs watcher | 监听文件变化 |

---

## 三、数据模型

### 3.1 仓库信息

```typescript
interface GitRepository {
  id: string;                    // 仓库ID
  path: string;                  // 本地路径
  url: string;                   // 远程URL
  name: string;                  // 仓库名称
  platform: 'none' | 'GitHub' | 'GitLab' | 'Gitee' | '自定义'; // 平台
  remotes: {
    name: string;                // 远程名称（origin/upstream）
    url: string;                 // URL
    ref: string;                 // 默认分支
    lastFetch: number;           // 最后拉取时间
  }[];
  HEAD: string;                  // 当前分支
  branches: GitBranch[];
  tags: GitTag[];
  lastActivity: number;          // 最后活动时间
  createdAt: number;
}

interface GitBranch {
  name: string;                  // 分支名
  commit: string;                // 最新提交Hash
  date: number;                  // 最后提交时间
  remote?: string;               // 远程分支
  ahead: number;                 // 领先数量
  behind: number;                // 落后数量
  isCurrent: boolean;            // 是否当前分支
  color: string;                 // 分支颜色
}

interface GitTag {
  name: string;                  // 标签名
  commit: string;                // 对应Hash
  date: number;                  // 创建时间
  message: string;               // 标签备注
}
```

### 3.2 提交记录

```typescript
interface GitCommit {
  hash: string;                  // 完整Commit Hash
  shortHash: string;             // 短Hash
  message: string;               // 提交信息
  author: {
    name: string;
    email: string;
    date: number;
  };
  parentHashes: string[];        // 父提交
  stats: {
    filesChanged: number;        // 变更文件数
    insertions: number;          // 新增行数
    deletions: number;           // 删除行数
  };
  branch: string;                // 所在分支
  tags?: string[];               // 关联标签
}

interface GitDiff {
  filePath: string;              // 文件路径
  oldPath?: string;              // 旧路径（重命名）
  mode: 'add' | 'modify' | 'delete' | 'rename' | 'copy'; // 变更类型
  status: 'A' | 'M' | 'D' | 'R' | 'C'; // Git状态
  hunks: GitHunk[];              // diff片段
}

interface GitHunk {
  oldStart: number;              // 左侧起始行
  oldLines: number;              // 左侧行数
  newStart: number;              // 右侧起始行
  newLines: number;              // 右侧行数
  lines: GitLine[];              // Diff行
}

interface GitLine {
  content: string;               // 行内容
  type: 'context' | 'addition' | 'deletion'; // 行类型
  oldLineNumber?: number;        // 左侧行号
  newLineNumber?: number;        // 右侧行号
}
```

### 3.3 文件状态

```typescript
interface GitFileStatus {
  path: string;                  // 文件路径
  state: 'modified' | 'untracked' | 'staged' | 'ignored'; // 状态
  staged: boolean;               // 是否已暂存
  indexState?: 'modified' | 'added'; // 索引状态
  workingDirState: 'modified' | 'untracked' | 'ignored' | 'clean'; // 工作目录状态
}
```

---

## 四、交互设计

### 4.1 仓库概览

```
> /git overview

📦 当前仓库: worker-agent
────────────────────────────────────────────────────────────────────────
🌿 分支: main (ahead 2, behind 1)
   ├─ main         abc1234 2小时前  [当前]  [●]
   ├─ dev           def5678 1天前
   ├─ feature/oauth gh89012 3天前
   └─ hotfix/login  ij34567 5天前

📋 提交记录:
   abc1234 feat: 添加OAuth2认证支持        2小时前 [abc1234] [abc1234]
   def5678 fix: 修复登录Bug               1天前 [def5678] [def5678]
   gh89012 docs: 更新README               3天前 [gh89012] [gh89012]
   ij34567 chore: 更新依赖                5天前 [ij34567] [ij34567]

📊 状态:
   修改的文件: 3 | 新增的文件: 2 | 删除的文件: 1
   ├─ modified: src/auth/oauth.ts
   ├─ modified: src/server/index.ts
   ├─ modified: .gitignore
   ├─ added: docs/OAUTH2.md
   └─ added: tests/auth.test.ts
───────────────────────────────────────────────────────────────────────
[命令] /git status | /git diff | /git commit | /git push | /git pull
───────────────────────────────────────────────────────────────────

### 4.2 暂存/提交

```
> /git commit --message "feat: 添加OAuth2认证支持"

📋 提交文件
─────────────────────────────────────────────────────────────────
修改的文件:
  [●] 3 src/auth/oauth.ts              [✓] [✓]
  [●] 1 src/server/index.ts            [✓] [✓]
  [●] 1 .gitignore                     [✓] [✓]

新增的文件:
  [●] 5 docs/OAUTH2.md                 [✓] [✓]
  [●] 3 tests/auth.test.ts             [✓] [✓]

────────────────────────────────────────────────────────────────
暂存所有: [●] 5个文件
提交信息: [feat: 添加OAuth2认证支持]
操作: [提交并推送] [仅提交] [取消]
─────────────────────────────────────────────────────────
```

### 4.3 Diff查看

```
> /git diff src/auth/oauth.ts

📝 文件差异 (src/auth/oauth.ts)
────────────────────────────────────────────────────────────────
@@ -10,7 +10,7 @@ // 认证配置 + 修改的配置
 interface OAuthConfig {
-  clientId: string;
   clientSecret: string;
+  redirectUri: string;  // 新增字段
  scopes: string[];
 }

--- src/auth/oauth.ts (old)
+++ src/auth/oauth.ts (new)
 ...
-[●] 旧行内容
+[●] 新行内容
 ──────────────────────────────────────────────────────────────────────
 [◀上一行] ◀◀  [当前行: 10-15] ▶▶  [下一行 ▶]  [关闭]
 ───────────────────────────────────────────────────────────────────────
```

---

## 五、核心功能

### 5.1 Git引擎

```typescript
interface GitEngine {
  // 仓库管理
  init(path: string): Promise<GitRepository>;
  clone(url: string, path: string): Promise<GitRepository>;
  open(path: string): Promise<GitRepository>;
  getRepository(path: string): GitRepository | null;
  
  // 状态管理
  getStatus(repo: GitRepository): Promise<GitFileStatus[]>;
  getBranches(repo: GitRepository): Promise<GitBranch[]>;
  getTags(repo: GitRepository): Promise<GitTag[]>;
  getCommits(repo: GitRepository, range?: string): Promise<GitCommit[]>;
  
  // 文件操作
  addFiles(repo: GitRepository, files: string[]): Promise<void>;
  removeFiles(repo: GitRepository, files: string[]): Promise<void>;
  
  // 暂存/提交
  stage(repo: GitRepository, files: string[]): Promise<void>;
  unstage(repo: GitRepository, files: string[]): Promise<void>;
  commit(repo: GitRepository, message: string, files?: string[]): Promise<GitCommit>;
  
  // Diff
  getDiff(repo: GitRepository, file?: string): Promise<GitDiff[]>;
  
  // 远程操作
  fetch(repo: GitRepository, remote: string): Promise<void>;
  pull(repo: GitRepository, remote: string, branch: string): Promise<void>;
  push(repo: GitRepository, remote: string, branch: string): Promise<void>;
  
  // 分支/标签管理
  createBranch(repo: GitRepository, name: string, baseRef?: string): Promise<GitBranch>;
  deleteBranch(repo: GitRepository, name: string): Promise<boolean>;
  switchBranch(repo: GitRepository, name: string): Promise<void>;
  createTag(repo: GitRepository, name: string, message: string): Promise<GitTag>;
  deleteTag(repo: GitRepository, name: string): Promise<boolean>;
  
  // 变更
  rebase(repo: GitRepository, baseBranch: string): Promise<void>;
  merge(repo: GitRepository, branch: string): Promise<boolean>;
  revert(repo: GitRepository, commitHash: string, message: string): Promise<GitCommit>;
}
```

### 5.2 Git客户端

```typescript
interface GitClient {
  // GitHub集成
  createPR(repo: GitRepository, options: PRCreateOptions): Promise<GitHubIssue>;
  mergePR(repo: GitRepository, prNumber: number): Promise<boolean>;
  
  // GitLab集成
  createMR(repo: GitRepository, options: MRCreateOptions): Promise<GitLabMergeRequest>;
  mergeMR(repo: GitRepository, mrId: number): Promise<boolean>;
  
  // Gitee集成
  createPR(repo: GitRepository, options: PRCreateOptions): Promise<GiteePullRequest>;
}
```

### 5.3 Git安装管理

```typescript
interface GitInstaller {
  // 自动Git检测
  detect(): {
    found: boolean;
    path: string;
    version: string;
  };
  
  // 安装Git
  install(): Promise<string>; // 返回安装路径
  
  // 卸载Git
  uninstall(): Promise<void>;
}
```

---

## 六、与现有模块的集成

### 6.1 与Agent的集成

```typescript
interface GitAgent {
  // 仓库管理
  getRepositories(): GitRepository[];
  openRepository(path: string): GitRepository;
  
  // 状态查询
  getStatus(repo: GitRepository): Promise<GitFileStatus[]>;
  getUncommittedChanges(repo: GitRepository): Promise<GitFileStatus[]>;
  
  // 分支/提交
  getBranches(repo: GitRepository): Promise<GitBranch[]>;
  getCommits(repo: GitRepository, range: string): Promise<GitCommit[]>;
  
  // 提交流程
  createCommit(repo: GitRepository, message: string): Promise<GitCommit>;
  
  // 远程操作
  push(repo: GitRepository): Promise<void>;
  pull(repo: GitRepository): Promise<void>;
  
  // Diff对比
  getDiff(repo: GitRepository, file?: string): Promise<GitDiff[]>;
}
```

### 6.2 与代码编辑器的集成

- 文件级操作：查看/编辑/比较
- Diff查看：对比历史版本
- 文件状态标注：左侧显示变更符号

### 6.3 与服务器管理集成

- SSH方式管理远程Git仓库
- 服务器上的Git操作

---

## 七、安全考虑

| 维度 | 保护措施 |
|------|------ |
| 密钥存储 | 加密存储SSH密钥/Git令牌 |
| 命令执行 | 命令白名单、安全审查 |
| 输入验证 | 用户输入验证、路径遍历防护 |
| 会话管理 | 安全令牌管理、会话隔离 |

### 7.1 安全考虑

| 维度 | 保护措施 |
|------ |------|
| 密钥存储 | 加密存储SSH密钥/Git令牌 |
| 命令执行 | 命令白名单、安全审查 |
| 输入验证 | 用户输入验证、路径遍历防护 |
| 会话管理 | 安全令牌管理、会话隔离 |

---

## 八、实施计划

### 阶段一（基础）
1. Git引擎封装（clone/status/commit/push/pull）
2. 仓库列表与状态显示
3. 基本Diff查看

### 阶段二（增强）
1. 分支/标签管理UI
2. PR/MR创建
3. Git自动安装/检测

### 阶段三（高级）
1. Git钩子系统
2. Git blame查看
3. 多仓库管理

---

## 八、实施计划

### 阶段一（基础）
1. Git引擎封装（clone/status/commit/push/pull）
2. 仓库列表与状态显示
3. 基本Diff查看

### 阶段二（增强）
1. 分支/标签管理UI
2. PR/MR创建
3. Git自动安装/检测

### 阶段三（高级）
1. Git钩子系统
2. Git blame查看
3. 多仓库管理
