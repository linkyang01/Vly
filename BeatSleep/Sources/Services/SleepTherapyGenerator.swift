import Foundation

// MARK: - 粉红噪音类型

enum PinkNoiseType: String, CaseIterable, Identifiable {
    case soft = "柔和粉红"
    case deep = "深度粉红"
    case rainfall = "雨声粉红"
    case ocean = "海浪粉红"
    case wind = "微风粉红"
    
    var id: String { rawValue }
    
    var frequencyCutoff: Double {
        switch self {
        case .soft: return 800
        case .deep: return 400
        case .rainfall: return 600
        case .ocean: return 500
        case .wind: return 700
        }
    }
    
    var description: String {
        switch self {
        case .soft: return "柔和细腻，适合浅睡"
        case .deep: return "深沉低频，深度睡眠"
        case .rainfall: return "雨声混合，舒缓放松"
        case .ocean: return "海浪节奏，自然入眠"
        case .wind: return "微风轻拂，轻柔助眠"
        }
    }
}

// MARK: - 等时性 Tone 类型

enum IsochronicToneType: String, CaseIterable, Identifiable {
    case alpha = "Alpha"
    case theta = "Theta"
    case delta = "Delta"
    case gamma = "Gamma"
    
    var id: String { rawValue }
    
    var frequency: Double {
        switch self {
        case .alpha: return 10.0
        case .theta: return 6.0
        case .delta: return 2.0
        case .gamma: return 40.0
        }
    }
    
    var beatRate: Double {
        switch self {
        case .alpha: return 2.0
        case .theta: return 1.5
        case .delta: return 0.5
        case .gamma: return 8.0
        }
    }
    
    var description: String {
        switch self {
        case .alpha: return "放松警觉、平静专注"
        case .theta: return "深度放松、创造力"
        case .delta: return "恢复性睡眠、愈合"
        case .gamma: return "高峰意识、整合"
        }
    }
    
    var icon: String {
        switch self {
        case .alpha: return "cloud.fill"
        case .theta: return "leaf.fill"
        case .delta: return "moon.fill"
        case .gamma: return "sparkles"
        }
    }
}

// MARK: - ASMR 类型

enum ASMRType: String, CaseIterable, Identifiable {
    case whisper = "轻声细语"
    case tapping = "敲击声"
    case scratching = "抓挠声"
    case water = "水滴声"
    case crinkling = "沙沙声"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .whisper: return "温柔语音，舒缓放松"
        case .tapping: return "节奏敲击，引导入睡"
        case .scratching: return "轻柔抓挠，注意力转移"
        case .water: return "流水潺潺，自然氛围"
        case .crinkling: return "纸张沙沙，温暖舒适"
        }
    }
    
    var icon: String {
        switch self {
        case .whisper: return "bubble.left.fill"
        case .tapping: return "hand.tap.fill"
        case .scratching: return "hand.raised.fill"
        case .water: return "drop.fill"
        case .crinkling: return "doc.fill"
        }
    }
}

// MARK: - 疗法生成器管理器

@MainActor
final class SleepTherapyManager: ObservableObject {
    static let shared = SleepTherapyManager()
    
    @Published var pinkNoiseType: PinkNoiseType = .soft
    @Published var isochronicType: IsochronicToneType = .theta
    @Published var asmrType: ASMRType?
    @Published var selectedSoundscape: SleepSoundscape?
    
    @Published private(set) var isPlayingPinkNoise: Bool = false
    @Published private(set) var isPlayingIsochronic: Bool = false
    @Published private(set) var isPlayingASMR: Bool = false
    
    private init() {}
    
    // MARK: - Pink Noise Control
    
    func togglePinkNoise() {
        isPlayingPinkNoise.toggle()
    }
    
    func setPinkNoiseType(_ type: PinkNoiseType) {
        pinkNoiseType = type
    }
    
    // MARK: - Isochronic Tone Control
    
    func toggleIsochronic() {
        isPlayingIsochronic.toggle()
    }
    
    func setIsochronicType(_ type: IsochronicToneType) {
        isochronicType = type
    }
    
    // MARK: - ASMR Control
    
    func toggleASMR(_ type: ASMRType?) {
        if isPlayingASMR && asmrType == type {
            isPlayingASMR = false
            asmrType = nil
        } else {
            asmrType = type
            isPlayingASMR = true
        }
    }
    
    // MARK: - Soundscape Control
    
    func selectSoundscape(_ soundscape: SleepSoundscape?) {
        selectedSoundscape = soundscape
    }
}
