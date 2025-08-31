import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: Theme.paddingL) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 80))
                .foregroundColor(Theme.awsOrange)
            
            Text("AWS Academy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text("Versión 1.0.0")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            VStack(spacing: Theme.paddingM) {
                Text("Tu compañero de aprendizaje para dominar AWS")
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: Theme.paddingS) {
                    Label("Desarrollado con SwiftUI", systemImage: "swift")
                    Label("Potenciado por AWS", systemImage: "cloud")
                    Label("Contenido generado con IA", systemImage: "brain")
                }
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, Theme.paddingL)
            
            Spacer()
            
            VStack(spacing: Theme.paddingS) {
                Text("© 2025 AWS Academy")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
                
                HStack(spacing: Theme.paddingM) {
                    Link("Sitio Web", destination: URL(string: "https://aws.amazon.com")!)
                        .font(.caption)
                        .foregroundColor(Theme.awsOrange)
                    
                    Text("•")
                        .foregroundColor(Theme.textTertiary)
                    
                    Link("Soporte", destination: URL(string: "mailto:support@awsacademy.com")!)
                        .font(.caption)
                        .foregroundColor(Theme.awsOrange)
                }
            }
        }
        .padding()
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutView()
        }
    }
}
