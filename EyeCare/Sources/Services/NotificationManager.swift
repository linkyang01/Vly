import Foundation
import UserNotifications

/// 通知管理器
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await setupNotificationCategories()
            }
            return granted
        } catch {
            print("通知权限请求失败: \(error)")
            return false
        }
    }
    
    /// 检查通知权限状态
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    /// 设置通知类别（用于通知交互）
    private func setupNotificationCategories() async {
        // 休息提醒类别
        let restCategory = UNNotificationCategory(
            identifier: "REST_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "START_TIMER",
                    title: "开始计时",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "稍后提醒",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "SKIP",
                    title: "跳过",
                    options: .destructive
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        // 成就解锁类别
        let achievementCategory = UNNotificationCategory(
            identifier: "ACHIEVEMENT_UNLOCK",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_ACHIEVEMENT",
                    title: "查看成就",
                    options: .foreground
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([restCategory, achievementCategory])
    }
    
    /// 发送休息提醒通知
    func sendRestReminder(minutesUntilNext: Int = 20) async {
        let content = UNMutableNotificationContent()
        content.title = "👁️ 让眼睛休息一下"
        content.body = "每 20 分钟看远处 20 秒，有助于缓解眼疲劳"
        content.sound = .default
        content.categoryIdentifier = "REST_REMINDER"
        content.userInfo = ["type": "rest-reminder"]
        
        // 1秒后触发（测试用，实际应用中根据时间间隔触发）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "rest-reminder", content: content, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("发送休息提醒通知失败: \(error)")
        }
    }
    
    /// 发送成就解锁通知
    func sendAchievementUnlockedNotification(achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 EyeCare"
        content.body = "🎉 新成就解锁！\n\(achievement.title)\n\(achievement.description)"
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT_UNLOCK"
        content.userInfo = ["type": "achievement", "achievementId": achievement.id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement-\(achievement.id)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    /// 移除所有待发送的通知
    func removeAllPendingRequests() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// 移除特定通知
    func removeRequest(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
