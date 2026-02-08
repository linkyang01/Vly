import SwiftUI

/// 设置视图
struct SettingsView: View {
    @ObservedObject var settingsService: SettingsService
    @ObservedObject var shortcutService: ShortcutService
    
    @State private var selectedTab: SettingsTab = .general
    
    var body: some View {
        HStack(spacing: 0) {
            // 侧边栏
            sidebar
            
            Divider()
            
            // 内容区
            content
        }
        .frame(width: 700, height: 500)
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    HStack {
                        Image(systemName: tab.iconName)
                            .frame(width: 24)
                        Text(tab.displayName)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        selectedTab == tab ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .frame(width: 150)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Content
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch selectedTab {
                case .general:
                    generalSettings
                case .playback:
                    playbackSettings
                case .subtitles:
                    subtitleSettings
                case .shortcuts:
                    keyboardShortcutsView
                case .about:
                    aboutView
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - General Settings
    
    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("外观")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    title: "主题",
                    description: "选择应用主题",
                    content: {
                        Picker("主题", selection: $settingsService.theme) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                )
                
                settingRow(
                    title: "强调色",
                    description: "选择应用强调色",
                    content: {
                        Picker("强调色", selection: $settingsService.accentColor) {
                            ForEach(AccentColor.allCases, id: \.self) { color in
                                Circle()
                                    .fill(colorForAccent(color))
                                    .frame(width: 20, height: 20)
                                    .tag(color)
                            }
                        }
                        .frame(width: 150)
                    }
                )
            }
            
            Divider()
            
            Text("播放列表")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    title: "显示播放列表",
                    description: "在主窗口显示播放列表",
                    content: {
                        Toggle("", isOn: $settingsService.showPlaylistSidebar)
                            .labelsHidden()
                    }
                )
                
                settingRow(
                    title: "播放列表位置",
                    description: "选择播放列表显示位置",
                    content: {
                        Picker("位置", selection: $settingsService.playlistPosition) {
                            ForEach(PlaylistPosition.allCases, id: \.self) { position in
                                Text(position.displayName).tag(position)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                )
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("恢复默认设置") {
                    settingsService.resetToDefaults()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Playback Settings
    
    private var playbackSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("播放")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    title: "记住播放位置",
                    description: "下次打开时从上次位置继续",
                    content: {
                        Toggle("", isOn: $settingsService.rememberPosition)
                            .labelsHidden()
                    }
                )
                
                settingRow(
                    title: "自动播放下一个",
                    description: "当前视频结束后自动播放列表中的下一个",
                    content: {
                        Toggle("", isOn: $settingsService.autoPlayNext)
                            .labelsHidden()
                    }
                )
                
                settingRow(
                    title: "加载时随机播放",
                    description: "打开播放列表时随机打乱顺序",
                    content: {
                        Toggle("", isOn: $settingsService.shuffleOnLoad)
                            .labelsHidden()
                    }
                )
                
                settingRow(
                    title: "默认播放速度",
                    description: "新视频的默认播放速度",
                    content: {
                        Picker("速度", selection: $settingsService.playbackSpeed) {
                            ForEach(PlaybackSpeed.allCases, id: \.self) { speed in
                                Text(speed.displayName).tag(speed)
                            }
                        }
                        .frame(width: 100)
                    }
                )
            }
            
            Divider()
            
            Text("画质")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    title: "默认画质",
                    description: "新视频的默认画质设置",
                    content: {
                        Picker("画质", selection: $settingsService.defaultQuality) {
                            ForEach(VideoQuality.allCases, id: \.self) { quality in
                                Text(quality.displayName).tag(quality)
                            }
                        }
                        .frame(width: 120)
                    }
                )
                
                settingRow(
                    title: "自动切换画质",
                    description: "根据网络情况自动调整画质",
                    content: {
                        Toggle("", isOn: $settingsService.autoQuality)
                            .labelsHidden()
                    }
                )
            }
        }
    }
    
    // MARK: - Subtitle Settings
    
    private var subtitleSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("字幕")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    title: "默认显示字幕",
                    description: "加载视频时自动显示字幕",
                    content: {
                        Toggle("", isOn: $settingsService.showSubtitles)
                            .labelsHidden()
                    }
                )
                
                settingRow(
                    title: "字幕编码",
                    description: "选择字幕文件编码格式",
                    content: {
                        Picker("编码", selection: $settingsService.subtitleEncoding) {
                            ForEach(SubtitleStyle.StringEncoding.allCases, id: \.self) { encoding in
                                Text(encoding.displayName).tag(encoding)
                            }
                        }
                        .frame(width: 120)
                    }
                )
                
                settingRow(
                    title: "默认字体大小",
                    description: "字幕的默认字体大小",
                    content: {
                        HStack {
                            Slider(value: $settingsService.subtitleSize, in: 8...32, step: 1)
                                .frame(width: 100)
                            Text("\(Int(settingsService.subtitleSize))pt")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                
                settingRow(
                    title: "字幕位置",
                    description: "字幕在视频中的默认位置",
                    content: {
                        Picker("位置", selection: $settingsService.subtitlePosition) {
                            ForEach(SubtitlePosition.allCases, id: \.self) { position in
                                Text(position.displayName).tag(position)
                            }
                        }
                        .frame(width: 100)
                    }
                )
            }
        }
    }
    
    // MARK: - Keyboard Shortcuts
    
    private var keyboardShortcutsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快捷键")
                .font(.headline)
            
            HStack {
                Toggle("启用快捷键", isOn: $shortcutService.isEnabled)
                    .toggleStyle(.switch)
                
                Spacer()
                
                Button("恢复默认") {
                    shortcutService.resetToDefaults()
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            // 快捷键列表
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ShortcutAction.allCases, id: \.self) { action in
                    if let shortcut = shortcutService.getShortcut(for: action) {
                        HStack {
                            Text(action.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text(shortcutKeyString(shortcut))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
        }
    }
    
    private func shortcutKeyString(_ shortcut: KeyboardShortcut) -> String {
        var parts: [String] = []
        
        for modifier in shortcut.modifiers {
            parts.append(modifier.displayName)
        }
        
        parts.append(shortcut.key.capitalized)
        return parts.joined(separator: "")
    }
    
    // MARK: - About View
    
    private var aboutView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Vly")
                .font(.title)
                .bold()
            
            Text("版本 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("简洁优雅的视频播放器")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("技术栈")
                    .font(.headline)
                
                Text("• KSPlayer + FFmpeg")
                Text("• SwiftUI 4.0")
                Text("• macOS 12.0+")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper
    
    private func settingRow<Content: View>(
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content()
        }
    }
    
    private func colorForAccent(_ color: AccentColor) -> Color {
        switch color {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        case .indigo: return .indigo
        }
    }
}

// MARK: - Settings Tab

enum SettingsTab: String, CaseIterable {
    case general
    case playback
    case subtitles
    case shortcuts
    case about
    
    var displayName: String {
        switch self {
        case .general: return "通用"
        case .playback: return "播放"
        case .subtitles: return "字幕"
        case .shortcuts: return "快捷键"
        case .about: return "关于"
        }
    }
    
    var iconName: String {
        switch self {
        case .general: return "gearshape"
        case .playback: return "play.circle"
        case .subtitles: return "captions.bubble"
        case .shortcuts: return "keyboard"
        case .about: return "info.circle"
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(
        settingsService: SettingsService.shared,
        shortcutService: ShortcutService.shared
    )
}
