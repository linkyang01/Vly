import SwiftUI
import WatchKit

@main
struct BeatSleep_Watch_App: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WatchHomeView()
            }
        }
    }
}
