//
//  PlayerControlsView.swift
//  Vly
//
//  视频播放器控制条 - 仿 IINA 风格
//

import SwiftUI

// MARK: - 播放状态

struct PlaybackState {
    var currentTime: Double = 0
    var duration: Double = 5527
    var isPlaying: Bool = false
    var volume: Float = 0.8
    
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }
    
    var durationFormatted: String {
        formatTime(duration)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - 设置

struct PlayerSettings {
    var aspectRatio: AspectRatio = .ratio16x9
    var rotation: Rotation = .zero
    var zoom: Zoom = .onex
    var audioTrack: AudioTrack = .japanese
    var subtitle: Subtitle = .chinese
    var subtitleSize: SubtitleSize = .medium
    var subtitlePosition: SubtitlePosition = .bottom
}

enum AspectRatio: String, CaseIterable { case original = "原始", ratio16x9 = "16:9", ratio16x10 = "16:10", ratio4x3 = "4:3", ratio21x9 = "21:9" }
enum Rotation: String, CaseIterable { case zero = "0°", ninety = "90°", oneEighty = "180°", twoSeventy = "270°" }
enum Zoom: String, CaseIterable { case point5x = "0.5x", onex = "1x", twox = "2x", fourx = "4x" }
enum AudioTrack: String, CaseIterable { case japanese = "日语 (AAC)", english = "英语 (AAC)", chinese = "中文 (AAC)" }
enum Subtitle: String, CaseIterable { case none = "无", chinese = "中文简体", english = "English", japanese = "日本語" }
enum SubtitleSize: String, CaseIterable { case small = "小", medium = "中", large = "大" }
enum SubtitlePosition: String, CaseIterable { case bottom = "底部", middle = "中部", top = "顶部" }

// MARK: - 主控制条视图

struct PlayerControlsView: View {
    @State private var playbackState = PlaybackState()
    @State private var settings = PlayerSettings()
    @State private var showingSettings = false
    @State private var isHovering = false
    
    let onPlayPause: () -> Void
    let onSeek: (Double) -> Void
    let onVolumeChange: (Float) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            progressBar
            timeDisplay
            controlsRow
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .padding(.top, 8)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.85), Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
        )
        .offset(y: isHovering ? 0 : 50)
        .opacity(isHovering ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.2)).frame(height: 4)
                RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: geometry.size.width * CGFloat(playbackState.progress), height: 4)
                Circle().fill(Color.white).frame(width: 12, height: 12).offset(x: geometry.size.width * CGFloat(playbackState.progress) - 6).shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(height: 4)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                let newProgress = max(0, min(1, Double(value.location.x / geometry.size.width)))
                playbackState.currentTime = newProgress * playbackState.duration
                onSeek(playbackState.currentTime)
            })
        }
        .frame(height: 4)
        .padding(.bottom, 16)
    }
    
    private var timeDisplay: some View {
        HStack(spacing: 4) {
            Text(playbackState.currentTimeFormatted).font(.system(size: 13, weight: .medium)).monospacedDigit()
            Text("/").font(.system(size: 13)).opacity(0.6)
            Text(playbackState.durationFormatted).font(.system(size: 13)).opacity(0.7)
        }
        .foregroundColor(.white)
        .padding(.bottom, 12)
    }
    
    private var controlsRow: some View {
        HStack(spacing: 20) {
            leftControls
            Spacer()
            rightControls
        }
    }
    
    private var leftControls: some View {
        HStack(spacing: 20) {
            Button(action: { playbackState.isPlaying.toggle(); onPlayPause() }) {
                Image(systemName: playbackState.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 24)).frame(width: 36, height: 36).foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            Button(action: { playbackState.currentTime = max(0, playbackState.currentTime - 10); onSeek(playbackState.currentTime) }) {
                Image(systemName: "gobackward.10").font(.system(size: 20)).foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            Button(action: { playbackState.currentTime = min(playbackState.duration, playbackState.currentTime + 10); onSeek(playbackState.currentTime) }) {
                Image(systemName: "goforward.10").font(.system(size: 20)).foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 8) {
                Image(systemName: volumeIcon).font(.system(size: 16)).foregroundColor(.white).frame(width: 20)
                Slider(value: Binding(get: { Double(playbackState.volume) }, set: { newValue in
                    playbackState.volume = Float(newValue)
                    onVolumeChange(playbackState.volume)
                }), in: 0...1).frame(width: 80).tint(.white)
            }
        }
    }
    
    private var volumeIcon: String {
        if playbackState.volume == 0 { return "speaker.slash.fill" }
        else if playbackState.volume < 0.5 { return "speaker.wave.1.fill" }
        else { return "speaker.wave.2.fill" }
    }
    
    private var rightControls: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(AspectRatio.allCases, id: \.self) { ratio in Button(action: { settings.aspectRatio = ratio }) { HStack { Text(ratio.rawValue); if settings.aspectRatio == ratio { Image(systemName: "checkmark") } } } }
            } label: {
                Text(settings.aspectRatio.rawValue).font(.system(size: 11, weight: .semibold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(Color.white.opacity(0.1)).cornerRadius(4)
            }
            .frame(minWidth: 36)
            
            Menu {
                ForEach(Rotation.allCases, id: \.self) { rotation in Button(action: { settings.rotation = rotation }) { HStack { Text(rotation.rawValue); if settings.rotation == rotation { Image(systemName: "checkmark") } } } }
            } label: {
                Text("↻").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(Color.white.opacity(0.1)).cornerRadius(4)
            }
            .frame(minWidth: 36)
            
            Button(action: {}) { Image(systemName: "list.bullet").font(.system(size: 16)).foregroundColor(.white) }.buttonStyle(.plain)
            
            Button(action: { showingSettings.toggle() }) { Image(systemName: "gearshape.fill").font(.system(size: 18)).foregroundColor(.white) }.buttonStyle(.plain).popover(isPresented: $showingSettings, arrowEdge: .top) {
                SettingsMenuView(settings: $settings, playbackState: $playbackState).frame(width: 320)
            }
            
            Button(action: {}) { Image(systemName: "arrow.up.left.and.arrow.down.right").font(.system(size: 16)).foregroundColor(.white) }.buttonStyle(.plain)
        }
    }
}

// MARK: - 设置菜单

struct SettingsMenuView: View {
    @Binding var settings: PlayerSettings
    @Binding var playbackState: PlaybackState
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "gearshape.fill").font(.system(size: 14))
                Text("设置").font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20).padding(.vertical, 16).background(Color(white: 0.1)).foregroundColor(.white)
            Divider().background(Color.white.opacity(0.1))
            settingsSection(title: "视频", icon: "film") {
                settingRow(label: "画面比例") { aspectRatioPicker }
                settingRow(label: "旋转") { rotationPicker }
                settingRow(label: "缩放") { zoomPicker }
            }
            Divider().background(Color.white.opacity(0.05))
            settingsSection(title: "音频", icon: "speaker.wave.2") {
                settingRow(label: "音轨") { audioTrackPicker }
                settingRow(label: "音量") { volumeSlider }
            }
            Divider().background(Color.white.opacity(0.05))
            settingsSection(title: "字幕", icon: "textformat") {
                settingRow(label: "字幕") { subtitlePicker }
                settingRow(label: "字体大小") { subtitleSizePicker }
                settingRow(label: "字幕位置") { subtitlePositionPicker }
            }
        }
        .background(Color(white: 0.08)).frame(width: 320)
    }
    
    private func settingsSection(title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                Text(title).font(.system(size: 11, weight: .semibold)).foregroundColor(.white.opacity(0.5)).textCase(.uppercase)
            }
            .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 12)
            VStack(spacing: 0) { content() }.padding(.horizontal, 20).padding(.bottom, 16)
        }
    }
    
    private func settingRow(label: String, @ViewBuilder content: () -> some View) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(.white.opacity(0.9))
            Spacer()
            content()
        }
        .padding(.vertical, 8)
    }
    
    private var aspectRatioPicker: some View {
        Menu {
            ForEach(AspectRatio.allCases, id: \.self) { ratio in Button(action: { settings.aspectRatio = ratio }) { HStack { Text(ratio.rawValue); if settings.aspectRatio == ratio { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.aspectRatio.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
    
    private var rotationPicker: some View {
        Menu {
            ForEach(Rotation.allCases, id: \.self) { rotation in Button(action: { settings.rotation = rotation }) { HStack { Text(rotation.rawValue); if settings.rotation == rotation { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.rotation.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
    
    private var zoomPicker: some View {
        Menu {
            ForEach(Zoom.allCases, id: \.self) { zoom in Button(action: { settings.zoom = zoom }) { HStack { Text(zoom.rawValue); if settings.zoom == zoom { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.zoom.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
    
    private var audioTrackPicker: some View {
        Menu {
            ForEach(AudioTrack.allCases, id: \.self) { track in Button(action: { settings.audioTrack = track }) { HStack { Text(track.rawValue); if settings.audioTrack == track { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.audioTrack.rawValue).font(.system(size: 12)).foregroundColor(.white).lineLimit(1).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 120)
    }
    
    private var volumeSlider: some View {
        Slider(value: Binding(get: { Double(playbackState.volume) }, set: { newValue in playbackState.volume = Float(newValue) }), in: 0...1).frame(width: 100).tint(.white)
    }
    
    private var subtitlePicker: some View {
        Menu {
            ForEach(Subtitle.allCases, id: \.self) { sub in Button(action: { settings.subtitle = sub }) { HStack { Text(sub.rawValue); if settings.subtitle == sub { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.subtitle.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
    
    private var subtitleSizePicker: some View {
        Menu {
            ForEach(SubtitleSize.allCases, id: \.self) { size in Button(action: { settings.subtitleSize = size }) { HStack { Text(size.rawValue); if settings.subtitleSize == size { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.subtitleSize.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
    
    private var subtitlePositionPicker: some View {
        Menu {
            ForEach(SubtitlePosition.allCases, id: \.self) { position in Button(action: { settings.subtitlePosition = position }) { HStack { Text(position.rawValue); if settings.subtitlePosition == position { Image(systemName: "checkmark") } } } }
        } label: {
            Text(settings.subtitlePosition.rawValue).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(6)
        }
        .frame(minWidth: 100)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            Spacer()
            PlayerControlsView(onPlayPause: { print("play/pause") }, onSeek: { _ in print("seek") }, onVolumeChange: { _ in print("volume") })
        }
        .frame(height: 252)
    }
    .frame(width: 1030, height: 580)
}
