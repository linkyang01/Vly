import Foundation

// MARK: - 共享类型

// MARK: - 呼吸步骤

struct BreathingStep: Identifiable, Codable {
    let id = UUID()
    let nameKey: String  // 使用 key 而不是硬编码文字
    let duration: TimeInterval
    let instructionKey: String
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }
    
    var instruction: String {
        NSLocalizedString(instructionKey, comment: "")
    }
}

// MARK: - 助眠技术枚举

enum BreathingTechnique: String, CaseIterable, Identifiable {
    case fourSevenEight = "four_seven_eight"
    case progressiveMuscleRelaxation = "progressive_muscle_relaxation"
    case bodyScan = "body_scan"
    case breathingTwoOneSix = "two_one_six"
    case whiteNoise = "white_noise"
    
    var id: String { rawValue }
    
    var nameKey: String {
        switch self {
        case .fourSevenEight: return "technique_478"
        case .progressiveMuscleRelaxation: return "technique_pmr"
        case .bodyScan: return "technique_bodyscan"
        case .breathingTwoOneSix: return "technique_216"
        case .whiteNoise: return "technique_whitenoise"
        }
    }
    
    var icon: String {
        switch self {
        case .fourSevenEight: return "wind"
        case .progressiveMuscleRelaxation: return "figure.mind.and.body"
        case .bodyScan: return "figure.stand"
        case .breathingTwoOneSix: return "wind"
        case .whiteNoise: return "cloud.rain.fill"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .fourSevenEight: return 180
        case .progressiveMuscleRelaxation: return 600
        case .bodyScan: return 900
        case .breathingTwoOneSix: return 120
        case .whiteNoise: return 1800
        }
    }
    
    var hasVoiceGuide: Bool {
        switch self {
        case .fourSevenEight, .breathingTwoOneSix: return true
        default: return false
        }
    }
    
    var steps: [BreathingStep] {
        switch self {
        case .fourSevenEight:
            return [
                BreathingStep(nameKey: "breathing_inhale", duration: 4, instructionKey: "breathing_inhale_instruction"),
                BreathingStep(nameKey: "breathing_hold", duration: 7, instructionKey: "breathing_hold_instruction"),
                BreathingStep(nameKey: "breathing_exhale", duration: 8, instructionKey: "breathing_exhale_instruction")
            ]
        case .breathingTwoOneSix:
            return [
                BreathingStep(nameKey: "breathing_inhale", duration: 2, instructionKey: "breathing_inhale_instruction"),
                BreathingStep(nameKey: "breathing_hold", duration: 1, instructionKey: "breathing_hold_instruction"),
                BreathingStep(nameKey: "breathing_exhale", duration: 6, instructionKey: "breathing_exhale_instruction")
            ]
        default:
            return []
        }
    }
    
    var descriptionKey: String {
        switch self {
        case .fourSevenEight: return "technique_478_desc"
        case .progressiveMuscleRelaxation: return "technique_pmr_desc"
        case .bodyScan: return "technique_bodyscan_desc"
        case .breathingTwoOneSix: return "technique_216_desc"
        case .whiteNoise: return "technique_whitenoise_desc"
        }
    }
    
    var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }
    
    var recommendedForKey: String {
        switch self {
        case .fourSevenEight: return "technique_478_recommended"
        case .progressiveMuscleRelaxation: return "technique_pmr_recommended"
        case .bodyScan: return "technique_bodyscan_recommended"
        case .breathingTwoOneSix: return "technique_216_recommended"
        case .whiteNoise: return "technique_whitenoise_recommended"
        }
    }
    
    var recommendedFor: String {
        NSLocalizedString(recommendedForKey, comment: "")
    }
    
    // 便捷属性：获取本地化名称
    var displayName: String {
        NSLocalizedString(nameKey, comment: "")
    }
}
