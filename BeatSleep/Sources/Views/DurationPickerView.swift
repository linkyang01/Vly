import SwiftUI

// MARK: - 时长选择器视图

struct DurationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let technique: BreathingTechnique
    @State private var selectedMinutes: Int
    @State private var customMinutes: String = ""
    @State private var isCustomMode = false
    
    init(technique: BreathingTechnique) {
        self.technique = technique
        // 读取保存的时长（单位是秒），转换为分钟
        let savedSeconds = UserDefaults.standard.integer(forKey: "duration_\(technique.rawValue)")
        _selectedMinutes = State(initialValue: savedSeconds > 0 ? Int(savedSeconds / 60) : Int(technique.duration / 60))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 标题
                        VStack(spacing: 8) {
                            Image(systemName: technique.icon)
                                .font(.system(size: 50))
                                .foregroundColor(technique.accentColor)
                            
                            Text(technique.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // 预设时长
                        VStack(alignment: .leading, spacing: 12) {
                            Text("duration_preset".localized())
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // 呼吸法最多3档，其他5档
                            let options = technique.steps.isEmpty ? [3, 5, 10, 15, 20] : [3, 5, 10]
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(options, id: \.self) { minutes in
                                    DurationButton(
                                        minutes: minutes,
                                        isSelected: !isCustomMode && selectedMinutes == minutes,
                                        accentColor: technique.accentColor
                                    ) {
                                        isCustomMode = false
                                        selectedMinutes = minutes
                                        customMinutes = ""
                                    }
                                }
                            }
                            
                            // 无步骤的方法显示自定义选项
                            if technique.steps.isEmpty {
                                HStack {
                                    TextField("60", text: $customMinutes)
                                        .keyboardType(.numberPad)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .onChange(of: customMinutes) { newValue in
                                            if let value = Int(newValue), value > 0 {
                                                selectedMinutes = min(value, 60)
                                                isCustomMode = true
                                            }
                                        }
                                    
                                    Text("duration_minutes".localized())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 保存时长显示
                        VStack(spacing: 8) {
                            Text("duration_selected".localized())
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(selectedMinutes) \(NSLocalizedString("techniques_min", comment: ""))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(technique.accentColor)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("duration_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("duration_cancel".localized()) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("duration_save".localized()) {
                        // 保存时转换为秒
                        UserDefaults.standard.set(selectedMinutes * 60, forKey: "duration_\(technique.rawValue)")
                        dismiss()
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 时长按钮

struct DurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(minutes)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : accentColor)
                
                Text("techniques_min".localized())
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? accentColor : accentColor.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        DurationPickerView(technique: .fourSevenEight)
    }
}
