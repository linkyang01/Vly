import SwiftUI
import UserNotifications

/// 20秒倒计时视图
struct RestTimerView: View {
    @State private var countdown = 20
    @State private var timer: Timer?
    @State private var isCompleted = false
    
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.green.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // 标题
                Text(isCompleted ? "👁️ 完成！" : "20-20-20 护眼时间")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // 进度圆环
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: isCompleted ? 1 : CGFloat(countdown) / 20)
                        .stroke(
                            isCompleted ? Color.green : 
                                LinearGradient(gradient: Gradient(colors: [.green, .green.opacity(0.7)]), 
                                              startPoint: .leading, 
                                              endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: countdown)
                    
                    // 中心图标
                    if isCompleted {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Image(systemName: "eye.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            if !isCompleted {
                                Text("\(countdown)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // 提示文字
                Text(isCompleted ? "眼睛焕然一新！" : "看向 6 米远的地方")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                Spacer()
                
                // 底部按钮
                if !isCompleted {
                    Button(action: {
                        stopTimer()
                        onSkip()
                    }) {
                        Text("跳过")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                } else {
                    Button(action: {
                        onComplete()
                    }) {
                        Text("完成")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                isCompleted = true
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RestTimerView(onComplete: {}, onSkip: {})
}
