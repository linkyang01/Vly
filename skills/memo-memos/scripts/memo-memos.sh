#!/bin/bash
# Quick memo script

# 检查参数
if [ $# -eq 0 ]; then
    echo "Usage: memo-memos \"content\" [folder]"
    echo "Example: memo-memos \"开会时间改到3点\""
    exit 1
fi

CONTENT="$1"
FOLDER="${2:-Notes}"

echo "$CONTENT" | memo notes -a -f "$FOLDER"

if [ $? -eq 0 ]; then
    echo "✅ 已添加到备忘录: $CONTENT"
else
    echo "❌ 添加失败"
    exit 1
fi
