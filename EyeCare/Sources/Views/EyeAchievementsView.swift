import SwiftUI

struct EyeAchievementsView: View {
    @EnvironmentObject var appState: AppState
    
    // 成就列表数据
    let achievements: [Achievement] = [
        // 已解锁
        Achievement(
            id: "beginner",
            title: "新手护眼者",
            description: "完成第 1 次护眼",
            icon: "leaf.fill",
            condition: 1,
            currentProgress: 1,
            isUnlocked: true,
            unlockedDate: Date()
        ),
        Achievement(
            id: "streak3",
            title: "连续护眼 · 3 天",
            description: "连续 3 天完成护眼",
            icon: "flame.fill",
            condition: 3,
            currentProgress: 3,
            isUnlocked: true,
            unlockedDate: Date()
        ),
        Achievement(
            id: "streak5",
            title: "连续护眼 · 5 天",
            description: "连续 5 天完成护眼",
            icon: "flame.fill",
            condition: 5,
            currentProgress: 5,
            isUnlocked: true,
            unlockedDate: Date()
        ),
        // 未解锁
        Achievement(
            id: "streak7",
            title: "每日护眼",
            description: "连续 7 天完成护眼",
            icon: "calendar",
            condition: 7,
            currentProgress: 5,
            isUnlocked: false,
            unlockedDate: nil
        ),
        Achievement(
            id: "eyesGuardian",
            title: "眼睛卫士",
            description: "累计 100 次护眼",
            icon: "eye.fill",
            condition: 100,
            currentProgress: 25,
            isUnlocked: false,
            unlockedDate: nil
        ),
        Achievement(
            id: "master",
            title: "护眼大师",
            description: "累计 365 次护眼",
            icon: "trophy.fill",
            condition: 365,
            currentProgress: 25,
            isUnlocked: false,
            unlockedDate: nil
        )
    ]
    
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
                    unlockedSection
                    lockedSection
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
            Text("成就")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("解锁成就，获得荣誉徽章")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    // MARK: - Unlocked Section
    
    private var unlockedSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("已解锁")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                
                Text("\(achievements.filter { $0.isUnlocked }.count) / \(achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            let unlockedAchievements = achievements.filter { $0.isUnlocked }
            if !unlockedAchievements.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(unlockedAchievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            } else {
                Text("还没有解锁任何成就，继续加油！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Locked Section
    
    private var lockedSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("待解锁")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            let lockedAchievements = achievements.filter { !$0.isUnlocked }
            if !lockedAchievements.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(lockedAchievements) { achievement in
                        AchievementCard(achievement: achievement, isLocked: true)
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Model & View

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let condition: Int
    let currentProgress: Int
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    var progress: Double {
        return Double(currentProgress) / Double(condition)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    var isLocked: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(isLocked ? Color.gray.opacity(0.2) : Color.green.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(isLocked ? .gray : .green)
            }
            
            // 标题
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isLocked ? .gray : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // 描述
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // 进度条
            if !achievement.isUnlocked {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * achievement.progress, height: 6)
                    }
                }
                .frame(height: 6)
                
                Text("\(achievement.currentProgress) / \(achievement.condition)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("已解锁")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground).opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .opacity(isLocked ? 0.7 : 1.0)
    }
}

#Preview {
    EyeAchievementsView()
        .environmentObject(AppState())
}
