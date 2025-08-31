
import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var level: ExperienceLevel
    var targetCertification: String?
    var weeklyGoalMinutes: Int
    var createdAt: Date
    var lastActiveAt: Date
    
    enum ExperienceLevel: String, Codable, CaseIterable {
        case beginner = "Principiante"
        case intermediate = "Intermedio"
        case advanced = "Avanzado"
        case expert = "Experto"
    }
}
