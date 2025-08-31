import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var isAnimating = false
    @State private var tapCount = 0
    
    var body: some View {
        ZStack {
            // Fondo adaptativo
            Theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: Theme.paddingL) {
                // Logo AWS
                Image(systemName: "cloud.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.awsOrange)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .onTapGesture(count: 5) {
                        // Admin mode con 5 taps
                        appEnvironment.adminModeEnabled = true
                    }
                
                Text("AWS Academy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.awsOrange))
                    .scaleEffect(1.2)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.8)) {
            isAnimating = true
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            SplashView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
