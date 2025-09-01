import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import AWSPredictionsPlugin

class AmplifyManager: ObservableObject {
    static let shared = AmplifyManager()
    @Published var isConfigured = false
    
    private init() {}
    
    func configure() async {
        do {
            // Verificar si ya está configurado
            if !isConfigured {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.add(plugin: AWSAPIPlugin())
                try Amplify.add(plugin: AWSS3StoragePlugin())
                try Amplify.add(plugin: AWSPredictionsPlugin())
                
                try Amplify.configure()
                
                await MainActor.run {
                    self.isConfigured = true
                }
                print("✅ Amplify configurado exitosamente")
            }
        } catch {
            print("❌ Error configurando Amplify: \(error)")
        }
    }
    
    func getCurrentUser() async -> AuthUser? {
        do {
            return try await Amplify.Auth.getCurrentUser()
        } catch {
            print("Error obteniendo usuario actual: \(error)")
            return nil
        }
    }
    
    func signOut() async {
        do {
            _ = await Amplify.Auth.signOut()
            print("Usuario deslogueado exitosamente")
        } catch {
            print("Error en signOut: \(error)")
        }
    }
}
