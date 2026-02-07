import SwiftUI
import WatchKit

@main
struct BeatSleepWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}

struct WatchContentView: View {
    var body: some View {
        TabView {
            WatchHomeView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.fill")
                }
            
            WatchTechniquesView()
                .tabItem {
                    Label("Techniques", systemImage: "lungs.fill")
                }
            
            WatchSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color.purple)
    }
}

#Preview {
    WatchContentView()
}
