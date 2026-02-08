import SwiftUI
import KSPlayer

/// KSPlayer 播放器主视图
struct KSVideoPlayerView: View {
    @ObservedObject var playerService: PlayerService
    @ObservedObject var playbackState: PlaybackState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 播放器层
                if let player = playerService.player {
                    KSPlayerViewRepresentable(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Color.black
                }
                
                // 加载指示器
                if playerService.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                // 错误提示
                if let error = playerService.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - NSViewRepresentable for KSPlayerLayer

struct KSPlayerViewRepresentable: NSViewRepresentable {
    let player: KSPlayerLayer
    
    func makeNSView(context: Context) -> NSView {
        let view = KSPlayerHostingView(player: player)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? KSPlayerHostingView)?.updatePlayer(player)
    }
}

class KSPlayerHostingView: NSView {
    private var player: KSPlayerLayer?
    private var playerLayerView: MacVideoPlayerView?
    
    init(player: KSPlayerLayer) {
        super.init(frame: .zero)
        self.player = player
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        guard let player = player else { return }
        
        let layerView = MacVideoPlayerView()
        layerView.playerLayer = player
        layerView.frame = bounds
        layerView.autoresizingMask = [.width, .height]
        
        addSubview(layerView)
        playerLayerView = layerView
    }
    
    func updatePlayer(_ newPlayer: KSPlayerLayer) {
        player = newPlayer
        setupView()
    }
}

// MARK: - Video Drop View

/// 支持拖放的播放器视图
struct DroppableVideoPlayerView: View {
    @ObservedObject var playerService: PlayerService
    @ObservedObject var playbackState: PlaybackState
    @State private var isDropping = false
    
    var body: some View {
        ZStack {
            // 播放器层
            if let _ = playerService.currentVideo {
                KSVideoPlayerView(
                    playerService: playerService,
                    playbackState: playbackState
                )
            } else {
                emptyStateView
            }
            
            // 拖放覆盖层
            if isDropping {
                dropOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onHover { hovering in
            isDropping = hovering && playerService.currentVideo == nil
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("拖放视频文件到此处")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("支持 MP4、MKV、AVI、FLV、WebM 等格式")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
    }
    
    private var dropOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
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
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
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
}

// MARK: - Preview

#Preview {
    DroppableVideoPlayerView(
        playerService: PlayerService.shared,
        playbackState: PlaybackState()
    )
    .frame(width: 800, height: 500)
}
