import SwiftUI

@main
struct BeatSleepApp: App {
    @StateObject private var sleepManager = SleepManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sleepManager)
        }
    }
}
