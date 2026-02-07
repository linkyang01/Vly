import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 400)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 400)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
        }
    }
}

#Preview {
    VideoPlayerView(url: URL(string: "https://example.com/video.mp4")!)
}
