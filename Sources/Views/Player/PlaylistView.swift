import SwiftUI

/// 播放列表视图
struct PlaylistView: View {
    @ObservedObject var playlistService: PlaylistService
    @ObservedObject var playerService: PlayerService
    
    let onDismiss: () -> Void
    
    @State private var isEditing = false
    @State private var draggedVideo: Video?
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            header
            
            Divider()
            
            // 视频列表
            if let playlist = playlistService.getCurrentPlaylist() {
                videoList(playlist: playlist)
            } else {
                emptyState
            }
            
            Divider()
            
            // 底部工具栏
            footer
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text(playlistService.getCurrentPlaylist()?.name ?? "播放列表")
                .font(.headline)
            
            Spacer()
            
            // 关闭按钮
            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("关闭播放列表")
            
            // 新建按钮
            Button(action: {
                playlistService.createPlaylist()
            }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .help("新建播放列表")
            
            // 编辑按钮
            Button(action: {
                isEditing.toggle()
            }) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    // MARK: - Video List
    
    private func videoList(playlist: Playlist) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(playlist.videos.enumerated()), id: \.element.id) { index, video in
                    videoRow(video: video, index: index, playlist: playlist)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func videoRow(video: Video, index: Int, playlist: Playlist) -> some View {
        HStack(spacing: 10) {
            // 当前播放指示
            if playerService.currentVideo?.id == video.id {
                Image(systemName: "waveform")
                    .foregroundColor(.accentColor)
            }
            
            // 序号或缩略图
            if isEditing {
                Text("\(index + 1)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            } else {
                AsyncThumbnailView(url: video.thumbnailURL)
                    .frame(width: 50, height: 30)
                    .cornerRadius(4)
            }
            
            // 视频信息
            VStack(alignment: .leading, spacing: 2) {
                Text(video.title)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(video.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(video.format.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 删除按钮（编辑模式）
            if isEditing {
                Button(action: {
                    playlistService.removeVideo(id: video.id, from: playlist.id)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            playerService.currentVideo?.id == video.id ?
            Color.accentColor.opacity(0.1) : Color.clear
        )
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture {
            playerService.loadVideo(video)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("播放列表为空")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // 添加视频
                NotificationCenter.default.post(name: .openFilePicker, object: nil)
            }) {
                Label("添加视频", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            // 播放模式
            Menu {
                Button(action: {
                    // 顺序播放
                }) {
                    Label("顺序播放", systemImage: "arrow.right")
                }
                Button(action: {
                    // 随机播放
                }) {
                    Label("随机播放", systemImage: "shuffle")
                }
                Button(action: {
                    // 循环播放
                }) {
                    Label("循环播放", systemImage: "repeat")
                }
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
            }
            
            Spacer()
            
            // 视频数量
            if let playlist = playlistService.getCurrentPlaylist() {
                Text("\(playlist.videoCount) 个视频")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Async Thumbnail View

struct AsyncThumbnailView: View {
    let url: URL?
    
    var body: some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "film")
                    .foregroundColor(.secondary)
            )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openFilePicker = Notification.Name("openFilePicker")
    static let hidePlaylist = Notification.Name("hidePlaylist")
}

// MARK: - Preview

#Preview {
    PlaylistView(
        playlistService: PlaylistService.shared,
        playerService: PlayerService.shared,
        onDismiss: {}
    )
    .frame(width: 280, height: 500)
}
