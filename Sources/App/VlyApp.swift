import SwiftUI
import AppKit

/// Vly 应用入口 - 支持多窗口和快捷键
@main
struct VlyApp: App {
    @StateObject private var settingsService = SettingsService.shared
    @StateObject private var shortcutService = ShortcutService.shared
    @StateObject private var playerService = PlayerService.shared
    @StateObject private var playlistService = PlaylistService.shared
    
    var body: some Scene {
        // 主窗口
        WindowGroup {
            ContentView()
                .environmentObject(settingsService)
                .environmentObject(shortcutService)
                .environmentObject(playerService)
                .environmentObject(playlistService)
                .onOpenURL { url in
                    handleOpenURL(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
                    playerService.stop()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    playerService.stop()
                }
        }
        
        // 设置窗口（系统原生）
        Settings {
            SettingsView(
                settingsService: settingsService,
                shortcutService: shortcutService
            )
        }
    }
    
    // MARK: - Setup
    
    private func handleOpenURL(_ url: URL) {
        // 通知所有窗口打开视频
        NotificationCenter.default.post(
            name: .openVideoURL,
            object: nil,
            userInfo: ["url": url]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openVideoURL = Notification.Name("openVideoURL")
    static let shortcutTriggered = Notification.Name("shortcutTriggered")
}
