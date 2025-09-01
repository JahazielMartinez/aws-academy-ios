import SwiftUI

struct OnboardingLevelView: View {
    @Binding var selectedLevel: User.ExperienceLevel?
    @State private var cardPressed: User.ExperienceLevel? = nil
    
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
                        isPressed: cardPressed == level,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedLevel = level
                            }
                        },
                        onPressChanged: { isPressed in
                            cardPressed = isPressed ? level : nil
                        }
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
    let isPressed: Bool
    let action: () -> Void
    let onPressChanged: (Bool) -> Void
    
    private var levelInfo: (icon: String, description: String, stars: Int) {
        switch level {
        case .beginner:
            return ("star", "Nuevo en AWS y cloud computing", 1)
        case .intermediate:
            return ("star.lefthalf.fill", "Conocimiento básico de servicios AWS", 2)
        case .advanced:
            return ("star.fill", "Experiencia práctica con AWS", 3)
        case .expert:
            return ("star.circle.fill", "Dominio profundo de arquitecturas AWS", 4)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.paddingM) {
                // Icon with stars
                VStack(spacing: 4) {
                    Image(systemName: levelInfo.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : Theme.awsOrange)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<4) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(
                                    index < levelInfo.stars ?
                                    (isSelected ? .white.opacity(0.8) : Theme.awsOrange.opacity(0.7)) :
                                    (isSelected ? .white.opacity(0.3) : Theme.textTertiary.opacity(0.3))
                                )
                        }
                    }
                }
                .frame(width: 50)
                
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
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Theme.paddingM)
            .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .stroke(isSelected ? Theme.awsOrange : Color.clear, lineWidth: 2)
            )
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

struct OnboardingLevelView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLevelView(selectedLevel: .constant(.beginner))
    }
}
