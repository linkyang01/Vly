import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @StateObject private var tracker = ConversionTracker.shared
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if tracker.shouldShowOnboarding() {
                OnboardingView()
            } else {
                MainView()
            }
        }
    }
}

// MARK: - 主视图

struct MainView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @StateObject private var tracker = ConversionTracker.shared
    
    var body: some View {
        TabView {
            SleepHomeView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.fill")
                }
            
            if tracker.daysActive <= 3 {
                TechniquesView()
                    .tabItem {
                        Label("Techniques", systemImage: "lungs.fill")
                    }
            } else if tracker.daysActive <= 5 {
                SleepTherapyView()
                    .tabItem {
                        Label("Sounds", systemImage: "waveform")
                    }
            } else {
                SleepTherapyView()
                    .tabItem {
                        Label("Therapy", systemImage: "sparkles")
                    }
            }
            
            WatchDataView()
                .tabItem {
                    Label("Watch", systemImage: "applewatch.watchface")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color.purple)
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepManager())
}
