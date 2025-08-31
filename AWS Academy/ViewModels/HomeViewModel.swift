import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var greeting: String = ""
    @Published var motivationalMessage: String = ""
    @Published var dailyProgress: DailyProgress?
    @Published var featuredCategories: [Category] = []
    @Published var recentServices: [Service] = []
    @Published var currentStreak: Int = 0
    @Published var dailyGoalMinutes: Int = 60
    
    init() {
        setGreeting()
        loadUserGoals()
    }
    
    func loadHomeData() {
        // Datos temporales - serán reemplazados por llamadas a AWS
        self.dailyProgress = DailyProgress(
            minutesStudied: 0,
            lessonsCompleted: 0,
            quizzesCompleted: 0,
            streak: 0
        )
        
        self.currentStreak = 0
        
        // Categorías vacías - se llenarán desde AWS
        self.featuredCategories = []
        
        // Servicios recientes vacíos - se llenarán desde AWS
        self.recentServices = []
    }
    
    private func setGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        
        switch hour {
        case 0..<12:
            greeting = userName.isEmpty ? "Buenos días" : "Buenos días, \(userName)"
        case 12..<19:
            greeting = userName.isEmpty ? "Buenas tardes" : "Buenas tardes, \(userName)"
        default:
            greeting = userName.isEmpty ? "Buenas noches" : "Buenas noches, \(userName)"
        }
        
        // Mensajes motivacionales variados
        let messages = [
            "¡Continuemos aprendiendo!",
            "Cada día más cerca de tu meta",
            "El conocimiento es poder",
            "Hoy es un gran día para aprender",
            "¡Vamos por más!"
        ]
        motivationalMessage = messages.randomElement() ?? messages[0]
    }
    
    private func loadUserGoals() {
        dailyGoalMinutes = UserDefaults.standard.integer(forKey: "weeklyGoalMinutes") / 7
        if dailyGoalMinutes == 0 {
            dailyGoalMinutes = 60 // Default
        }
    }
}

struct DailyProgress {
    let minutesStudied: Int
    let lessonsCompleted: Int
    let quizzesCompleted: Int
    let streak: Int
}
