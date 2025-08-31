
import SwiftUI

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ProgressCard(
                title: "Minutos",
                value: "45",
                icon: "clock.fill",
                color: .orange
            )
            ProgressCard(
                title: "Lecciones",
                value: "3",
                icon: "book.fill",
                color: .blue
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
