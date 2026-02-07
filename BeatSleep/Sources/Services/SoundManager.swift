import Foundation
import AVFoundation
import Combine

// MARK: - 声音类型

enum SoundType: String, CaseIterable, Identifiable {
    case rain = "雨声"
    case ocean = "海浪"
    case forest = "森林"
    case wind = "微风"
    case whiteNoise = "白噪音"
    case thunder = "雷雨"
    case fireplace = "壁炉"
    case crickets = "蟋蟀"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "waveform"
        case .forest: return "leaf.fill"
        case .wind: return "wind"
        case .whiteNoise: return "speaker.wave.2.fill"
        case .thunder: return "cloud.bolt.rain.fill"
        case .fireplace: return "flame.fill"
        case .crickets: return "antenna.radiowaves.left.and.right"
        }
    }
    
    var filename: String {
        switch self {
        case .rain: return "rain"
        case .ocean: return "ocean"
        case .forest: return "forest"
        case .wind: return "wind"
        case .whiteNoise: return "white_noise"
        case .thunder: return "thunder"
        case .fireplace: return "fireplace"
        case .crickets: return "crickets"
        }
    }
    
    var category: String {
        switch self {
        case .rain, .thunder: return "nature"
        case .ocean: return "water"
        case .forest, .wind: return "nature"
        case .whiteNoise: return "noise"
        case .fireplace: return "ambient"
        case .crickets: return "nature"
        }
    }
    
    var isPremium: Bool {
        // 免费用户可使用前3个，付费解锁全部
        switch self {
        case .rain, .ocean, .forest: return false
        default: return true
        }
    }
}

// MARK: - 播放状态

enum PlaybackState: Equatable {
    case idle
    case preparing
    case playing
    case paused
    case stopped
}

// MARK: - 声音配置

struct SoundConfig: Equatable {
    var sound: SoundType
    var volume: Double
    var isLooping: Bool
    var fadeInDuration: Double
    var fadeOutDuration: Double
    
    static let `default` = SoundConfig(
        sound: .rain,
        volume: 0.7,
        isLooping: true,
        fadeInDuration: 2.0,
        fadeOutDuration: 2.0
    )
}

// MARK: - 混音配置

struct MixingConfig: Equatable {
    var primarySound: SoundType?
    var secondarySound: SoundType?
    var primaryVolume: Double
    var secondaryVolume: Double
    
    static let `default` = MixingConfig(
        primarySound: nil,
        secondarySound: nil,
        primaryVolume: 0.7,
        secondaryVolume: 0.3
    )
}

// MARK: - SoundManager

@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published private(set) var playbackState: PlaybackState = .idle
    @Published private(set) var currentSound: SoundType?
    @Published var config: SoundConfig = .default
    @Published var mixingConfig: MixingConfig = .default
    @Published var timerDuration: TimeInterval = 1800 // 默认 30 分钟
    
    // 限制追踪
    @Published private(set) var freeUsageMinutes: Int = 0
    @Published private(set) var isSubscribed: Bool = false
    
    private let maxFreeMinutes = 30 // 免费用户每天30分钟
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var usageTimer: Timer?
    
    private init() {
        loadSubscriptionStatus()
        startUsageTracking()
    }
    
    // MARK: - 权限检查
    
    func canPlaySound(_ sound: SoundType) -> Bool {
        if isSubscribed {
            return true
        }
        // 免费用户只能使用免费声音
        return !sound.isPremium
    }
    
    func canUseFeature(_ feature: String) -> Bool {
        if isSubscribed {
            return true
        }
        // 免费用户限制
        switch feature {
        case "premium_sounds":
            return false
        case "binaural_beats":
            return false
        case "stories":
            return false
        case "meditation":
            return false
        default:
            return true
        }
    }
    
    // MARK: - Public Methods
    
    func play(_ sound: SoundType, volume: Double? = nil) -> Bool {
        // 检查权限
        guard canPlaySound(sound) else {
            return false
        }
        guard canUseMoreTime() else {
            // 显示付费墙提示
            return false
        }
        
        stop()
        
        currentSound = sound
        playbackState = .preparing
        
        if let vol = volume {
            config.volume = vol
        }
        
        setupAudioSession()
        
        // 模拟播放（实际需要加载音频文件）
        playbackState = .playing
        startUsageTracking()
        
        return true
    }
    
    func pause() {
        guard playbackState == .playing else { return }
        playbackState = .paused
        stopUsageTracking()
    }
    
    func resume() {
        guard playbackState == .paused else { return }
        guard canUseMoreTime() else { return }
        
        playbackState = .playing
        startUsageTracking()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSound = nil
        playbackState = .idle
        stopUsageTracking()
    }
    
    func setVolume(_ volume: Double) {
        config.volume = max(0, min(1, volume))
        audioPlayer?.volume = Float(config.volume)
    }
    
    func startTimer(duration: TimeInterval? = nil) {
        let duration = duration ?? timerDuration
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSubscriptionStatus() {
        isSubscribed = UserDefaults.standard.bool(forKey: "is_subscribed")
    }
    
    private func startUsageTracking() {
        usageTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.freeUsageMinutes += 1
            }
        }
    }
    
    private func stopUsageTracking() {
        usageTimer?.invalidate()
        usageTimer = nil
    }
    
    private func canUseMoreTime() -> Bool {
        if isSubscribed {
            return true
        }
        return freeUsageMinutes < maxFreeMinutes
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ 音频会话设置失败: \(error)")
        }
    }
    
    // MARK: - 订阅管理
    
    func subscribe() {
        isSubscribed = true
        UserDefaults.standard.set(true, forKey: "is_subscribed")
        freeUsageMinutes = 0
    }
}
