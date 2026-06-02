# Worker Agent — 多仓库管理模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：多Git仓库管理，自动发现/克隆/同步，仓库间关联

---

## 一、功能定位

### 1.1 核心价值

| 价值 | 说明 |
|------|------|
| 多仓库管理 | 统一管理多个Git仓库 |
| 仓库发现 | 自动发现本地Git仓库 |
| 快速切换 | 在仓库间快速切换 |
| 仓库同步 | 批量操作（批量pull/push） |

### 1.2 与现有模块的关系

- git集成模块: 仓库详情查看/操作
- 内置终端: 可在仓库内执行Git命令
- Agent控制台: Agent可操作多仓库
- 服务器管理: 远程仓库管理

---

## 二、数据模型

```typescript
interface GitRepository {
  id: string;              // 仓库ID (UUID)
  path: string;            // 本地路径
  name: string;            // 仓库名称 (如 worker-agent)
  platform: 'github' | 'gitee' | 'self-hosted' | 'unknown';
  platformUrl: string;     // 平台URL (如 https://github.com/user/repo)
  remotes: GitRemote[];
  branches: {
    total: number;
    tracking: number;
    detached: number;
  };
  lastActivity: number;    // 最后修改时间
  lastCommitDate: number;  // 最后提交时间
  lastPushDate: number;    // 最后推送时间
  createdAt: number;       // 仓库创建时间
  icon: string;            // 仓库图标
  language: string;        // 主要语言
  starCount: number;       // star数量
  description: string;     // 仓库描述
  tags: string[];          // 仓库标签
}

interface GitRemote {
  id: string;
  name: string;            // 远程名称 (origin, upstream, fork)
  url: string;             // URL
  isPushable: boolean;     // 是否可推送
  ref: string;             // 默认分支
  status: 'connected' | 'unreachable' | 'unknown';
  lastFetch: number;       // 最后拉取时间
  lastPush: number;        // 最后推送时间
}
```

---

## 三、交互设计

### 3.1 仓库概览

```
> /workspaces

📁 工作区 (12个仓库, 3个位置)                       [搜索] [排序: 最近活跃] [分组: 按位置]
─────────────────────────────────────────────────────────────────────────────────────────
📂 ~/projects (6个仓库)
  ├── 🐘 worker-agent       v1.0.0 | GitHub | 修改于10分钟前
  ├── 🐘 frontend           v2.1.0 | GitHub | 2小时前
  ├── 🐘 backend            v3.0.0 | GitHub | 昨天
  ├── 📦 api-server         latest  | Gitee | 3天前
  ├── 📦 database-migrate   latest  | Gitee | 1周前
  └── 📁 shared-library     v1.2.0 | GitLab | 2周前

📂 ~/code (4个仓库)
  ├── 🐘 cli-tool          v0.1.0 | GitHub | 1个月前
  ├── 📦 micro-service-a   latest  | Gitee | 1个月前
  ├── 📦 micro-service-b   latest  | Gitee | 1个月前
  └── 📁 test-project      latest  | Gitee | 3个月前

📂 ~/sandbox (2个仓库)
  ├── 🧪 rust-experiment   main | GitHub | 6个月前
  └── 🧪 py-ai-study       main | GitHub | 6个月前
────────────────────────────────────────────────────────────────────────────────────────
[命令] /workspace open <repo> | /workspace sync-all | 双击打开仓库
```

### 3.2 仓库详情

```
> /workspace open worker-agent

📦 worker-agent | GitHub | https://github.com/user/worker-agent
───────────────────────────────────────────────────────────────────────────────
概要:
  当前分支: main
  最近提交: abc1234 feat: 添加OAuth2认证支持    10分钟前
  最后推送: today 12:00
  未推送提交: 2
  未拉取: 1
  修改文件: 3

统计:
  语言: TypeScript 70% / JavaScript 20% / Other 10%
  Star: 0 | Fork: 0 | Watch: 0
  Size: 1.2MB | Files: 42

操作:
  [打开在编辑器] [Open Terminal] [Clone] [Fetch] [Pull] [Push]
───────────────────────────────────────────────────────────────────────────────
```

### 3.3 批量操作

```
> /workspace sync all

📋 批量同步 (12个仓库)
───────────────────────────────────────────────────────────────────────────────
仓库                     操作         状态                耗时
───────────────────────────────────────────────────────────────────────────
worker-agent             fetch+pull   ✅ 成功             1.2s
frontend                 fetch+pull   ✅ 成功             0.8s
backend                  fetch+pull   ⚠️ 需要合并         1.5s
api-server               fetch+pull   ✅ 成功             0.5s
database-migrate         fetch+pull   ✅ 成功             0.3s
shared-library           fetch        ✅ 成功             0.4s
cli-tool                 fetch        ✅ 成功             0.6s
micro-service-a          fetch+pull   ✅ 成功             0.7s
micro-service-b          fetch+pull   ✅ 成功             0.6s
rust-experiment          fetch        ✅ 成功             0.4s
py-ai-study              fetch        ✅ 成功             0.3s
test-project             fetch        ✅ 成功             0.2s

─────────────────────────────────────────────────────────────────────────────────
结果: ✅ 11成功 | ⚠️ 1需要处理 | ❌ 0失败
[查看详情] [处理冲突] [取消]
```

### 3.4 快捷命令

```
/workspace open <repo>    // 打开仓库
/workspace open --quick   // 使用fzf快速选择
/workspace open --file <file> // 通过文件快速定位仓库
/workspace sync all       // 同步所有仓库
/workspace sync <repo>    // 同步指定仓库
/workspace push all       // 推送到所有仓库
/workspace clone <url>    // 克隆新仓库
/workspace discover [path] // 发现本地仓库
/workspace remove <id>    // 从列表中移除
/workspace remove <id>    // 从列表中移除
```

---

## 四、模块设计

### 4.1 仓库管理器

```typescript
interface WorkspaceManager extends BaseAgent {
  // 仓库管理
  discoverRepositories(baseDir?: string): Promise<GitRepository[]>;
  openRepository(path: string): Promise<GitRepository>;
  removeRepository(id: string): Promise<void>;
  getAllRepositories(): GitRepository[];
  // 仓库操作
  syncAll(options?: SyncOptions): Promise<SyncResult>;
  // 快速搜索
  quickOpen(): Promise<GitRepository>;
  // 统计
  getStats(): WorkspaceStats;
}

interface WorkspaceStats {
  totalRepos: number;
  totalSize: number;
  totalCommits: number;
  totalBranches: number;
  byLocation: Record<string, number>; // 按位置分组
  byPlatform: Record<string, number>; // 按平台分组
}
```

### 4.2 同步引擎

```typescript
interface SyncEngine {
  fetch(repo: GitRepository): Promise<void>;
  pull(repo: GitRepository): Promise<boolean>;
  push(repo: GitRepository): Promise<boolean>;
  sync(repo: GitRepository, options: SyncOptions): Promise<SyncResult>;
  syncAll(options: SyncOptions): Promise<SyncResult[]>;
}

interface SyncOptions {
  fetchOnly?: boolean;
  pullIfBehind?: boolean;
  pushIfAhead?: boolean;
  skipUnreachable?: boolean; // 跳不可达的仓库
  continueOnError?: boolean; // 遇到错误是否继续
  parallel?: number; // 并行数
  reportProgress?: boolean; // 报告进度
}

interface SyncResult {
  repoId: string;
  repoName: string;
  status: 'success' | 'error' | 'conflict' | 'skipped';
  fetchTime: number;
  pullTime: number;
  pushTime: number;
  errors?: string[];
  conflicts?: ConflictInfo[];
}
```

### 4.3 发现引擎

```typescript
interface RepositoryDiscovery {
  // 发现本地仓库
  discoverFromPath(path: string): Promise<GitRepository[]>;
  discoverFromEnv(env: NodeJS.ProcessEnv): Promise<GitRepository[]>;
  // 添加仓库
  addRepository(config: RepositoryConfig): Promise<void>;
  // 移除仓库
  removeRepository(id: string): Promise<void>;
  // 扫描路径
  scanPaths(paths: string[]): Promise<GitRepository[]>;
}
```

---

## 五、配置文件

### 5.1 工作区配置

```json
// data/workspaces.json
{
  "config": {
    "discoverPaths": ["~/projects", "~/code", "~/sandbox"],
    "excludePatterns": ["node_modules", ".git", "dist", "build", "vendor"],
    "autoDiscover": true,
    "syncOnStartup": false,
    "syncInterval": 0,
    "defaultFetchAll": true,
    "showStarred": true
  },
  "repositories": [
    {
      "id": "repo_001",
      "path": "~/projects/worker-agent",
      "name": "worker-agent",
      "platform": "github",
      "platformUrl": "https://github.com/user/worker-agent",
      "active": true,
      "tags": ["main", "core"],
      "icon": "📦",
      "language": "TypeScript",
      "createdAt": 1690000000000,
      "lastAccessedAt": 1717305600000,
      "lastCommitDate": 1717305600000,
      "lastSyncDate": 1717305600000,
      "syncStatus": "synced"
      "lastSyncDate": 1717305600000,
      "syncStatus": "synced"
    {
      "id": "repo_001",
      "path": "~/projects/worker-agent",
      "name": "worker-agent",
      "platform": "github",
      "platformUrl": "https://github.com/user/worker-agent",
      "active": true,
      "tags": ["main", "core"],
      "icon": "📦",
      "language": "TypeScript",
      "createdAt": 1690000000000,
      "lastAccessedAt": 1717305600000,
      "lastCommitDate": 1717305600000,
    "lastSyncDate": 1717305600000,
      "syncStatus": "synced"
    }
  ]
}
```

---

## 六、实施计划

### 阶段一（基础）
1. 仓库发现功能
2. 仓库列表/详情查看
3. 基础同步（fetch/pull/pull/sync）
4. 仓库列表/详情查看
4. 基础同步（fetch/pull/push）

### 阶段二（增强）
1. 多仓库同步
2. 快速打开
3. 仓库配置

### 阶段三（高级）
1. 智能同步策略
2. 仓库关联管理
3. 仓库监控（变更通知）
