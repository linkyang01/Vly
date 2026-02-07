import SwiftUI

@main
struct SleepWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WatchHomeView()
            }
        }
    }
}
