import Foundation
import UserNotifications

// MARK: - 通知管理器

class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - 权限请求
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - 检查权限状态
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - 调度每日睡前提醒
    
    func scheduleBedtimeReminder(time: Date, enabled: Bool) {
        center.removeAllPendingNotificationRequests()
        
        guard enabled else { return }
        
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else {
                self?.requestPermission { _ in }
                return
            }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            
            // 计算下次提醒时间
            var nextDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
            
            // 如果今天的时间已经过了，计算到明天
            if nextDate <= Date() {
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            }
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.hour, .minute], from: nextDate),
                repeats: true
            )
            
            let content = UNMutableNotificationContent()
            content.title = "🌙 " + NSLocalizedString("notification_title", comment: "")
            content.body = NSLocalizedString("notification_body", comment: "")
            content.sound = .default
            content.categoryIdentifier = "BEDTIME_REMINDER"
            
            let request = UNNotificationRequest(
                identifier: "bedtimeReminder",
                content: content,
                trigger: trigger
            )
            
            self?.center.add(request)
        }
    }
    
    // MARK: - 调度次日睡眠回顾提醒
    
    func scheduleSleepReviewReminder() {
        // 检查权限
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else {
                self?.requestPermission { _ in }
                return
            }
            
            // 计算明早 9 点的提醒
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.day! += 1
            components.hour = 9
            components.minute = 0
            
            guard let nextDate = calendar.date(from: components) else { return }
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.hour, .minute], from: nextDate),
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = "☀️ " + NSLocalizedString("notification_review_title", comment: "")
            content.body = NSLocalizedString("notification_review_body", comment: "")
            content.sound = .default
            content.categoryIdentifier = "SLEEP_REVIEW"
            
            // 添加自定义操作
            let openAction = UNNotificationAction(
                identifier: "OPEN_REVIEW",
                title: NSLocalizedString("notification_review_open", comment: ""),
                options: [.foreground]
            )
            
            let dismissAction = UNNotificationAction(
                identifier: "DISMISS",
                title: NSLocalizedString("notification_review_later", comment: ""),
                options: []
            )
            
            let category = UNNotificationCategory(
                identifier: "SLEEP_REVIEW",
                actions: [openAction, dismissAction],
                intentIdentifiers: [],
                options: []
            )
            self?.center.setNotificationCategories([category])
            
            let request = UNNotificationRequest(
                identifier: "sleepReviewReminder",
                content: content,
                trigger: trigger
            )
            
            // 移除旧的回顾提醒
            self?.center.removePendingNotificationRequests(withIdentifiers: ["sleepReviewReminder"])
            self?.center.add(request)
        }
    }
    
    // MARK: - 取消所有通知
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - 获取待发送通知列表
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

// MARK: - 本地化字符串

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
