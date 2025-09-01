import SwiftUI

struct OnboardingGoalView: View {
    @Binding var selectedCertification: String?
    @State private var cardPressed: String? = nil
    
    // Certificaciones oficiales de AWS
    let certifications = [
        CertificationInfo(
            id: "cloud-practitioner",
            name: "Cloud Practitioner",
            level: "Foundational",
            icon: "cloud",
            color: "#6B46C1",
            difficulty: "Principiante",
            duration: "2-3 meses"
        ),
        CertificationInfo(
            id: "solutions-architect-associate",
            name: "Solutions Architect",
            level: "Associate",
            icon: "building.2",
            color: "#FF9900",
            difficulty: "Intermedio",
            duration: "3-4 meses"
        ),
        CertificationInfo(
            id: "developer-associate",
            name: "Developer",
            level: "Associate",
            icon: "chevron.left.forwardslash.chevron.right",
            color: "#146EB4",
            difficulty: "Intermedio",
            duration: "3-4 meses"
        ),
        CertificationInfo(
            id: "sysops-associate",
            name: "SysOps Administrator",
            level: "Associate",
            icon: "gearshape.2",
            color: "#36C5F0",
            difficulty: "Intermedio",
            duration: "4-5 meses"
        ),
        CertificationInfo(
            id: "solutions-architect-professional",
            name: "Solutions Architect Pro",
            level: "Professional",
            icon: "building.2.fill",
            color: "#FF6900",
            difficulty: "Avanzado",
            duration: "6+ meses"
        ),
        CertificationInfo(
            id: "devops-professional",
            name: "DevOps Engineer Pro",
            level: "Professional",
            icon: "infinity",
            color: "#2EB67D",
            difficulty: "Avanzado",
            duration: "6+ meses"
        ),
        CertificationInfo(
            id: "no-certification",
            name: "Solo aprender",
            level: "Sin certificación",
            icon: "book",
            color: "#808080",
            difficulty: "Flexible",
            duration: "A tu ritmo"
        )
    ]
    
    var body: some View {
        VStack(spacing: Theme.paddingL) {
            VStack(spacing: Theme.paddingM) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.awsOrange)
                
                Text("¿Cuál es tu objetivo?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Elige la certificación que deseas obtener")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.paddingXL)
            
            ScrollView {
                VStack(spacing: Theme.paddingS) {
                    ForEach(certifications) { cert in
                        CertificationCard(
                            certification: cert,
                            isSelected: selectedCertification == cert.id,
                            isPressed: cardPressed == cert.id,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCertification = cert.id
                                }
                            },
                            onPressChanged: { isPressed in
                                cardPressed = isPressed ? cert.id : nil
                            }
                        )
                    }
                }
                .padding(.horizontal, Theme.paddingL)
            }
        }
    }
}

struct CertificationInfo: Identifiable {
    let id: String
    let name: String
    let level: String
    let icon: String
    let color: String
    let difficulty: String
    let duration: String
}

struct CertificationCard: View {
    let certification: CertificationInfo
    let isSelected: Bool
    let isPressed: Bool
    let action: () -> Void
    let onPressChanged: (Bool) -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.paddingM) {
                Image(systemName: certification.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: certification.color) ?? Theme.awsOrange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(certification.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 8) {
                        Text(certification.level)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: certification.color) ?? Theme.awsOrange)
                            .cornerRadius(4)
                        
                        Text(certification.difficulty)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("•")
                            .foregroundColor(Theme.textTertiary)
                        
                        Text(certification.duration)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.awsOrange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .stroke(isSelected ? Theme.awsOrange : Color.clear, lineWidth: 2)
            )
            .cornerRadius(Theme.cornerRadiusM)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPressChanged(true) }
                .onEnded { _ in
                    onPressChanged(false)
                    action()
                }
        )
    }
}

struct OnboardingGoalView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingGoalView(selectedCertification: .constant(nil))
    }
}
