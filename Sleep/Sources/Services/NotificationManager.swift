import Foundation
import UserNotifications

// MARK: - 通知管理器

class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - 请求权限
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - 睡前提醒
    
    func scheduleBedtimeReminder(at time: Date) async {
        // 移除旧通知
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        // 创建新通知
        let content = UNMutableNotificationContent()
        content.title = "bedtime_reminder_title".localized()
        content.body = "bedtime_reminder_body".localized()
        content.sound = .default
        content.categoryIdentifier = "BEDTIME_REMINDER"
        
        // 设置触发时间
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "bedtimeReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Bedtime reminder scheduled for \(time)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    // MARK: - 睡眠回顾提醒
    
    func scheduleSleepReviewReminder() async {
        // 移除旧通知
        center.removePendingNotificationRequests(withIdentifiers: ["sleepReviewReminder"])
        center.removeDeliveredNotifications(withIdentifiers: ["sleepReviewReminder"])
        
        // 创建上午 9 点的提醒
        let content = UNMutableNotificationContent()
        content.title = "sleep_review_title".localized()
        content.body = "sleep_review_body".localized()
        content.sound = .default
        content.categoryIdentifier = "SLEEP_REVIEW"
        
        // 设置触发时间（明天上午 9 点）
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        
        let calendar = Calendar.current
        if let nextMorning = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) {
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "sleepReviewReminder",
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
                print("Sleep review reminder scheduled for \(nextMorning)")
            } catch {
                print("Error scheduling sleep review reminder: \(error)")
            }
        }
    }
    
    // MARK: - 取消通知
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func cancelBedtimeReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["bedtimeReminder"])
        center.removeDeliveredNotifications(withIdentifiers: ["bedtimeReminder"])
    }
    
    // MARK: - 获取状态
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
}
