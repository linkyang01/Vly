#!/usr/bin/env python3
"""
生成安睡 App 图标
紫色渐变 + 月亮 + 星星
"""

from PIL import Image, ImageDraw, ImageGradient
import math

# 图标尺寸
SIZE = 1024
CENTER = SIZE // 2

# 颜色配置
COLORS = [
    (139, 92, 246),   # #8B5CF6 紫色
    (99, 102, 241),   # #6366F1 靛蓝
    (168, 85, 247),   # #A855F7 亮紫
    (59, 130, 246),   # #3B82F6 蓝色
]

def create_gradient_background(size):
    """创建紫色渐变背景"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 创建径向渐变
    for i in range(size, 0, -2):
        ratio = 1 - (i / size)
        r = int(COLORS[0][0] + (COLORS[1][0] - COLORS[0][0]) * ratio)
        g = int(COLORS[0][1] + (COLORS[1][1] - COLORS[0][1]) * ratio)
        b = int(COLORS[0][2] + (COLORS[1][2] - COLORS[0][2]) * ratio)
        color = (r, g, b, 255)
        
        # 画圆（从大到小）
        draw.ellipse([size//2 - i//2, size//2 - i//2, size//2 + i//2, size//2 + i//2], 
                             fill=color, outline=None)
    
    return img

def draw_moon(draw, center, radius, color):
    """画月亮"""
    # 主月亮
    draw.ellipse([
        center[0] - radius,
        center[1] - radius,
        center[0] + radius,
        center[1] + radius
    ], fill=color, outline=None)
    
    # 月牙效果（用深色遮挡）
    crescent_radius = radius * 0.9
    crescent_offset = radius * 0.2
    
    # 创建月牙
    draw.ellipse([
        center[0] - crescent_radius + crescent_offset,
        center[1] - crescent_radius,
        center[0] + crescent_radius + crescent_offset,
        center[1] + crescent_radius
    ], fill=(20, 20, 40, 255), outline=None)

def draw_stars(draw, positions, color):
    """画星星"""
    for pos in positions:
        x, y, size = pos
        # 画简单的星星（圆点）
        draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], 
                             fill=color, outline=None)

def main():
    print("🎨 生成安睡 App 图标...")
    
    # 创建透明背景
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    
    # 创建渐变背景层
    bg_layer = create_gradient_background(SIZE)
    img.paste(bg_layer, (0, 0))
    
    # 添加黑色遮罩（圆角）
    mask = Image.new('L', (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.ellipse([0, 0, SIZE, SIZE], fill=255)
    img.putalpha(mask)
    
    # 创建绘图对象
    draw = ImageDraw.Draw(img)
    
    # 月亮参数
    moon_color = (255, 248, 220)  # 米白色
    moon_radius = SIZE * 0.35
    moon_center = (SIZE // 2 - SIZE * 0.1, SIZE // 2)
    
    # 画月亮
    draw_moon(draw, moon_center, moon_radius, moon_color)
    
    # 画星星
    star_positions = [
        (SIZE * 0.7, SIZE * 0.25, 20),
        (SIZE * 0.8, SIZE * 0.45, 15),
        (SIZE * 0.75, SIZE * 0.65, 12),
        (SIZE * 0.85, SIZE * 0.75, 18),
        (SIZE * 0.6, SIZE * 0.55, 10),
        (SIZE * 0.55, SIZE * 0.35, 8),
    ]
    star_color = (255, 255, 255, 200)
    draw_stars(draw, star_positions, star_color)
    
    # 保存图标
    output_path = "/Users/yanglin/.openclaw/workspace/l-sleep/Resources/AppIcon.png"
    img.save(output_path, 'PNG')
    print(f"✅ 图标已生成: {output_path}")
    print(f"📐 尺寸: {SIZE}x{SIZE}")

if __name__ == "__main__":
    main()
