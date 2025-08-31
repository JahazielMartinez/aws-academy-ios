
import SwiftUI

struct OnboardingLevelView: View {
    @Binding var selectedLevel: User.ExperienceLevel?
    
    var body: some View {
        VStack(spacing: Theme.paddingXL) {
            Spacer()
            
            VStack(spacing: Theme.paddingM) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.awsOrange)
                
                Text("¿Cuál es tu nivel actual?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Esto nos ayudará a personalizar tu experiencia")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: Theme.paddingM) {
                ForEach(User.ExperienceLevel.allCases, id: \.self) { level in
                    LevelCard(
                        level: level,
                        isSelected: selectedLevel == level,
                        action: { selectedLevel = level }
                    )
                }
            }
            .padding(.horizontal, Theme.paddingL)
            
            Spacer()
        }
    }
}

struct LevelCard: View {
    let level: User.ExperienceLevel
    let isSelected: Bool
    let action: () -> Void
    
    private var levelInfo: (icon: String, description: String) {
        switch level {
        case .beginner:
            return ("star", "Nuevo en AWS y cloud computing")
        case .intermediate:
            return ("star.lefthalf.fill", "Conocimiento básico de servicios AWS")
        case .advanced:
            return ("star.fill", "Experiencia práctica con AWS")
        case .expert:
            return ("star.circle.fill", "Dominio profundo de arquitecturas AWS")
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.paddingM) {
                Image(systemName: levelInfo.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Theme.awsOrange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : Theme.textPrimary)
                    
                    Text(levelInfo.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : Theme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(Theme.paddingM)
            .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingLevelView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLevelView(selectedLevel: .constant(.beginner))
    }
}
