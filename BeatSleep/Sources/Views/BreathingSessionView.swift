import SwiftUI
import AVFoundation

// MARK: - 4-7-8 呼吸页面（核心功能）

struct BreathingSessionView: View {
    let technique: BreathingTechnique
    let customDuration: TimeInterval?
    
    init(technique: BreathingTechnique, customDuration: TimeInterval? = nil) {
        self.technique = technique
        self.customDuration = customDuration
    }
    
    @State private var currentStepIndex = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var totalElapsed: TimeInterval = 0
    @State private var cycleCount = 0
    @State private var sessionCompleted = false
    @State private var showingCompletion = false
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var totalCycles = 0
    @State private var synthesizer: AVSpeechSynthesizer?
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerSection
                Spacer()
                breathingCircle
                stepInstruction
                Spacer()
                controlButtons
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showingCompletion) {
            GoodNightView()
        }
        .onAppear {
            timeRemaining = technique.steps.first?.duration ?? 0
            let effectiveDuration = customDuration ?? technique.userDuration
            if !technique.steps.isEmpty {
                let cycleDuration = technique.steps.reduce(0) { $0 + $1.duration }
                totalCycles = max(1, Int(effectiveDuration / cycleDuration))
            }
            startBreathing()
        }
        .onDisappear {
            stopBreathing()
        }
    }
    
    // MARK: - 背景渐变
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - 头部
    
    private var headerSection: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 10), spacing: 8)], spacing: 8) {
                ForEach(0..<totalCycles, id: \.self) { index in
                    Circle()
                        .fill(index <= cycleCount ? Color.purple : Color.white.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: 240)
            .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - 呼吸动画圆
    
    private var breathingCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.2), lineWidth: 4)
                .frame(width: 260, height: 260)
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [currentStepColor.opacity(0.3), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(isRunning ? animationScale : 1.0)
                    .animation(
                        .easeInOut(duration: currentStep.duration)
                        .repeatForever(autoreverses: true),
                        value: isRunning && !sessionCompleted
                    )
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(currentStepColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
                
                VStack(spacing: 8) {
                    if sessionCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("breathing_complete".localized())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else if isRunning {
                        Text(currentStep.name)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(Int(timeRemaining) + 1)")
                            .font(.system(size: 64, weight: .light))
                            .foregroundColor(currentStepColor)
                            .monospacedDigit()
                        Text(currentStep.instruction)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("breathing_ready".localized())
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(Int(technique.duration / 60)) " + "techniques_min".localized())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    // MARK: - 动画缩放
    
    private var animationScale: CGFloat {
        switch currentStep.name {
        case "breathing_inhale".localized(), "吸气": return 1.15
        case "breathing_hold".localized(), "屏息", "屏住呼吸": return 1.0
        default: return 0.9
        }
    }
    
    // MARK: - 步骤指示
    
    private var stepInstruction: some View {
        VStack(spacing: 8) {
            if !sessionCompleted && isRunning {
                HStack(spacing: 12) {
                    Circle()
                        .fill(currentStepColor)
                        .frame(width: 8, height: 8)
                    Text("breathing_hold".localized() + " \(Int(timeRemaining)) " + "seconds".localized())
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - 控制按钮
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            if sessionCompleted {
                Button(action: { dismiss() }) {
                    Text("breathing_done".localized())
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(16)
                }
            } else if !isRunning {
                Button(action: startBreathing) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("breathing_start".localized())
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                }
            } else if isPaused {
                HStack(spacing: 16) {
                    Button(action: resumeBreathing) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("breathing_resume".localized())
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(16)
                    }
                    Button(action: { dismiss() }) {
                        Text("breathing_give_up".localized())
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            } else {
                Button(action: pauseBreathing) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("breathing_pause".localized())
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(16)
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - 计算属性
    
    private var currentStep: BreathingStep {
        technique.steps[currentStepIndex]
    }
    
    private var currentStepColor: Color {
        let name = currentStep.name
        if name == "breathing_inhale".localized() || name == "吸气" {
            return Color(hex: "#8B5CF6")
        } else if name == "breathing_hold".localized() || name == "屏息" || name == "屏住呼吸" {
            return Color(hex: "#3B82F6")
        } else {
            return Color(hex: "#10B981")
        }
    }
    
    private var progress: Double {
        guard timeRemaining > 0, currentStep.duration > 0 else { return 1 }
        return 1 - (timeRemaining / currentStep.duration)
    }
    
    // MARK: - TTS 语音
    
    private func speak(_ text: String) {
        guard let synthesizer = synthesizer else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        synthesizer.speak(utterance)
    }
    
    // MARK: - 呼吸控制
    
    private func setupBreathing() {
        synthesizer = AVSpeechSynthesizer()
        timeRemaining = technique.steps.first?.duration ?? 0
        let effectiveDuration = customDuration ?? technique.userDuration
        if !technique.steps.isEmpty {
            let cycleDuration = technique.steps.reduce(0) { $0 + $1.duration }
            totalCycles = max(1, Int(effectiveDuration / cycleDuration))
        }
    }
    
    private func startBreathing() {
        if synthesizer == nil {
            synthesizer = AVSpeechSynthesizer()
        }
        isRunning = true
        isPaused = false
        speakBreathingStep()
        startTimer()
    }
    
    private func pauseBreathing() {
        isPaused = true
        synthesizer?.pauseSpeaking(at: .immediate)
        stopTimer()
    }
    
    private func resumeBreathing() {
        isPaused = false
        synthesizer?.continueSpeaking()
        startTimer()
    }
    
    private func stopBreathing() {
        stopTimer()
        synthesizer?.stopSpeaking(at: .immediate)
        synthesizer = nil
    }
    
    // MARK: - 计时器
    
    @State private var timer: Timer?
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0.1 {
                timeRemaining -= 0.1
                totalElapsed += 0.1
            } else {
                nextStep()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func speakBreathingStep() {
        let isChinese = Locale.current.language.languageCode?.identifier == "zh"
        let inhale = isChinese ? "吸气" : "Breathe in"
        let hold = isChinese ? "屏息" : "Hold your breath"
        let exhale = isChinese ? "呼气" : "Exhale"
        
        switch currentStep.name {
        case "breathing_inhale".localized(), "吸气", "Breathe in":
            speak(inhale)
        case "breathing_hold".localized(), "屏息", "屏住呼吸", "Hold your breath":
            speak(hold)
        case "breathing_exhale".localized(), "呼气", "Exhale":
            speak(exhale)
        default:
            break
        }
    }
    
    private func nextStep() {
        let steps = technique.steps
        
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            timeRemaining = steps[currentStepIndex].duration
            speakBreathingStep()
        } else {
            if cycleCount < totalCycles - 1 {
                cycleCount += 1
                currentStepIndex = 0
                timeRemaining = steps[0].duration
                speakBreathingStep()
            } else {
                completeBreathing()
            }
        }
    }
    
    private func completeBreathing() {
        stopTimer()
        isRunning = false
        sessionCompleted = true
        
        // 计算总时长
        let effectiveDuration = customDuration ?? technique.userDuration
        
        // 调度次日回顾提醒
        NotificationManager.shared.scheduleSleepReviewReminder()
        
        // 显示晚安页面
        showingCompletion = true
    }
}

// MARK: - 预览

#Preview {
    BreathingSessionView(technique: .fourSevenEight)
}
