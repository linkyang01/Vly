import SwiftUI

struct WatchBreathingView: View {
    let technique: BreathingTechnique
    
    @State private var isRunning = false
    @State private var currentStepIndex = 0
    @State private var timeRemaining: Double = 0
    @State private var totalElapsed: Double = 0
    @State private var timer: Timer?
    
    private var steps: [BreathingStep] {
        technique.steps
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标
            Image(systemName: technique.icon)
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            // 当前状态
            if isRunning {
                Text(stepName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                // 呼吸动画
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: animationSize, height: animationSize)
                    .scaleEffect(isRunning ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: stepDuration).repeatForever(autoreverses: true), value: isRunning)
                    .onAppear {
                        if !isRunning {
                            startBreathing()
                        }
                    }
                
                // 倒计时
                Text(formatTime(Int(timeRemaining)))
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                // 停止按钮
                Button(action: stopBreathing) {
                    Text("breathing_stop")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            } else {
                Text(stepName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                Spacer()
                
                // 开始按钮
                Button(action: startBreathing) {
                    Text("breathing_start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .padding(.top, 8)
        .navigationTitle(localizedName(for: technique))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopBreathing()
        }
    }
    
    private var stepName: String {
        guard !steps.isEmpty else { return "Ready" }
        let step = steps[currentStepIndex]
        switch step.name {
        case "breathing_inhale", "吸气", "Breathe in": return "breathe_in".localized()
        case "breathing_hold", "屏息", "屏住呼吸", "Hold your breath": return "breathe_hold".localized()
        case "breathing_exhale", "呼气", "Exhale": return "breathe_out".localized()
        default: return step.name.localized()
        }
    }
    
    private var stepDuration: Double {
        guard !steps.isEmpty else { return 4 }
        return steps[currentStepIndex].duration
    }
    
    private var animationSize: CGFloat {
        80
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func startBreathing() {
        guard !steps.isEmpty else { return }
        
        isRunning = true
        currentStepIndex = 0
        timeRemaining = steps[0].duration
        totalElapsed = 0
        startTimer()
    }
    
    private func stopBreathing() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
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
    
    private func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            timeRemaining = steps[currentStepIndex].duration
        } else {
            // 完成一轮
            currentStepIndex = 0
            timeRemaining = steps[0].duration
        }
    }
}

// MARK: - Localized Extension

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    NavigationStack {
        WatchBreathingView(technique: .fourSevenEight)
    }
}
