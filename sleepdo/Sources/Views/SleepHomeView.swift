import SwiftUI

struct SleepHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 欢迎卡片
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                        
                        Text("晚安")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("祝你有个好梦")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // 睡眠卡片
                    SleepCard(title: "智能唤醒", icon: "sparkles", color: .purple) {
                        Text("AI 分析最佳唤醒时间")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // 快速操作
                    HStack(spacing: 16) {
                        QuickActionButton(icon: "moon.fill", title: "睡前仪式", color: .blue)
                        QuickActionButton(icon: "waveform", title: "声音助眠", color: .cyan)
                        QuickActionButton(icon: "timer", title: "定时器", color: .orange)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("睡眠")
        }
    }
}

struct SleepCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            content
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.15))
                .cornerRadius(16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SleepHomeView()
}
