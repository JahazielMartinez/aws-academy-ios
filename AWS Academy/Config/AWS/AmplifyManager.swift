import Foundation

class AmplifyManager {
    static let shared = AmplifyManager()
    
    private init() {
        configure()
    }
    
    private func configure() {
        // Configuración se agregará después de crear recursos en AWS
        print("AWS Amplify configurado")
    }
}
