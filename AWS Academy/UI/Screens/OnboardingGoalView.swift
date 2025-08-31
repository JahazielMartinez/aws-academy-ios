
import SwiftUI

struct OnboardingGoalView: View {
    @Binding var selectedCertification: String?
    
    // Certificaciones oficiales de AWS
    let certifications = [
        CertificationInfo(
            id: "cloud-practitioner",
            name: "Cloud Practitioner",
            level: "Foundational",
            icon: "cloud",
            color: "#6B46C1"
        ),
        CertificationInfo(
            id: "solutions-architect-associate",
            name: "Solutions Architect",
            level: "Associate",
            icon: "building.2",
            color: "#FF9900"
        ),
        CertificationInfo(
            id: "developer-associate",
            name: "Developer",
            level: "Associate",
            icon: "chevron.left.forwardslash.chevron.right",
            color: "#146EB4"
        ),
        CertificationInfo(
            id: "sysops-associate",
            name: "SysOps Administrator",
            level: "Associate",
            icon: "gearshape.2",
            color: "#36C5F0"
        ),
        CertificationInfo(
            id: "solutions-architect-professional",
            name: "Solutions Architect Pro",
            level: "Professional",
            icon: "building.2.fill",
            color: "#FF6900"
        ),
        CertificationInfo(
            id: "devops-professional",
            name: "DevOps Engineer Pro",
            level: "Professional",
            icon: "infinity",
            color: "#2EB67D"
        ),
        CertificationInfo(
            id: "no-certification",
            name: "Solo aprender",
            level: "Sin certificación",
            icon: "book",
            color: "#808080"
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
                            action: { selectedCertification = cert.id }
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
}

struct CertificationCard: View {
    let certification: CertificationInfo
    let isSelected: Bool
    let action: () -> Void
    
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
                    
                    Text(certification.level)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .stroke(isSelected ? Theme.awsOrange : Color.clear, lineWidth: 2)
            )
            .cornerRadius(Theme.cornerRadiusM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingGoalView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingGoalView(selectedCertification: .constant(nil))
    }
}
