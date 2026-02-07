import SwiftUI

// MARK: - 练习完成页面

struct CompletionView: View {
    let displayName: String
    let icon: String
    let accentColor: String
    let duration: TimeInterval
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sleepManager: SleepManager
    
    @State private var timeToSleep: Int = 5  // 默认 5 分钟
    @State private var quality: SleepQuality = .good
    @State private var showingSaveSuccess = false
    
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
                
                // 成功图标
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("completion_great_job")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("completion_session_done")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // 练习信息
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(Color(hex: accentColor))
                        Text(displayName)
                            .foregroundColor(.white)
                    }
                    .font(.headline)
                    
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 入睡时间输入
                VStack(spacing: 12) {
                    Text("completion_how_long")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker("completion_time_to_sleep", selection: $timeToSleep) {
                        Text("< 5 min").tag(0)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("20 min").tag(20)
                        Text("30 min").tag(30)
                        Text("> 30 min").tag(31)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                .padding(.horizontal, 20)
                
                // 质量评价
                VStack(spacing: 8) {
                    Text("completion_quality")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        ForEach(SleepQuality.allCases, id: \.self) { q in
                            Button(action: { quality = q }) {
                                VStack(spacing: 4) {
                                    Text(q.emoji)
                                        .font(.title)
                                    Text(q.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .opacity(quality == q ? 1 : 0.5)
                            .scaleEffect(quality == q ? 1.1 : 1.0)
                        }
                    }
                }
                
                Spacer()
                
                // 保存按钮
                Button(action: saveSession) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("completion_save")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) minutes"
    }
    
    private func saveSession() {
        let session = SleepSession(
            id: UUID(),
            date: Date(),
            bedTime: Date(),
            wakeTime: nil,
            techniqueUsed: displayName,
            timeToFallAsleep: TimeInterval(timeToSleep * 60),
            quality: quality,
            heartRateData: nil,
            notes: nil
        )
        
        sleepManager.addSession(session)
        showingSaveSuccess = true
        
        // 震动反馈
        FeedbackManager.shared.success()
        
        // 延迟后关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
}

// MARK: - 预览

#Preview {
    CompletionView(
        displayName: "4-7-8 呼吸",
        icon: "wind",
        accentColor: "#8B5CF6",
        duration: 180
    )
    .environmentObject(SleepManager())
}
