import SwiftUI

struct WhiteNoisePlayerPage: View {
    let sound: WhiteNoiseType
    let duration: TimeInterval
    
    @StateObject private var player = WhiteNoisePlayer.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showCompletion = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 声音图标
                    VStack(spacing: 16) {
                        Image(systemName: sound.icon)
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: sound.color))
                        
                        Text(sound.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // 波形动画
                    WaveformView(player: player)
                        .frame(height: 120)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 时间显示
                    VStack(spacing: 8) {
                        Text(player.formattedRemainingTime)
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        Text("剩余时间")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 控制按钮
                    HStack(spacing: 40) {
                        // 音量滑块
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.gray)
                            
                            Slider(value: Binding(
                                get: { player.volume },
                                set: { player.setVolume($0) }
                            ), in: 0...1)
                            .tint(.purple)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // 播放控制
                    HStack(spacing: 40) {
                        Button(action: {
                            player.stop()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                        
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
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Circle().fill(Color.purple))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(width: 56, height: 56)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onAppear {
                player.play(sound, duration: duration)
            }
            .onDisappear {
                player.stop()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
                    player.stop()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                player.stop()
            }
            .onChange(of: player.isPlaying) { newValue in
                if !newValue && player.elapsedTime >= duration {
                    showCompletion = true
                }
            }
            .fullScreenCover(isPresented: $showCompletion) {
                CompletionView()
            }
        }
    }
}

struct WaveformView: View {
    @ObservedObject var player: WhiteNoisePlayer
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(player.isPlaying && !player.isPaused ? Color.purple : Color.gray.opacity(0.3))
                    .frame(
                        width: 6,
                        height: CGFloat.random(in: 20...80) * (player.isPlaying && !player.isPaused ? player.waveformAmplitude : 0.3)
                    )
            }
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    WhiteNoisePlayerPage(sound: .rain, duration: 300)
}
