import SwiftUI

struct WatchHomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Status
            VStack(spacing: 8) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("Sleep")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Breathing shortcut
            NavigationLink(destination: WatchTechniquesView()) {
                VStack(spacing: 8) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 30))
                    Text("Breathe")
                        .font(.headline)
                }
                .frame(width: 140, height: 140)
                .background(Color.purple.opacity(0.2))
                .cornerRadius(20)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}
