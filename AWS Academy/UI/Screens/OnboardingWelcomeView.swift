import SwiftUI

struct OnboardingWelcomeView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.paddingXL) {
            Spacer()
            
            // AWS Logo animado
            Image(systemName: "cloud.fill")
                .font(.system(size: 100))
                .foregroundColor(Theme.awsOrange)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(spacing: Theme.paddingM) {
                Text("Bienvenido a")
                    .font(.title2)
                    .foregroundColor(Theme.textSecondary)
                
                Text("AWS Academy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            
            VStack(spacing: Theme.paddingM) {
                Text("Tu camino hacia la maestría en AWS")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Aprende servicios de AWS de manera interactiva y obtén certificaciones")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.paddingL)
            }
            
            Spacer()
            
            // Features
            VStack(spacing: Theme.paddingM) {
                FeatureRow(
                    icon: "brain",
                    title: "Aprendizaje Adaptativo",
                    description: "Contenido personalizado a tu nivel"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progreso Medible",
                    description: "Rastrea tu avance día a día"
                )
                
                FeatureRow(
                    icon: "medal.fill",
                    title: "Certificaciones",
                    description: "Prepárate para exámenes oficiales"
                )
            }
            .padding(.horizontal, Theme.paddingL)
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.awsOrange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct OnboardingWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingWelcomeView()
                .preferredColorScheme(.light)
            
            OnboardingWelcomeView()
                .preferredColorScheme(.dark)
        }
    }
}
