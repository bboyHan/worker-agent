# Worker Agent — 数据备份模块设计

## 一、功能定位

数据备份是平台的核心功能，用于保护用户的数据安全。支持本地备份和远程备份两种方式。

## 二、架构

### 2.1 备份策略

| 方式 | 描述 | 场景 |
|------|------|------|
| 本地备份 | 导出单个文件 | 手动备份、U盘迁移 |
| 远程备份 | 推送到服务器/云存储 | 自动化备份 |
| 自动备份 | 定时自动备份 | 防止数据丢失 |

### 2.2 备份内容

| 项目 | 包含内容 |
|------|--|
| 配置 | settings.json |
| 任务数据 | tasks.json |
| SSH密钥 | keys/（加密） |
| 知识库 | knowledge/** |
| 代码片段 | snippets.json |

### 2.3 备份类型

#### 本地备份（手动）

```
> /backup local --type full --output ~/backups/worker-agent.zip

✅ 备份完成
  文件名: worker-agent-20260602-120000.zip
  大小: 2.3MB
  目录: 12个文件
  备份时间: 2026-06-03 12:00:00

  [查看备份日志]  [打开备份文件]  [取消]
```

#### 远程备份（Push到服务器）

```
> /backup remote --type rsync --dest admin@192.168.1.200:/backups/

✅ 远程备份完成
  方式: rsync
  目标: admin@192.168.1.200:/backups/worker-agent-20260602-120000.zip
  大小: 2.3MB
  耗时: 42ms
```

#### 自动备份（定时）

```
> /backup schedule --every 8h --remote rsync://admin@192.168.1.200:/backups/

✅ 备份策略已配置
  频率: 每8小时
  方式: rsync
  目标: admin@192.168.1.200:/backups/

  [查看详情]  [立即执行]  [取消]
```

## 三、模块设计

```typescript
interface BackupEngine {
  // 创建备份
  createBackup(options: BackupOptions): Promise<BackupFile>;
  
  // 恢复备份
  restoreBackup(backupFile: BackupFile): Promise<boolean>;
  
  // 列表备份
  listBackups(): Promise<BackupFile[]>;
  
  // 删除备份
  deleteBackup(backupId: string): Promise<void>;
  
  // 验证备份
  verifyBackup(backupFile: BackupFile): Promise<boolean>;
}

interface BackupOptions {
  type: 'full' | 'incremental' | 'config-only';
  target: 'local' | 'remote' | 'both';
  dest: string;  // 目标路径/URL
  include: string[];  // 包含的文件/目录
  exclude: string[];  // 排除的文件/目录
  compress: 'none' | 'zip' | 'tar.gz';
  password?: string;  // 备份文件密码（可选）
}

interface BackupFile {
  id: string;
  timestamp: number;
  size: number;
  type: 'full' | 'incremental' | 'config-only';
  dest: string;
  files: string[];
  isEncrypted: boolean;
  isValid: boolean;
}
```

## 四、实施计划

### 阶段一（基础）
1. 本地手动备份/恢复
2. 压缩功能

### 阶段二（增强）
1. 远程推送到服务器
2. SSH密钥加密

### 阶段三（高级）
1. 自动定时备份
2. 远程存储（S3/ OSS）

---

## 四、数据备份模块详细设计

### 4.1 架构总览

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Backup Engine                                                                  │
│ ┌─────────────────────────────┐ ┌──────────────────────┐ ┌────────────────────┐  │
│ │ Local Backup               │ │ Remote Backup       │ │ Auto Backup       │  │
│ │ (手动备份到本地)              │ │ (推送到服务器/云)    │ │ (定时自动备份)      │  │
│ └─────────────────────────────┘ └──────────────────────┘ └────────────────────┘  │
│ ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│ │ Backup Config (备份配置)                                                          │  │
│ │ - 备份策略 (全量/增量/配置)                                                         │  │
│ │ - 备份时间 (手动/定时)                                                         │  │
│ │ - 备份目标 (本地/远程/两者)                                                         │  │
│ │ - 备份内容 (配置/密钥/知识库/所有)                                                   │  │
│ └──────────────────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────────────────
```

### 4.2 数据模型

```typescript
interface BackupConfig {
  id: string;                // 配置ID
  name: string;              // 配置名称
  type: 'full' | 'incremental' | 'config'; // 类型
  target: 'local' | 'remote' | 'both';     // 备份目标
  schedule: {
    enabled: boolean;        // 是否启用定时备份
    interval: '1m' | '5m' | '1h' | '6h' | 'daily' | 'weekly'; // 频率
    lastRun: number;        // 上次运行时间
    nextRun: number;        // 下次运行时间
  };
  options: {
    includePaths: string[];  // 包含的目录/文件
    excludePaths: string[];  // 排除的目录/文件
    encrypt: boolean;        // 是否加密
    compress: 'none' | 'zip' | 'tar.gz'; // 压缩格式
    dest: string;           // 备份目标路径/URL
  };
  isActive: boolean;         // 是否启用
  createdAt: number;         // 创建时间
  updatedAt: number;         // 更新时间
}
```

### 4.3 备份操作

#### 4.3.1 备份创建

```typescript
interface BackupFile {
  id: string;
  timestamp: number;
  type: 'full' | 'incremental' | 'config';
  size: number;            // 备份文件大小
  path: string;            // 备份文件路径
  config: BackupConfig;    // 备份配置
  files: BackupFileEntry[]; // 包含的文件列表
  status: 'created' | 'verifying' | 'verified' | 'error';
  createdAt: number;
}

interface BackupEngine {
  create(options: BackupOptions): Promise<BackupFile>;
  restore(file: BackupFile): Promise<void>;
}

interface BackupOptions {
  type: 'full' | 'incremental' | 'config';
  target: 'local' | 'remote' | 'both';
  dest: string;            // 目标路径/URL
  encrypt: boolean;        // 是否加密
  compress: 'none' | 'zip' | 'tar.gz';
}
```

#### 4.3.2 备份恢复

```
> /backup restore worker-agent-20260602.zip

✅ 备份恢复成功
  已恢复文件:
    - settings.json
    - tasks.json
    - keys/
    - knowledge/
  恢复时间: 2026-06-03 14:00:00

  [查看备份日志]  [打开备份文件]
```

---

## 五、备份策略

### 5.1 备份频率

| 频率 | 适用场景 |
|------|------|
| 每次手动 | 用户主动备份 |
| 每小时 | 重要服务器配置 |
| 每天 | 一般数据备份 |
| 每周 | 长期数据备份 |

### 5.2 备份内容

| 内容 | 说明 |
|------|------|
| 配置文件 | settings.json |
| 密钥文件 | keys/（加密） |
| 任务数据 | tasks.json |
| 代码片段 | snippets.json |
| 知识库 | knowledge/** |
| 自定义目录 | 用户指定 |

---

## 六、实施计划

### 阶段一（基础）
1. 手动备份/恢复功能
2. ZIP压缩打包
3. 备份列表/管理

### 阶段二（增强）
1. 加密备份
2. 远程推送（rsync/SFTP）
3. 增量备份

### 阶段三（高级）
1. 自动定时备份
2. 多地点备份
3. 备份验证/完整性检查
