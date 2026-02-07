import SwiftUI

@main
struct SleepApp: App {
    @StateObject private var sleepManager = SleepManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sleepManager)
        }
    }
}
