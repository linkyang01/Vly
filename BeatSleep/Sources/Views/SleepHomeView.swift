import SwiftUI

// MARK: - 首页

struct SleepHomeView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 渐变背景
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
                            VStack(alignment: .leading, spacing: 12) {
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
                                
                                ForEach(sleepManager.sessions.prefix(5)) { session in
                                    SessionRow(session: session)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.08))
                            )
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

// MARK: - 会话行

struct SessionRow: View {
    let session: SleepSession
    
    var body: some View {
        HStack(spacing: 8) {
            // 时间
            Text(formatTime(session.bedTime))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 45, alignment: .leading)
            
            // 质量
            Text(session.quality.emoji + " " + session.qualityText)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            
            // 时长
            Text(session.durationText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 55, alignment: .leading)
            
            // 练习
            Text("[" + session.techniqueUsed + "]")
                .font(.system(size: 11))
                .foregroundColor(.orange)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - SleepSession 扩展

extension SleepSession {
    var qualityText: String {
        switch quality {
        case .excellent: return "极佳"
        case .good: return "良好"
        case .fair: return "一般"
        case .poor: return "较差"
        }
    }
    
    var durationText: String {
        guard let wakeTime = wakeTime else { return "--" }
        let hours = Int(wakeTime.timeIntervalSince(bedTime) / 3600)
        let minutes = Int(wakeTime.timeIntervalSince(bedTime) / 60) % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
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

// MARK: - 所有会话视图

struct AllSessionsView: View {
    @EnvironmentObject var sleepManager: SleepManager
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "#0D0D1A"),
                    Color(hex: "#1A1A3E"),
                    Color(hex: "#2D1B4E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            List {
                ForEach(sleepManager.sessions) { session in
                    SessionRow(session: session)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("home_see_all".localized())
        .preferredColorScheme(.dark)
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        SleepHomeView()
            .environmentObject(SleepManager())
    }
}
