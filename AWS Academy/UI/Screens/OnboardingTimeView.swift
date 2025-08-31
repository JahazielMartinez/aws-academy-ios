
import SwiftUI

struct OnboardingTimeView: View {
    @Binding var weeklyMinutes: Int
    
    let timeOptions = [
        TimeOption(minutes: 30, label: "30 min", description: "5 min al día"),
        TimeOption(minutes: 60, label: "1 hora", description: "~10 min al día"),
        TimeOption(minutes: 120, label: "2 horas", description: "~17 min al día"),
        TimeOption(minutes: 180, label: "3 horas", description: "~25 min al día"),
        TimeOption(minutes: 300, label: "5 horas", description: "~45 min al día"),
        TimeOption(minutes: 420, label: "7+ horas", description: "1+ hora al día")
    ]
    
    var body: some View {
        VStack(spacing: Theme.paddingXL) {
            Spacer()
            
            VStack(spacing: Theme.paddingM) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.awsOrange)
                
                Text("¿Cuánto tiempo dedicarás?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Meta semanal de estudio")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            
            VStack(spacing: Theme.paddingM) {
                Text("\(formatTime(weeklyMinutes)) por semana")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.awsOrange)
                
                Slider(
                    value: Binding(
                        get: { Double(weeklyMinutes) },
                        set: { weeklyMinutes = Int($0) }
                    ),
                    in: 30...420,
                    step: 30
                )
                .accentColor(Theme.awsOrange)
                .padding(.horizontal, Theme.paddingL)
            }
            
            Spacer()
            
            // Opciones rápidas
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.paddingM) {
                ForEach(timeOptions) { option in
                    TimeCard(
                        option: option,
                        isSelected: weeklyMinutes == option.minutes,
                        action: { weeklyMinutes = option.minutes }
                    )
                }
            }
            .padding(.horizontal, Theme.paddingL)
            
            VStack(spacing: Theme.paddingS) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("Podrás cambiar esto en cualquier momento")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Text("Te enviaremos recordatorios para ayudarte a cumplir tu meta")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.paddingL)
            
            Spacer()
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) minutos"
        } else if minutes == 60 {
            return "1 hora"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) horas"
            } else {
                return "\(hours)h \(mins)min"
            }
        }
    }
}

struct TimeOption: Identifiable {
    let id = UUID()
    let minutes: Int
    let label: String
    let description: String
}

struct TimeCard: View {
    let option: TimeOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(option.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Theme.textPrimary)
                
                Text(option.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.paddingM)
            .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusS)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTimeView(weeklyMinutes: .constant(60))
    }
}
