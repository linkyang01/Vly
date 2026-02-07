import SwiftUI

// MARK: - 呼吸练习视图

struct BreathingSessionView: View {
    let technique: BreathingTechnique
    @StateObject private var player = BreathingPlayer.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showCompletion = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 呼吸动画
                    BreathingCircleView(
                        player: player,
                        technique: technique
                    )
                    .frame(width: 280, height: 280)
                    
                    Spacer()
                    
                    // 状态信息
                    VStack(spacing: 16) {
                        Text(technique.shortName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let step = player.currentStep {
                            Text(step.name)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                            
                            Text("\(step.duration - Int(player.currentStepProgress * Double(step.duration)))")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white)
                                .monospacedDigit()
                        }
                        
                        // 周期进度
                        HStack(spacing: 8) {
                            Text("Cycle \(player.currentCycle)/\(player.totalCycles)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text(formatTime(player.elapsedTime))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // 控制按钮
                    ControlButtonsView(player: player, onStop: {
                        stopAndDismiss()
                    })
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("quit") {
                        stopAndDismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                player.start(technique: technique)
            }
            // 检测场景变化（后台时停止）
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
                    player.stop()
                }
            }
            // 检测导航状态变化
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                player.stop()
            }
            .onChange(of: player.isPlaying) { newValue in
                if !newValue && !player.isPaused {
                    showCompletion = true
                }
            }
            .fullScreenCover(isPresented: $showCompletion) {
                CompletionView()
            }
        }
    }
    
    private func stopAndDismiss() {
        player.stop()
        dismiss()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#0D0D1A"),
                Color(hex: "#1A1A3E"),
                Color(hex: "#2D1B4E")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - 呼吸圆圈动画

struct BreathingCircleView: View {
    @ObservedObject var player: BreathingPlayer
    let technique: BreathingTechnique
    
    var body: some View {
        ZStack {
            // 外圈（呼吸动画）
            Circle()
                .stroke(Color.purple.opacity(0.2), lineWidth: 4)
                .frame(width: 260, height: 260)
            
            // 内圈（进度动画）
            Circle()
                .trim(from: 0, to: player.currentStepProgress)
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: player.currentStepProgress)
            
            // 呼吸动画圆圈
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(
                    width: 100 + player.currentStepProgress * 120,
                    height: 100 + player.currentStepProgress * 120
                )
                .blur(radius: 20)
                .animation(.linear(duration: 0.05), value: player.currentStepProgress)
            
            // 中心图标
            VStack(spacing: 8) {
                Image(systemName: player.isPaused ? "pause.fill" : (player.isPlaying ? "lungs.fill" : "play.fill"))
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                if player.isPaused {
                    Text("paused")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - 控制按钮

struct ControlButtonsView: View {
    @ObservedObject var player: BreathingPlayer
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // 停止按钮
            Button(action: onStop) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            // 播放/暂停按钮
            Button(action: {
                if player.isPlaying {
                    if player.isPaused {
                        player.resume()
                    } else {
                        player.pause()
                    }
                }
            }) {
                Image(systemName: player.isPaused ? "play.fill" : "pause.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.purple)
                    )
            }
        }
    }
}

// MARK: - 预览

#Preview {
    BreathingSessionView(technique: .fourSevenEight)
}
