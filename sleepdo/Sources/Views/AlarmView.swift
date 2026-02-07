import SwiftUI

struct AlarmView: View {
    @State private var alarms: [Alarm] = [
        Alarm(time: "07:00", label: "工作日", enabled: true, repeatDays: ["周一", "周二", "周三", "周四", "周五"]),
        Alarm(time: "09:00", label: "周末", enabled: false, repeatDays: ["周六", "周日"])
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 智能唤醒卡片
                    SmartWakeupCard()
                        .padding(.horizontal)
                    
                    // 闹钟列表
                    VStack(spacing: 16) {
                        ForEach(alarms) { alarm in
                            AlarmRow(alarm: alarm)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("闹钟")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                    }
                }
            }
        }
    }
}

struct SmartWakeupCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                Text("AI 智能唤醒")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("已开启")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text("在浅睡眠期间唤醒你，精神更充沛")
                .font(.caption)
                .foregroundColor(.gray)
            
            // 进度条
            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i < 3 ? Color(red: 139/255, green: 92/255, blue: 246/255) : Color.gray.opacity(0.3))
                        .frame(height: 8)
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct AlarmRow: View {
    let alarm: Alarm
    @State private var isEnabled: Bool
    
    init(alarm: Alarm) {
        self.alarm = alarm
        self._isEnabled = State(initialValue: alarm.enabled)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.time)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isEnabled ? .white : .gray)
                
                Text(alarm.label)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(alarm.repeatDays.joined(separator: " "))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(Color(red: 139/255, green: 92/255, blue: 246/255))
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(16)
    }
}

struct Alarm: Identifiable {
    let id = UUID()
    let time: String
    let label: String
    let enabled: Bool
    let repeatDays: [String]
}

#Preview {
    AlarmView()
}
