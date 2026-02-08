import Foundation

/// 设置服务 - 管理用户偏好设置
class SettingsService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = SettingsService()
    
    // MARK: - Keys
    
    private enum Keys {
        static let playbackSpeed = "settings_playback_speed"
        static let defaultVolume = "settings_default_volume"
        static let rememberVolume = "settings_remember_volume"
        static let autoPlayNext = "settings_auto_play_next"
        static let shuffleOnLoad = "settings_shuffle_on_load"
        static let loopMode = "settings_loop_mode"
        static let showSubtitles = "settings_show_subtitles"
        static let subtitleEncoding = "settings_subtitle_encoding"
        static let subtitleSize = "settings_subtitle_size"
        static let subtitlePosition = "settings_subtitle_position"
        static let defaultQuality = "settings_default_quality"
        static let autoQuality = "settings_auto_quality"
        static let rememberPosition = "settings_remember_position"
        static let showOnboarding = "settings_show_onboarding"
        static let theme = "settings_theme"
        static let accentColor = "settings_accent_color"
        static let showPlaylistSidebar = "settings_show_playlist_sidebar"
        static let playlistPosition = "settings_playlist_position"
        static let shortcutEnabled = "settings_shortcut_enabled"
    }
    
    // MARK: - Published Properties
    
    @Published var playbackSpeed: PlaybackSpeed = .normal
    @Published var defaultVolume: Double = 1.0
    @Published var rememberVolume: Bool = true
    @Published var autoPlayNext: Bool = true
    @Published var shuffleOnLoad: Bool = false
    @Published var loopMode: RepeatMode = .none
    @Published var showSubtitles: Bool = true
    @Published var subtitleEncoding: SubtitleStyle.StringEncoding = .utf8
    @Published var subtitleSize: Double = 16
    @Published var subtitlePosition: SubtitlePosition = .bottom
    @Published var defaultQuality: VideoQuality = .auto
    @Published var autoQuality: Bool = true
    @Published var rememberPosition: Bool = true
    @Published var showOnboarding: Bool = true
    @Published var theme: AppTheme = .system
    @Published var accentColor: AccentColor = .blue
    @Published var showPlaylistSidebar: Bool = true
    @Published var playlistPosition: PlaylistPosition = .right
    @Published var shortcutEnabled: Bool = true
    
    // MARK: - Initialization
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    func resetToDefaults() {
        playbackSpeed = .normal
        defaultVolume = 1.0
        rememberVolume = true
        autoPlayNext = true
        shuffleOnLoad = false
        loopMode = .none
        showSubtitles = true
        subtitleEncoding = .utf8
        subtitleSize = 16
        subtitlePosition = .bottom
        defaultQuality = .auto
        autoQuality = true
        rememberPosition = true
        showOnboarding = true
        theme = .system
        accentColor = .blue
        showPlaylistSidebar = true
        playlistPosition = .right
        shortcutEnabled = true
        
        saveSettings()
    }
    
    // MARK: - Persistence
    
    private func loadSettings() {
        let userDefaults = UserDefaults.standard
        
        if let speedRaw = userDefaults.string(forKey: Keys.playbackSpeed),
           let speed = PlaybackSpeed(rawValue: Double(speedRaw) ?? 1.0) {
            playbackSpeed = speed
        }
        
        defaultVolume = userDefaults.double(forKey: Keys.defaultVolume)
        rememberVolume = userDefaults.object(forKey: Keys.rememberVolume) as? Bool ?? true
        autoPlayNext = userDefaults.object(forKey: Keys.autoPlayNext) as? Bool ?? true
        shuffleOnLoad = userDefaults.object(forKey: Keys.shuffleOnLoad) as? Bool ?? false
        
        if let loopRaw = userDefaults.string(forKey: Keys.loopMode),
           let loop = RepeatMode(rawValue: loopRaw) {
            loopMode = loop
        }
        
        showSubtitles = userDefaults.object(forKey: Keys.showSubtitles) as? Bool ?? true
        
        if let encodingRaw = userDefaults.string(forKey: Keys.subtitleEncoding),
           let encoding = SubtitleStyle.StringEncoding(rawValue: encodingRaw) {
            subtitleEncoding = encoding
        }
        
        subtitleSize = userDefaults.double(forKey: Keys.subtitleSize)
        subtitlePosition = SubtitlePosition(rawValue: userDefaults.string(forKey: Keys.subtitlePosition) ?? "bottom") ?? .bottom
        
        if let qualityRaw = userDefaults.string(forKey: Keys.defaultQuality),
           let quality = VideoQuality(rawValue: qualityRaw) {
            defaultQuality = quality
        }
        
        autoQuality = userDefaults.object(forKey: Keys.autoQuality) as? Bool ?? true
        rememberPosition = userDefaults.object(forKey: Keys.rememberPosition) as? Bool ?? true
        showOnboarding = userDefaults.object(forKey: Keys.showOnboarding) as? Bool ?? true
        
        if let themeRaw = userDefaults.string(forKey: Keys.theme),
           let theme = AppTheme(rawValue: themeRaw) {
            self.theme = theme
        }
        
        if let colorRaw = userDefaults.string(forKey: Keys.accentColor),
           let color = AccentColor(rawValue: colorRaw) {
            accentColor = color
        }
        
        showPlaylistSidebar = userDefaults.object(forKey: Keys.showPlaylistSidebar) as? Bool ?? true
        playlistPosition = PlaylistPosition(rawValue: userDefaults.string(forKey: Keys.playlistPosition) ?? "right") ?? .right
        shortcutEnabled = userDefaults.object(forKey: Keys.shortcutEnabled) as? Bool ?? true
    }
    
    private func saveSettings() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(playbackSpeed.rawValue, forKey: Keys.playbackSpeed)
        userDefaults.set(defaultVolume, forKey: Keys.defaultVolume)
        userDefaults.set(rememberVolume, forKey: Keys.rememberVolume)
        userDefaults.set(autoPlayNext, forKey: Keys.autoPlayNext)
        userDefaults.set(shuffleOnLoad, forKey: Keys.shuffleOnLoad)
        userDefaults.set(loopMode.rawValue, forKey: Keys.loopMode)
        userDefaults.set(showSubtitles, forKey: Keys.showSubtitles)
        userDefaults.set(subtitleEncoding.rawValue, forKey: Keys.subtitleEncoding)
        userDefaults.set(subtitleSize, forKey: Keys.subtitleSize)
        userDefaults.set(subtitlePosition.rawValue, forKey: Keys.subtitlePosition)
        userDefaults.set(defaultQuality.rawValue, forKey: Keys.defaultQuality)
        userDefaults.set(autoQuality, forKey: Keys.autoQuality)
        userDefaults.set(rememberPosition, forKey: Keys.rememberPosition)
        userDefaults.set(showOnboarding, forKey: Keys.showOnboarding)
        userDefaults.set(theme.rawValue, forKey: Keys.theme)
        userDefaults.set(accentColor.rawValue, forKey: Keys.accentColor)
        userDefaults.set(showPlaylistSidebar, forKey: Keys.showPlaylistSidebar)
        userDefaults.set(playlistPosition.rawValue, forKey: Keys.playlistPosition)
        userDefaults.set(shortcutEnabled, forKey: Keys.shortcutEnabled)
    }
}

/// 应用主题
enum AppTheme: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .system: return "跟随系统"
        }
    }
}

/// 强调色
enum AccentColor: String, Codable, CaseIterable {
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case teal = "teal"
    case indigo = "indigo"
    
    var displayName: String {
        rawValue.capitalized
    }
}

/// 播放列表位置
enum PlaylistPosition: String, Codable, CaseIterable {
    case left = "left"
    case right = "right"
    
    var displayName: String {
        switch self {
        case .left: return "左侧"
        case .right: return "右侧"
        }
    }
}
