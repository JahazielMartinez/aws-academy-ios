
import Foundation

struct Service: Identifiable, Codable {
    let id: String
    var name: String
    var fullName: String
    var description: String
    var category: String
    var icon: String
    var difficulty: Difficulty
    var estimatedMinutes: Int
    var isCompleted: Bool
    var completionPercentage: Double
    var content: ServiceContent?
    
    enum Difficulty: String, Codable, CaseIterable {
        case basic = "Básico"
        case intermediate = "Intermedio"
        case advanced = "Avanzado"
    }
    
    init(id: String = UUID().uuidString,
         name: String = "",
         fullName: String = "",
         description: String = "",
         category: String = "",
         icon: String = "cloud",
         difficulty: Difficulty = .basic,
         estimatedMinutes: Int = 15,
         isCompleted: Bool = false,
         completionPercentage: Double = 0,
         content: ServiceContent? = nil) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.description = description
        self.category = category
        self.icon = icon
        self.difficulty = difficulty
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
        self.completionPercentage = completionPercentage
        self.content = content
    }
}

struct ServiceContent: Codable {
    var basicContent: BasicContent?
    var advancedContent: AdvancedContent?
}

struct BasicContent: Codable {
    var concept: String
    var analogy: String
    var example: String
    var realWorldExample: RealWorldExample?
    var objective: String
    var flashcard: Flashcard
}

struct RealWorldExample: Codable {
    var company: String
    var useCase: String
    var reason: String
}

struct Flashcard: Codable {
    var question: String
    var answer: String
}

struct AdvancedContent: Codable {
    var layers: [ContentLayer]
}

struct ContentLayer: Codable {
    var layerNumber: Int
    var title: String
    var content: String
}
