import SwiftUI

struct AchievementsView: View {
    @State private var selectedCategory: AchievementCategory = .all
    @State private var achievements: [Achievement] = []
    
    enum AchievementCategory: String, CaseIterable {
        case all = "Todos"
        case learning = "Aprendizaje"
        case streak = "Racha"
        case mastery = "Maestría"
        case special = "Especiales"
    }
    
    var filteredAchievements: [Achievement] {
        if selectedCategory == .all {
            return achievements
        }
        return achievements.filter { $0.category == selectedCategory.rawValue }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Progress summary
                    AchievementsSummary(
                        unlocked: unlockedCount,
                        total: achievements.count
                    )
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.paddingS) {
                            ForEach(AchievementCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.paddingM)
                    }
                    
                    // Achievements grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Theme.paddingM) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, Theme.paddingM)
                }
                .padding(.vertical, Theme.paddingM)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Logros")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadAchievements()
            }
        }
    }
    
    private func loadAchievements() {
        // Cargar logros desde AWS/Local
        achievements = [
            Achievement(
                id: "1",
                title: "Primera Lección",
                description: "Completa tu primera lección",
                icon: "book.fill",
                category: "Aprendizaje",
                isUnlocked: true,
                unlockedDate: Date(),
                progress: 100
            ),
            Achievement(
                id: "2",
                title: "Racha de 7 días",
                description: "Estudia 7 días seguidos",
                icon: "flame.fill",
                category: "Racha",
                isUnlocked: false,
                progress: 43
            )
        ]
    }
}

struct AchievementsSummary: View {
    let unlocked: Int
    let total: Int
    
    var percentage: Double {
        total > 0 ? Double(unlocked) / Double(total) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: Theme.paddingM) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Logros Desbloqueados")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(unlocked) de \(total)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.awsOrange)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.2)
                        .foregroundColor(Theme.awsOrange)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(percentage / 100))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(Theme.awsOrange)
                        .rotationEffect(Angle(degrees: 270))
                    
                    Text("\(Int(percentage))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
                .frame(width: 60, height: 60)
            }
            
            // Next achievement preview
            if let nextAchievement = getNextAchievement() {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.awsOrange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Próximo logro")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        Text(nextAchievement)
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    Spacer()
                }
                .padding(Theme.paddingS)
                .background(Theme.tertiaryBackground)
                .cornerRadius(Theme.cornerRadiusS)
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal, Theme.paddingM)
    }
    
    private func getNextAchievement() -> String? {
        // Retornar el próximo logro más cercano
        return "Completa 5 lecciones"
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .white : Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
                .padding(.vertical, Theme.paddingS)
                .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
                .cornerRadius(Theme.cornerRadiusS)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Theme.awsOrange : Theme.tertiaryBackground)
                    .frame(width: 60, height: 60)
                
                if !achievement.isUnlocked && achievement.progress > 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(achievement.progress) / 100)
                        .stroke(Theme.awsOrange, lineWidth: 3)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                }
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : Theme.textTertiary)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            if !achievement.isUnlocked && achievement.progress > 0 {
                Text("\(achievement.progress)%")
                    .font(.caption2)
                    .foregroundColor(Theme.awsOrange)
            }
            
            if achievement.isUnlocked, let date = achievement.unlockedDate {
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.paddingS)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: String
    let isUnlocked: Bool
    var unlockedDate: Date? = nil
    var progress: Int = 0
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
}
