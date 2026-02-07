import Foundation
import Combine

@MainActor
final class VideoPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isFullScreen = false
    @Published var playbackRate: Double = 1.0
    
    var onPlaybackEnd: (() -> Void)?
    
    func play() {
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        currentTime = time
    }
    
    func setPlaybackRate(_ rate: Double) {
        playbackRate = rate
    }
    
    func enterFullScreen() {
        isFullScreen = true
    }
    
    func exitFullScreen() {
        isFullScreen = false
    }
    
    func cleanup() {
        isPlaying = false
    }
}
