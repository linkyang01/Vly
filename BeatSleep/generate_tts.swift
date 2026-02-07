#!/usr/bin/env swift
import AVFoundation

// 生成渐进式肌肉放松 TTS（10分钟）
let progressiveText = """
找一个安静舒适的地方躺下，轻轻闭上眼睛，让身体完全放松，感受每一次呼吸。
现在，把注意力集中在你的双脚，感受脚底的温暖，慢慢收紧脚趾，保持，松开的。
感受放松的感觉。现在把注意力移到小腿，收紧小腿肌肉，保持，完全松开，让重量完全沉入地面。
注意力来到腹部，轻轻收紧腹部，感受腹部的紧张，呼气，让一切放松。
现在手臂和肩膀，慢慢握紧拳头，感受前臂的紧张，松开的，让肩膀完全放松。
最后脸部肌肉，收紧额头，松开的，咬紧牙关，松开的，让整个面部完全放松。
现在整个身体都非常放松，感受呼吸的节奏，就这样静静躺着，给自己一点时间，慢慢回到当下，轻轻睁开眼睛。
"""

// 生成身体扫描 TTS（10分钟）
let bodyScanText = """
找一个舒适的姿势躺下，轻轻闭上眼睛，自然呼吸，让身体完全放松。
注意力来到右脚脚趾，感受每一个脚趾，现在脚趾慢慢放松，感觉温暖从脚底升起，向右脚踝移动，完全放松。
左脚也是一样，整个双脚都非常放松。注意力来到右小腿，感受小腿的肌肉，让它完全放松。右大腿，肌肉慢慢松弛。
左腿也是一样，整个双腿像棉花一样柔软。注意力来到腹部，感受腹部的起伏，每一次呼气，腹部完全放松，感受腹部的温暖。
现在胸部，随着呼吸起伏，每一次吸气，胸部微微扩张，呼气完全放松，感受心跳的节奏。
注意力来到右手臂，手指手掌前臂，完全放松，右手臂非常沉重，左手臂也是一样，整个手臂都非常放松。
肩膀慢慢向后放松，感受颈部的连接，让重力带走所有紧张。最后整个面部，额头放松，眉毛舒展，眼睛完全放松，颊下巴，整个面部像婴儿一样安详。
现在整个身体都非常放松，从脚到头顶，完全松弛，就这样静静感受，给自己一点时间，慢慢回到当下，轻轻睁开眼睛。
"""

func speak(_ text: String, filename: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: text)
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.5  // 很慢
    utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
    utterance.volume = 1.0
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let outputURL = documentsPath.appendingPathComponent(filename)
    
    print("生成中: \(filename)...")
    
    // 注意：AVSpeechSynthesizer 不能直接导出为音频文件
    // 这个脚本仅供参考，实际需要用专业录音棚或在线 TTS 服务
    print("注意：AVSpeechSynthesizer 无法直接导出 MP3")
    print("建议：使用 Azure TTS 或 Google Cloud TTS API 生成")
}

speak(progressiveText, filename: "progressive_tts.txt")
speak(bodyScanText, filename: "bodyscan_tts.txt")
