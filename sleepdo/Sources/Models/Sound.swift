//
//  Sound.swift
//  SleepDo
//
//  声音模型
//

import Foundation
import SwiftUI

struct Sound: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let category: SoundCategory
    let description: String
    let isPremium: Bool
    let unlockAchievementId: String?
    
    init(
        id: String,
        name: String,
        icon: String,
        category: SoundCategory,
        description: String,
        isPremium: Bool = false,
        unlockAchievementId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.category = category
        self.description = description
        self.isPremium = isPremium
        self.unlockAchievementId = unlockAchievementId
    }
}

enum SoundCategory: String, Codable, CaseIterable {
    case natural = "自然"
    case ambient = "环境"
    case whiteNoise = "白噪声"
    case meditation = "冥想"
    case music = "音乐"
    case urban = "城市"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .natural: return "leaf.fill"
        case .ambient: return "cloud.fill"
        case .whiteNoise: return "waveform"
        case .meditation: return "sparkles"
        case .music: return "music.note"
        case .urban: return "building.2.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

extension Sound {
    static let all: [Sound] = [
        // 自然声音
        Sound(id: "rain", name: "雨夜", icon: "cloud.rain.fill", category: .natural, description: "最适合入睡的雨声"),
        Sound(id: "forest_rain", name: "森林雨", icon: "leaf.fill", category: .natural, description: "轻柔的森林雨声"),
        Sound(id: "thunder", name: "雷雨", icon: "cloud.bolt.fill", category: .natural, description: "雷雨交加的震撼声", isPremium: true),
        Sound(id: "waterfall", name: "瀑布", icon: "waterfall.fill", category: .natural, description: "壮观的瀑布声", isPremium: true),
        Sound(id: "river", name: "河流", icon: "river.fill", category: .natural, description: "平静的河流声", isPremium: true),
        Sound(id: "wind", name: "微风", icon: "wind", category: .natural, description: "轻柔的风声", isPremium: true),
        Sound(id: "ocean", name: "海浪", icon: "water.waves.fill", category: .natural, description: "经典的海浪声"),
        Sound(id: "waves_crash", name: "海浪拍打", icon: "water.waves.fill", category: .natural, description: "海浪拍打岩石声", isPremium: true),
        Sound(id: "rainforest", name: "雨林", icon: "tree.fill", category: .natural, description: "热带雨林声", isPremium: true),
        Sound(id: "birds", name: "鸟鸣", icon: "bird.fill", category: .natural, description: "清晨鸟鸣声", isPremium: true),
        Sound(id: "cricket", name: "虫鸣", icon: "antenna.radiowaves.left.and.right", category: .natural, description: "夏夜虫鸣声", isPremium: true),
        Sound(id: "whale", name: "鲸鱼", icon: "figure.wave", category: .natural, description: "鲸鱼歌声", isPremium: true),
        
        // 环境声音
        Sound(id: "fireplace", name: "壁炉", icon: "flame.fill", category: .ambient, description: "温暖的篝火声"),
        Sound(id: "cafe", name: "咖啡厅", icon: "cup.and.saucer.fill", category: .ambient, description: "咖啡厅背景音", isPremium: true),
        Sound(id: "library", name: "图书馆", icon: "book.fill", category: .ambient, description: "安静的图书馆", isPremium: true),
        Sound(id: "fan", name: "电风扇", icon: "fan.fill", category: .ambient, description: "电风扇运转声", isPremium: true),
        Sound(id: "ac", name: "空调", icon: "air.conditioner.horizontal.fill", category: .ambient, description: "空调运转声", isPremium: true),
        Sound(id: "car", name: "车内", icon: "car.fill", category: .ambient, description: "行驶中的车内声", isPremium: true),
        Sound(id: "train", name: "火车", icon: "tram.fill", category: .ambient, description: "火车行驶声", isPremium: true),
        Sound(id: "office", name: "办公室", icon: "building.2.fill", category: .ambient, description: "办公室白噪音", isPremium: true),
        
        // 白噪声
        Sound(id: "white_noise", name: "白噪声", icon: "circle.hexagongrid.fill", category: .whiteNoise, description: "纯白噪声"),
        Sound(id: "pink_noise", name: "粉红噪声", icon: "circle.fill", category: .whiteNoise, description: "柔和的粉红噪声", isPremium: true),
        Sound(id: "brown_noise", name: "布朗噪声", icon: "waveform", category: .whiteNoise, description: "深沉的布朗噪声"),
        Sound(id: "static", name: "静电噪声", icon: "antenna.radiowaves.left.and.right", category: .whiteNoise, description: "老式电视雪花声", isPremium: true),
        
        // 冥想声音
        Sound(id: "singing_bowl", name: "颂钵", icon: "sparkles", category: .meditation, description: "西藏颂钵声", isPremium: true),
        Sound(id: "tibetan_bells", name: "藏铃", icon: "bell.fill", category: .meditation, description: "冥想藏铃声", isPremium: true),
        Sound(id: "chimes", name: "风铃", icon: "wind", category: .meditation, description: "清脆的风铃声", isPremium: true),
        Sound(id: "om", name: "OM唱诵", icon: "waveform.path.ecg", category: .meditation, description: "OM冥想唱诵", isPremium: true),
        Sound(id: "bowl_4min", name: "4分钟颂钵", icon: "clock.fill", category: .meditation, description: "4分钟冥想颂钵"),
        Sound(id: "gong", name: "锣声", icon: "bell.badge.fill", category: .meditation, description: "冥想锣声", isPremium: true),
        
        // 音乐
        Sound(id: "piano", name: "钢琴", icon: "pianokeys", category: .music, description: "轻柔钢琴曲", isPremium: true),
        Sound(id: "guitar", name: "吉他", icon: "guitars.fill", category: .music, description: "轻柔吉他曲", isPremium: true),
        Sound(id: "violin", name: "小提琴", icon: "music.quarternote.3", category: .music, description: "小提琴独奏", isPremium: true),
        Sound(id: "harp", name: "竖琴", icon: "music.note.list", category: .music, description: "竖琴音乐", isPremium: true),
        Sound(id: "ambient_music", name: "氛围音乐", icon: "music.note", category: .music, description: "氛围电子音乐"),
        Sound(id: "classical", name: "古典乐", icon: "music.mic", category: .music, description: "古典乐选段", isPremium: true),
        
        // 城市
        Sound(id: "night_city", name: "夜晚城市", icon: "building.2.fill", category: .urban, description: "夜晚城市背景音", isPremium: true),
        Sound(id: "rain_city", name: "雨夜城市", icon: "cloud.rain.fill", category: .urban, description: "雨夜城市声", isPremium: true),
        Sound(id: "subway", name: "地铁", icon: "tram.tunnel.fill", category: .urban, description: "地铁行驶声", isPremium: true),
        Sound(id: "heartbeat", name: "心跳", icon: "heart.fill", category: .other, description: "放松的心跳声"),
        Sound(id: "prayer", name: "祈祷文", icon: "hands.sparkles.fill", category: .other, description: "平静的祈祷声", isPremium: true),
    ]
    
    static let unlocked: [Sound] = all.filter { !$0.isPremium }
    static let premium: [Sound] = all.filter { $0.isPremium }
    
    static func category(_ category: SoundCategory) -> [Sound] {
        all.filter { $0.category == category }
    }
}
