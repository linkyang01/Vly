//
//  AlarmService.swift
//  SleepDo
//
//  闹钟服务
//

import Foundation
import UserNotifications
import Combine

class AlarmService: ObservableObject {
    static let shared = AlarmService()
    
    @Published var alarms: [Alarm] = []
    @Published var smartWakeupEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let alarmsKey = "alarms"
    private let smartWakeupKey = "smartWakeupEnabled"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAlarms()
        requestNotificationPermission()
    }
    
    // MARK: - Alarm CRUD
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        scheduleNotification(for: alarm)
    }
    
    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            cancelNotification(for: alarm)
            scheduleNotification(for: alarm)
        }
    }
    
    func deleteAlarm(_ alarmId: String) {
        if let alarm = alarms.first(where: { $0.id == alarmId }) {
            cancelNotification(for: alarm)
        }
        alarms.removeAll { $0.id == alarmId }
        saveAlarms()
    }
    
    func toggleAlarm(_ alarmId: String) {
        if let index = alarms.firstIndex(where: { $0.id == alarmId }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            
            if alarms[index].isEnabled {
                scheduleNotification(for: alarms[index])
            } else {
                cancelNotification(for: alarms[index])
            }
        }
    }
    
    // MARK: - Smart Wakeup
    
    func getOptimalWakeTime(for targetTime: Date) -> Date? {
        guard smartWakeupEnabled else { return targetTime }
        
        // 智能唤醒：找到浅睡眠窗口
        // 假设睡眠周期约90分钟，在目标时间前30分钟窗口内唤醒
        let calendar = Calendar.current
        let searchRange: TimeInterval = 30 * 60  // 30分钟
        
        // 简单实现：返回目标时间前30分钟内的任意时间
        // 实际应该结合睡眠数据计算浅睡眠阶段
        return targetTime.addingTimeInterval(-searchRange)
    }
    
    // MARK: - Statistics
    
    func getOnTimeWakeCount() -> Int {
        // 统计准时起床次数
        0
    }
    
    func getSnoozeCount() -> Int {
        // 统计延后次数
        alarms.reduce(0) { $0 + ($1.snoozeCount) }
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        guard alarm.isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "起床时间到"
        content.body = alarm.label
        content.sound = .default
        
        // 计算触发时间
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
        
        var trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: alarm.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id])
    }
    
    // MARK: - Persistence
    
    private func loadAlarms() {
        guard let data = userDefaults.data(forKey: alarmsKey),
              let saved = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return
        }
        alarms = saved
        smartWakeupEnabled = userDefaults.bool(forKey: smartWakeupKey)
    }
    
    private func saveAlarms() {
        guard let data = try? JSONEncoder().encode(alarms) else { return }
        userDefaults.set(data, forKey: alarmsKey)
        userDefaults.set(smartWakeupEnabled, forKey: smartWakeupKey)
    }
}

// MARK: - Alarm Model

struct Alarm: Identifiable, Codable {
    let id: String
    var time: Date
    var label: String
    var isEnabled: Bool
    var repeatDays: [Int]  // 1=周一, 7=周日
    var snoozeCount: Int
    var smartWakeup: Bool
    
    init(
        id: String = UUID().uuidString,
        time: Date,
        label: String,
        isEnabled: Bool = true,
        repeatDays: [Int] = [],
        snoozeCount: Int = 0,
        smartWakeup: Bool = true
    ) {
        self.id = id
        self.time = time
        self.label = label
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.snoozeCount = snoozeCount
        self.smartWakeup = smartWakeup
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var repeatDaysText: String {
        guard !repeatDays.isEmpty else { return "不重复" }
        
        let dayNames = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        return repeatDays.sorted().compactMap { dayNames[$0 - 1] }.joined(separator: " ")
    }
}

extension Alarm {
    static let samples: [Alarm] = [
        Alarm(time: Date(), label: "工作日", repeatDays: [1, 2, 3, 4, 5]),
        Alarm(time: Date().addingTimeInterval(2 * 3600), label: "周末", repeatDays: [6, 7], isEnabled: false)
    ]
}
