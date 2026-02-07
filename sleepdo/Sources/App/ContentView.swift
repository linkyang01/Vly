import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 内容区域
                TabView(selection: $selectedTab) {
                    SleepHomeView().tag(0)
                    SoundsView().tag(1)
                    AlarmView().tag(2)
                    StatsView().tag(3)
                    SettingsView().tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // 自定义 TabBar
                SleepDoTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - 自定义 TabBar
struct SleepDoTabBar: View {
    @Binding var selectedTab: Int
    let tabItems = [
        (icon: "moon.fill", name: "睡眠", tag: 0),
        (icon: "music.note", name: "声音", tag: 1),
        (icon: "alarm.fill", name: "闹钟", tag: 2),
        (icon: "chart.bar.fill", name: "统计", tag: 3),
        (icon: "gearshape.fill", name: "设置", tag: 4)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.tag) { item in
                Button(action: { selectedTab = item.tag }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == item.tag ? .white : .gray)
                        Text(item.name)
                            .font(.system(size: 10))
                            .foregroundColor(selectedTab == item.tag ? .white : .gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        )
        .padding(.bottom, 24)
    }
}

#Preview {
    ContentView()
}
