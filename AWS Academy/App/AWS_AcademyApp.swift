import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
// import AWSPredictionsPlugin  // <-- quítalo si no usas Predictions y no está en tu JSON

@main
struct AWS_AcademyApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    private static var didConfigureAmplify = false

    init() {
        configureAmplifyOnce()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
                .preferredColorScheme(nil)
        }
    }

    private func configureAmplifyOnce() {
        // Evita configurar en SwiftUI Previews
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        #endif

        guard !Self.didConfigureAmplify else {
            print("ℹ️ Amplify ya estaba configurado (guard).")
            return
        }

        Amplify.Logging.logLevel = .verbose

        do {
            // Agrega SOLO los plugins que tienes en amplifyconfiguration.json
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            // Si agregas Predictions, asegúrate de tener su sección en el JSON:
            // try Amplify.add(plugin: AWSPredictionsPlugin())

            try Amplify.configure()        // <-- SOLO una vez
            Self.didConfigureAmplify = true
            print("✅ Amplify configurado exitosamente")
        } catch {
            // Si por alguna razón ya estaba configurado, marca la bandera y continúa
            let msg = String(describing: error).lowercased()
            if msg.contains("already been configured") {
                Self.didConfigureAmplify = true
                print("ℹ️ Amplify ya estaba configurado (catch).")
            } else {
                print("❌ Error configurando Amplify: \(error)")
            }
        }
    }
}
