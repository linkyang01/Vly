import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @StateObject private var tracker = ConversionTracker.shared
    @State private var showOnboarding = false
    @State private var showPaywall = false
    @State private var showReview = true  // 演示模式：始终显示
    
    var body: some View {
        Group {
            if tracker.shouldShowOnboarding() {
                OnboardingView()
            } else {
                MainView()
            }
        }
        .onChange(of: tracker.currentStage) { newStage in
            if newStage == .day8Paywall {
                showPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showReview) {
            SleepReviewView()
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
