import SwiftUI

// MARK: - 白噪音播放页面

struct WhiteNoisePlayerPage: View {
    let soundType: WhiteNoiseType
    let duration: TimeInterval  // 单位：秒
    
    @StateObject private var player = WhiteNoisePlayer.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: TimeInterval
    @State private var isPlaying = false
    @State private var timer: Timer?
    
    init(soundType: WhiteNoiseType, duration: TimeInterval = 300) {
        self.soundType = soundType
        self.duration = duration
        _timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // 波形动画
                WaveformView(isPlaying: isPlaying, color: Color(hex: soundType.accentColor))
                    .frame(height: 200)
                
                // 倒计时
                Text(formatTime(timeRemaining))
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                // 当前播放声音
                HStack(spacing: 12) {
                    Image(systemName: soundType.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: soundType.accentColor))
                    
                    Text("playing".localized() + ": " + soundType.displayName)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // 进度条
                ProgressView(value: progress, total: 1)
                    .tint(Color(hex: soundType.accentColor))
                    .padding(.horizontal, 40)
                
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
                        .background(Color(hex: soundType.accentColor))
                        .cornerRadius(16)
                    }
                }
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // 自动开始播放
            startPlayback()
        }
        .onDisappear {
            // 页面关闭时停止
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
        player.play(type: soundType, volume: 0.8)
        isPlaying = true
        startTimer()
    }
    
    private func togglePlay() {
        if isPlaying {
            player.stop()
            timer?.invalidate()
            isPlaying = false
        } else {
            player.play(type: soundType, volume: 0.8)
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
                // 时间到，自动停止
                player.stop()
                timer?.invalidate()
                isPlaying = false
                timeRemaining = 0
            }
        }
    }
}

// MARK: - 波形动画视图

struct WaveformView: View {
    let isPlaying: Bool
    let color: Color
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.6))
                    .frame(width: 8, height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: isPlaying
                    )
            }
        }
        .frame(height: 60)
        .onChange(of: isPlaying) { newValue in
            animating = newValue
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        guard isPlaying else { return 20 }
        let heights: [CGFloat] = [40, 60, 80, 60, 40]
        return heights[index]
    }
}

#Preview {
    WhiteNoisePlayerPage(soundType: .rain, duration: 300)
}
