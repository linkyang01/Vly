import SwiftUI
import AVKit

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var showingFilePicker = false
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var showingControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if videoURL != nil {
                    VideoPlayerLayerView(player: playerManager.player)
                    
                    if showingControls {
                        FloatingControlBar(playerManager: playerManager)
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 100)
                    }
                } else {
                    EmptyStateView(showingFilePicker: $showingFilePicker)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
            .onHover { hovering in
                if videoURL != nil {
                    if hovering { showControls() }
                    else { hideControlsAfterDelay() }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.movie, .video, .mpeg4Movie, .quickTimeMovie],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        let accessing = url.startAccessingSecurityScopedResource()
                        videoURL = url
                        playerManager.load(url: url)
                        if accessing { url.stopAccessingSecurityScopedResource() }
                    }
                case .failure(let error):
                    print("选择文件失败: \(error)")
                }
            }
        }
    }
    
    private func showControls() {
        showingControls = true
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    
    private func hideControlsAfterDelay() {
        if playerManager.isPlaying {
            controlsTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                withAnimation { showingControls = false }
            }
        }
    }
}

struct FloatingControlBar: View {
    @ObservedObject var playerManager: VideoPlayerManager
    @State private var volume: Double = 0.8
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button {} label: {
                    Image(systemName: volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 10))
                }
                .frame(width: 18, height: 18)
                .glassButton()
                
                SmallSlider(value: $volume, range: 0...1, width: 39)
                
                Button { playerManager.seek(relative: -15) } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 10))
                }
                .frame(width: 18, height: 18)
                .glassButton()
                
                Button { playerManager.togglePlayPause() } label: {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                }
                .frame(width: 32, height: 32)
                .glassButton(isHighlighted: true)
                
                Button { playerManager.seek(relative: 15) } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 10))
                }
                .frame(width: 18, height: 18)
                .glassButton()
                
                Spacer()
                
                Button {} label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 10))
                }
                .frame(width: 18, height: 18)
                .glassButton()
                
                Button {} label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 10))
                }
                .frame(width: 18, height: 18)
                .glassButton()
            }
            .frame(height: 32)
            
            HStack(spacing: 8) {
                Text(playerManager.currentTimeText)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Color(nsColor: NSColor(white: 0.6, alpha: 1.0)))
                    .frame(width: 28, alignment: .leading)
                
                ProgressBar(playerManager: playerManager)
                
                Text(playerManager.durationText)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Color(nsColor: NSColor(white: 0.6, alpha: 1.0)))
                    .frame(width: 34, alignment: .trailing)
            }
            .frame(height: 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(width: 265)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.08, opacity: 0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        )
    }
}

struct ProgressBar: View {
    @ObservedObject var playerManager: VideoPlayerManager
    @State private var isHovering = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(nsColor: NSColor(white: 0.2, alpha: 1.0)))
                    .frame(height: 2)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * playerManager.progress, height: 2)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(x: geometry.size.width * playerManager.progress - 4)
                    .opacity(isHovering ? 1 : 0)
            }
            .contentShape(Capsule())
            .onHover { hovering in
                isHovering = hovering
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let progress = min(max(0, Double(value.location.x / geometry.size.width)), 1)
                        let time = progress * playerManager.duration
                        playerManager.seek(to: time)
                    }
            )
        }
        .frame(height: 8)
    }
}

struct SmallSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let width: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(nsColor: NSColor(white: 0.2, alpha: 1.0)))
                    .frame(height: 2)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * value / (range.upperBound - range.lowerBound), height: 2)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .offset(x: geometry.size.width * value / (range.upperBound - range.lowerBound) - 3)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in
                        let newValue = Double(dragValue.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        value = min(max(range.lowerBound, newValue), range.upperBound)
                    }
            )
        }
        .frame(width: width, height: 6)
    }
}

struct GlassButtonStyle: ButtonStyle {
    var isHighlighted: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(nsColor: NSColor(white: isHighlighted ? 0.15 : 0.08, alpha: 1.0)))
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension View {
    func glassButton(isHighlighted: Bool = false) -> some View {
        self.buttonStyle(GlassButtonStyle(isHighlighted: isHighlighted))
            .foregroundColor(.white)
    }
}

struct EmptyStateView: View {
    @Binding var showingFilePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(nsColor: NSColor(white: 0.3, alpha: 1.0)))
            
            Text("Vly")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("选择文件或拖放视频到此处")
                .font(.caption)
                .foregroundColor(Color(nsColor: NSColor(white: 0.5, alpha: 1.0)))
            
            Button { showingFilePicker = true } label: {
                Text("选择文件")
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct VideoPlayerLayerView: NSViewRepresentable {
    let player: AVPlayer?
    
    func makeNSView(context: Context) -> VlyVideoPlayerView {
        let view = VlyVideoPlayerView()
        view.player = player
        return view
    }
    
    func updateNSView(_ nsView: VlyVideoPlayerView, context: Context) {
        nsView.player = player
    }
}

final class VlyVideoPlayerView: NSView {
    weak var player: AVPlayer? {
        didSet { playerLayer.player = player }
    }
    
    private let playerLayer = AVPlayerLayer()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.addSublayer(playerLayer)
        playerLayer.frame = bounds
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        playerLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }
}

final class VideoPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.8
    
    let player = AVPlayer()
    
    init() {
        player.volume = volume
    }
    
    func load(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        setupObservers()
    }
    
    func play() {
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime)
    }
    
    func seek(relative offset: TimeInterval) {
        let newTime = max(0, min(duration, currentTime + offset))
        seek(to: newTime)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var currentTimeText: String {
        formatTime(currentTime)
    }
    
    var durationText: String {
        formatTime(duration)
    }
    
    private var timeObserver: Any?
    
    private func setupObservers() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds
            self?.duration = self?.player.currentItem?.duration.seconds ?? 0
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        let m = s / 60
        let sec = s % 60
        return "\(m):\(String(format: "%02d", sec))"
    }
}

#Preview {
    ContentView()
}
