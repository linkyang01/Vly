import SwiftUI
import WatchConnectivity

struct WatchDataView: View {
    @StateObject private var watchManager = WatchDataManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 连接状态
                        ConnectionStatusCard(isConnected: watchManager.isConnected)
                        
                        if watchManager.isConnected {
                            // 心率数据
                            if let heartRate = watchManager.currentHeartRate {
                                HeartRateCard(heartRate: heartRate, hrv: watchManager.currentHRV)
                            }
                            
                            // 控制按钮
                            ControlButtonsCard(
                                isMonitoring: watchManager.isMonitoring,
                                onStart: { watchManager.startMonitoring() },
                                onStop: { watchManager.stopMonitoring() }
                            )
                        } else {
                            NotConnectedCard()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("watch_title".localized())
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
}

struct ConnectionStatusCard: View {
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isConnected ? "applewatch" : "applewatch.slash")
                .font(.title2)
                .foregroundColor(isConnected ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isConnected ? "watch_connected".localized() : "watch_not_connected".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isConnected ? "Syncing..." : "Pair your watch")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }
}

struct HeartRateCard: View {
    let heartRate: Int
    let hrv: Double?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("watch_heart_rate".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("Live")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("\(heartRate)")
                        .font(.system(size: 56, weight: .light))
                        .foregroundColor(.purple)
                        .monospacedDigit()
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let hrv = hrv {
                    Divider().frame(height: 60).background(Color.gray.opacity(0.3))
                    
                    VStack(spacing: 8) {
                        Text(String(format: "%.0f", hrv))
                            .font(.system(size: 56, weight: .light))
                            .foregroundColor(.purple)
                            .monospacedDigit()
                        Text("ms")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08)))
    }
}

struct ControlButtonsCard: View {
    let isMonitoring: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: isMonitoring ? onStop : onStart) {
                HStack {
                    Image(systemName: isMonitoring ? "stop.fill" : "play.fill")
                    Text(isMonitoring ? "Stop" : "Start")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isMonitoring ? Color.red : Color.purple)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }
}

struct NotConnectedCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "applewatch.watchface")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("watch_not_connected".localized())
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Open the Sleep app on your Apple Watch")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
    }
}

#Preview {
    WatchDataView()
}
