import Foundation
import CoreData
import SwiftUI

@main
struct LinfuseApp: App {
    @StateObject private var coreDataManager = CoreDataManager.shared
    @StateObject private var libraryVM = LibraryViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .environmentObject(coreDataManager)
                .environmentObject(libraryVM)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("Import Videos...") {
                    // Open import dialog
                }
                .keyboardShortcut("i")
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
