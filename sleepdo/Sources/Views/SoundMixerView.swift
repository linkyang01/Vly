//
//  SoundMixerView.swift
//  SleepDo
//
//  混音器页面
//

import SwiftUI

struct SoundMixerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddSound = false
    @State private var showPresets = false
    
    let playingSounds = [
        ("雨夜", "cloud.rain.fill", 0.7, Color.blue),
        ("海浪", "water.waves.fill", 0.4, Color.cyan)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 当前播放的声音
                    VStack(alignment: .leading, spacing: 16) {
                        Text("正在播放")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(playingSounds, id: \.0) { sound in
                                SoundSliderRow(name: sound.0, icon: sound.1, volume: sound.2, color: sound.3)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 添加声音按钮
                    Button(action: { showAddSound = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加声音")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 139/255, green: 92/255, blue: 246/255))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // 预设
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("预设")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button("查看全部") { showPresets = true }
                                .font(.subheadline)
                                .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            PresetRow(name: "雨天午后", icon: "cloud.rain.fill", sounds: "雨夜 + 海浪", isPlaying: true)
                            PresetRow(name: "森林露营", icon: "leaf.fill", sounds: "森林雨 + 河流", isPlaying: false)
                            PresetRow(name: "海浪涛声", icon: "water.waves.fill", sounds: "海浪 + 白噪声", isPlaying: false)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 24)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("混音器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {}
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                }
            }
        }
    }
}

struct SoundSliderRow: View {
    let name: String
    let icon: String
    @State private var volume: Double
    let color: Color
    
    init(name: String, icon: String, volume: Double, color: Color) {
        self.name = name
        self.icon = icon
        self._volume = State(initialValue: volume)
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .cornerRadius(8)
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            Slider(value: $volume, in: 0...1)
                .tint(Color(red: 139/255, green: 92/255, blue: 246/255))
            
            Text("\(Int(volume * 100))%")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 40)
            
            Button(action: {}) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(12)
    }
}

struct PresetRow: View {
    let name: String
    let icon: String
    let sounds: String
    let isPlaying: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                .frame(width: 44, height: 44)
                .background(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(sounds)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
        }
        .padding(12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(12)
    }
}

#Preview {
    SoundMixerView()
}
