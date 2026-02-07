import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VideoPlayerViewModel()
    
    var body: some View {
        Group {
            if let url = videoURL {
                VideoPlayerRepresentedView(url: url, viewModel: viewModel)
                    .ignoresSafeArea()
            } else {
                ContentUnavailableView(
                    "No Video",
                    systemImage: "film",
                    description: Text("Video file not found")
                )
            }
        }
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.cleanup()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct VideoPlayerRepresentedView: NSViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: VideoPlayerViewModel
    
    func makeNSView(context: Context) -> AVPlayerView {
        let player = AVPlayer(url: url)
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .minimal
        playerView.showsFullScreenToggleButton = true
        
        // Observe playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            viewModel.onPlaybackEnd?()
        }
        
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        // Updates handled by AVPlayerView automatically
    }
}

#Preview {
    VideoPlayerView(videoURL: nil)
}
