import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "首页"
        case stats = "统计"
        case achievements = "成就"
        case settings = "设置"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .stats: return "chart.bar.fill"
            case .achievements: return "trophy.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 页面内容
            switch selectedTab {
            case .home:
                EyeHomeView()
            case .stats:
                EyeStatsView()
            case .achievements:
                EyeAchievementsView()
            case .settings:
                EyeSettingsView()
            }
            
            // 自定义 TabBar
            VStack(spacing: 0) {
                Divider()
                    .opacity(0.3)
                
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        TabButton(tab: tab, selectedTab: $selectedTab)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                )
            }
            .padding(.bottom, 34) // 底部安全区域
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabButton: View {
    let tab: ContentView.Tab
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == tab ? .green : .gray)
                
                Text(tab.rawValue)
                    .font(.system(size: 10))
                    .foregroundColor(selectedTab == tab ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
