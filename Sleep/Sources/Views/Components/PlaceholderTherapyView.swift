import SwiftUI

struct PlaceholderTherapyView: View {
    let title: String
    let icon: String
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.6))
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("即将推出")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: onStart) {
                Text("开始练习")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.purple)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 60)
    }
}

#Preview {
    PlaceholderTherapyView(
        title: "渐进式肌肉放松",
        icon: "figure.cooldown",
        onStart: {}
    )
}
