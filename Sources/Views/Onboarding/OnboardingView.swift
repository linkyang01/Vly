import SwiftUI

/// 首次启动引导视图
struct OnboardingView: View {
    @ObservedObject var settingsService: SettingsService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    @State private var hasCompletedOnboarding = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "欢迎使用 Vly",
            description: "简洁优雅的视频播放器，支持多种格式和 4K HDR 播放。",
            iconName: "play.rectangle.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "多格式支持",
            description: "支持 MP4、MKV、AVI、FLV、WebM 等主流格式，通过 FFmpeg 解码。",
            iconName: "film",
            color: .purple
        ),
        OnboardingPage(
            title: "快捷键操作",
            description: "使用空格播放/暂停，方向键快进快退，F 键全屏，更多快捷键请查看设置。",
            iconName: "keyboard",
            color: .orange
        ),
        OnboardingPage(
            title: "播放列表",
            description: "创建播放列表，拖放排序，记住播放进度，享受不间断的观影体验。",
            iconName: "list.bullet.rectangle",
            color: .green
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 页面内容
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageContent(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
            
            // 指示器和按钮
            VStack(spacing: 20) {
                // 页面指示器
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // 按钮
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button("上一步") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("下一步") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("开始使用") {
                            completeOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(30)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 550, height: 400)
    }
    
    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.iconName)
                .font(.system(size: 70))
                .foregroundColor(page.color)
            
            Text(page.title)
                .font(.title)
                .bold()
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private func completeOnboarding() {
        settingsService.showOnboarding = false
        hasCompletedOnboarding = true
        dismiss()
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

// MARK: - Preview

#Preview {
    OnboardingView(settingsService: SettingsService.shared)
}
