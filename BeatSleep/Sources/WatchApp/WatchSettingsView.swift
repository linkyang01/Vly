import SwiftUI

struct WatchSettingsView: View {
    @AppStorage("watchHapticEnabled") private var watchHapticEnabled = true
    @AppStorage("watchSoundEnabled") private var watchSoundEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                Section(NSLocalizedString("settings_feedback", comment: "")) {
                    Toggle(NSLocalizedString("settings_haptic_alerts", comment: ""), isOn: $watchHapticEnabled)
                    Toggle(NSLocalizedString("settings_sound_alerts", comment: ""), isOn: $watchSoundEnabled)
                }
                
                Section(NSLocalizedString("settings_about", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("settings_version", comment: ""))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
        }
    }
}

#Preview {
    WatchSettingsView()
}
