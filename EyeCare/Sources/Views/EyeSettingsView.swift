import SwiftUI

struct EyeSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = true
    @State private var reminderInterval: TimeInterval = 20 * 60 // 20 分钟
    @State private var watchHapticEnabled = true
    @State private var showAbout = false
    
    private let intervals: [TimeInterval] = [20 * 60, 30 * 60, 45 * 60, 60 * 60]
    private let intervalNames: [String] = ["每 20 分钟", "每 30 分钟", "每 45 分钟", "每 60 分钟"]
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.green.opacity(0.1),
                    Color.green.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    notificationSettingsSection
                    deviceSettingsSection
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("个性化你的护眼体验")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    // MARK: - Notification Settings Section
    
    private var notificationSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("提醒设置")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 0) {
                // 提醒开关
                SettingsRow(
                    icon: "bell.fill",
                    title: "提醒开关",
                    color: .red
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // 提醒间隔
                SettingsPickerRow(
                    icon: "clock.fill",
                    title: "提醒间隔",
                    color: .blue,
                    options: intervalNames,
                    selectedIndex: Binding(
                        get: { intervals.firstIndex(of: reminderInterval) ?? 0 },
                        set: { reminderInterval = intervals[$0] }
                    )
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - Device Settings Section
    
    private var deviceSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("关联设置")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Apple Watch 震动
                SettingsRow(
                    icon: "applewatch",
                    title: "Apple Watch 震动",
                    color: .purple
                ) {
                    Toggle("", isOn: $watchHapticEnabled)
                        .labelsHidden()
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // 关联 BeatSleep
                SettingsActionRow(
                    icon: "heart.fill",
                    title: "关联 BeatSleep",
                    color: .pink,
                    action: {
                        // 跳转到 BeatSleep 关联设置
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                // 快捷指令
                SettingsActionRow(
                    icon: "square.grid.2x2",
                    title: "快捷指令",
                    color: .orange,
                    action: {
                        // 打开快捷指令设置
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("关于")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsActionRow(
                    icon: "info.circle.fill",
                    title: "版本信息",
                    color: .gray,
                    action: {
                        showAbout = true
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsActionRow(
                    icon: "star.fill",
                    title: "给我们评分",
                    color: .yellow,
                    action: {
                        // 打开 App Store 评分页面
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsActionRow(
                    icon: "envelope.fill",
                    title: "联系我们",
                    color: .blue,
                    action: {
                        // 打开邮件或反馈页面
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
    }
}

// MARK: - Supporting Views

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

struct SettingsPickerRow: View {
    let icon: String
    let title: String
    let color: Color
    let options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("", selection: $selectedIndex) {
                ForEach(options.indices, id: \.self) { index in
                    Text(options[index])
                        .tag(index)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App 图标
                Image(systemName: "eye.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                // App 名称
                Text("EyeCare")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 版本
                Text("版本 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 描述
                Text("20-20-20 护眼助手\n帮助你养成健康的用眼习惯")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EyeSettingsView()
        .environmentObject(AppState())
}
