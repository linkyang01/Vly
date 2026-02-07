//
//  VlyVideoPlayerView.swift
//  Vly
//
//  基于 AVPlayer 的视频播放器视图 (macOS)
//

import SwiftUI
import AVKit

struct VlyVideoPlayerView: View {
    let url: URL
    @StateObject private var playerManager = VideoPlayerManager()
    
    var body: some View {
        ZStack {
            // 视频层
            VideoPlayerLayerView(player: playerManager.player)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 控制条
            PlayerControlsView(
                onPlayPause: {
                    playerManager.togglePlayPause()
                },
                onSeek: { time in
                    playerManager.seek(to: time)
                },
                onVolumeChange: { volume in
                    playerManager.setVolume(volume)
                }
            )
            .frame(height: 252)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .onAppear {
            playerManager.loadVideo(from: url)
        }
    }
}

// MARK: - Video Player Manager

class VideoPlayerManager: ObservableObject {
    let player = AVPlayer()
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Float = 0.8 {
        didSet {
            player.volume = volume
        }
    }
    
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var playerItem: AVPlayerItem?
    private var durationObserver: NSKeyValueObservation?
    
    init() {
        setupPlayer()
    }
    
    deinit {
        removeObservers()
    }
    
    private func setupPlayer() {
        player.volume = volume
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if time.seconds.isFinite {
                self.currentTime = time.seconds
            }
        }
    }
    
    func loadVideo(from url: URL) {
        removeObservers()
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.status == .readyToPlay {
                    self?.duration = item.duration.seconds
                }
            }
        }
        
        durationObserver = playerItem?.observe(\.duration, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.duration.seconds.isFinite && item.duration.seconds > 0 {
                    self?.duration = item.duration.seconds
                }
            }
        }
        
        player.play()
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player.volume = volume
    }
    
    private func removeObservers() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        statusObserver?.invalidate()
        statusObserver = nil
        durationObserver?.invalidate()
        durationObserver = nil
    }
}

// MARK: - Video Player Layer View

struct VideoPlayerLayerView: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .none
        view.videoGravity = .resizeAspect
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}
