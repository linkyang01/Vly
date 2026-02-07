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
        case .rain: return "rain_name".localized()
        case .ocean: return "ocean_name".localized()
        case .wind: return "wind_name".localized()
        case .fire: return "fire_name".localized()
        case .forest: return "forest_name".localized()
        case .river: return "river_name".localized()
        }
    }
    
    var description: String {
        switch self {
        case .rain: return "rain_desc".localized()
        case .ocean: return "ocean_desc".localized()
        case .wind: return "wind_desc".localized()
        case .fire: return "fire_desc".localized()
        case .forest: return "forest_desc".localized()
        case .river: return "river_desc".localized()
        }
    }
    
    var accentColor: String {
        switch self {
        case .rain: return "#3B82F6"
        case .ocean: return "#06B6D4"
        case .wind: return "#14B8A6"
        case .fire: return "#F97316"
        case .forest: return "#22C55E"
        case .river: return "#3B82F6"
        }
    }
}
