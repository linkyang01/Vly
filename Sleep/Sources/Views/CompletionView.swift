import SwiftUI

// MARK: - 完成视图

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sleepManager: SleepManager
    @State private var selectedQuality: SleepQuality = .good
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // 标题
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("completion_title".localized())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("completion_message".localized())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 质量选择
                    VStack(spacing: 16) {
                        Text("completion_quality".localized())
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            ForEach(SleepQuality.allCases, id: \.self) { quality in
                                Button(action: { selectedQuality = quality }) {
                                    VStack(spacing: 8) {
                                        Text(quality.emoji)
                                            .font(.system(size: 32))
                                        Text(quality.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedQuality == quality ? Color.purple.opacity(0.3) : Color.white.opacity(0.05))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 完成按钮
                    Button(action: saveAndDismiss) {
                        Text("completion_save".localized())
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 60)
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
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
    
    private func saveAndDismiss() {
        // 保存会话
        let session = SleepSession(
            id: UUID(),
            date: Date(),
            bedTime: Date(),
            wakeTime: nil,
            techniqueUsed: "Breathing",
            timeToFallAsleep: nil,
            quality: selectedQuality,
            heartRateData: nil,
            notes: nil
        )
        
        sleepManager.addSession(session)
        FeedbackManager.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - 预览

#Preview {
    CompletionView()
        .environmentObject(SleepManager())
}
