import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var mainStats = MainStats(
        totalMinutes: 0,
        minutesChange: 0,
        lessonsCompleted: 0,
        lessonsChange: 0,
        quizzesCompleted: 0,
        quizzesChange: 0,
        averageScore: 0,
        scoreChange: 0
    )
    
    @Published var currentStreak = StreakInfo(
        currentDays: 0,
        bestDays: 0,
        weekData: [false, false, false, false, false, false, false]
    )
    
    @Published var activityData: [ActivityData] = []
    @Published var categoryProgress: [CategoryProgress] = []
    @Published var timeDistribution: [TimeDistribution] = []
    
    // For ProgressByCategoryView
    @Published var overallProgress: Double = 0
    @Published var totalServicesCompleted = 0
    @Published var totalCategories = 0
    @Published var totalHours = 0
    
    func loadProgressData(for timeRange: ProgressDashboardView.TimeRange) {
        // Simulación temporal - se reemplazará con datos de AWS
        mainStats = MainStats(
            totalMinutes: 0,
            minutesChange: 0,
            lessonsCompleted: 0,
            lessonsChange: 0,
            quizzesCompleted: 0,
            quizzesChange: 0,
            averageScore: 0,
            scoreChange: 0
        )
        
        activityData = [
            ActivityData(label: "L", minutes: 0),
            ActivityData(label: "M", minutes: 0),
            ActivityData(label: "M", minutes: 0),
            ActivityData(label: "J", minutes: 0),
            ActivityData(label: "V", minutes: 0),
            ActivityData(label: "S", minutes: 0),
            ActivityData(label: "D", minutes: 0)
        ]
        
        categoryProgress = []
        timeDistribution = []
    }
    
    func loadCategoryProgress() {
        // Cargar progreso por categoría desde AWS
        categoryProgress = []
        calculateOverallProgress()
    }
    
    func sortedCategories(by option: ProgressByCategoryView.SortOption) -> [CategoryProgress] {
        switch option {
        case .progress:
            return categoryProgress.sorted { $0.percentage > $1.percentage }
        case .name:
            return categoryProgress.sorted { $0.name < $1.name }
        case .time:
            return categoryProgress.sorted { $0.timeSpent > $1.timeSpent }
        }
    }
    
    private func calculateOverallProgress() {
        guard !categoryProgress.isEmpty else {
            overallProgress = 0
            return
        }
        
        let totalCompleted = categoryProgress.reduce(0) { $0 + $1.completedServices }
        let totalServices = categoryProgress.reduce(0) { $0 + $1.totalServices }
        
        overallProgress = totalServices > 0 ? Double(totalCompleted) / Double(totalServices) * 100 : 0
        totalServicesCompleted = totalCompleted
        totalCategories = categoryProgress.count
        totalHours = categoryProgress.reduce(0) { $0 + $1.timeSpent } / 60
    }
}
