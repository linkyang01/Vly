import Foundation

// MARK: - 呼吸步骤

struct BreathingStep {
    let name: String
    let duration: Int
    let instruction: String
}

// MARK: - 呼吸技术

enum BreathingTechnique: String, CaseIterable, Identifiable {
    case fourSevenEight = "478"
    case twoOneSix = "216"
    case progressive = "progressive"
    case bodyScan = "bodyScan"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .fourSevenEight: return "4-7-8 Breathing"
        case .twoOneSix: return "2-1-6 Breathing"
        case .progressive: return "Progressive Muscle"
        case .bodyScan: return "Body Scan"
        }
    }
    
    var shortName: String {
        switch self {
        case .fourSevenEight: return "4-7-8"
        case .twoOneSix: return "2-1-6"
        case .progressive: return "Progressive"
        case .bodyScan: return "Body Scan"
        }
    }
    
    var icon: String {
        switch self {
        case .fourSevenEight: return "lungs.fill"
        case .twoOneSix: return "wind"
        case .progressive: return "figure.cooldown"
        case .bodyScan: return "figure.scan"
        }
    }
    
    var steps: [BreathingStep] {
        switch self {
        case .fourSevenEight:
            return [
                BreathingStep(name: "Inhale", duration: 4, instruction: "Breathe in slowly"),
                BreathingStep(name: "Hold", duration: 7, instruction: "Hold your breath"),
                BreathingStep(name: "Exhale", duration: 8, instruction: "Breathe out completely")
            ]
        case .twoOneSix:
            return [
                BreathingStep(name: "Inhale", duration: 2, instruction: "Breathe in"),
                BreathingStep(name: "Hold", duration: 1, instruction: "Hold briefly"),
                BreathingStep(name: "Exhale", duration: 6, instruction: "Breathe out slowly")
            ]
        default:
            return []
        }
    }
    
    var description: String {
        switch self {
        case .fourSevenEight:
            return "Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds."
        case .twoOneSix:
            return "Inhale for 2 seconds, hold for 1 second, exhale for 6 seconds."
        case .progressive:
            return "Tense and release muscle groups to release physical tension."
        case .bodyScan:
            return "Scan through your body to release tension and relax."
        }
    }
    
    var recommendedDuration: TimeInterval {
        switch self {
        case .fourSevenEight, .twoOneSix: return 180  // 3 minutes
        case .progressive, .bodyScan: return 600  // 10 minutes
        }
    }
}
