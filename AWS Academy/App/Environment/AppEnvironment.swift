import SwiftUI
import Amplify

class AppEnvironment: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var currentUser: User?
    @Published var isOfflineMode: Bool = false
    @Published var adminModeEnabled: Bool = false
    
    init() {
        loadUserPreferences()
    }
    
    private func loadUserPreferences() {
        // Solo cargar preferencias generales aquí
        // La lógica específica del usuario se maneja en ContentView
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }
}
