import SwiftUI
import WatchConnectivity

struct WatchHomeView: View {
    @EnvironmentObject var delegate: ExtensionDelegate
    @State private var showingTechniques = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 状态
                VStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.purple)
                    
                    Text("home_ready_sleep")
                        .font(.headline)
                    
                    // 实时心率
                    if let heartRate = delegate.currentHeartRate {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(heartRate)")
                                .font(.system(size: 24, weight: .light, design: .rounded))
                            Text("bpm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .foregroundColor(.gray)
                            Text("--")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.gray)
                            Text("bpm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // 快捷开始
                NavigationLink(destination: WatchTechniquesView()) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("breathing_start")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Localized Extension

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    WatchHomeView()
        .environmentObject(ExtensionDelegate.shared)
}
