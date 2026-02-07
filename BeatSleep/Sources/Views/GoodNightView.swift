import SwiftUI

// MARK: - 晚安页面（练习完成后显示，5秒自动消失）

struct GoodNightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var countdown = 5
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                VStack(spacing: 8) {
                    Text("goodnight_title")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("goodnight_message")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("goodnight_closing")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(countdown)")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.purple)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if countdown > 1 {
                    countdown -= 1
                } else {
                    timer.invalidate()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - 预览

#Preview {
    GoodNightView()
}
