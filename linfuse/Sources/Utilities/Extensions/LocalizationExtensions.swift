import Foundation

// MARK: - Localization Helper

struct L10n {
    /// Get localized string for a key
    static func string(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
    
    /// Get localized string with format arguments
    static func string(_ key: String, _ args: CVarArg...) -> String {
        String(format: NSLocalizedString(key, comment: ""), arguments: args)
    }
}

// MARK: - String Extension

extension String {
    /// Localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Localized string with arguments
    func localized(with args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

// MARK: - View Extension for Localization

import SwiftUI

extension View {
    /// Localized string from key path
    func localize(_ keyPath: KeyPath<L10nKeys, String>) -> some View {
        self.environment(\.locale, Locale.current)
    }
}

// MARK: - L10n Keys

struct L10nKeys {
    // MARK: - App
    static let appName = "app.name"
    static let appVersion = "app.version"
    static let appBuild = "app.build"
    
    // MARK: - Sidebar
    static let sidebarLibrary = "sidebar.library"
    static let sidebarAllMovies = "sidebar.allMovies"
    static let sidebarRecentlyAdded = "sidebar.recentlyAdded"
    static let sidebarContinueWatching = "sidebar.continueWatching"
    static let sidebarWatchlist = "sidebar.watchlist"
    static let sidebarSmartCollections = "sidebar.smartCollections"
    static let sidebarTopRated = "sidebar.topRated"
    static let sidebarRecentlyWatched = "sidebar.recentlyWatched"
    static let sidebarGenres = "sidebar.genres"
    static let sidebarLibraryFolders = "sidebar.libraryFolders"
    static let sidebarAddFolder = "sidebar.addFolder"
    
    // MARK: - Toolbar
    static let toolbarSearch = "toolbar.search"
    static let toolbarSort = "toolbar.sort"
    static let toolbarFilter = "toolbar.filter"
    static let toolbarView = "toolbar.view"
    static let toolbarImport = "toolbar.import"
    
    // MARK: - Movie Detail
    static let detailOverview = "detail.overview"
    static let detailCastCrew = "detail.castCrew"
    static let detailPlay = "detail.play"
    static let detailResume = "detail.resume"
    static let detailDetails = "detail.details"
    static let detailAdded = "detail.added"
    static let detailReleased = "detail.released"
    static let detailRuntime = "detail.runtime"
    static let detailFileSize = "detail.fileSize"
    
    // MARK: - Player
    static let playerNowPlaying = "player.nowPlaying"
    static let playerPlay = "player.play"
    static let playerPause = "player.pause"
    static let playerDecodingRestricted = "player.decodingRestricted"
    static let playerUpgradeMessage = "player.upgradeMessage"
    
    // MARK: - Settings
    static let settingsTitle = "settings.title"
    static let settingsGeneral = "settings.general"
    static let settingsLibrary = "settings.library"
    static let settingsPlayer = "settings.player"
    static let settingsAbout = "settings.about"
    
    // MARK: - Errors
    static let errorLoadMovies = "error.loadMovies"
    static let errorNetwork = "error.network"
    static let errorFileNotFound = "error.fileNotFound"
    
    // MARK: - Common
    static let commonCancel = "common.cancel"
    static let commonConfirm = "common.confirm"
    static let commonSave = "common.save"
    static let commonDelete = "common.delete"
    static let commonClose = "common.close"
    static let commonRetry = "common.retry"
    static let commonOk = "common.ok"
    static let commonLoading = "common.loading"
}

// MARK: - Locale Manager

final class LocaleManager: ObservableObject {
    static let shared = LocaleManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.code, forKey: "selectedLanguage")
            updateLocale()
        }
    }
    
    enum Language: String, CaseIterable {
        case english = "en"
        case simplifiedChinese = "zh-Hans"
        
        var code: String {
            rawValue
        }
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .simplifiedChinese: return "简体中文"
            }
        }
        
        var locale: Locale {
            Locale(identifier: rawValue)
        }
    }
    
    private init() {
        let savedCode = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Language.english.code
        currentLanguage = Language(rawValue: savedCode) ?? .english
    }
    
    private func updateLocale() {
        UserDefaults.standard.set([currentLanguage.code], forKey: "AppleLanguages")
        NotificationCenter.default.post(name: .localeChanged, object: nil)
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let localeChanged = Notification.Name("localeChanged")
}

// MARK: - Usage Examples

/*
 // Basic usage:
 Text(L10n.string("sidebar.allMovies"))
 
 // String extension:
 Text("sidebar.allMovies".localized)
 
 // With arguments:
 Text(L10n.string("importer.success", 5)) // "5 video(s) have been added"
 
 // View modifier:
 Text("Hello").localized(\.appName)
 
 // Direct key access:
 Text(L10nKeys.sidebarAllMovies.localized)
*/
