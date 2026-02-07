import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 预定义颜色

extension Color {
    static let sleepBackgroundStart = Color(hex: "#0D0D1A")
    static let sleepBackgroundMiddle = Color(hex: "#1A1A3E")
    static let sleepBackgroundEnd = Color(hex: "#2D1B4E")
    
    static let primaryPurple = Color.purple
    static let secondaryPurple = Color(hex: "#8B5CF6")
    static let accentOrange = Color(hex: "#F97316")
    
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let textTertiary = Color.white.opacity(0.6)
    
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.1)
    
    static let successGreen = Color(hex: "#10B981")
    static let warningYellow = Color(hex: "#F59E0B")
    static let errorRed = Color(hex: "#EF4444")
    
    static let heartRateLow = Color(hex: "#3B82F6")
    static let heartRateNormal = Color(hex: "#8B5CF6")
    static let heartRateHigh = Color(hex: "#F97316")
    
    // MARK: - 渐变
    
    static var sleepGradient: LinearGradient {
        LinearGradient(
            colors: [sleepBackgroundStart, sleepBackgroundMiddle, sleepBackgroundEnd],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardBackground, cardBackground.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
