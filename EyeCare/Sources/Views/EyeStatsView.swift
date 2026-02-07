import SwiftUI
import Charts

struct EyeStatsView: View {
    @EnvironmentObject var appState: AppState
    
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
                VStack(spacing: 24) {
                    headerSection
                    weeklyStatsSection
                    weeklyTrendSection
                    usageHeatmapSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 120)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("统计")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("用眼数据一览")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    // MARK: - Weekly Stats Section
    
    private var weeklyStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "本周总次数",
                value: "\(appState.weeklyStats.reduce(0) { $0 + $1.restCount })",
                subtitle: "次",
                icon: "eye.fill",
                color: .green
            )
            
            StatCard(
                title: "总护眼时长",
                value: "\(appState.weeklyStats.reduce(0) { $0 + $1.restCount } * 20 / 60)",
                subtitle: "分钟",
                icon: "clock.fill",
                color: .blue
            )
        }
    }
    
    // MARK: - Weekly Trend Section
    
    private var weeklyTrendSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("本周趋势")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // 简化版柱状图
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(appState.weeklyStats) { stat in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(stat.completionRate >= 80 ? Color.green : 
                                      stat.completionRate >= 50 ? Color.yellow : Color.orange)
                                .frame(width: 32, height: CGFloat(stat.completionRate) * 1.5)
                            
                            Text(stat.dayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200)
                
                // 完成率提示
                HStack {
                    Spacer()
                    Text("平均完成率: \(String(format: "%.0f", Double(appState.weeklyStats.reduce(0) { $0 + $1.completionRate }) / Double(appState.weeklyStats.count)))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - Usage Heatmap Section
    
    private var usageHeatmapSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("用眼高峰时段")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // 时段数据
                VStack(spacing: 12) {
                    TimeSlotRow(
                        timeRange: "上午 10-12 点",
                        activity: "活跃",
                        level: 5
                    )
                    
                    TimeSlotRow(
                        timeRange: "下午 2-4 点",
                        activity: "一般",
                        level: 3
                    )
                    
                    TimeSlotRow(
                        timeRange: "晚上 8-10 点",
                        activity: "较少",
                        level: 2
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground).opacity(0.9))
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground).opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

struct TimeSlotRow: View {
    let timeRange: String
    let activity: String
    let level: Int
    
    var body: some View {
        HStack {
            Text(timeRange)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < level ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(activity)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    EyeStatsView()
        .environmentObject(AppState())
}
