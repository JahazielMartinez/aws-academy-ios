
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var selectedLevel: User.ExperienceLevel?
    @Published var selectedCertification: String?
    @Published var weeklyMinutes: Int = 30
    
    func saveOnboardingData() {
        // Guardar en UserDefaults temporalmente
        // Después se sincronizará con AWS
        if let level = selectedLevel {
            UserDefaults.standard.set(level.rawValue, forKey: "userLevel")
        }
        
        if let cert = selectedCertification {
            UserDefaults.standard.set(cert, forKey: "targetCertification")
        }
        
        UserDefaults.standard.set(weeklyMinutes, forKey: "weeklyGoalMinutes")
    }
}
