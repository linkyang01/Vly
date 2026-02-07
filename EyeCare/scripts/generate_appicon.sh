#!/bin/bash

# Vly AppIcon 生成脚本
# 用法: ./generate_appicon.sh [项目路径]

set -e

PROJECT_PATH="${1:-.}"
ASSETS_PATH="$PROJECT_PATH/Resources/Assets.xcassets/AppIcon.appiconset"

echo "🎨 生成 AppIcon..."

# 检查 Assets.xcassets 是否存在
if [ ! -d "$ASSETS_PATH" ]; then
    echo "❌ 找不到 Assets.xcassets: $ASSETS_PATH"
    echo "   请确保项目路径正确"
    exit 1
fi

# 创建临时工作目录
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"

# 方法1: 如果有 ImageMagick，使用它
if command -v convert &> /dev/null; then
    echo "📦 使用 ImageMagick 生成图标..."
    
    # 创建基础图标 (渐变背景 + 播放按钮)
    convert -size 1024x1024 \
        gradient:'#1a1a2e-#16213e' \
        -gravity center \
        -fill white \
        -font SF-Mono-Regular \
        -pointsize 400 \
        -annotate 0 "▶" \
        icon_1024.png
    
    # 生成所有尺寸
    for size in 1024 512 256 128 64 32 16; do
        convert icon_1024.png -resize ${size}x${size} icon_${size}.png
    done
    
elif command -v python3 &> /dev/null; then
    echo "🐍 使用 Python + PIL 生成图标..."
    
    # 检查 PIL 是否安装
    python3 -c "from PIL import Image, ImageDraw" 2>/dev/null || pip3 install Pillow
    
    cat > generate_icons.py << 'PYTHON'
import os
from PIL import Image, ImageDraw

sizes = [16, 32, 64, 128, 256, 512, 1024]
colors = {
    'bg': (26, 26, 46, 255),      # 深蓝背景
    'icon': (255, 255, 255, 255)  # 白色图标
}

for size in sizes:
    img = Image.new('RGBA', (size, size), colors['bg'])
    draw = ImageDraw.Draw(img)
    
    # 画播放按钮 (三角形)
    padding = size // 4
    draw.polygon([
        (padding + size//8, padding),
        (padding + size//8, size - padding),
        (size - padding, size // 2)
    ], fill=colors['icon'])
    
    filename = f'icon_{size}.png'
    img.save(filename)
    print(f'✅ {filename}')

print('🎉 完成!')
PYTHON
    
    python3 generate_icons.py
    
    for size in $sizes; do
        mv icon_${size}.png icon_${size}.png 2>/dev/null || true
    done
    
else
    echo "❌ 需要 ImageMagick 或 Python3 + PIL"
    echo ""
    echo "💡 安装方法:"
    echo "   ImageMagick: brew install imagemagick"
    echo "   或 Python: brew install python3 && pip3 install Pillow"
    exit 1
fi

# 检查是否生成了图标
if [ ! -f "icon_1024.png" ]; then
    echo "❌ 图标生成失败"
    exit 1
fi

# 复制到 Assets.xcassets
echo "📁 复制到 Assets.xcassets..."

# 检查 Contents.json 是否存在
if [ ! -f "$ASSETS_PATH/Contents.json" ]; then
    cat > "$ASSETS_PATH/Contents.json" << 'JSON'
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
fi

# 复制图标文件
cp icon_16x16.png "$ASSETS_PATH/icon_16.png" 2>/dev/null || true
cp icon_32x32.png "$ASSETS_PATH/icon_32.png" 2>/dev/null || true
cp icon_128x128.png "$ASSETS_PATH/icon_128.png" 2>/dev/null || true
cp icon_256x256.png "$ASSETS_PATH/icon_256.png" 2>/dev/null || true
cp icon_512x512.png "$ASSETS_PATH/icon_512.png" 2>/dev/null || true

# 清理
rm -rf "$WORK_DIR"

echo ""
echo "✅ AppIcon 生成完成!"
echo "📂 图标位置: $ASSETS_PATH"
echo ""
echo "💡 下一步:"
echo "   1. 打开 Xcode"
echo "   2. 清理项目 (Cmd+Shift+K)"
echo "   3. 重新编译 (Cmd+B)"
