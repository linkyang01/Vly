import SwiftUI
import WatchConnectivity

struct WatchHomeView: View {
    @State private var heartRate: Int?
    @State private var isConnected = false
    
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
                    if isConnected, let hr = heartRate {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(hr)")
                                .font(.system(size: 24, weight: .light, design: .rounded))
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
        .onAppear {
            // 通过 WCSession 获取连接状态
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(["command": "getStatus"]) { reply in
                    DispatchQueue.main.async {
                        self.isConnected = true
                        if let hr = reply["heartRate"] as? Int {
                            self.heartRate = hr
                        }
                    }
                } errorHandler: { _ in
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                }
            }
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    WatchHomeView()
}
