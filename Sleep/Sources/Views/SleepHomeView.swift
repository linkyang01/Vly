import SwiftUI

// MARK: - 首页

struct SleepHomeView: View {
    @EnvironmentObject var sleepManager: SleepManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 今日卡片
                        TodayCard()
                        
                        // 趋势卡片
                        if let trend = sleepManager.improvementFromLastWeek {
                            TrendCard(improvement: trend)
                        }
                        
                        // 历史记录
                        if !sleepManager.sessions.isEmpty {
                            RecentSessionsCard(sessions: Array(sleepManager.sessions.prefix(5)))
                        } else {
                            EmptyStateCard()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("home_title".localized())
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - 背景渐变
    
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
}

// MARK: - 今日卡片

struct TodayCard: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("home_tonight".localized())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("home_ready_sleep".localized())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "moon.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            // 快捷开始按钮
            NavigationLink(destination: TechniquesView()) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("home_start_routine".localized())
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - 趋势卡片

struct TrendCard: View {
    let improvement: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("home_getting_better".localized())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("home_falling_asleep".localized() + " " + improvement)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.15))
        )
    }
}

// MARK: - 历史记录卡片

struct RecentSessionsCard: View {
    let sessions: [SleepSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("home_recent_sleep".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: AllSessionsView()) {
                    Text("home_see_all".localized())
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            
            ForEach(sessions) { session in
                SessionRow(session: session)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - 会话行

struct SessionRow: View {
    let session: SleepSession
    
    var body: some View {
        HStack {
            // 日期
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(session.date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(formatTime(session.bedTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 入睡时间
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.formattedTimeToFallAsleep)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Text(session.techniqueUsed)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 质量
            Text(session.quality.emoji)
                .font(.title3)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let isChinese = Locale.current.language.languageCode?.identifier == "zh"
        if isChinese {
            formatter.dateFormat = "M月d日"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - 空状态卡片

struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple.opacity(0.6))
            
            Text("home_no_records".localized())
                .font(.headline)
                .foregroundColor(.white)
            
            Text("home_first_session".localized())
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: TechniquesView()) {
                Text("home_get_started".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        SleepHomeView()
            .environmentObject(SleepManager())
    }
}
