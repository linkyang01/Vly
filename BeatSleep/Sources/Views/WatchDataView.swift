import SwiftUI
import WatchConnectivity

// MARK: - Watch 数据页面

struct WatchDataView: View {
    @StateObject private var watchManager = WatchDataManager.shared
    @State private var showConnectionHelp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ConnectionStatusCard(
                            isConnected: watchManager.isConnected,
                            onConnect: { showConnectionHelp = true }
                        )
                        
                        if watchManager.isConnected {
                            RealtimeDataCard(
                                heartRate: watchManager.currentHeartRate,
                                hrv: watchManager.currentHRV,
                                readiness: watchManager.sleepReadiness
                            )
                            
                            
                            if !watchManager.history.isEmpty {
                                DataTrendCard(data: watchManager.history)
                            }
                            
                            ControlButtonsCard(
                                isMonitoring: watchManager.isConnected,
                                onStart: { watchManager.startMonitoring() },
                                onStop: { watchManager.stopMonitoring() },
                                onSync: { watchManager.requestSync() }
                            )
                        } else {
                            NotConnectedCard(onHelp: { showConnectionHelp = true })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("watch_data_title".localized())
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showConnectionHelp) {
                ConnectionHelpSheet()
            }
            .onAppear {
                _ = watchManager
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - 连接状态卡片

struct ConnectionStatusCard: View {
    let isConnected: Bool
    let onConnect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isConnected ? "applewatch" : "applewatch.slash")
                .font(.title2)
                .foregroundColor(isConnected ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isConnected ? "watch_connected".localized() : "watch_not_connected".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isConnected ? "watch_syncing".localized() : "watch_tap_connect".localized())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
        .onTapGesture {
            if !isConnected { onConnect() }
        }
    }
}

// MARK: - 实时数据卡片

struct RealtimeDataCard: View {
    let heartRate: Int?
    let hrv: Double?
    let readiness: SleepReadiness
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("watch_realtime".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("watch_live".localized()).font(.caption).foregroundColor(.green)
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(Color.green.opacity(0.2)))
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("watch_heart_rate".localized()).font(.caption).foregroundColor(.gray)
                    if let hr = heartRate {
                        Text("\(hr)").font(.system(size: 56, weight: .light)).foregroundColor(.purple).monospacedDigit()
                        Text("watch_bpm".localized()).font(.caption).foregroundColor(.gray)
                    } else {
                        Text("--").font(.system(size: 56, weight: .light)).foregroundColor(.gray)
                    }
                }
                
                Divider().frame(height: 60).background(Color.gray.opacity(0.3))
                
                VStack(spacing: 8) {
                    Text("watch_hrv".localized()).font(.caption).foregroundColor(.gray)
                    if let h = hrv {
                        Text(String(format: "%.0f", h)).font(.system(size: 56, weight: .light)).foregroundColor(.purple).monospacedDigit()
                        Text("watch_ms".localized()).font(.caption).foregroundColor(.gray)
                    } else {
                        Text("--").font(.system(size: 56, weight: .light)).foregroundColor(.gray)
                    }
                }
                
                Divider().frame(height: 60).background(Color.gray.opacity(0.3))
                
                VStack(spacing: 8) {
                    Text("watch_sleep_ready".localized()).font(.caption).foregroundColor(.gray)
                    Text(readiness.emoji).font(.system(size: 40))
                    Text(readiness.description.localized()).font(.caption2).foregroundColor(.gray).multilineTextAlignment(.center).frame(width: 80)
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08)))
    }
}

// MARK: - 数据趋势卡片

struct DataTrendCard: View {
    let data: [HeartRateSample]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("watch_today_trend".localized()).font(.headline).foregroundColor(.white)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 2) {
                    let displayData = Array(data.suffix(30))
                    let maxHR = displayData.map(\.bpm).max() ?? 100
                    let minHR = displayData.map(\.bpm).min() ?? 50
                    let range = max(maxHR - minHR, 10)
                    
                    ForEach(displayData) { sample in
                        let height = CGFloat(sample.bpm - minHR) / CGFloat(range) * 80
                        Rectangle()
                            .fill(gradientForBPM(sample.bpm))
                            .frame(width: max(4, geometry.size.width / CGFloat(displayData.count) - 2), height: max(4, height))
                            .cornerRadius(2)
                    }
                }
            }
            .frame(height: 100)
            
            HStack {
                if let first = data.first, let last = data.last {
                    VStack(alignment: .leading) {
                        Text("watch_start".localized()).font(.caption2).foregroundColor(.gray)
                        Text("\(first.bpm) BPM").font(.caption).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Text("watch_min".localized()).font(.caption2).foregroundColor(.gray)
                        Text("\(data.map(\.bpm).min() ?? 0) BPM").font(.caption).foregroundColor(.purple)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("watch_current".localized()).font(.caption2).foregroundColor(.gray)
                        Text("\(last.bpm) BPM").font(.caption).foregroundColor(.white)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }
    
    private func gradientForBPM(_ bpm: Int) -> Color {
        if bpm < 60 { return .blue }
        else if bpm < 70 { return .purple }
        else if bpm < 80 { return .orange }
        else { return .red }
    }
}

// MARK: - 控制按钮卡片

struct ControlButtonsCard: View {
    let isMonitoring: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    let onSync: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: isMonitoring ? onStop : onStart) {
                    HStack {
                        Image(systemName: isMonitoring ? "stop.fill" : "play.fill")
                        Text(isMonitoring ? "watch_stop".localized() : "watch_start".localized())
                    }
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isMonitoring ? Color.red : Color.purple)
                    .cornerRadius(12)
                }
                
                Button(action: onSync) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("watch_sync".localized())
                    }
                    .font(.headline).foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }
}

// MARK: - 未连接卡片

struct NotConnectedCard: View {
    let onHelp: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "applewatch.watchface").font(.system(size: 60)).foregroundColor(.gray)
            Text("watch_pair".localized()).font(.headline).foregroundColor(.white)
            Text("watch_open_app".localized()).font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
            Button(action: onHelp) {
                Text("watch_how_connect".localized()).font(.subheadline).foregroundColor(.purple)
            }
        }
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
    }
}

// MARK: - 连接帮助页面

struct ConnectionHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "applewatch").font(.system(size: 60)).foregroundColor(.purple)
                            Text("watch_connect_title".localized()).font(.title2).fontWeight(.bold).foregroundColor(.white)
                        }
                        .padding(.top, 32)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HelpStep(number: 1, title: "watch_help_step1".localized(), description: "watch_help_step1_desc".localized())
                            HelpStep(number: 2, title: "watch_help_step2".localized(), description: "watch_help_step2_desc".localized())
                            HelpStep(number: 3, title: "watch_help_step3".localized(), description: "watch_help_step3_desc".localized())
                            HelpStep(number: 4, title: "watch_help_step4".localized(), description: "watch_help_step4_desc".localized())
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("watch_done".localized()) { dismiss() }.foregroundColor(.purple)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct HelpStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)").font(.headline).foregroundColor(.white).frame(width: 30, height: 30).background(Circle().fill(Color.purple))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundColor(.white)
                Text(description).font(.subheadline).foregroundColor(.gray)
            }
        }
        .padding().background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }
}

#Preview {
    WatchDataView()
}
