import Foundation
import AVFoundation

// MARK: - 双耳节拍类型

enum BinauralBeatType: String, CaseIterable, Identifiable {
    case delta = "Delta"
    case theta = "Theta"
    case alpha = "Alpha"
    case beta = "Beta"
    case gamma = "Gamma"
    
    var id: String { rawValue }
    
    var frequencyRange: ClosedRange<Double> {
        switch self {
        case .delta: return 0.5...4.0
        case .theta: return 4.0...8.0
        case .alpha: return 8.0...13.0
        case .beta: return 13.0...30.0
        case .gamma: return 30.0...100.0
        }
    }
    
    var defaultFrequency: Double {
        switch self {
        case .delta: return 2.0
        case .theta: return 6.0
        case .alpha: return 10.0
        case .beta: return 20.0
        case .gamma: return 40.0
        }
    }
    
    var description: String {
        switch self {
        case .delta: return "深度睡眠、脑波修复"
        case .theta: return "浅睡、冥想、创造力"
        case .alpha: return "放松、平静、浅睡"
        case .beta: return "专注、警觉、清醒"
        case .gamma: return "高峰体验、整合"
        }
    }
    
    var icon: String {
        switch self {
        case .delta: return "moon.fill"
        case .theta: return "leaf.fill"
        case .alpha: return "cloud.fill"
        case .beta: return "bolt.fill"
        case .gamma: return "sparkles"
        }
    }
}

// MARK: - 双耳节拍配置

struct BinauralBeatConfig: Equatable {
    var type: BinauralBeatType
    var baseFrequency: Double
    var beatFrequency: Double
    var volume: Double
    var isEnabled: Bool
    
    static let `default` = BinauralBeatConfig(
        type: .theta,
        baseFrequency: 200.0,
        beatFrequency: 6.0,
        volume: 0.3,
        isEnabled: false
    )
}

// MARK: - 简化的双耳节拍生成器

@MainActor
final class BinauralBeatGenerator: ObservableObject {
    static let shared = BinauralBeatGenerator()
    
    @Published private(set) var config: BinauralBeatConfig = .default
    @Published private(set) var isPlaying: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var oscillator: AVAudioUnitSampler?
    private var timer: Timer?
    
    private init() {}
    
    func configure(type: BinauralBeatType, volume: Double = 0.3) {
        config = BinauralBeatConfig(
            type: type,
            baseFrequency: 200.0,
            beatFrequency: type.defaultFrequency,
            volume: volume,
            isEnabled: true
        )
    }
    
    func setVolume(_ volume: Double) {
        config.volume = max(0, min(1, volume))
    }
    
    func start() {
        guard !isPlaying else { return }
        guard config.isEnabled else { return }
        
        do {
            setupAudioEngine()
            try audioEngine?.start()
            isPlaying = true
        } catch {
            print("❌ 双耳节拍启动失败: \(error)")
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        audioEngine?.stop()
        audioEngine = nil
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    private func setupAudioEngine() {
        let engine = AVAudioEngine()
        let output = engine.outputNode
        let format = output.outputFormat(forBus: 0)
        
        oscillator = AVAudioUnitSampler()
        engine.attach(oscillator!)
        
        engine.connect(oscillator!, to: output, format: format)
        
        audioEngine = engine
        
        // 模拟播放 - 实际需要加载音频文件
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            // 实际应用中这里会播放生成的音频
        }
    }
}

// MARK: - 预设组合

struct BinauralPreset: Identifiable {
    let id = UUID()
    let name: String
    let type: BinauralBeatType
    let description: String
    
    static let sleep = BinauralPreset(
        name: "睡眠",
        type: .delta,
        description: "帮助进入深度睡眠"
    )
    
    static let relax = BinauralPreset(
        name: "放松",
        type: .alpha,
        description: "平静放松、缓解焦虑"
    )
    
    static let meditation = BinauralPreset(
        name: "冥想",
        type: .theta,
        description: "深度冥想状态"
    )
    
    static let all: [BinauralPreset] = [sleep, relax, meditation]
}
