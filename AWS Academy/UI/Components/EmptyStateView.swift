
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Theme.paddingL) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Theme.textTertiary)
            
            VStack(spacing: Theme.paddingS) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.paddingL)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.paddingL)
                        .padding(.vertical, Theme.paddingM)
                        .background(Theme.awsOrange)
                        .cornerRadius(Theme.cornerRadiusM)
                }
                .padding(.top, Theme.paddingS)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            icon: "cloud",
            title: "Sin conexión",
            message: "No se puede cargar el contenido en este momento",
            actionTitle: "Reintentar",
            action: {}
        )
    }
}
