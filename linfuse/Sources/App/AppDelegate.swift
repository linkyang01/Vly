import SwiftUI
import CoreData

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Core Data is already initialized via lazy property
        // Set up menu bar extras if needed
        setupMenus()
        
        // Post welcome notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .appDidFinishLaunching, object: nil)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Save any pending changes
        CoreDataManager.shared.saveContext()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "linfuse" else { return }
        
        switch url.host {
        case "movie":
            if let movieId = url.pathComponents.dropFirst().first {
                NotificationCenter.default.post(
                    name: .openMovieDetail,
                    object: nil,
                    userInfo: ["movieId": movieId]
                )
            }
        case "play":
            if let movieId = url.pathComponents.dropFirst().first {
                NotificationCenter.default.post(
                    name: .playVideo,
                    object: nil,
                    userInfo: ["movieId": movieId]
                )
            }
        default:
            break
        }
    }
    
    private func setupMenus() {
        // Additional menu setup if needed
    }
}

extension Notification.Name {
    static let appDidFinishLaunching = Notification.Name("appDidFinishLaunching")
    static let openMovieDetail = Notification.Name("openMovieDetail")
    static let playVideo = Notification.Name("playVideo")
}
