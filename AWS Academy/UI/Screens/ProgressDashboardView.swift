import SwiftUI

struct ProgressDashboardView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
        case all = "Todo"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Time range selector
                    Picker("Período", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Theme.paddingM)
                    .onChange(of: selectedTimeRange) { _, newValue in
                        viewModel.loadProgressData(for: newValue)
                    }
                    
                    // Main stats
                    MainStatsSection(stats: viewModel.mainStats)
                    
                    // Study streak
                    StreakSection(streak: viewModel.currentStreak)
                    
                    // Activity chart
                    ActivityChartSection(data: viewModel.activityData)
                    
                    // Progress by category
                    CategoryProgressSection(categories: viewModel.categoryProgress)
                    
                    // Achievements
                    AchievementsPreviewSection()
                    
                    // Study time distribution
                    StudyTimeDistributionSection(distribution: viewModel.timeDistribution)
                }
                .padding(.vertical, Theme.paddingM)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Mi Progreso")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadProgressData(for: selectedTimeRange)
            }
        }
    }
}

struct MainStatsSection: View {
    let stats: MainStats
    
    var body: some View {
        VStack(spacing: Theme.paddingM) {
            HStack(spacing: Theme.paddingM) {
                StatCardSimple(
                    title: "Tiempo Total",
                    value: "\(stats.totalMinutes)",
                    unit: "minutos",
                    icon: "clock.fill",
                    color: .blue,
                    change: "+\(stats.minutesChange)%"
                )
                
                StatCardSimple(
                    title: "Lecciones",
                    value: "\(stats.lessonsCompleted)",
                    unit: "completadas",
                    icon: "book.fill",
                    color: .green,
                    change: "+\(stats.lessonsChange)"
                )
            }
            
            HStack(spacing: Theme.paddingM) {
                StatCardSimple(
                    title: "Quizzes",
                    value: "\(stats.quizzesCompleted)",
                    unit: "realizados",
                    icon: "questionmark.circle.fill",
                    color: .purple,
                    change: "+\(stats.quizzesChange)"
                )
                
                StatCardSimple(
                    title: "Promedio",
                    value: "\(stats.averageScore)%",
                    unit: "precisión",
                    icon: "target",
                    color: Theme.awsOrange,
                    change: "+\(stats.scoreChange)%"
                )
            }
        }
        .padding(.horizontal, Theme.paddingM)
    }
}

struct StatCardSimple: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
                Text(change)
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(Theme.paddingM)
        .frame(maxWidth: .infinity)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct StreakSection: View {
    let streak: StreakInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Racha de Estudio")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            HStack(spacing: Theme.paddingL) {
                // Current streak
                VStack(spacing: Theme.paddingS) {
                    HStack(spacing: 4) {
                        Text("\(streak.currentDays)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Theme.awsOrange)
                        Text("🔥")
                            .font(.system(size: 36))
                    }
                    
                    Text("Días consecutivos")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Divider()
                    .frame(height: 60)
                
                // Best streak
                VStack(alignment: .leading, spacing: Theme.paddingS) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Mejor racha")
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    Text("\(streak.bestDays) días")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
                
                Spacer()
            }
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .padding(.horizontal, Theme.paddingM)
            
            // Calendar view
            WeeklyStreakView(weekData: streak.weekData)
                .padding(.horizontal, Theme.paddingM)
        }
    }
}

struct WeeklyStreakView: View {
    let weekData: [Bool]
    let weekDays = ["L", "M", "M", "J", "V", "S", "D"]
    
    var body: some View {
        HStack(spacing: Theme.paddingS) {
            ForEach(0..<7) { index in
                VStack(spacing: 4) {
                    Text(weekDays[index])
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                    
                    Circle()
                        .fill(index < weekData.count && weekData[index] ? Theme.awsOrange : Theme.tertiaryBackground)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(index < weekData.count && weekData[index] ? 1 : 0)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.paddingS)
    }
}

struct ActivityChartSection: View {
    let data: [ActivityData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Actividad Semanal")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            // Simplified bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.awsOrange.opacity(0.8))
                            .frame(width: 40, height: CGFloat(day.minutes * 2))
                        
                        Text(day.label)
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .padding(.horizontal, Theme.paddingM)
        }
    }
}

struct CategoryProgressSection: View {
    let categories: [CategoryProgress]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack {
                Text("Progreso por Categoría")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: ProgressByCategoryView()) {
                    Text("Ver todo")
                        .font(.subheadline)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            .padding(.horizontal, Theme.paddingM)
            
            VStack(spacing: Theme.paddingM) {
                ForEach(categories.prefix(3)) { category in
                    CategoryProgressRow(category: category)
                }
            }
            .padding(.horizontal, Theme.paddingM)
        }
    }
}

struct CategoryProgressRow: View {
    let category: CategoryProgress
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Color(hex: category.color) ?? Theme.awsOrange)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(Int(category.percentage))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.awsOrange)
            }
            
            ProgressView(value: category.percentage / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: category.color) ?? Theme.awsOrange))
            
            HStack {
                Text("\(category.completedServices)/\(category.totalServices) servicios")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text("\(category.timeSpent) min")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct AchievementsPreviewSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack {
                Text("Logros Recientes")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: AchievementsView()) {
                    Text("Ver todos")
                        .font(.subheadline)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            .padding(.horizontal, Theme.paddingM)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    ForEach(0..<5) { index in
                        AchievementBadge(
                            icon: "star.fill",
                            title: "Logro \(index + 1)",
                            unlocked: index < 2
                        )
                    }
                }
                .padding(.horizontal, Theme.paddingM)
            }
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let unlocked: Bool
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            ZStack {
                Circle()
                    .fill(unlocked ? Theme.awsOrange : Theme.tertiaryBackground)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(unlocked ? .white : Theme.textTertiary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
        .opacity(unlocked ? 1.0 : 0.5)
    }
}

struct StudyTimeDistributionSection: View {
    let distribution: [TimeDistribution]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Distribución del Tiempo")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            VStack(spacing: Theme.paddingS) {
                ForEach(distribution) { item in
                    HStack {
                        Circle()
                            .fill(Color(hex: item.color) ?? Theme.awsOrange)
                            .frame(width: 8, height: 8)
                        
                        Text(item.category)
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                        
                        Spacer()
                        
                        Text("\(item.minutes) min")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("(\(item.percentage)%)")
                            .font(.caption)
                            .foregroundColor(Theme.textTertiary)
                    }
                }
            }
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .padding(.horizontal, Theme.paddingM)
        }
    }
}

// Data Models for Progress
struct MainStats {
    let totalMinutes: Int
    let minutesChange: Int
    let lessonsCompleted: Int
    let lessonsChange: Int
    let quizzesCompleted: Int
    let quizzesChange: Int
    let averageScore: Int
    let scoreChange: Int
}

struct StreakInfo {
    let currentDays: Int
    let bestDays: Int
    let weekData: [Bool]
}

struct ActivityData: Identifiable {
    let id = UUID()
    let label: String
    let minutes: Int
}

struct CategoryProgress: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let completedServices: Int
    let totalServices: Int
    let timeSpent: Int
    
    var percentage: Double {
        Double(completedServices) / Double(totalServices) * 100
    }
}

struct TimeDistribution: Identifiable {
    let id = UUID()
    let category: String
    let minutes: Int
    let percentage: Int
    let color: String
}

struct ProgressDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressDashboardView()
    }
}
