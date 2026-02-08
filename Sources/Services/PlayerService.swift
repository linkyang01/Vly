import Foundation
import KSPlayer
import Combine

/// 播放器服务 - KSPlayer 封装
@MainActor
class PlayerService: NSObject, ObservableObject, KSPlayerLayerDelegate {
    // MARK: - Singleton
    
    static let shared = PlayerService()
    
    // MARK: - Published Properties
    
    @Published var player: KSPlayerLayer?
    @Published var playbackState: PlaybackState = PlaybackState()
    @Published var currentVideo: Video?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Seek Interval
    
    private let seekInterval: TimeInterval = 15
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - KSPlayerLayerDelegate
    
    nonisolated func player(layer: KSPlayerLayer, state: KSPlayerState) {
        Task { @MainActor in
            self.handleStatusChange(state)
        }
    }
    
    nonisolated func player(layer: KSPlayerLayer, currentTime: TimeInterval, totalTime: TimeInterval) {
        Task { @MainActor in
            self.playbackState.currentTime = currentTime
            self.playbackState.duration = totalTime
        }
    }
    
    nonisolated func player(layer: KSPlayerLayer, finish error: Error?) {
        Task { @MainActor in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.playbackState.isPlaying = false
            }
        }
    }
    
    nonisolated func player(layer: KSPlayerLayer, bufferedCount: Int, consumeTime: TimeInterval) {
        // 处理缓冲进度
    }
    
    // MARK: - Public Methods
    
    func loadVideo(url: URL) {
        isLoading = true
        errorMessage = nil
        
        let options = KSOptions()
        player = KSPlayerLayer(url: url, isAutoPlay: true, options: options, delegate: self)
        
        // 创建视频对象
        currentVideo = Video(
            title: url.lastPathComponent,
            url: url,
            duration: 0,
            currentPosition: 0
        )
        
        isLoading = false
    }
    
    func loadVideo(_ video: Video) {
        loadVideo(url: video.url)
        seek(to: video.currentPosition)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(time: time, autoPlay: true) { _ in }
    }
    
    func seekForward(_ interval: TimeInterval? = nil) {
        let targetTime = playbackState.currentTime + (interval ?? seekInterval)
        let clampedTime = min(targetTime, playbackState.duration)
        seek(to: clampedTime)
    }
    
    func seekBackward(_ interval: TimeInterval? = nil) {
        let targetTime = playbackState.currentTime - (interval ?? seekInterval)
        let clampedTime = max(targetTime, 0)
        seek(to: clampedTime)
    }
    
    func seekToProgress(_ progress: Double) {
        let targetTime = playbackState.duration * progress
        seek(to: targetTime)
    }
    
    func setVolume(_ volume: Double) {
        let clampedVolume = max(0, min(1, volume))
        playbackState.volume = clampedVolume
    }
    
    func toggleMute() {
        playbackState.isMuted.toggle()
    }
    
    func setPlaybackRate(_ rate: PlaybackSpeed) {
        player?.player.playbackRate = Float(rate.rawValue)
        playbackState.playbackRate = rate
    }
    
    func increasePlaybackRate() {
        switch playbackState.playbackRate {
        case .slowest: setPlaybackRate(.slow)
        case .slow: setPlaybackRate(.normal)
        case .normal: setPlaybackRate(.fast)
        case .fast: setPlaybackRate(.faster)
        case .faster: setPlaybackRate(.fastest)
        case .fastest: break
        }
    }
    
    func decreasePlaybackRate() {
        switch playbackState.playbackRate {
        case .slowest: break
        case .slow: setPlaybackRate(.slowest)
        case .normal: setPlaybackRate(.slow)
        case .fast: setPlaybackRate(.normal)
        case .faster: setPlaybackRate(.fast)
        case .fastest: setPlaybackRate(.faster)
        }
    }
    
    func resetPlaybackRate() {
        setPlaybackRate(.normal)
    }
    
    func stepForward() {
        // KSPlayer 不支持逐帧播放
    }
    
    func stepBackward() {
        // KSPlayer 不支持逐帧播放
    }
    
    func selectSubtitleTrack(_ track: SubtitleTrack?) {
        // 字幕功能在 KSPlayer 中自动处理
    }
    
    func enterFullscreen() {
        playbackState.isFullscreen = true
    }
    
    func exitFullscreen() {
        playbackState.isFullscreen = false
    }
    
    func toggleFullscreen() {
        playbackState.isFullscreen.toggle()
    }
    
    // MARK: - Stop
    
    func stop() {
        pause()
        player?.pause()
        player = nil
        currentVideo = nil
        playbackState.reset()
    }
    
    // MARK: - Subtitle Methods
    
    func toggleSubtitleVisibility() {
        playbackState.isSubtitleVisible.toggle()
    }
    
    // MARK: - Quality Methods
    
    func selectQuality(_ quality: VideoQuality) {
        playbackState.currentQuality = quality
    }
    
    // MARK: - Info
    
    func getCurrentPosition() -> TimeInterval {
        return playbackState.currentTime
    }
    
    func saveCurrentPosition() {
        guard var video = currentVideo else { return }
        video.currentPosition = playbackState.currentTime
        currentVideo = video
    }
    
    // MARK: - Private Methods
    
    private func handleStatusChange(_ state: KSPlayerState) {
        switch state {
        case .buffering, .bufferFinished:
            playbackState.isPlaying = true
        case .paused:
            playbackState.isPlaying = false
        case .error:
            playbackState.isPlaying = false
        case .readyToPlay:
            isLoading = false
            errorMessage = nil
        case .initialized, .preparing, .playedToTheEnd:
            break
        @unknown default:
            break
        }
    }
}
