import Foundation
import AppKit

/// 快捷键服务 - 管理全局快捷键
class ShortcutService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = ShortcutService()
    
    // MARK: - Published Properties
    
    @Published var shortcuts: [KeyboardShortcut] = []
    @Published var isEnabled: Bool = true
    
    // MARK: - Private Properties
    
    private let userDefaultsKey = "vly_keyboard_shortcuts"
    private var eventMonitor: Any?
    
    // MARK: - Initialization
    
    private init() {
        loadShortcuts()
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    func getShortcut(for action: ShortcutAction) -> KeyboardShortcut? {
        shortcuts.first { $0.action == action }
    }
    
    func updateShortcut(_ shortcut: KeyboardShortcut) {
        if let index = shortcuts.firstIndex(where: { $0.action == shortcut.action }) {
            shortcuts[index] = shortcut
            saveShortcuts()
        }
    }
    
    func resetToDefaults() {
        shortcuts = KeyboardShortcut.defaultShortcuts
        saveShortcuts()
    }
    
    func isShortcutAvailable(_ event: NSEvent, action: ShortcutAction) -> Bool {
        guard isEnabled else { return false }
        
        guard let shortcut = shortcuts.first(where: { $0.action == action && $0.isEnabled }) else {
            return false
        }
        
        // 检查按键
        let keyMatches = event.keyCode == keyCode(for: shortcut.key) || 
                         event.characters == shortcut.key.lowercased()
        
        // 检查修饰键
        let modifiersMatch = event.modifierFlags.contains(shortcut.modifierMask)
        
        return keyMatches && modifiersMatch
    }
    
    // MARK: - Event Handling
    
    private func startMonitoring() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: .keyDown
        ) { [weak self] event in
            self?.handleKeyDown(event)
            return event
        }
    }
    
    private func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        // 检查快捷键并执行相应操作
        for shortcut in shortcuts where shortcut.isEnabled {
            if matchesEvent(event, shortcut: shortcut) {
                NotificationCenter.default.post(
                    name: .shortcutTriggered,
                    object: nil,
                    userInfo: ["action": shortcut.action]
                )
                return nil // 阻止事件继续传播
            }
        }
        return event
    }
    
    private func matchesEvent(_ event: NSEvent, shortcut: KeyboardShortcut) -> Bool {
        let keyCode = keyCode(for: shortcut.key)
        let keyMatches = event.keyCode == keyCode
        let modifiersMatch = event.modifierFlags == shortcut.modifierMask
        
        return keyMatches && modifiersMatch
    }
    
    private func keyCode(for key: String) -> UInt16 {
        switch key.lowercased() {
        case "space": return 49
        case "left": return 123
        case "right": return 124
        case "up": return 126
        case "down": return 125
        case "f": return 3
        case "m": return 46
        case ",": return 43
        case ".": return 47
        case "0": return 29
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "5": return 23
        case "6": return 22
        case "7": return 26
        case "8": return 28
        case "9": return 25
        case "[": return 33
        case "]": return 30
        case "\\": return 42
        case "q": return 12
        case "n": return 45
        case "w": return 13
        case "c": return 8
        case "+", "=": return 24
        case "-", "_": return 27
        default: return 0
        }
    }
    
    // MARK: - Persistence
    
    private func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let loaded = try? JSONDecoder().decode([KeyboardShortcut].self, from: data) {
            shortcuts = loaded
        } else {
            shortcuts = KeyboardShortcut.defaultShortcuts
        }
        
        isEnabled = UserDefaults.standard.object(forKey: "vly_shortcut_enabled") as? Bool ?? true
    }
    
    private func saveShortcuts() {
        if let data = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}

// MARK: - Subtitle Service

/// 字幕服务 - 管理字幕加载和显示
class SubtitleService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = SubtitleService()
    
    // MARK: - Published Properties
    
    @Published var availableTracks: [SubtitleTrack] = []
    @Published var currentTrack: SubtitleTrack?
    @Published var style: SubtitleStyle = SubtitleStyle()
    @Published var isVisible: Bool = true
    
    // MARK: - Private Properties
    
    private var subtitleLayer: Any?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func loadSubtitles(from url: URL) {
        // 检测字幕格式并加载
        let ext = url.pathExtension.lowercased()
        
        let track = SubtitleTrack(
            name: url.deletingPathExtension().lastPathComponent,
            language: detectLanguage(from: url),
            isExternal: true,
            url: url
        )
        
        availableTracks.append(track)
        currentTrack = track
    }
    
    func loadEmbeddedSubtitles(from assetTracks: [String: String]) {
        // 从视频轨道加载内嵌字幕
        for (id, name) in assetTracks {
            let track = SubtitleTrack(
                id: id,
                name: name,
                isExternal: false
            )
            availableTracks.append(track)
        }
    }
    
    func selectTrack(_ track: SubtitleTrack?) {
        currentTrack = track
    }
    
    func toggleVisibility() {
        isVisible.toggle()
    }
    
    func updateStyle(_ newStyle: SubtitleStyle) {
        style = newStyle
    }
    
    func increaseFontSize() {
        style.fontSize = min(style.fontSize + 2, 32)
    }
    
    func decreaseFontSize() {
        style.fontSize = max(style.fontSize - 2, 8)
    }
    
    func clear() {
        availableTracks.removeAll()
        currentTrack = nil
    }
    
    // MARK: - Private Methods
    
    private func detectLanguage(from url: URL) -> String? {
        let ext = url.pathExtension.lowercased()
        
        switch ext {
        case "srt":
            // SRT 可能有语言标识，如 video.en.srt
            if let components = url.deletingPathExtension().lastPathComponent.components(separatedBy: ".").last,
               components.count == 2 {
                return components
            }
        case "ass", "ssa":
            // ASS/SSA 文件头可能包含语言信息
            return nil
        case "vtt":
            return "en"
        default:
            return nil
        }
        
        return nil
    }
}
