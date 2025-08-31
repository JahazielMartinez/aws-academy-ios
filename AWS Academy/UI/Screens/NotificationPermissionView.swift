
import SwiftUI

struct NotificationPermissionView: View {
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.paddingXL) {
                Spacer()
                
                // Icono animado
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.awsOrange)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: Theme.paddingM) {
                    Text("Mantente al día")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Recibe recordatorios para cumplir tus metas de aprendizaje")
                        .font(.body)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.paddingL)
                }
                
                Spacer()
                
                // Beneficios
                VStack(alignment: .leading, spacing: Theme.paddingM) {
                    BenefitRow(
                        icon: "calendar",
                        text: "Recordatorios diarios personalizados"
                    )
                    
                    BenefitRow(
                        icon: "flame",
                        text: "Mantén tu racha de aprendizaje"
                    )
                    
                    BenefitRow(
                        icon: "trophy",
                        text: "Celebra tus logros"
                    )
                    
                    BenefitRow(
                        icon: "sparkles",
                        text: "Nuevos contenidos y actualizaciones"
                    )
                }
                .padding(.horizontal, Theme.paddingXL)
                
                Spacer()
                
                // Botones
                VStack(spacing: Theme.paddingM) {
                    Button(action: enableNotifications) {
                        Text("Activar notificaciones")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.awsOrange)
                            .cornerRadius(Theme.cornerRadiusM)
                    }
                    
                    Button(action: skipNotifications) {
                        Text("Tal vez más tarde")
                            .font(.body)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, Theme.paddingL)
                .padding(.bottom, Theme.paddingL)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func enableNotifications() {
        // Aquí se solicitarán los permisos de notificación
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                navigateToHome = true
            }
        }
    }
    
    private func skipNotifications() {
        navigateToHome = true
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.awsOrange)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
        }
    }
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationPermissionView()
                .preferredColorScheme(.light)
            
            NotificationPermissionView()
                .preferredColorScheme(.dark)
        }
    }
}
