import Foundation
import AVFoundation
import Combine

// MARK: - 白噪音播放器

class WhiteNoisePlayer: ObservableObject {
    static let shared = WhiteNoisePlayer()
    
    @Published var isPlaying = false
    @Published var currentSoundType: WhiteNoiseType?
    @Published var currentVolume: Double = 0.5
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
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
    
    func play(type: WhiteNoiseType, volume: Double = 0.8) {
        stop()
        
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "mp3", subdirectory: "sounds") else {
            print("Audio file not found: sounds/\(type.rawValue).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = Float(volume)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentSoundType = type
            currentVolume = volume
            isPlaying = true
            print("Playing: \(type.rawValue), volume: \(volume)")
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentSoundType = nil
    }
    
    func setVolume(_ volume: Double) {
        currentVolume = volume
        audioPlayer?.volume = Float(volume)
    }
}
