//
//  StatsView.swift
//  SleepDo
//
//  睡眠数据统计页面 - AI智能唤醒风格
//

import SwiftUI
import Charts

struct StatsView: View {
    @State private var selectedPeriod: String = "7天"
    let periods = ["7天", "14天", "30天"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部标题
                HStack {
                    Text("睡眠统计")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Picker("周期", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                    .colorMultiply(Color(red: 139/255, green: 92/255, blue: 246/255))
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 睡眠概览卡片
                SleepOverviewCard()
                    .padding(.horizontal)
                
                // 睡眠阶段卡片
                SleepStagesCard()
                    .padding(.horizontal)
                
                // 睡眠趋势图表
                SleepTrendChartCard()
                    .padding(.horizontal)
                
                // 每日睡眠列表
                DailySleepListCard()
                    .padding(.horizontal)
                
                // 成就概览卡片
                AchievementOverviewCard()
                    .padding(.horizontal)
                
                // 底部黑色条
                Color.black.frame(height: 60)
            }
            .padding(.vertical)
        }
        .background(Color.clear.ignoresSafeArea())
    }
}

// MARK: - 睡眠概览卡片
struct SleepOverviewCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // 睡眠时长
                VStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                    Text("7h 23m")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("平均睡眠")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .frame(height: 50)
                
                // 入睡时间
                VStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                    Text("23:42")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("平均入睡")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .frame(height: 50)
                
                // 清醒次数
                VStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                    Text("1.2")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("平均清醒")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

// MARK: - 睡眠阶段卡片
struct SleepStagesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                Text("睡眠阶段分布")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                SleepStageRow(stage: "深睡", icon: "moon.fill", progress: 0.25, color: .blue)
                SleepStageRow(stage: "浅睡", icon: "cloud.moon.fill", progress: 0.45, color: .cyan)
                SleepStageRow(stage: "REM", icon: "sparkles", progress: 0.20, color: .purple)
                SleepStageRow(stage: "清醒", icon: "sun.max.fill", progress: 0.10, color: .orange)
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct SleepStageRow: View {
    let stage: String
    let icon: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                Text(stage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 睡眠趋势图表卡片
struct SleepTrendChartCard: View {
    let sleepData: [SleepData] = [
        SleepData(day: "周一", hours: 6.5),
        SleepData(day: "周二", hours: 7.2),
        SleepData(day: "周三", hours: 8.0),
        SleepData(day: "周四", hours: 7.8),
        SleepData(day: "周五", hours: 6.8),
        SleepData(day: "周六", hours: 8.5),
        SleepData(day: "周日", hours: 7.3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                Text("本周睡眠趋势")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Chart(sleepData) { data in
                BarMark(
                    x: .value("星期", data.day),
                    y: .value("时长", data.hours)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 139/255, green: 92/255, blue: 246/255), Color(red: 168/255, green: 85/255, blue: 247/255)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.2))
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct SleepData: Identifiable {
    let id = UUID()
    let day: String
    let hours: Double
}

// MARK: - 每日睡眠列表卡片
struct DailySleepListCard: View {
    let dailyData: [DailySleep] = [
        DailySleep(date: "今天", score: 85, hours: "7h 23m", quality: .good),
        DailySleep(date: "昨天", score: 78, hours: "6h 45m", quality: .medium),
        DailySleep(date: "上周", score: 92, hours: "8h 12m", quality: .excellent),
        DailySleep(date: "上周", score: 65, hours: "6h 02m", quality: .bad)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                Text("最近记录")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("查看全部") {}
                    .font(.subheadline)
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
            
            VStack(spacing: 12) {
                ForEach(dailyData) { data in
                    DailySleepRow(data: data)
                    if data.id != dailyData.last?.id {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct DailySleepRow: View {
    let data: DailySleep
    
    var qualityColor: Color {
        switch data.quality {
        case .excellent: return .green
        case .good: return .blue
        case .medium: return .orange
        case .bad: return .red
        }
    }
    
    var qualityText: String {
        switch data.quality {
        case .excellent: return "优秀"
        case .good: return "良好"
        case .medium: return "一般"
        case .bad: return "较差"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.date)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(data.hours)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 睡眠质量评分
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)
                Circle()
                    .trim(from: 0, to: CGFloat(data.score) / 100)
                    .stroke(qualityColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                Text("\(data.score)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // 质量标签
            Text(qualityText)
                .font(.caption)
                .foregroundColor(qualityColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(qualityColor.opacity(0.15))
                .cornerRadius(8)
        }
    }
}

enum SleepQuality {
    case excellent, good, medium, bad
}

struct DailySleep: Identifiable {
    let id = UUID()
    let date: String
    let score: Int
    let hours: String
    let quality: SleepQuality
}

// MARK: - 成就概览卡片
struct AchievementOverviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                Text("成就进度")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("12/35")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 139/255, green: 92/255, blue: 246/255), Color(red: 168/255, green: 85/255, blue: 247/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 12/35, height: 12)
                }
            }
            .frame(height: 12)
            
            // 成就类别网格
            AchievementCategoryGrid()
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct AchievementCategoryGrid: View {
    let categories: [(name: String, icon: String, count: String, color: Color)] = [
        ("睡眠", "moon.fill", "3/8", .blue),
        ("连续", "flame.fill", "4/10", .orange),
        ("闹钟", "bell.fill", "2/7", .purple),
        ("里程碑", "star.fill", "3/10", .yellow)
    ]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(categories, id: \.name) { category in
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .frame(width: 32, height: 32)
                        .background(category.color.opacity(0.15))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(category.count)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    StatsView()
}
