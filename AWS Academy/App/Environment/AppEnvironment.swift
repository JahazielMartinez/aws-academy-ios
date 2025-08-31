import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var isOnboardingCompleted: Bool = true  // Cambiar a true para testing
    @Published var currentUser: User?
    @Published var isOfflineMode: Bool = false
    @Published var adminModeEnabled: Bool = false
    
    init() {
        loadUserPreferences()
        
        // TEMPORAL: Crear usuario de prueba para ver el TabBar
        // Comentar estas líneas cuando implementes el login real
        self.currentUser = User(
            id: "test-user",
            name: "Usuario Prueba",
            level: .beginner,
            targetCertification: "cloud-practitioner",
            weeklyGoalMinutes: 60,
            createdAt: Date(),
            lastActiveAt: Date()
        )
    }
    
    private func loadUserPreferences() {
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    }
}
