import Foundation
import AppKit

/// 播放历史记录
struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let videoId: UUID
    let title: String
    let url: URL
    let watchedAt: Date
    let watchDuration: TimeInterval
    let totalDuration: TimeInterval
    let completionPercentage: Double
    
    init(
        id: UUID = UUID(),
        videoId: UUID,
        title: String,
        url: URL,
        watchedAt: Date = Date(),
        watchDuration: TimeInterval,
        totalDuration: TimeInterval
    ) {
        self.id = id
        self.videoId = videoId
        self.title = title
        self.url = url
        self.watchedAt = watchedAt
        self.watchDuration = watchDuration
        self.totalDuration = totalDuration
        self.completionPercentage = totalDuration > 0 ? watchDuration / totalDuration : 0
    }
    
    var isCompleted: Bool {
        completionPercentage >= 0.9
    }
    
    var formattedWatchedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: watchedAt, relativeTo: Date())
    }
}

/// 快捷键配置
struct KeyboardShortcut: Identifiable, Codable, Equatable {
    let id: UUID
    let action: ShortcutAction
    var key: String
    var modifiers: [ModifierKey]
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        action: ShortcutAction,
        key: String,
        modifiers: [ModifierKey] = [],
        isEnabled: Bool = true
    ) {
        self.id = id
        self.action = action
        self.key = key
        self.modifiers = modifiers
        self.isEnabled = isEnabled
    }
    
    var keyEquivalent: String {
        key.lowercased()
    }
    
    var modifierMask: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        for modifier in modifiers {
            switch modifier {
            case .command: flags.insert(.command)
            case .option: flags.insert(.option)
            case .control: flags.insert(.control)
            case .shift: flags.insert(.shift)
            case .function: flags.insert(.function)
            }
        }
        return flags
    }
    
    static let defaultShortcuts: [KeyboardShortcut] = [
        KeyboardShortcut(action: .playPause, key: " ", modifiers: []),
        KeyboardShortcut(action: .seekBackward, key: "Left", modifiers: []),
        KeyboardShortcut(action: .seekForward, key: "Right", modifiers: []),
        KeyboardShortcut(action: .volumeUp, key: "Up", modifiers: []),
        KeyboardShortcut(action: .volumeDown, key: "Down", modifiers: []),
        KeyboardShortcut(action: .toggleFullscreen, key: "f", modifiers: [.command]),
        KeyboardShortcut(action: .toggleMute, key: "m", modifiers: []),
        KeyboardShortcut(action: .previousFrame, key: ",", modifiers: []),
        KeyboardShortcut(action: .nextFrame, key: ".", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "0", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "1", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "2", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "3", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "4", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "5", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "6", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "7", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "8", modifiers: []),
        KeyboardShortcut(action: .seekToProgress, key: "9", modifiers: []),
        KeyboardShortcut(action: .slowerPlayback, key: "[", modifiers: []),
        KeyboardShortcut(action: .fasterPlayback, key: "]", modifiers: []),
        KeyboardShortcut(action: .resetPlaybackSpeed, key: "\\", modifiers: []),
        KeyboardShortcut(action: .quit, key: "q", modifiers: [.command]),
        KeyboardShortcut(action: .newWindow, key: "n", modifiers: [.command]),
        KeyboardShortcut(action: .closeWindow, key: "w", modifiers: [.command]),
        KeyboardShortcut(action: .toggleSubtitle, key: "c", modifiers: []),
        KeyboardShortcut(action: .increaseSubtitleSize, key: "+", modifiers: [.command]),
        KeyboardShortcut(action: .decreaseSubtitleSize, key: "-", modifiers: [.command])
    ]
}

/// 快捷键动作
enum ShortcutAction: String, Codable, CaseIterable {
    case playPause = "play_pause"
    case seekBackward = "seek_backward"
    case seekForward = "seek_forward"
    case volumeUp = "volume_up"
    case volumeDown = "volume_down"
    case toggleFullscreen = "toggle_fullscreen"
    case toggleMute = "toggle_mute"
    case previousFrame = "previous_frame"
    case nextFrame = "next_frame"
    case seekToProgress = "seek_to_progress"
    case slowerPlayback = "slower_playback"
    case fasterPlayback = "faster_playback"
    case resetPlaybackSpeed = "reset_playback_speed"
    case quit = "quit"
    case newWindow = "new_window"
    case closeWindow = "close_window"
    case toggleSubtitle = "toggle_subtitle"
    case increaseSubtitleSize = "increase_subtitle_size"
    case decreaseSubtitleSize = "decrease_subtitle_size"
    case showPlaylist = "show_playlist"
    case showSettings = "show_settings"
    
    var displayName: String {
        switch self {
        case .playPause: return "播放/暂停"
        case .seekBackward: return "快退 15 秒"
        case .seekForward: return "快进 15 秒"
        case .volumeUp: return "音量 +"
        case .volumeDown: return "音量 -"
        case .toggleFullscreen: return "全屏切换"
        case .toggleMute: return "静音切换"
        case .previousFrame: return "上一帧"
        case .nextFrame: return "下一帧"
        case .seekToProgress: return "跳转到进度"
        case .slowerPlayback: return "减速播放"
        case .fasterPlayback: return "加速播放"
        case .resetPlaybackSpeed: return "重置播放速度"
        case .quit: return "退出"
        case .newWindow: return "新建窗口"
        case .closeWindow: return "关闭窗口"
        case .toggleSubtitle: return "切换字幕"
        case .increaseSubtitleSize: return "增大字幕"
        case .decreaseSubtitleSize: return "减小字幕"
        case .showPlaylist: return "显示播放列表"
        case .showSettings: return "显示设置"
        }
    }
    
    var defaultKey: String {
        switch self {
        case .playPause: return "空格"
        case .seekBackward: return "←"
        case .seekForward: return "→"
        case .volumeUp: return "↑"
        case .volumeDown: return "↓"
        case .toggleFullscreen: return "F"
        case .toggleMute: return "M"
        case .previousFrame: return ","
        case .nextFrame: return "."
        case .seekToProgress: return "0-9"
        case .slowerPlayback: return "["
        case .fasterPlayback: return "]"
        case .resetPlaybackSpeed: return "\\"
        case .quit: return "Q"
        case .newWindow: return "⌘N"
        case .closeWindow: return "⌘W"
        case .toggleSubtitle: return "C"
        case .increaseSubtitleSize: return "⌘+"
        case .decreaseSubtitleSize: return "⌘-"
        case .showPlaylist: return "⌘P"
        case .showSettings: return "⌘,"
        }
    }
}

/// 修饰键
enum ModifierKey: String, Codable, CaseIterable {
    case command = "command"
    case option = "option"
    case control = "control"
    case shift = "shift"
    case function = "function"
    
    var displayName: String {
        switch self {
        case .command: return "⌘"
        case .option: return "⌥"
        case .control: return "⌃"
        case .shift: return "⇧"
        case .function: return "Fn"
        }
    }
}
