import SwiftUI

struct SettingsView: View {
    @State private var sleepGoal: Double = 8.0
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A")
                    .ignoresSafeArea()
                
                List {
                    // Sleep Goal
                    Section("settings_goal".localized()) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(Int(sleepGoal)) hours")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Slider(value: $sleepGoal, in: 4...12, step: 1)
                                .tint(.purple)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Reminder
                    Section("settings_reminder".localized()) {
                        Toggle(isOn: $reminderEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.purple)
                                Text("bedtime_reminder")
                            }
                        }
                        
                        if reminderEnabled {
                            HStack {
                                Text("settings_reminder_time")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(formattedTime)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    
                    // Subscription
                    Section("subscription_title") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("subscription_free")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text("subscription_days_remaining")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button(action: {}) {
                                Text("subscription_upgrade")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.purple)
                                    )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // About
                    Section("settings_about") {
                        HStack {
                            Text("settings_version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        Link(destination: URL(string: "https://example.com/privacy")!) {
                            HStack {
                                Text("settings_privacy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Link(destination: URL(string: "https://example.com/terms")!) {
                            HStack {
                                Text("settings_terms")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("settings_title".localized())
            .preferredColorScheme(.dark)
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
}

#Preview {
    SettingsView()
}
