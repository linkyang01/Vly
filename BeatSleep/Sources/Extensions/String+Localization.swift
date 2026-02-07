import Foundation

// MARK: - 本地化扩展

extension String {
    /// 获取本地化字符串
    /// - Parameter comment: 翻译备注（可选）
    /// - Returns: 本地化后的字符串
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

// MARK: - 便捷方法

extension String {
    /// 快速获取本地化字符串
    static func loc(_ key: String) -> String {
        return key.localized()
    }
}
