import Foundation

// MARK: - 白噪音类型

enum WhiteNoiseType: String, CaseIterable, Identifiable {
    case rain = "rain"
    case ocean = "ocean"
    case wind = "wind"
    case fire = "fire"
    case forest = "forest"
    case river = "river"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.rain"
        case .ocean: return "water.waves"
        case .wind: return "wind"
        case .fire: return "flame.fill"
        case .forest: return "leaf"
        case .river: return "drop.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .rain: return "Rain"
        case .ocean: return "Ocean"
        case .wind: return "Wind"
        case .fire: return "Fireplace"
        case .forest: return "Forest"
        case .river: return "River"
        }
    }
    
    var color: String {
        switch self {
        case .rain: return "#3B82F6"
        case .ocean: return "#06B6D4"
        case .wind: return "#14B8A6"
        case .fire: return "#F97316"
        case .forest: return "#22C55E"
        case .river: return "#3B82F6"
        }
    }
    
    var filename: String {
        "\(rawValue).mp3"
    }
}
