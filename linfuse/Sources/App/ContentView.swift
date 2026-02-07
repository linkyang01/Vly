import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var importedVideos: [ImportedVideo] = []
    @State private var playerURL: URL?
    @State private var showPlayer = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MovieGridView()
            }
            .tabItem { Label("Movies", systemImage: "film.stack") }
            .tag(0)
            
            NavigationStack {
                Text("TV Shows").frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .tabItem { Label("TV Shows", systemImage: "tv") }
            .tag(1)
            
            NavigationStack {
                VideoImporterView(importedVideos: $importedVideos, showPlayer: $showPlayer, playerURL: $playerURL)
            }
            .tabItem { Label("My Videos", systemImage: "play.rectangle.stack") }
            .tag(2)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favorites", systemImage: "star.fill") }
            .tag(3)
            
            NavigationStack {
                WatchHistoryView()
            }
            .tabItem { Label("History", systemImage: "clock.fill") }
            .tag(4)
            
            NavigationStack {
                SimpleSettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(5)
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showPlayer) {
            if let url = playerURL {
                VideoPlayerSheet(url: url)
            }
        }
    }
}

struct VideoPlayerSheet: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(spacing: 0) {
            VideoPlayerRepresentable(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Player")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

struct VideoPlayerRepresentable: NSViewRepresentable {
    let player: AVPlayer?
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .default
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}

struct SimpleSettingsView: View {
    @State private var libraryPath = ""
    @State private var enableMetadata = true
    @State private var enableCloudSync = false
    @State private var selectedServerType = 0
    
    var body: some View {
        Form {
            Section("Library") {
                HStack {
                    TextField("Library Path", text: $libraryPath)
                    Button("Browse") { }
                }
            }
            Section("Network Storage") {
                Picker("Server Type", selection: $selectedServerType) {
                    Text("SMB").tag(0)
                    Text("NFS").tag(1)
                    Text("WebDAV").tag(2)
                }
                Button("Add Server") { }
                Button("Manage Servers") { }
            }
            Section("Features") {
                Toggle("Enable Metadata Fetching", isOn: $enableMetadata)
                Toggle("Enable Cloud Sync", isOn: $enableCloudSync)
            }
            Section("Keyboard Shortcuts") {
                HStack { Text("Play/Pause"); Spacer(); Text("Space").foregroundColor(.secondary) }
                HStack { Text("Skip Forward"); Spacer(); Text("→").foregroundColor(.secondary) }
                HStack { Text("Skip Backward"); Spacer(); Text("←").foregroundColor(.secondary) }
            }
            Section("About") {
                HStack { Text("Version"); Spacer(); Text("1.0.0").foregroundColor(.secondary) }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500)
        .padding()
    }
}

#Preview {
    ContentView()
}
