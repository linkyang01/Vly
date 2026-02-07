import SwiftUI

// MARK: - 占位符疗法视图（渐进式肌肉放松、身体扫描、白噪音）

struct PlaceholderTherapyView: View {
    let technique: BreathingTechnique
    let customDuration: TimeInterval?  // 用户自定义时长
    
    init(technique: BreathingTechnique, customDuration: TimeInterval? = nil) {
        self.technique = technique
        self.customDuration = customDuration
    }
    
    private var effectiveDuration: TimeInterval {
        customDuration ?? technique.userDuration
    }
    
    @State private var isPlaying = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // 头部
                VStack(spacing: 16) {
                    Image(systemName: technique.icon)
                        .font(.system(size: 60))
                        .foregroundColor(technique.accentColor)
                    
                    Text(technique.displayName.localized())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                Spacer()
                
                if isPlaying {
                    PlayingAnimationView(technique: technique, timeRemaining: timeRemaining, effectiveDuration: effectiveDuration)
                } else {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(technique.accentColor.opacity(0.3), lineWidth: 4)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: 0.3)
                                .stroke(technique.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("therapy_ready".localized())
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text(formatDuration(effectiveDuration))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    if !isPlaying {
                        Button(action: startSession) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("therapy_start".localized())
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(technique.gradient)
                            .cornerRadius(16)
                        }
                    } else {
                        Button(action: stopSession) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("therapy_stop".localized())
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onDisappear {
            stopSession()
        }
    }
    
    private func startSession() {
        isPlaying = true
        timeRemaining = effectiveDuration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                stopSession()
            }
        }
    }
    
    private func stopSession() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - 播放中动画视图

struct PlayingAnimationView: View {
    let technique: BreathingTechnique
    let timeRemaining: TimeInterval
    let effectiveDuration: TimeInterval
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(technique.accentColor.opacity(0.2 - Double(index) * 0.05))
                        .frame(width: 200 + Double(index) * 40, height: 200 + Double(index) * 40)
                        .scaleEffect(1.0 + ((effectiveDuration - timeRemaining).truncatingRemainder(dividingBy: 2)) * 0.1)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                            value: timeRemaining
                        )
                }
                
                VStack(spacing: 8) {
                    Image(systemName: isActive ? "waveform" : "pause.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Text("therapy_remaining".localized())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var isActive: Bool {
        Int(timeRemaining) % 2 == 0
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        PlaceholderTherapyView(technique: .progressiveMuscleRelaxation)
    }
}
