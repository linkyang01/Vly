import Foundation
import AVFoundation
import Combine

// MARK: - 冥想引导播放器

class TherapyPlayer: NSObject, ObservableObject {
    static let shared = TherapyPlayer()
    
    @Published var isPlaying = false
    @Published var isGuidePlaying = false  // 引导语播放状态
    @Published var currentTherapyType: TherapyType?
    @Published var currentVolume: Double = 0.5
    
    private var guidePlayer: AVAudioPlayer?
    private var bgPlayer: AVAudioPlayer?
    private var backgroundSoundType: WhiteNoiseType?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - 播放控制
    
    func play(type: TherapyType, backgroundSound: WhiteNoiseType? = nil, volume: Double = 1.0) {
        stop()
        
        currentTherapyType = type
        currentVolume = volume
        isPlaying = true
        isGuidePlaying = true
        
        // 播放引导语
        playGuide(type: type, volume: volume)
        
        // 如果选择了背景音，在引导语结束后播放
        if let sound = backgroundSound {
            backgroundSoundType = sound
            // 引导语时长约 60 秒，60 秒后开始播放背景音
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.playBackground(sound: sound, volume: volume * 0.5)
            }
        }
    }
    
    func stop() {
        guidePlayer?.stop()
        bgPlayer?.stop()
        guidePlayer = nil
        bgPlayer = nil
        isPlaying = false
        isGuidePlaying = false
        currentTherapyType = nil
        backgroundSoundType = nil
    }
    
    func setVolume(_ volume: Double) {
        currentVolume = volume
        guidePlayer?.volume = Float(volume)
        bgPlayer?.volume = Float(volume * 0.5)
    }
    
    // MARK: - 内部方法
    
    private func playGuide(type: TherapyType, volume: Double) {
        let lang = Locale.current.language.languageCode?.identifier == "zh" ? "cn" : "en"
        let fileName = type.fileName(lang: lang)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Guide audio not found: \(fileName).mp3")
            return
        }
        
        do {
            guidePlayer = try AVAudioPlayer(contentsOf: url)
            guidePlayer?.volume = Float(volume)
            guidePlayer?.delegate = self
            guidePlayer?.play()
            print("Playing guide: \(fileName)")
        } catch {
            print("Failed to play guide: \(error)")
        }
    }
    
    private func playBackground(sound: WhiteNoiseType, volume: Double) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3", subdirectory: "sounds") else {
            print("Background sound not found: sounds/\(sound.rawValue).mp3")
            return
        }
        
        do {
            bgPlayer = try AVAudioPlayer(contentsOf: url)
            bgPlayer?.volume = Float(volume)
            bgPlayer?.numberOfLoops = -1  // 循环
            bgPlayer?.play()
            print("Playing background: \(sound.rawValue)")
        } catch {
            print("Failed to play background: \(error)")
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension TherapyPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == guidePlayer {
            isGuidePlaying = false
            // 引导语播放完毕，如果需要继续播放背景音，会继续播放
            // 如果没有背景音，则整个播放结束
            if backgroundSoundType == nil {
                isPlaying = false
                currentTherapyType = nil
            }
        }
    }
}

// MARK: - 冥想类型

enum TherapyType: String, CaseIterable, Identifiable {
    case progressive = "progressive"
    case bodyscan = "bodyscan"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .progressive: return "figure.flexibility"
        case .bodyscan: return "figure.scan"
        }
    }
    
    var displayName: String {
        switch self {
        case .progressive: return "progressive_name".localized()
        case .bodyscan: return "bodyscan_name".localized()
        }
    }
    
    var description: String {
        switch self {
        case .progressive: return "progressive_desc".localized()
        case .bodyscan: return "bodyscan_desc".localized()
        }
    }
    
    var accentColor: String {
        switch self {
        case .progressive: return "#8B5CF6"  // 紫色
        case .bodyscan: return "#06B6D4"     // 青色
        }
    }
    
    func fileName(lang: String) -> String {
        return "\(rawValue)_\(lang)"
    }
}
