import Foundation
import AVFoundation
import Combine

// MARK: - 白噪音播放器

@MainActor
class WhiteNoisePlayer: NSObject, ObservableObject {
    static let shared = WhiteNoisePlayer()
    
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentSound: WhiteNoiseType?
    @Published var volume: Double = 0.7
    @Published var remainingTime: TimeInterval?
    @Published var elapsedTime: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var displayLink: CADisplayLink?
    private var soundStartTime: CFTimeInterval = 0
    
    override private init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - 公共方法
    
    func play(_ sound: WhiteNoiseType, duration: TimeInterval? = nil) {
        print("Attempting to play sound: \(sound.filename)")
        currentSound = sound
        isPlaying = true
        isPaused = false
        remainingTime = duration
        elapsedTime = 0
        
        // 查找声音文件
        guard let url = Bundle.main.url(forResource: sound.filename, withExtension: nil) else {
            print("ERROR: Sound file not found: \(sound.filename)")
            
            // 尝试在 sounds 子文件夹中查找
            if let altUrl = Bundle.main.url(forResource: sound.filename, withExtension: nil, subdirectory: "sounds") {
                print("Found in sounds folder: \(altUrl)")
                setupAudioPlayer(with: altUrl)
                return
            }
            
            // 列出所有可用的资源
            if let resources = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) {
                print("Available mp3 files: \(resources.map { $0.lastPathComponent })")
            }
            return
        }
        
        setupAudioPlayer(with: url)
    }
    
    private func setupAudioPlayer(with url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = Float(volume)
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
            audioPlayer?.prepareToPlay()
            
            let success = audioPlayer?.play() ?? false
            print("Audio player started: \(success), playing: \(audioPlayer?.isPlaying ?? false)")
            
            if audioPlayer?.isPlaying == true {
                soundStartTime = CACurrentMediaTime()
                startTimer()
                startDisplayLink()
            }
            
        } catch {
            print("Error creating audio player: \(error)")
        }
    }
    
    func pause() {
        isPaused = true
        audioPlayer?.pause()
        stopDisplayLink()
    }
    
    func resume() {
        isPaused = false
        audioPlayer?.play()
        soundStartTime = CACurrentMediaTime()
        startDisplayLink()
    }
    
    func stop() {
        isPlaying = false
        isPaused = false
        audioPlayer?.stop()
        audioPlayer = nil
        currentSound = nil
        stopTimer()
        stopDisplayLink()
    }
    
    func setVolume(_ value: Double) {
        volume = value
        audioPlayer?.volume = Float(volume)
    }
    
    // MARK: - 计时器
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime += 1
                
                if let remaining = self?.remainingTime {
                    if self?.elapsedTime ?? 0 >= remaining {
                        self?.stop()
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startDisplayLink() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateDisplay() {
        // 用于触发 UI 更新
    }
    
    // MARK: - Waveform Animation Support
    
    var waveformAmplitude: Double {
        guard isPlaying, !isPaused else { return 0.1 }
        let time = CACurrentMediaTime() - soundStartTime
        return 0.3 + 0.7 * sin(time * 2 * .pi * 0.5)
    }
    
    // MARK: - 格式化
    
    var formattedRemainingTime: String {
        guard let totalRemaining = remainingTime else { return "--:--" }
        let remaining = totalRemaining - elapsedTime
        guard remaining > 0 else { return "00:00" }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioPlayerDelegate

extension WhiteNoisePlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio finished playing: \(flag)")
        stop()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio decode error: \(error)")
        }
    }
}
