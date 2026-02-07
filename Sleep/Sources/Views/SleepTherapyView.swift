import SwiftUI

struct SleepTherapyView: View {
    @State private var selectedSound: WhiteNoiseType?
    @State private var selectedDuration: TimeInterval = 300
    @State private var showPlayer = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 白噪音选择
                        Text("whitenoise_title")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(WhiteNoiseType.allCases) { sound in
                                SoundCard(sound: sound, isSelected: selectedSound == sound) {
                                    selectedSound = sound
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 时长选择
                        Text("duration_title")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        
                        DurationPickerView(selectedDuration: $selectedDuration)
                            .padding(.horizontal, 20)
                        
                        // 开始按钮
                        if selectedSound != nil {
                            Button(action: {
                                showPlayer = true
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("start")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.purple)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("whitenoise_title")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showPlayer) {
                if let sound = selectedSound {
                    WhiteNoisePlayerPage(sound: sound, duration: selectedDuration)
                }
            }
        }
    }
}

struct SoundCard: View {
    let sound: WhiteNoiseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: sound.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : Color(hex: sound.color))
                
                Text(sound.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple : Color.white.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }
}

struct DurationPickerView: View {
    @Binding var selectedDuration: TimeInterval
    
    private let durations: [(TimeInterval, String)] = [
        (60, "1 min"),
        (300, "5 min"),
        (600, "10 min"),
        (1800, "30 min"),
        (3600, "1 hour")
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(durations, id: \.0) { duration, label in
                Button(action: {
                    selectedDuration = duration
                }) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(selectedDuration == duration ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedDuration == duration ? Color.purple.opacity(0.8) : Color.white.opacity(0.05))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SleepTherapyView()
}
