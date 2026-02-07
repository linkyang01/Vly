import SwiftUI

// MARK: - 引导流程视图

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @ObservedObject var tracker = ConversionTracker.shared
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "onboarding_welcome_title".localized(),
            subtitle: "onboarding_welcome_subtitle".localized(),
            description: "onboarding_welcome_description".localized(),
            imageName: "moon.stars.fill",
            color: .indigo
        ),
        OnboardingPage(
            title: "onboarding_478_title".localized(),
            subtitle: "onboarding_478_subtitle".localized(),
            description: "onboarding_478_description".localized(),
            imageName: "wind",
            color: .blue
        ),
        OnboardingPage(
            title: "onboarding_sounds_title".localized(),
            subtitle: "onboarding_sounds_subtitle".localized(),
            description: "onboarding_sounds_description".localized(),
            imageName: "waveform",
            color: .purple
        ),
        OnboardingPage(
            title: "onboarding_plan_title".localized(),
            subtitle: "onboarding_plan_subtitle".localized(),
            description: "onboarding_plan_description".localized(),
            imageName: "calendar",
            color: .green
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [pages[currentPage].color.opacity(0.3), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 60)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("onboarding_continue".localized())
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            tracker.completeOnboarding()
                        } label: {
                            Text("onboarding_skip".localized())
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Button {
                            tracker.completeOnboarding()
                        } label: {
                            Text("onboarding_start".localized())
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 引导页面模型

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - 引导页面视图

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 180, height: 180)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundColor(page.color)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - 预览

#Preview {
    OnboardingView()
}
