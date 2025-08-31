import SwiftUI

@main
struct AWS_AcademyApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
                .preferredColorScheme(nil) // Respeta el modo del sistema
        }
    }
}
