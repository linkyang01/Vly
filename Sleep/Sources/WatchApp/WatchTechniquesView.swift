import SwiftUI

struct WatchTechniquesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 4-7-8 Breathing
                NavigationLink(destination: WatchBreathingView(technique: .fourSevenEight)) {
                    HStack {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(.purple)
                        Text("4-7-8")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // 2-1-6 Breathing
                NavigationLink(destination: WatchBreathingView(technique: .twoOneSix)) {
                    HStack {
                        Image(systemName: "wind")
                            .foregroundColor(.blue)
                        Text("2-1-6")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle("Techniques")
    }
}

struct WatchBreathingView: View {
    let technique: BreathingTechnique
    @State private var isPlaying = false
    @State private var currentStep = 0
    @State private var countdown = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(technique.shortName)
                .font(.headline)
            
            // Circle animation
            Circle()
                .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: isPlaying ? 100 : 80, height: isPlaying ? 100 : 80)
                        .animation(.easeInOut(duration: 2), value: isPlaying)
                )
            
            if isPlaying {
                Text(technique.steps[currentStep].name)
                    .font(.title3)
                    .foregroundColor(.purple)
                
                Text("\(countdown)")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: togglePlaying) {
                Text(isPlaying ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isPlaying ? Color.red : Color.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .navigationTitle(technique.shortName)
    }
    
    private func togglePlaying() {
        if isPlaying {
            stopBreathing()
        } else {
            startBreathing()
        }
    }
    
    private func startBreathing() {
        isPlaying = true
        currentStep = 0
        countdown = technique.steps[0].duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            if !isPlaying {
                timer?.invalidate()
                return
            }
            
            if countdown > 1 {
                countdown -= 1
            } else {
                currentStep += 1
                if currentStep >= technique.steps.count {
                    currentStep = 0
                }
                countdown = technique.steps[currentStep].duration
            }
        }
    }
    
    private func stopBreathing() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
}
