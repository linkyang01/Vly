import SwiftUI
import WatchConnectivity

struct WatchDataView: View {
    @EnvironmentObject var delegate: ExtensionDelegate
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 连接状态
                HStack {
                    Image(systemName: delegate.isConnected ? "applewatch.watchface" : "applewatch")
                        .foregroundColor(delegate.isConnected ? .green : .gray)
                    Text(delegate.isConnected ? "watch_connected" : "watch_disconnected")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                
                // 心率卡片
                VStack(spacing: 12) {
                    // 心率
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        if let heartRate = delegate.currentHeartRate {
                            Text("\(heartRate)")
                                .font(.system(size: 48, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("bpm")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                        } else {
                            Text("--")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 8)
                    
                    // HRV
                    if let hrv = delegate.currentHRV {
                        HStack(spacing: 4) {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.purple)
                            Text(String(format: "%.0f ms", hrv))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 睡眠准备度
                    SleepReadinessBadge(readiness: sleepReadiness)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal)
                
                // 未连接提示
                if !delegate.isConnected {
                    VStack(spacing: 16) {
                        Image(systemName: "applewatch")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("watch_pair_needed")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("watch_open_phone")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("watch_data")
    }
    
    private var sleepReadiness: SleepReadiness {
        guard let hrv = delegate.currentHRV else {
            return .unknown
        }
        
        if hrv > 50 {
            return .ready
        } else if hrv > 30 {
            return .moderate
        } else {
            return .notReady
        }
    }
}

// MARK: - Sleep Readiness

enum SleepReadiness {
    case ready
    case moderate
    case notReady
    case unknown
    
    var description: String {
        switch self {
        case .ready: return "Relaxed & ready"
        case .moderate: return "Getting there..."
        case .notReady: return "Still alert"
        case .unknown: return "Collecting..."
        }
    }
    
    var emoji: String {
        switch self {
        case .ready: return "moon.fill"
        case .moderate: return "zzz"
        case .notReady: return "sun.max"
        case .unknown: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Sleep Readiness Badge

struct SleepReadinessBadge: View {
    let readiness: SleepReadiness
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: readiness.emoji)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("watch_sleep_readiness")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text(readiness.description)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    private var color: Color {
        switch readiness {
        case .ready: return .green
        case .moderate: return .yellow
        case .notReady: return .orange
        case .unknown: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        WatchDataView()
    }
    .environmentObject(ExtensionDelegate.shared)
}
