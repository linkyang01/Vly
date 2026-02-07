//
//  AchievementService.swift
//  SleepDo
//
//  成就服务
//

import Foundation
import Combine

class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var progress: [String: AchievementProgress] = [:]
    @Published var unlockedAchievements: [Achievement] = []
    @Published var totalUnlocked: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "achievement_progress"
    
    init() {
        loadProgress()
    }
    
    // MARK: - Public Methods
    
    func incrementProgress(for achievementId: String, by value: Int = 1) {
        guard let achievement = Achievement.all.first(where: { $0.id == achievementId }) else {
            return
        }
        
        if progress[achievementId] == nil {
            progress[achievementId] = AchievementProgress(
                id: achievementId,
                currentValue: 0,
                isUnlocked: false,
                unlockedAt: nil
            )
        }
        
        progress[achievementId]?.currentValue += value
        
        // 检查是否解锁
        checkUnlock(achievement: achievement)
        
        saveProgress()
    }
    
    func checkUnlock(achievement: Achievement) {
        guard let currentProgress = progress[achievement.id],
              !currentProgress.isUnlocked else {
            return
        }
        
        if currentProgress.currentValue >= achievement.targetValue {
            unlock(achievement: achievement)
        }
    }
    
    func unlock(achievement: Achievement) {
        progress[achievement.id]?.isUnlocked = true
        progress[achievement.id]?.unlockedAt = Date()
        
        if !unlockedAchievements.contains(achievement) {
            unlockedAchievements.append(achievement)
        }
        
        totalUnlocked = unlockedAchievements.count
        saveProgress()
        
        // 发送通知
        NotificationCenter.default.post(
            name: .achievementUnlocked,
            object: nil,
            userInfo: ["achievement": achievement]
        )
    }
    
    func isUnlocked(_ achievementId: String) -> Bool {
        progress[achievementId]?.isUnlocked ?? false
    }
    
    func getProgress(_ achievementId: String) -> AchievementProgress? {
        progress[achievementId]
    }
    
    func getAchievement(_ achievementId: String) -> Achievement? {
        Achievement.all.first { $0.id == achievementId }
    }
    
    func resetAllProgress() {
        progress.removeAll()
        unlockedAchievements.removeAll()
        totalUnlocked = 0
        userDefaults.removeObject(forKey: progressKey)
    }
    
    // MARK: - Category Stats
    
    func unlockedCount(for category: AchievementCategory) -> Int {
        Achievement.all
            .filter { $0.category == category }
            .filter { isUnlocked($0.id) }
            .count
    }
    
    func totalCount(for category: AchievementCategory) -> Int {
        Achievement.all.filter { $0.category == category }.count
    }
    
    // MARK: - Persistence
    
    private func loadProgress() {
        guard let data = userDefaults.data(forKey: progressKey),
              let saved = try? JSONDecoder().decode([String: AchievementProgress].self, from: data) else {
            return
        }
        
        progress = saved
        unlockedAchievements = Achievement.all.filter { isUnlocked($0.id) }
        totalUnlocked = unlockedAchievements.count
    }
    
    private func saveProgress() {
        guard let data = try? JSONEncoder().encode(progress) else {
            return
        }
        userDefaults.set(data, forKey: progressKey)
    }
}

extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}

// MARK: - Achievement Progress Extensions

extension AchievementProgress {
    var displayProgress: String {
        guard let achievement = Achievement.all.first(where: { $0.id == id }) else {
            return ""
        }
        return "\(currentValue)/\(achievement.targetValue)"
    }
    
    var displayPercentage: Int {
        Int(progress * 100)
    }
}
