import SwiftUI
import KSPlayer
import UniformTypeIdentifiers

/// 主内容视图
struct ContentView: View {
    // MARK: - Services
    
    @StateObject private var playerService = PlayerService.shared
    @StateObject private var playlistService = PlaylistService.shared
    @StateObject private var settingsService = SettingsService.shared
    
    // MARK: - State
    
    @State private var showingFilePicker = false
    @State private var showingDropOverlay = false
    @State private var showingPlaylist = false  // 控制播放列表显示/隐藏
    @State private var showOnboarding = false  // Onboarding 控制
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 右侧播放列表（可收起）
                if showingPlaylist {
                    playlistSidebar
                }
                
                // 播放器区域
                playerArea
                    .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.black)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: FileService.supportedVideoFormats,
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .onOpenURL { url in
            playerService.loadVideo(url: url)
        }
        .onAppear {
            setupNotifications()
            checkOnboarding()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(settingsService: settingsService)
        }
    }
    
    // MARK: - Player Area
    
    private var playerArea: some View {
        GeometryReader { geometry in
            ZStack {
                // 播放器
                DroppableVideoPlayerView(
                    playerService: playerService,
                    playbackState: playerService.playbackState
                )
                
                // 控制栏（悬停显示）
                VStack {
                    Spacer()
                    PlayerControlsView(
                        playerService: playerService,
                        playbackState: playerService.playbackState,
                        settingsService: settingsService,
                        showingPlaylist: $showingPlaylist
                    )
                }
                
                // 拖放覆盖层
                if showingDropOverlay {
                    dropOverlay
                }
            }
            .onDrop(of: [.fileURL, .movie, .video], isTargeted: nil) { providers in
                handleDrop(providers: providers)
                return true
            }
            .onHover { hovering in
                showingDropOverlay = hovering && playerService.currentVideo == nil
            }
        }
    }
    
    private var dropOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
            .foregroundColor(.blue)
            .frame(width: 400, height: 250)
            .background(Color.blue.opacity(0.1))
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "plus.square.on.square")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("释放以添加视频")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("支持 MP4、MKV、AVI、FLV、WebM 等格式")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    // MARK: - Playlist Sidebar
    
    private var playlistSidebar: some View {
        PlaylistView(
            playlistService: playlistService,
            playerService: playerService,
            onDismiss: {
                showingPlaylist = false
            }
        )
        .frame(width: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .border(Color.gray.opacity(0.2), width: 1)
    }
    
    // MARK: - Actions
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .shortcutTriggered,
            object: nil,
            queue: .main
        ) { notification in
            guard let action = notification.userInfo?["action"] as? ShortcutAction else { return }
            handleShortcut(action)
        }
    }
    
    private func handleShortcut(_ action: ShortcutAction) {
        switch action {
        case .playPause:
            playerService.togglePlayPause()
        case .seekForward:
            playerService.seekForward()
        case .seekBackward:
            playerService.seekBackward()
        case .volumeUp:
            playerService.setVolume(playerService.playbackState.volume + 0.1)
        case .volumeDown:
            playerService.setVolume(playerService.playbackState.volume - 0.1)
        case .toggleFullscreen:
            playerService.toggleFullscreen()
        case .toggleMute:
            playerService.toggleMute()
        case .seekToProgress:
            break
        case .slowerPlayback:
            playerService.decreasePlaybackRate()
        case .fasterPlayback:
            playerService.increasePlaybackRate()
        case .resetPlaybackSpeed:
            playerService.resetPlaybackRate()
        case .showSettings:
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        default:
            break
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            playerService.loadVideo(url: url)
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            let videos = FileService.shared.importFiles(urls: urls)
            if let firstVideo = videos.first {
                playerService.loadVideo(firstVideo)
            }
            
            // 添加到播放列表
            if !videos.isEmpty {
                playlistService.addVideos(videos, to: playlistService.getCurrentPlaylist()?.id ?? playlistService.playlists.first?.id ?? UUID())
            }
        case .failure(let error):
            print("选择文件失败: \(error)")
        }
    }
    
    // MARK: - Onboarding
    
    private func checkOnboarding() {
        if settingsService.showOnboarding {
            showOnboarding = true
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
