#!/bin/bash
# 写入备忘录到 Notes.app
# 用法: ./write-memo.sh "内容"

CONTENT="$1"
FOLDER="${2:-Notes}"

osascript <<EOF
tell application "Notes"
    tell folder "$FOLDER"
        make new note with properties {body:"$CONTENT"}
    end tell
end tell
EOF
