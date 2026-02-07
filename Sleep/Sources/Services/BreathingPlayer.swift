import Foundation
import AVFoundation
import Combine

// MARK: - 呼吸播放器

@MainActor
class BreathingPlayer: ObservableObject {
    static let shared = BreathingPlayer()
    
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentStepIndex = 0
    @Published var currentStepProgress: Double = 0
    @Published var currentCycle = 1
    @Published var totalCycles = 4
    @Published var totalDuration: TimeInterval = 180  // 默认3分钟
    @Published var elapsedTime: TimeInterval = 0
    
    private var technique: BreathingTechnique?
    private var cancellables = Set<AnyCancellable>()
    private var displayLink: CADisplayLink?
    private var stepStartTime: CFTimeInterval = 0
    private var stepTimer: Timer?
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - 公共方法
    
    func start(technique: BreathingTechnique, cycles: Int = 4) {
        self.technique = technique
        self.totalCycles = cycles
        self.totalDuration = technique.recommendedDuration
        self.currentCycle = 1
        self.currentStepIndex = 0
        self.elapsedTime = 0
        self.isPlaying = true
        self.isPaused = false
        
        setupDisplayLink()
        
        // 延迟开始 TTS，确保音频会话已激活
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.speakStep(technique: technique, stepIndex: 0)
        }
    }
    
    func pause() {
        isPaused = true
        stepTimer?.invalidate()
        stopDisplayLink()
    }
    
    func resume() {
        isPaused = false
        setupDisplayLink()
        stepStartTime = CACurrentMediaTime()
    }
    
    func stop() {
        isPlaying = false
        isPaused = false
        stepTimer?.invalidate()
        stepTimer = nil
        stopDisplayLink()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - 私有方法
    
    private func setupDisplayLink() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60)
        displayLink?.add(to: .main, forMode: .common)
        stepStartTime = CACurrentMediaTime()
        
        // 启动步骤计时器
        startStepTimer()
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func startStepTimer() {
        stepTimer?.invalidate()
        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying, !self.isPaused else { return }
            
            self.elapsedTime += 0.1
            
            // 检查是否完成当前步骤
            guard let technique = self.technique else { return }
            let currentStep = technique.steps[self.currentStepIndex]
            let stepDuration = Double(currentStep.duration)
            
            if self.elapsedTime >= stepDuration {
                self.moveToNextStep()
            }
            
            // 检查是否完成所有周期
            if self.currentCycle > self.totalCycles {
                self.completeSession()
            }
        }
    }
    
    @objc private func updateProgress() {
        guard isPlaying, !isPaused, let technique = technique else { return }
        
        let currentStep = technique.steps[currentStepIndex]
        let stepDuration = Double(currentStep.duration)
        
        // 更新进度
        let elapsed = CACurrentMediaTime() - stepStartTime
        currentStepProgress = min(elapsed / stepDuration, 1.0)
    }
    
    private func moveToNextStep() {
        guard let technique = technique else { return }
        
        currentStepIndex += 1
        
        // 检查是否完成一个周期
        if currentStepIndex >= technique.steps.count {
            currentCycle += 1
            currentStepIndex = 0
            
            // 播报新周期
            if currentCycle <= totalCycles {
                speak("Cycle \(currentCycle) of \(totalCycles)")
            }
        }
        
        // 重置计时
        stepStartTime = CACurrentMediaTime()
        currentStepProgress = 0
        
        // 播报当前步骤
        speakStep(technique: technique, stepIndex: currentStepIndex)
    }
    
    private func speakStep(technique: BreathingTechnique, stepIndex: Int) {
        let step = technique.steps[stepIndex]
        let message = "\(step.name) for \(step.duration) seconds"
        speak(message)
    }
    
    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.7
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
        print("TTS: \(message)")
    }
    
    private func completeSession() {
        stop()
        FeedbackManager.shared.completeSession()
    }
    
    // MARK: - 计算属性
    
    var currentStep: BreathingStep? {
        guard let technique = technique else { return nil }
        guard currentStepIndex < technique.steps.count else { return nil }
        return technique.steps[currentStepIndex]
    }
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return elapsedTime / totalDuration
    }
}
