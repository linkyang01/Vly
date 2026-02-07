import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 用户信息
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("用户")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("升级到终身会员")
                                .font(.caption)
                                .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
                    .cornerRadius(20)
                    
                    // 设置列表
                    VStack(spacing: 1) {
                        SettingsRow(icon: "bell.fill", title: "通知设置", color: .orange)
                        SettingsRow(icon: "moon.fill", title: "睡眠设置", color: .blue)
                        SettingsRow(icon: "waveform", title: "声音设置", color: .cyan)
                        SettingsRow(icon: "heart.fill", title: "健康数据", color: .red)
                        SettingsRow(icon: "lock.fill", title: "隐私政策", color: .gray)
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
                    .cornerRadius(16)
                    
                    // 关于
                    VStack(spacing: 12) {
                        SettingsRow(icon: "info.circle.fill", title: "关于", color: .green)
                        SettingsRow(icon: "star.fill", title: "评价", color: .yellow)
                        SettingsRow(icon: "questionmark.circle.fill", title: "帮助", color: .purple)
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("设置")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(16)
    }
}

#Preview {
    SettingsView()
}
