import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @StateObject private var tracker = ConversionTracker.shared
    @Environment(\.dismiss) private var dismiss
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Sleep",
            description: "The easiest way to fall asleep faster",
            icon: "moon.stars.fill",
            color: "#8B5CF6"
        ),
        OnboardingPage(
            title: "4-7-8 Breathing",
            description: "A scientifically proven technique to help you relax",
            icon: "lungs.fill",
            color: "#06B6D4"
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "See how your sleep improves over time",
            icon: "chart.line.uptrend.xyaxis",
            color: "#10B981"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A")
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // 页面指示器
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 40)
                
                // 按钮
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    } else {
                        Button("Get Started") {
                            tracker.completeOnboarding()
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: page.color))
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
