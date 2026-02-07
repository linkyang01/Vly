#!/bin/bash

# BeatSleep 自动同步脚本
# 用法: ./scripts/sync.sh

set -e

SOURCE_DIR="/Users/yanglin/.openclaw/workspace/BeatSleep"
ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/BeatSleep"

# 创建 iCloud 目录
mkdir -p "$ICLOUD_DIR"

echo "=========================================="
echo "  BeatSleep 同步工具"
echo "=========================================="

# 同步到 iCloud
echo "📤 同步到 iCloud..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='build' \
    --exclude='DerivedData' \
    --exclude='*.xcodeproj' \
    "$SOURCE_DIR/" \
    "$ICLOUD_DIR/"

echo "✅ 同步完成!"
echo "iCloud 位置: $ICLOUD_DIR"

# 检查 iCloud 可用性
if [ -d "$ICLOUD_DIR" ]; then
    echo ""
    echo "📁 iCloud 内容:"
    ls -la "$ICLOUD_DIR"
fi
