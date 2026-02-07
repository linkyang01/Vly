import Foundation
import SwiftUI

// MARK: - 转化追踪器

@MainActor
class ConversionTracker: ObservableObject {
    static let shared = ConversionTracker()
    
    @Published var currentStage: ConversionStage = .day1Onboarding
    @Published var daysActive: Int = 0
    @Published var sessionsCompleted: Int = 0
    @Published var firstSessionDate: Date?
    
    private let userDefaultsKey = "sleepConversionTracker"
    
    init() {
        load()
    }
    
    // MARK: - 公共方法
    
    func shouldShowOnboarding() -> Bool {
        return firstSessionDate == nil
    }
    
    func recordSessionCompleted() {
        sessionsCompleted += 1
        save()
    }
    
    func completeOnboarding() {
        firstSessionDate = Date()
        daysActive = 1
        currentStage = .day1FirstSession
        save()
    }
    
    func updateDaysActive() {
        guard let firstDate = firstSessionDate else { return }
        daysActive = Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
        updateStage()
        save()
    }
    
    // MARK: - 私有方法
    
    private func updateStage() {
        switch daysActive {
        case 0:
            currentStage = .day1Onboarding
        case 1:
            currentStage = .day1FirstSession
        case 2...5:
            currentStage = .day2Discovery
        case 6...7:
            currentStage = .day6Engagement
        case 8:
            currentStage = .day8Paywall
        default:
            currentStage = .day8Paywall
        }
    }
    
    // MARK: - 持久化
    
    private func save() {
        let data: [String: Any] = [
            "currentStage": currentStage.rawValue,
            "daysActive": daysActive,
            "sessionsCompleted": sessionsCompleted,
            "firstSessionDate": firstSessionDate ?? Date.distantPast
        ]
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    private func load() {
        guard let data = UserDefaults.standard.dictionary(forKey: userDefaultsKey) else { return }
        
        if let stageRaw = data["currentStage"] as? String,
           let stage = ConversionStage(rawValue: stageRaw) {
            currentStage = stage
        }
        
        daysActive = data["daysActive"] as? Int ?? 0
        sessionsCompleted = data["sessionsCompleted"] as? Int ?? 0
        
        if let dateInterval = data["firstSessionDate"] as? TimeInterval {
            firstSessionDate = Date(timeIntervalSince1970: dateInterval)
            updateDaysActive()
        }
    }
}

// MARK: - 转化阶段

enum ConversionStage: String {
    case day1Onboarding = "day1Onboarding"
    case day1FirstSession = "day1FirstSession"
    case day2Discovery = "day2Discovery"
    case day3Exploration = "day3Exploration"
    case day4Value = "day4Value"
    case day5Retention = "day5Retention"
    case day6Engagement = "day6Engagement"
    case day7Urgency = "day7Urgency"
    case day8Paywall = "day8Paywall"
    case subscribed = "subscribed"
    case churned = "churned"
    
    var title: String {
        switch self {
        case .day1Onboarding: return "Day 1: Onboarding"
        case .day1FirstSession: return "Day 1: First Session"
        case .day2Discovery: return "Day 2: Discovery"
        case .day3Exploration: return "Day 3: Exploration"
        case .day4Value: return "Day 4: Value Demo"
        case .day5Retention: return "Day 5: Retention"
        case .day6Engagement: return "Day 6: Engagement"
        case .day7Urgency: return "Day 7: Urgency"
        case .day8Paywall: return "Day 8: Paywall"
        case .subscribed: return "Subscribed"
        case .churned: return "Churned"
        }
    }
}
