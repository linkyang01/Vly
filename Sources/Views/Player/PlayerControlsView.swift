import SwiftUI

/// 播放器控制栏视图
struct PlayerControlsView: View {
    @ObservedObject var playerService: PlayerService
    @ObservedObject var playbackState: PlaybackState
    @ObservedObject var settingsService: SettingsService
    @Binding var showingPlaylist: Bool
    
    @State private var isHovering = false
    @State private var previewProgress: Double?
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 进度条
            progressBar
            
            // 控制按钮
            HStack(spacing: 16) {
                // 左侧按钮组
                leftControls
                
                Spacer()
                
                // 进度时间
                timeDisplay
                
                Spacer()
                
                // 右侧按钮组
                rightControls
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .opacity(isHovering ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: FileService.supportedVideoFormats,
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 6)
                
                // 缓冲进度
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: geometry.size.width * playbackState.bufferProgress, height: 6)
                
                // 播放进度
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * (previewProgress ?? playbackState.progressPercentage), height: 6)
                
                // 进度滑块
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)
                    .shadow(radius: 2)
                    .offset(x: max(0, min(geometry.size.width - 7, geometry.size.width * (previewProgress ?? playbackState.progressPercentage) - 7)))
                    .opacity(isHovering ? 1 : 0)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let progress = value.location.x / geometry.size.width
                        let clampedProgress = max(0, min(1, progress))
                        previewProgress = clampedProgress
                    }
                    .onEnded { value in
                        let progress = value.location.x / geometry.size.width
                        let clampedProgress = max(0, min(1, progress))
                        playerService.seekToProgress(clampedProgress)
                        previewProgress = nil
                    }
            )
        }
        .frame(height: 14)
    }
    
    // MARK: - Left Controls
    
    private var leftControls: some View {
        HStack(spacing: 12) {
            // 播放列表按钮
            Button(action: {
                showingPlaylist.toggle()
            }) {
                Image(systemName: showingPlaylist ? "list.bullet.rectangle.fill" : "list.bullet.rectangle")
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help(showingPlaylist ? "隐藏播放列表" : "显示播放列表")
            
            // 打开文件按钮
            Button(action: {
                showingFilePicker = true
            }) {
                Image(systemName: "folder")
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("打开文件")
            
            Divider()
                .frame(height: 20)
            
            // 快退 15 秒
            Button(action: {
                playerService.seekBackward()
            }) {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("快退 15 秒")
            
            // 播放/暂停
            Button(action: {
                playerService.togglePlayPause()
            }) {
                Image(systemName: playbackState.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .help(playbackState.isPlaying ? "暂停" : "播放")
            
            // 快进 15 秒
            Button(action: {
                playerService.seekForward()
            }) {
                Image(systemName: "goforward.15")
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("快进 15 秒")
            
            Divider()
                .frame(height: 20)
            
            // 音量控制
            HStack(spacing: 4) {
                Button(action: {
                    playerService.toggleMute()
                }) {
                    Image(systemName: mutedIcon)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("静音")
                
                Slider(
                    value: Binding(
                        get: { playbackState.volume },
                        set: { playerService.setVolume($0) }
                    ),
                    in: 0...1
                )
                .frame(width: 60)
            }
        }
    }
    
    private var mutedIcon: String {
        if playbackState.isMuted || playbackState.volume == 0 {
            return "speaker.slash.fill"
        } else if playbackState.volume < 0.5 {
            return "speaker.wave.1"
        } else {
            return "speaker.wave.2"
        }
    }
    
    // MARK: - Time Display
    
    private var timeDisplay: some View {
        Text("\(playbackState.formattedCurrentTime) / \(playbackState.formattedDuration)")
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))
    }
    
    // MARK: - Right Controls
    
    private var rightControls: some View {
        HStack(spacing: 12) {
            // 播放速度
            speedMenu
            
            // 字幕选择
            subtitleMenu
            
            // 全屏切换
            Button(action: {
                playerService.toggleFullscreen()
            }) {
                Image(systemName: playbackState.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("全屏切换")
        }
    }
    
    // MARK: - Speed Menu
    
    private var speedMenu: some View {
        Menu {
            ForEach(PlaybackSpeed.allCases, id: \.self) { speed in
                Button(action: {
                    playerService.setPlaybackRate(speed)
                }) {
                    HStack {
                        Text(speed.displayName)
                        if playbackState.playbackRate == speed {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            Button(action: {
                playerService.decreasePlaybackRate()
            }) {
                Label("减速", systemImage: "minus")
            }
            
            Button(action: {
                playerService.increasePlaybackRate()
            }) {
                Label("加速", systemImage: "plus")
            }
            
            Button(action: {
                playerService.resetPlaybackRate()
            }) {
                Label("重置", systemImage: "arrow.counterclockwise")
            }
        } label: {
            Text(playbackState.playbackRate.displayName)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .cornerRadius(4)
        }
        .menuStyle(.borderlessButton)
    }
    
    // MARK: - Subtitle Menu
    
    private var subtitleMenu: some View {
        Menu {
            Button(action: {
                playerService.toggleSubtitleVisibility()
            }) {
                Label(
                    playbackState.isSubtitleVisible ? "隐藏字幕" : "显示字幕",
                    systemImage: playbackState.isSubtitleVisible ? "captions.bubble.fill" : "captions.bubble"
                )
            }
            
            Divider()
            
            Button(action: {
                playerService.selectSubtitleTrack(nil)
            }) {
                Text("关闭字幕")
            }
            
            ForEach(playbackState.subtitleTracks) { track in
                Button(action: {
                    playerService.selectSubtitleTrack(track)
                }) {
                    HStack {
                        Text(track.name)
                        if playbackState.currentSubtitleTrack?.id == track.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "captions.bubble")
                .font(.system(size: 14))
        }
        .menuStyle(.borderlessButton)
    }
    
    // MARK: - File Import
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            let videos = FileService.shared.importFiles(urls: urls)
            if let firstVideo = videos.first {
                playerService.loadVideo(firstVideo)
            }
        case .failure(let error):
            print("选择文件失败: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        
        PlayerControlsView(
            playerService: PlayerService.shared,
            playbackState: PlaybackState(),
            settingsService: SettingsService.shared,
            showingPlaylist: .constant(false)
        )
        .background(Color.black)
        
        Spacer()
    }
    .frame(width: 800, height: 600)
}
