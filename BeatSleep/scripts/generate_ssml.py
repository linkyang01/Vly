#!/usr/bin/env python3
"""
生成带停顿的 SSML 文本，用于 TTS 网站

使用方法：
1. 打开 https://elevenlabs.io
2. 选择 Text to Speech
3. 切换到 "Manual" 或 "SSML" 模式
4. 复制生成的 SSML 文本
5. 生成下载
"""

import sys
import re

def add_pause_to_text(text, pause_seconds=3):
    """给每句话添加停顿标记"""
    sentences = re.split(r'[。\n]', text)
    sentences = [s.strip() for s in sentences if s.strip()]
    
    ssml = '<speak>\n'
    for i, sentence in enumerate(sentences):
        ssml += f'  {sentence}<break time="{pause_seconds}s"/>\n'
    ssml += '</speak>'
    return ssml

# 渐进式肌肉放松
progressive_cn = """
找一个安静舒适的地方躺下，轻轻闭上眼睛，让身体完全放松，感受每一次呼吸。

现在，把注意力集中在你的双脚，感受脚底的温暖，慢慢收紧脚趾，保持，松开的，感受放松的感觉。

现在把注意力移到小腿，收紧小腿肌肉，保持，完全松开，让重量完全沉入地面。

注意力来到腹部，轻轻收紧腹部，感受腹部的紧张，呼气，让一切放松。

现在手臂和肩膀，慢慢握紧拳头，感受前臂的紧张，松开的，让肩膀完全放松。

最后脸部肌肉，收紧额头，松开的，咬紧牙关，松开的，让整个面部完全放松。

现在整个身体都非常放松，感受呼吸的节奏，就这样静静躺着，给自己一点时间，慢慢回到当下，轻轻睁开眼睛。
"""

# 身体扫描
bodyscan_cn = """
找一个舒适的姿势躺下，轻轻闭上眼睛，自然呼吸，让身体完全放松。

注意力来到右脚脚趾，感受每一个脚趾，现在脚趾慢慢放松，感觉温暖从脚底升起，向右脚踝移动，完全放松。

左脚也是一样，整个双脚都非常放松。

注意力来到右小腿，感受小腿的肌肉，让它完全放松。右大腿，肌肉慢慢松弛。左腿也是一样，整个双腿像棉花一样柔软。

注意力来到腹部，感受腹部的起伏，每一次呼气，腹部完全放松，感受腹部的温暖。

现在胸部，随着呼吸起伏，每一次吸气，胸部微微扩张，呼气完全放松，感受心跳的节奏。

注意力来到右手臂，手指手掌前臂，完全放松，右手臂非常沉重，左手臂也是一样，整个手臂都非常放松。

肩膀慢慢向后放松，感受颈部的连接，让重力带走所有紧张。

最后整个面部，额头放松，眉毛舒展，眼睛完全放松，颊下巴，整个面部像婴儿一样安详。

现在整个身体都非常放松，从脚到头顶，完全松弛，就这样静静感受，给自己一点时间，慢慢回到当下，轻轻睁开眼睛。
"""

if __name__ == '__main__':
    print("=" * 60)
    print("渐进式肌肉放松 - SSML 版本")
    print("=" * 60)
    print(add_pause_to_text(progressive_cn, pause_seconds=3))
    print()
    print("=" * 60)
    print("身体扫描 - SSML 版本")
    print("=" * 60)
    print(add_pause_to_text(bodyscan_cn, pause_seconds=3))
