import SwiftUI
import WatchConnectivity

struct WatchDataView: View {
    @State private var isConnected = false
    @State private var heartRate: Int?
    @State private var hrv: Double?
    @State private var history: [HeartRateData] = []
    @State private var sleepReadiness: SleepReadiness = .unknown
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 连接状态
                HStack {
                    Image(systemName: isConnected ? "applewatch.watchface" : "applewatch")
                        .foregroundColor(isConnected ? .green : .gray)
                    Text(isConnected ? "watch_connected" : "watch_disconnected")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                
                if isConnected {
                    // 心率卡片
                    VStack(spacing: 12) {
                        // 心率
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            if let hr = heartRate {
                                Text("\(hr)")
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
                        if let h = hrv {
                            HStack(spacing: 4) {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(.purple)
                                Text(String(format: "%.0f ms", h))
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
                    
                    // 趋势图
                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("watch_trend")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                ForEach(history.suffix(10)) { sample in
                                    let height = CGFloat(sample.bpm) / 200.0 * 60
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.purple.opacity(0.7))
                                        .frame(width: 20, height: max(4, height))
                                }
                            }
                            .frame(height: 60)
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal)
                    }
                    
                    // 统计
                    HStack(spacing: 16) {
                        StatCard(
                            title: "watch_avg_hr",
                            value: averageHeartRate.map { "\($0)" } ?? "--",
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "watch_samples",
                            value: "\(history.count)",
                            unit: "",
                            icon: "chart.bar.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                } else {
                    // 未连接
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
        .onAppear {
            fetchData()
        }
    }
    
    private var averageHeartRate: Int? {
        guard !history.isEmpty else { return nil }
        let total = history.reduce(0) { $0 + $1.bpm }
        return total / history.count
    }
    
    private func fetchData() {
        guard WCSession.default.isReachable else {
            isConnected = false
            return
        }
        
        isConnected = true
        WCSession.default.sendMessage(["command": "getHeartRateData"]) { reply in
            if let hr = reply["heartRate"] as? Int {
                DispatchQueue.main.async {
                    self.heartRate = hr
                }
            }
            if let h = reply["hrv"] as? Double {
                DispatchQueue.main.async {
                    self.hrv = h
                }
            }
            if let samples = reply["history"] as? [[String: Any]] {
                let data = samples.compactMap { dict -> HeartRateData? in
                    guard let bpm = dict["bpm"] as? Int,
                          let timestamp = dict["timestamp"] as? TimeInterval else { return nil }
                    return HeartRateData(timestamp: timestamp, bpm: bpm)
                }
                DispatchQueue.main.async {
                    self.history = data
                    self.updateSleepReadiness()
                }
            }
        } errorHandler: { _ in
            DispatchQueue.main.async {
                self.isConnected = false
            }
        }
    }
    
    private func updateSleepReadiness() {
        guard let hrv = hrv else {
            sleepReadiness = .unknown
            return
        }
        
        if hrv > 50 {
            sleepReadiness = .ready
        } else if hrv > 30 {
            sleepReadiness = .moderate
        } else {
            sleepReadiness = .notReady
        }
    }
}

// MARK: - Supporting Types

struct HeartRateData: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let bpm: Int
}

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
        case .ready: return "🌙"
        case .moderate: return "💤"
        case .notReady: return "☀️"
        case .unknown: return "📊"
        }
    }
}

// MARK: - Sleep Readiness Badge

struct SleepReadinessBadge: View {
    let readiness: SleepReadiness
    
    var body: some View {
        HStack(spacing: 8) {
            Text(readiness.emoji)
                .font(.title2)
            
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

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    NavigationStack {
        WatchDataView()
    }
}
