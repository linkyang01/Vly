import Foundation

// MARK: - Date Extensions

extension Date {
    /// 格式化日期为字符串
    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    /// 是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// 是否是昨天
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// 获取今天是星期几 (1-7)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// 获取星期几的中文名
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.shortWeekdaySymbols[weekday - 1]
    }
    
    /// 获取一天开始的时间
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 获取一天结束的时间
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// 相对时间描述（如 "3 分钟前"）
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Int Extensions

extension Int {
    /// 格式化为分钟显示
    var minutesFormatted: String {
        if self < 60 {
            return "\(self) 分钟"
        } else {
            let hours = self / 60
            let minutes = self % 60
            if minutes > 0 {
                return "\(hours) 小时 \(minutes) 分钟"
            } else {
                return "\(hours) 小时"
            }
        }
    }
    
    /// 格式化为次数显示
    var timesFormatted: String {
        return "\(self) 次"
    }
}

// MARK: - Double Extensions

extension Double {
    /// 格式化为百分比
    var percentageFormatted: String {
        return String(format: "%.0f%%", self)
    }
    
    /// 格式化为带一位小数的百分比
    var percentageWithOneDecimal: String {
        return String(format: "%.1f%%", self)
    }
}

// MARK: - String Extensions

extension String {
    /// 本地化字符串
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// 带参数的本地化字符串
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Color Extensions

import SwiftUI

extension Color {
    /// 绿色主题色
    static let eyeCareGreen = Color(hex: "#22C55E")
    
    /// 从十六进制字符串创建颜色
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
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - View Extensions

extension View {
    /// 卡片样式
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
    }
    
    /// 渐变背景
    func gradientBackground() -> some View {
        self
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color.eyeCareGreen.opacity(0.1),
                        Color.eyeCareGreen.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
