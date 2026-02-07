import SwiftUI
import AVFoundation

// MARK: - 放松练习引导语

struct RelaxationScript {
    // 渐进式肌肉放松步骤
    static let progressiveScript: [String] = [
        "Find a comfortable position. Close your eyes and take a deep breath.",
        "Let's begin with progressive muscle relaxation. We'll tense and release each muscle group.",
        "Start with your forehead. Scrunch up your forehead muscles. Hold for 5 seconds. Release.",
        "Now your eyes. Squeeze your eyes tightly. Hold. Release.",
        "Move to your jaw. Clench your teeth. Hold. Release and let your jaw relax.",
        "Neck and shoulders. Raise your shoulders up toward your ears. Hold. Release.",
        "Arms. Make fists with both hands. Hold the tension. Release and feel the warmth.",
        "Hands and wrists. Stretch your fingers wide. Hold. Release.",
        "Chest. Take a deep breath and hold. Release slowly.",
        "Stomach. Tighten your abdominal muscles. Hold. Release.",
        "Hips and buttocks. Squeeze your hip muscles. Hold. Release.",
        "Thighs. Tighten your leg muscles. Hold. Release.",
        "Calves. Point your toes upward. Hold. Release.",
        "Feet. Curl your toes. Hold. Release.",
        "Now scan through your body. Notice any areas that still feel tense. Breathe into those areas.",
        "Your whole body feels relaxed and heavy.",
        "Take a deep breath. As you exhale, feel yourself sinking deeper into relaxation.",
        "You are calm, peaceful, and ready for restful sleep.",
        "Stay in this peaceful state. Breathe slowly. Drift into deep relaxation."
    ]
    
    // 身体扫描引导语
    static let bodyScanScript: [String] = [
        "Find a comfortable position. Close your eyes and take a deep breath.",
        "Begin to notice your body. Start at the top of your head.",
        "Notice your forehead. Is it tense? Soften any tension you find.",
        "Your eyes. Let them rest gently. Feel them becoming heavy.",
        "Your cheeks, jaw, and lips. Relax any tightness. Let your mouth soften.",
        "Your neck and throat. Let all the tension melt away.",
        "Your shoulders. They can drop down and relax completely.",
        "Your arms and hands. Feel them becoming heavier with each breath.",
        "Your chest and heart. Feel your heartbeat slowing down.",
        "Your stomach. Let it rise and fall naturally with each breath.",
        "Your lower back. Release any stress you're holding there.",
        "Your hips and pelvis. Let them sink into comfort.",
        "Your thighs. Notice the warmth spreading through your legs.",
        "Your knees and shins. Feel them becoming heavy and relaxed.",
        "Your ankles and feet. Let them completely let go.",
        "Now scan from your feet back up to your head.",
        "Your whole body feels light, peaceful, and completely relaxed.",
        "Breathe slowly. You are safe. You are calm. You are at peace.",
        "Drift deeper into this wonderful relaxation. Sleep is coming naturally."
    ]
}

// MARK: - 疗法播放器页面

struct TherapyPlayerPage: View {
    let technique: BreathingTechnique
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var whiteNoisePlayer = WhiteNoisePlayer.shared
    @State private var isPlaying = false
    @State private var scriptIndex = 0
    @State private var scriptTimer: Timer?
    @State private var timeUntilNextScript = 30
    @State private var currentTime: TimeInterval = 0
    @State private var totalTime: TimeInterval = 600 // 10 minutes
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var script: [String] {
        switch technique {
        case .progressive:
            return RelaxationScript.progressiveScript
        case .bodyScan:
            return RelaxationScript.bodyScanScript
        default:
            return RelaxationScript.progressiveScript
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Therapy icon
                Image(systemName: technique.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                // Title
                Text(technique.shortName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Status
                if isPlaying {
                    Text("播放引导语...")
                        .font(.body)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                // Breathing animation
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: isPlaying ? 180 : 160)
                            .blur(radius: 20)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isPlaying)
                    )
                
                Spacer()
                
                // Progress
                VStack(spacing: 8) {
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white)
                    
                    Text("剩余时间")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 40) {
                    // Quit button
                    Button(action: stopAll) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    
                    // Play/Pause button
                    Button(action: togglePlaying) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.purple))
                    }
                    
                    // Skip button
                    Button(action: stopAll) {
                        Image(systemName: "forward.end")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAll()
        }
        .onDisappear {
            stopAll()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                stopAll()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            stopAll()
        }
    }
    
    private var formattedTime: String {
        let remaining = max(0, totalTime - currentTime)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func togglePlaying() {
        if isPlaying {
            pauseAll()
        } else {
            resumeAll()
        }
    }
    
    private func startAll() {
        isPlaying = true
        currentTime = 0
        timeUntilNextScript = 30
        
        // 播放背景白噪音
        whiteNoisePlayer.play(.rain, duration: totalTime)
        
        // 开始引导语
        speak(script[scriptIndex])
        startScriptTimer()
        startTimeTimer()
    }
    
    private func pauseAll() {
        isPlaying = false
        whiteNoisePlayer.pause()
        scriptTimer?.invalidate()
    }
    
    private func resumeAll() {
        isPlaying = true
        whiteNoisePlayer.resume()
        startScriptTimer()
    }
    
    private func stopAll() {
        isPlaying = false
        whiteNoisePlayer.stop()
        scriptTimer?.invalidate()
        scriptTimer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        dismiss()
    }
    
    private func startScriptTimer() {
        scriptTimer?.invalidate()
        scriptTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            guard isPlaying else { return }
            
            timeUntilNextScript -= 1
            
            if timeUntilNextScript <= 0 {
                scriptIndex += 1
                if scriptIndex < script.count {
                    speak(script[scriptIndex])
                    timeUntilNextScript = 30 // 每30秒播报一次
                } else {
                    // 循环播放
                    scriptIndex = 0
                    speak(script[0])
                    timeUntilNextScript = 30
                }
            }
        }
    }
    
    private func startTimeTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            guard isPlaying else { return }
            currentTime += 1
            if currentTime >= totalTime {
                stopAll()
            }
        }
    }
    
    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.75
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
        print("TTS: \(message)")
    }
}

#Preview {
    TherapyPlayerPage(technique: .progressive)
}
