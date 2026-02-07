#!/bin/bash

# BeatSleep 备份脚本
# 用法: ./scripts/backup.sh [本地路径]
# 示例: ./scripts/backup.sh

set -e

# 配置
PROJECT_NAME="BeatSleep"
SOURCE_DIR="/Users/yanglin/.openclaw/workspace/$PROJECT_NAME"
BACKUP_BASE="$HOME/Backups/$PROJECT_NAME"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p "$BACKUP_BASE"

echo "=========================================="
echo "  BeatSleep 备份工具 v1.0"
echo "  日期: $DATE"
echo "=========================================="

# 检查源目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 错误: 找不到项目目录 $SOURCE_DIR"
    exit 1
fi

# 创建备份
BACKUP_FILE="$BACKUP_BASE/${PROJECT_NAME}_${DATE}.tar.gz"
echo "📦 创建备份: $BACKUP_FILE"

tar -czf "$BACKUP_FILE" \
    -C "$(dirname "$SOURCE_DIR")" \
    --exclude='.git' \
    --exclude='build' \
    --exclude='DerivedData' \
    --exclude='*.xcodeproj' \
    "$PROJECT_NAME"

# 检查备份文件
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ 备份成功! 大小: $SIZE"
else
    echo "❌ 备份失败!"
    exit 1
fi

# 清理旧备份（保留最近10个）
BACKUP_COUNT=$(ls -1 "$BACKUP_BASE"/*.tar.gz 2>/dev/null | wc -l)
echo "📊 当前备份数量: $BACKUP_COUNT"

if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo "🧹 清理旧备份（保留最近10个）..."
    ls -t "$BACKUP_BASE"/*.tar.gz | tail -n +11 | xargs -r rm
    echo "✅ 清理完成"
fi

# 列出所有备份
echo ""
echo "📁 所有备份:"
ls -lh "$BACKUP_BASE"/*.tar.gz | tail -5

echo ""
echo "✅ 备份完成!"
echo "备份位置: $BACKUP_FILE"

# 可选：同步到 iCloud
read -p "📤 同步到 iCloud? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "同步到 iCloud..."
    cp "$BACKUP_FILE" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/$PROJECT_NAME/"
    echo "✅ 已同步到 iCloud"
fi

exit 0
