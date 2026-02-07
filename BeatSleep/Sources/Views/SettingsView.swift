import SwiftUI
import StoreKit
import UserNotifications

// MARK: - 设置页面

struct SettingsView: View {
    @AppStorage("targetSleepDuration") private var targetSleepDuration = 8.0
    @AppStorage("reminderEnabled") private var reminderEnabled = true
    @State private var reminderTime: Date {
        didSet {
            // 保存时间到 UserDefaults
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
            // 重新调度通知
            NotificationManager.shared.scheduleBedtimeReminder(
                time: reminderTime,
                enabled: reminderEnabled
            )
        }
    }
    
    init() {
        _reminderEnabled = AppStorage(wrappedValue: true, "reminderEnabled")
        // 从 UserDefaults 读取保存的时间，如果不存在则使用默认值 21:00
        let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date
        let defaultTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
        _reminderTime = State(initialValue: savedTime ?? defaultTime)
    }
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    
    @State private var showSubscriptionSheet = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 渐变背景
                LinearGradient(
                    colors: [
                        Color(hex: "#0D0D1A"),
                        Color(hex: "#1A1A3E"),
                        Color(hex: "#2D1B4E")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Form {
                    // 睡眠目标
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.purple)
                                
                                Text("settings_target_duration".localized())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("\(Int(targetSleepDuration))")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.white)
                                
                                Text("settings_hours".localized())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 16)
                            }
                            
                            Slider(value: $targetSleepDuration, in: 5...12, step: 0.5)
                                .tint(.purple)
                                .onChange(of: targetSleepDuration) { _ in
                                    FeedbackManager.shared.tap()
                                }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("settings_sleep_goal".localized())
                            .foregroundColor(.white)
                    }
                    
                    // 提醒
                    Section {
                        Toggle(isOn: $reminderEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.purple)
                                Text("settings_bedtime_reminder".localized())
                            }
                        }
                        .tint(.purple)
                        .onChange(of: reminderEnabled) { _ in
                            FeedbackManager.shared.tap()
                            // 调度或取消通知
                            NotificationManager.shared.scheduleBedtimeReminder(
                                time: reminderTime,
                                enabled: reminderEnabled
                            )
                        }
                        
                        if reminderEnabled {
                            DatePicker(
                                "settings_time".localized(),
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .environment(\.colorScheme, .dark)
                            .accentColor(.purple)
                        }
                    } header: {
                        Text("settings_reminder".localized())
                            .foregroundColor(.white)
                    }
                    
                    // 反馈
                    Section {
                        Toggle(isOn: $soundEnabled) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.purple)
                                Text("settings_sound_effects".localized())
                            }
                        }
                        .tint(.purple)
                        
                        Toggle(isOn: $hapticEnabled) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(.purple)
                                Text("settings_haptic_feedback".localized())
                            }
                        }
                        .tint(.purple)
                    } header: {
                        Text("settings_feedback".localized())
                            .foregroundColor(.white)
                    }
                    
                    // 订阅
                    Section {
                        Button(action: {
                            FeedbackManager.shared.tap()
                            showSubscriptionSheet = true
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                
                                Text("settings_upgrade_pro".localized())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("settings_days_left".localized())
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    } header: {
                        Text("settings_subscription".localized())
                            .foregroundColor(.white)
                    }
                    
                    // 关于
                    Section {
                        HStack {
                            Text("settings_version".localized())
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        Link(destination: URL(string: "https://beatsleep.app/privacy")!) {
                            HStack {
                                Text("settings_privacy_policy".localized())
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Link(destination: URL(string: "https://beatsleep.app/terms")!) {
                            HStack {
                                Text("settings_terms_service".localized())
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Link(destination: URL(string: "https://beatsleep.app/support")!) {
                            HStack {
                                Text("settings_contact_support".localized())
                                Spacer()
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                        .foregroundColor(.white)
                    } header: {
                        Text("settings_about".localized())
                            .foregroundColor(.white)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("settings_title".localized())
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showSubscriptionSheet) {
                SubscriptionSheet()
            }
            .onAppear {
                // App 启动时检查通知权限并调度
                NotificationManager.shared.checkPermissionStatus { status in
                    if status == .notDetermined {
                        NotificationManager.shared.requestPermission { _ in }
                    }
                }
            }
        }
    }
}

// MARK: - 订阅页面

struct SubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 1
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "#0D0D1A"),
                    Color(hex: "#1A1A3E"),
                    Color(hex: "#2D1B4E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 头部
                VStack(spacing: 12) {
                    Text("settings_unlock_full".localized())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("settings_most_beatsleep".localized())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 32)
                
                Spacer()
                
                // 订阅选项
                VStack(spacing: 16) {
                    // 月付
                    PlanCard(
                        title: "settings_monthly".localized(),
                        price: "$4.99",
                        period: "/month",
                        description: "settings_cancel_anytime".localized(),
                        isSelected: selectedPlan == 1
                    ) {
                        selectedPlan = 1
                    }
                    
                    // 年付（推荐）
                    PlanCard(
                        title: "settings_yearly".localized(),
                        price: "$39.99",
                        period: "/year",
                        description: "settings_save_33".localized(),
                        isSelected: selectedPlan == 2,
                        isRecommended: true
                    ) {
                        selectedPlan = 2
                    }
                    
                    // 终身
                    PlanCard(
                        title: "settings_lifetime".localized(),
                        price: "$99.99",
                        period: "once",
                        description: "settings_onetime_payment".localized(),
                        isSelected: selectedPlan == 3
                    ) {
                        selectedPlan = 3
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 按钮
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Text("settings_start_trial".localized())
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(16)
                    }
                    
                    Text("settings_free_then".localized() + " " + planPrice + "/" + planPeriod)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var planPrice: String {
        switch selectedPlan {
        case 1: return "$4.99"
        case 2: return "$3.33"
        case 3: return "$99.99"
        default: return "$4.99"
        }
    }
    
    private var planPeriod: String {
        switch selectedPlan {
        case 1: return "month"
        case 2: return "year"
        case 3: return "once"
        default: return "month"
        }
    }
}

// MARK: - 订阅卡片

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let description: String
    let isSelected: Bool
    var isRecommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(alignment: .top, spacing: 2) {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(period)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                if isRecommended {
                    Text("settings_best_value".localized())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览

#Preview {
    SettingsView()
}
