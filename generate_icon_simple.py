#!/usr/bin/env python3
"""
生成安睡 App 图标 - 纯色版本
"""

# 输出 SVG 代码（可以用在线工具转换为 PNG）
svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#8B5CF6"/>
      <stop offset="50%" style="stop-color:#6366F1"/>
      <stop offset="100%" style="stop-color:#3B82F6"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="10" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  
  <!-- 背景圆 -->
  <circle cx="512" cy="512" r="512" fill="url(#bgGrad)"/>
  
  <!-- 月亮 -->
  <circle cx="450" cy="512" r="200" fill="#FFF8DC"/>
  <circle cx="550" cy="512" r="200" fill="url(#bgGrad)"/>
  
  <!-- 星星 -->
  <circle cx="700" cy="250" r="15" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="800" cy="450" r="12" fill="#FFFFFF" opacity="0.8"/>
  <circle cx="750" cy="650" r="18" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="850" cy="750" r="10" fill="#FFFFFF" opacity="0.7"/>
  <circle cx="600" cy="550" r="8" fill="#FFFFFF" opacity="0.8"/>
  <circle cx="680" cy="380" r="6" fill="#FFFFFF" opacity="0.6"/>
</svg>'''

# 保存 SVG
svg_path = "/Users/yanglin/.openclaw/workspace/l-sleep/Resources/AppIcon.svg"
with open(svg_path, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"✅ SVG 图标已生成: {svg_path}")
print("📝 可用在线工具 svg-to-png.com 转换为 1024x1024 PNG")
