#!/bin/bash

# BeatSleep 快速备份（极简版）
# 用法: ./scripts/quick_backup.sh

set -e

BACKUP_DIR="$HOME/Backups/BeatSleep"
mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

# 备份 Sources 和 docs
tar -czf "$BACKUP_DIR/BeatSleep_quick_${DATE}_${TIME}.tar.gz" \
    --exclude='.git' \
    -C /Users/yanglin/.openclaw/workspace \
    BeatSleep/Sources \
    BeatSleep/docs \
    BeatSleep/CODING_STANDARDS.md \
    BeatSleep/README.md

echo "✅ 快速备份完成: BeatSleep_quick_${DATE}_${TIME}.tar.gz"
ls -lh "$BACKUP_DIR"/*.tar.gz | tail -3
