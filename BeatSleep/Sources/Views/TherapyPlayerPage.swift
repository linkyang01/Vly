import SwiftUI

// MARK: - 冥想引导播放页面

struct TherapyPlayerPage: View {
    let therapyType: TherapyType
    let duration: TimeInterval  // 单位：秒
    
    @StateObject private var player = TherapyPlayer.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: TimeInterval
    @State private var isPlaying = false
    @State private var showGuideIndicator = true
    @State private var timer: Timer?
    @State private var showingCompletion = false
    
    init(therapyType: TherapyType, duration: TimeInterval = 300) {
        self.therapyType = therapyType
        self.duration = duration
        _timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: therapyType.accentColor).opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // 图标
                Image(systemName: therapyType.icon)
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: therapyType.accentColor))
                    .padding(.bottom, 16)
                
                // 标题
                Text(therapyType.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 引导语状态
                if player.isGuidePlaying {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .foregroundColor(.green)
                        Text("guide_playing".localized())
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // 倒计时
                Text(formatTime(timeRemaining))
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                // 进度条
                ProgressView(value: progress, total: 1)
                    .tint(Color(hex: therapyType.accentColor))
                    .padding(.horizontal, 60)
                
                Spacer()
                    .frame(height: 40)
                
                // 控制按钮
                HStack(spacing: 24) {
                    Button(action: togglePlay) {
                        HStack {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            Text(isPlaying ? "pause".localized() : "play".localized())
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140)
                        .padding()
                        .background(Color(hex: therapyType.accentColor))
                        .cornerRadius(16)
                    }
                }
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showingCompletion) {
            CompletionView(
                displayName: therapyType.displayName,
                icon: therapyType.icon,
                accentColor: therapyType.accentColor,
                duration: duration
            )
        }
        .onAppear {
            startPlayback()
        }
        .onDisappear {
            player.stop()
            timer?.invalidate()
        }
    }
    
    // MARK: - 计算属性
    
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return 1 - (timeRemaining / duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - 播放控制
    
    private func startPlayback() {
        player.play(type: therapyType, volume: 1.0)
        isPlaying = true
        startTimer()
    }
    
    private func togglePlay() {
        if isPlaying {
            player.stop()
            timer?.invalidate()
            isPlaying = false
        } else {
            player.play(type: therapyType, volume: 1.0)
            isPlaying = true
            startTimer()
        }
    }
    
    private func stopAndDismiss() {
        player.stop()
        timer?.invalidate()
        dismiss()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                player.stop()
                timer?.invalidate()
                isPlaying = false
                timeRemaining = 0
                showingCompletion = true
            }
        }
    }
}

// MARK: - 背景音选择视图

struct BackgroundSoundSelector: View {
    @Binding var selectedSound: WhiteNoiseType?
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("background_sound".localized())
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 无背景音选项
                    Button(action: { if isEnabled { selectedSound = nil } }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(selectedSound == nil ? 0.2 : 0.1))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "speaker.slash.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Text("none".localized())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(selectedSound == nil ? 1 : 0.5))
                        }
                        .frame(width: 70)
                    }
                    .opacity(isEnabled ? 1 : 0.5)
                    
                    // 白噪音选项
                    ForEach(WhiteNoiseType.allCases) { sound in
                        Button(action: { if isEnabled { selectedSound = sound } }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: sound.accentColor).opacity(selectedSound == sound ? 0.3 : 0.15))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: sound.icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(Color(hex: sound.accentColor))
                                }
                                Text(sound.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(selectedSound == sound ? 1 : 0.5))
                            }
                            .frame(width: 70)
                        }
                        .opacity(isEnabled ? 1 : 0.5)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    TherapyPlayerPage(therapyType: .progressive, duration: 300)
}
