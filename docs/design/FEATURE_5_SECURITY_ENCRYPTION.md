# Worker Agent — 安全/加密模块设计

> 版本: 1.0 | 日期: 2026-06-02
> 定位：平台内敏感数据加密、SSH密钥管理、凭证管理

---

## 一、功能定位

### 1.1 核心价值

| 价值 | 说明 |
|------|------|
| 密钥加密存储 | SSH密钥/Git令牌/API凭证等敏感数据加密|
| 密码管理 | 支持密码/密钥/令牌安全存储 |
| 安全审计 | 记录所有安全相关操作 |
| 安全隔离 | 敏感数据内存隔离 |

### 1.2 约束条件

- 所有敏感数据使用AES-256-GCM加密存储
- 主密钥（Master Key）可设为环境变量或手动输入
- 无需外部服务（如Keychain），纯本地方案

---

## 二、数据模型

### 2.1 主密钥

```typescript
interface MasterKey {
  encrypted: boolean;          // 主密钥是否已加密
  keyId: string;               // 主密钥ID
  createdAt: number;           // 创建时间
  updatedAt: number;           // 更新时间
  algorithm: 'aes-256-gcm';   // 加密算法
  derivedFrom: 'password' | 'env' | 'kdf';  // 派生来源
}

// 主密钥存储格式（加密）
interface EncryptedMasterKey {
  version: string;             // 存储格式版本
  algorithm: string;           // 密钥派生算法
  iterations: number;          // KDF迭代次数
  salt: string;                // 盐值（Base64）
  iv: string;                  // 初始向量（Base64）
  ciphertext: string;          // 密文（Base64）
  tag: string;                 // GCM标签（Base64）
}
```

### 2.2 密钥分类

```typescript
enum KeyType {
  SSH_PRIVATE_KEY = 'ssh-private-key',
  SSH_PUBLIC_KEY = 'ssh-public-key',
  GIT_TOKEN = 'git-token',
  GIT_USERNAME = 'git-username',
  API_KEY = 'api-key',
  DATABASE_PASSWORD = 'database-password',
  SMTP_PASSWORD = 'smtp-password',
  CUSTOM = 'custom'
}

interface KeyRing {
  id: string;                  // 密钥ID
  name: string;                // 密钥名称
  description?: string;        // 描述
  keyType: KeyType;            // 密钥类型
  encryptedData: string;       // 加密后的数据（Base64）
  metadata: {
    host?: string;             // 主机
    username?: string;         // 用户名
    port?: number;             // 端口
    protocol?: string;         // 协议
    fingerprint?: string;      // 指纹
    [key: string]: any;
  };
  createdAt: number
  updatedAt: number:
  createdAt: number;           // 创建时间
  updatedAt: number;           // 更新时间
  isFavorite: boolean;         // 是否收藏
  isLocked: boolean;           // 是否锁定
}
```

### 2.3 凭证项

```typescript
interface CredentialItem {
  id: string;
  name: string;
  type: 'token' | 'password' | 'api-key' | 'ssh-key' | 'custom';
  encryptedData: string;       // 加密后的值
  metadata: {
    url?: string;              // URL
    host?: string;             // 主机
    port?: number;             // 端口
    username?: string;         // 用户名
    [key: string]: any;
  };
  description?: string;
  isFavorite: boolean;
  createdAt: number;
  updatedAt: number;
  lastAccessedAt: number;
  accessCount: number;
}

// SSH密钥项特殊化
interface SshKeyItem {
  id: string;
  name: string;
  type: 'private' | 'public';
  fileName: string;            // 私钥文件名
  privateKeyData: string;      // 私钥数据（加密）
  publicKeyData: string;       // 公钥数据
  fingerprint: string;
  host: string;                // 关联主机
  port: number;                // 端口
  username: string;            // 用户名
  isFavorite: boolean;
  createdAt: number;
  updatedAt: number;
}

interface SshPkiKeyItem {
  id: string;                  // SSH私钥项
  name: string;                // 密钥名称
  type: 'private' | 'public'; // 类型
  fileName: string;            // 私钥文件名
  privateKeyData: string;     // 私钥数据（加密）
  publicKeyData: string;      // 公钥数据（明文）
  fingerprint: string;        // 指纹
  host: string;               // 关联主机
  port: number;               // 端口
  username: string;           // 用户名
  isFavorite: boolean;
  createdAt: number;
  updatedAt: number;
}
```

---

## 三、加密方案

### 3.1 加密流程

```
用户设定 Master Password → PBKDF2 → 主密钥 → AES-256-GCM → 加密数据

1. 用户输入/设置主密码
2. 使用PBKDF2(KDF)派生主密钥（Key Derivation Function）
   - 算法: PBKDF2-SHA256
   - 迭代次数: 100,000
   - 盐值: 随机生成，存储于密钥元数据
3. 主密钥用于加密/解密所有敏感数据
   - 算法: AES-256-GCM（认证加密）
   - IV: 每次加密随机生成，存储于元数据
4. 所有加密数据以JSON格式存储
{
  "id": "key_001",
  "name": "GitHub Token",
  "encryptedData": "<AES-256-GCM密文>",
  "metadata": {
    "algorithm": "aes-256-gcm",
    "iv": "<Base64 IV>",
    "salt": "<Base64 Salt>",
    "version": "1.0"
  }
}
```

### 3.2 主密钥存储

有两种方式：
1. **环境变量**：`WORKER_AGENT_MASTER_KEY`（推荐用于CI/自动化）
2. **用户输入**：每次启动要求输入密码（更安全）

---

## 四、SSH密钥管理

### 4.1 SSH密钥加密存储

```typescript
// SSH私钥加密
// ~/.config/worker-agent/keys/
{
  "keys": [
    {
      "id": "ssh_001",
      "name": "GitHub",
      "type": "private",
      "fileName": "id_github",
      "encryptedData": "EncryptedKeyData",
      "metadata": {
        "host": "github.com",
        "username": "admin",
        "port": "22",
        "fingerprint": "SHA256:...",
        "version": "1"
      },
      "createdAt": 1234567890
      "updatedAt": 987654321,
      "isFavorite": true  // 是否收藏
    }
  ],
  "encryptedPrivateKeys": {
    "key_001": {
      "encryptedData": "<AES-256-GCM密文（私钥内容）>",
      "metadata": {
        "algorithm": "aes-256-gcm",
        "iv": "<Base64 IV>",
        "salt": "<Base64 Salt>",
        "version": "1"
      }
    },
    "encryptedPublicKeys": {
      "key_001": {
        "publicKeyData": "ssh-rsa <public-key> admin@host"  // 公钥明文存储
      }
    }
  }
}
```

### 4.2 SSH Agent集成

```typescript
interface SshAgentManager extends EventEmitter {
  // Agent管理
  start(): Promise<void>;
  stop(): void;
  isRunning(): boolean;
  // 密钥管理
  addKey(key: KeyringItem): Promise<void>;
  removeKey(keyId: string): Promise<void>;
  listKeys(): Promise<KeyringItem[]>;
  // 认证代理
  authWithAgent(host: string, port: number, username: string): Promise<boolean>;
  // 代理转发
  enableForwarding(): void;
  disableForwarding(): void;
  // 事件
  on(event: 'key-added', listener: (key: KeyringItem) => void): this;
  on(event: 'key-removed', listener: (keyId: string) => void): this;
  on(event: 'key-error', listener: (error: Error) => void): this;
}
```

---

## 五、凭证管理

### 5.1 凭证加密

```typescript
interface Credential {
  id: string;
  name: string;
  type: 'token' | 'password' | 'api-key' | 'custom';
  encryptedData: string;     // 加密后的值
  metadata: {
    url?: string;            // URL
    host?: string;           // 主机
    port?: number;           // 端口
    username?: string;       // 用户名
    [key: string]: any;
  };
  description?: string;
  isFavorite: boolean;
  createdAt: number;
  updatedAt: number;
  lastAccessedAt: number;
  accessCount: number;
}

interface EncryptedCredential {
  id: string;
  name: string;
  type: 'token' | 'password' | 'api-key' | 'custom';
  encryptedData: string;     // 加密后的值
  metadata: {
    algorithm: string;
    iv: string;
    salt: string;
    version: string;
    url?: string;
    host?: string;
    port?: number;
    username?: string;
    [key: string]: any;
  };
  description?: string;
  isFavorite: boolean;
  createdAt: number;
  updatedAt: number;
  lastAccessedAt: number;
  accessCount: number;
}
```

### 5.1 凭证访问

```typescript
// CredentialManager API
class CredentialManager {
  // CRUD
  create(credential: Credential): Promise<CredentialItem>;
  read(id: string): Promise<CredentialItem>;
  update(id: string, updates: Partial<CredentialItem>): Promise<void>;
  delete(id: string): Promise<void>;
  list(filter?: { favorite?: boolean; type?: string; search?: string }): Promise<CredentialItem[]>;
  decrypt(id: string): Promise<string>;
  // 安全
  lockAll(): Promise<void>;
}
```

---

## 六、安全审计

### 6.1 安全事件记录

```typescript
interface SecurityEvent {
  id: string;                // 事件ID（UUID）
  type: 'key-generated' | 'key-added' | 'key-modified' | 'key-deleted' | 'credential-added' | 'credential-modified' | 'credential-deleted' | 'credential-decrypted' | 'ssh-auth-success' | 'ssh-auth-failed' | 'master-key-changed' | 'import' | 'export' | 'lock' | 'unlock';
  metadata: {
    keyId?: string;
    credentialId?: string;
    host?: string;
    username?: string;
    [key: string]: any;
  };
  timestamp: number;
  source: 'ui' | 'api' | 'automated';
  success: boolean;
  error?: string;
}

// 审计事件存储（JSON文件）
interface SecurityAuditLog {
  events: SecurityEvent[];
  maxEvents: number;
  lastRotation: number;
}
```

### 6.2 审计日志文件

```json
// ~/.config/worker-agent/audit.json
{
  "version": "1.0",
  "events": [
    {
      "id": "evt_001",
      "type": "key-generated",
      "metadata": {
        "keyId": "key_001",
        "type": "ssh-private-key"
      },
      "timestamp": 1717305600000,
      "source": "ui"
      "timestamp": 1717305600000,
      "source": "ui",
    {
      "id": "evt_001",
      "type": "ssh-auth-success",
      "metadata": {
        "keyId": "key_001",
        "host": "github.com",
        "username": "admin"
      },
      "timestamp": 1717305660000,
      "source": "ssh-agent"
    }
  ]
}
```

---

## 七、实施计划

### 阶段一（基础）
1. AES-256-GCM加密模块
2. 主密钥（Master Key）管理
3. SSH密钥加密存储/加载

### 阶段二（增强）
1. 凭证管理器
2. SSH Agent集成
3. 安全审计

### 阶段三（高级）
1. Keychain集成（macOS/Windows）
2. 密钥轮换

---

## 八、安全考虑

| 维度 | 措施 |
|------|--|
| 密钥长度 | 256-bit AES |
| 主密钥安全 | PBKDF2-100k iterations |
| 密码管理 | 用户输入/环境变量 |
| 内存保护 | 敏感数据使用后清除 |
| 日志脱敏 | 所有日志脱敏（无明文密钥）| |
| 审计日志 | 所有敏感事件记录 |
| 权限控制 | 文件权限chmod 600 |
| 备份安全 | 加密备份 |
