import SwiftUI

struct EyeHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showRestTimer = false
    
    private let dailyGoal = 10
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.green.opacity(0.1),
                    Color.green.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    todayStatsSection
                    quickRestSection
                    tipSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showRestTimer) {
            RestTimerView(onComplete: {
                appState.completeRest(duration: 20)
                showRestTimer = false
            }, onSkip: {
                appState.skipTimer()
                showRestTimer = false
            })
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("EyeCare")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("保护眼睛，守护视力健康")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 10)
    }
    
    // MARK: - Today's Stats Section
    
    private var todayStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日护眼")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // 进度卡片
            VStack(spacing: 16) {
                // 进度条
                HStack(spacing: 12) {
                    Text("\(appState.todayRestCount)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("/ \(dailyGoal)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .green.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(appState.todayRestCount) / CGFloat(dailyGoal), height: 12)
                            .animation(.easeInOut(duration: 0.5), value: appState.todayRestCount)
                    }
                }
                .frame(height: 12)
                
                // 统计信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("上次休息")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let lastRest = appState.lastRestTime {
                            Text(timeAgo(from: lastRest))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        } else {
                            Text("暂无")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("连续天数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(appState.streakDays) 天")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - Quick Rest Section
    
    private var quickRestSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("立即休息")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Button(action: {
                showRestTimer = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title3)
                    Text("开始 20 秒计时")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .green.opacity(0.3), radius: 8, y: 4)
                )
            }
        }
    }
    
    // MARK: - Tip Section
    
    private var tipSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("小知识")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 16) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("20-20-20 法则")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("每 20 分钟看远处 20 秒，可以有效缓解眼疲劳")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - Helpers
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    EyeHomeView()
        .environmentObject(AppState())
}
