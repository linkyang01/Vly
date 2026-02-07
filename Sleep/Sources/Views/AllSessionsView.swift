import SwiftUI

struct AllSessionsView: View {
    @EnvironmentObject var sleepManager: SleepManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessionsByDate.keys.sorted().reversed(), id: \.self) { dateKey in
                    Text(dateKey + " · " + "\(sessionsByDate[dateKey]?.count ?? 0) 次")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    ForEach(sessionsByDate[dateKey] ?? []) { session in
                        SessionItemRow(session: session)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
        .navigationTitle("全部记录")
    }
    
    private var sessionsByDate: [String: [SleepSession]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        var groups: [String: [SleepSession]] = [:]
        for session in sleepManager.sessions {
            let key = formatter.string(from: session.date)
            groups[key, default: []].append(session)
        }
        return groups
    }
}

struct SessionItemRow: View {
    let session: SleepSession
    
    var body: some View {
        HStack(spacing: 8) {
            Text(formatTime(session.bedTime))
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            Text(session.quality.emoji + " " + session.qualityText)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            
            Text(session.durationText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            Text(session.hasHeartRate ? "心率 \(session.averageHeartRate)" : "心率 --")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            
            Text("[" + session.techniqueUsed + "]")
                .font(.system(size: 11))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

extension SleepSession {
    var qualityText: String {
        switch quality {
        case .excellent: return "极佳"
        case .good: return "良好"
        case .fair: return "一般"
        case .poor: return "较差"
        }
    }
    
    var durationText: String {
        guard let wakeTime = wakeTime else { return "--" }
        let hours = Int(wakeTime.timeIntervalSince(bedTime) / 3600)
        let minutes = Int(wakeTime.timeIntervalSince(bedTime) / 60) % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    
    var hasHeartRate: Bool {
        guard let data = heartRateData else { return false }
        return !data.isEmpty
    }
    
    var averageHeartRate: Int {
        guard let data = heartRateData, !data.isEmpty else { return 0 }
        return data.map(\.bpm).reduce(0, +) / data.count
    }
}

#Preview {
    NavigationStack {
        AllSessionsView()
            .environmentObject(SleepManager())
    }
}
