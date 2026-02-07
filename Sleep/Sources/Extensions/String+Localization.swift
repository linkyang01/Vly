import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
    
    func localized(locale: Locale) -> String {
        guard let path = Bundle.main.path(forResource: locale.language.languageCode?.identifier ?? "en", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self.localized()
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

// MARK: - 便捷方法

extension String {
    var isChinese: Bool {
        Locale.current.language.languageCode?.identifier == "zh"
    }
    
    var toChinese: String {
        guard isChinese else { return self }
        return self
    }
    
    var toEnglish: String {
        guard !isChinese else { return self }
        return self
    }
}
