import SwiftUI

// MARK: - 付费墙视图

struct PaywallView: View {
    @ObservedObject var tracker = ConversionTracker.shared
    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var isProcessing = false
    
    private var subtitleText: String {
        return "paywall_used_days".localized() + 
               " \(tracker.daysActive) " + 
               "paywall_days".localized() + 
               "，" + 
               "paywall_ready".localized()
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color.purple.opacity(0.3), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // 头部
                    VStack(spacing: 16) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("paywall_unlock".localized())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(subtitleText)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // 价值展示
                    ValueDisplaySection()
                    
                    // 订阅计划
                    SubscriptionPlansSection(
                        selectedPlan: $selectedPlan,
                        onSelect: { plan in
                            selectedPlan = plan
                        }
                    )
                    
                    // CTA 按钮
                    VStack(spacing: 16) {
                        Button {
                            purchase()
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Text(selectedPlan.ctaTextKey.localized())
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                        
                        // 恢复购买
                        Button {
                            restorePurchase()
                        } label: {
                            Text("paywall_restore".localized())
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // 条款
                        HStack(spacing: 4) {
                            Text("paywall_agree_terms".localized())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("paywall_terms".localized())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("paywall_and".localized())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("paywall_privacy".localized())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
    
    private func purchase() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            tracker.subscribe()
            isProcessing = false
            dismiss()
        }
    }
    
    private func restorePurchase() {
        // 恢复购买逻辑
    }
    
    private func dismiss() {
        // 关闭视图
    }
}

// MARK: - 订阅计划

enum SubscriptionPlan: String, CaseIterable {
    case monthly = "monthly"
    case annual = "annual"
    case lifetime = "lifetime"
    
    var id: String { rawValue }
    
    var titleKey: String {
        switch self {
        case .monthly: return "paywall_monthly"
        case .annual: return "paywall_annual"
        case .lifetime: return "paywall_lifetime"
        }
    }
    
    var ctaTextKey: String {
        switch self {
        case .monthly: return "paywall_subscribe_monthly"
        case .annual: return "paywall_subscribe_annual"
        case .lifetime: return "paywall_buy_lifetime"
        }
    }
}

// MARK: - 价值展示区域

struct ValueDisplaySection: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("paywall_your_results".localized())
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 24) {
                ValueItem(
                    icon: "flame.fill",
                    value: "7",
                    label: "paywall_streak_days".localized(),
                    color: .orange
                )
                
                ValueItem(
                    icon: "clock.fill",
                    value: "45min",
                    label: "paywall_total_time".localized(),
                    color: .blue
                )
                
                ValueItem(
                    icon: "heart.fill",
                    value: "+15%",
                    label: "paywall_hrv_improvement".localized(),
                    color: .green
                )
            }
            
            Text("paywall_continue_unlock".localized())
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

struct ValueItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 订阅计划区域

struct SubscriptionPlansSection: View {
    @Binding var selectedPlan: SubscriptionPlan
    let onSelect: (SubscriptionPlan) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                SubscriptionPlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    onSelect: {
                        selectedPlan = plan
                        onSelect(plan)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 订阅计划卡片

struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 16) {
                // 选择指示器
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 2)
                
                // 内容
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plan.titleKey.localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text(plan.priceText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground).opacity(isSelected ? 0.95 : 0.8)))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}

extension SubscriptionPlan {
    var priceText: String {
        switch self {
        case .monthly: return "$4.99/mo"
        case .annual: return "$39.99/yr"
        case .lifetime: return "$99.99"
        }
    }
}

// MARK: - 预览

#Preview {
    PaywallView()
}
