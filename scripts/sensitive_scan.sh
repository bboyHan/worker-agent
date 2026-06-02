#!/bin/bash
# 敏感内容检测脚本
# 在 git add/commit 之前运行，确保没有敏感内容泄露

set -e

echo "🔍 开始敏感内容扫描..."

# 定义敏感内容模式
SENSITIVE_PATTERNS=(
    "ghp_[a-zA-Z0-9]{20,}"
    "gho_[a-zA-Z0-9]{20,}"
    "ghs_[a-zA-Z0-9]{20,}"
    "ghr_[a-zA-Z0-9]{20,}"
    "sk-[a-zA-Z0-9_-]{20,}"
    "sk-proj-[a-zA-Z0-9_-]{20,}"
    "token.*=.*['\"][a-zA-Z0-9_-]{20,}['\"]"
    "password.*=.*['\"][^'\"]+['\"]"
    "api_key.*=.*['\"][^'\"]+['\"]"
    "AWS[A-Z0-9]{20,}"
    "AIzaSy[a-zA-Z0-9_-]{33}"
    "AKIA[0-9A-Z]{16}"
    "private.key"
    "-----BEGIN.*PRIVATE KEY-----"
    "-----BEGIN RSA PRIVATE KEY-----"
    "-----BEGIN OPENSSH PRIVATE KEY-----"
)

# 检查 git 状态
cd "$(git rev-parse --show-toplevel)"
FILES_TO_CHECK=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || git ls-files --others --exclude-standard)

if [ -z "$FILES_TO_CHECK" ]; then
    echo "✅ 没有需要扫描的文件"
    exit 0
fi

ERRORS=0

for file in $FILES_TO_CHECK; do
    if ! [ -f "$file" ]; then
        continue
    fi
    
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo "❌ 在 $file 中检测到敏感内容匹配: $pattern"
            ERRORS=$((ERRORS + 1))
        fi
    done
done

if [ $ERRORS -gt 0 ]; then
    echo "⚠️ 扫描发现 $ERRORS 个敏感内容问题！"
    echo "请检查这些文件，移除敏感信息后再提交。"
    exit 1
fi

echo "✅ 敏感内容扫描通过！"
exit 0
