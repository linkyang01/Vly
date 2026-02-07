#!/bin/bash

# BeatSleep 恢复脚本
# 用法: ./scripts/restore.sh [备份文件路径]
# 示例: ./scripts/restore.sh ~/Backups/BeatSleep/BeatSleep_20260206_120000.tar.gz

set -e

if [ -z "$1" ]; then
    echo "用法: ./restore.sh <备份文件路径>"
    echo ""
    echo "可用备份:"
    ls -lh ~/Backups/BeatSleep/*.tar.gz 2>/dev/null || echo "无备份文件"
    exit 1
fi

BACKUP_FILE="$1"
TARGET_DIR="/Users/yanglin/.openclaw/workspace"

echo "=========================================="
echo "  BeatSleep 恢复工具"
echo "=========================================="

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 错误: 找不到备份文件 $BACKUP_FILE"
    exit 1
fi

# 显示备份信息
echo "📦 备份文件: $BACKUP_FILE"
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "📦 大小: $SIZE"
echo ""

# 确认恢复
read -p "⚠️  这将覆盖当前项目。是否继续? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 备份当前版本
if [ -d "$TARGET_DIR/BeatSleep" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    echo "📦 备份当前版本到 BeatSleep_backup_$TIMESTAMP..."
    mv "$TARGET_DIR/BeatSleep" "$TARGET_DIR/BeatSleep_backup_$TIMESTAMP"
fi

# 解压恢复
echo "📦 恢复中..."
tar -xzf "$BACKUP_FILE" -C "$TARGET_DIR"

echo ""
echo "✅ 恢复完成!"
echo ""
echo "旧版本备份位置: $TARGET_DIR/BeatSleep_backup_$TIMESTAMP"
echo "确认无误后可手动删除:"
echo "  rm -rf $TARGET_DIR/BeatSleep_backup_$TIMESTAMP"
