import Foundation
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    // Estado público
    @Published var isSignedIn = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage = ""

    /// Marca si la sesión actual proviene de un **login** iniciado por el usuario
    /// (botón "Ya tengo cuenta"). Si es `true`, ContentView saltará el onboarding.
    @Published var didSignInFromLogin = false

    // Stash temporal para auto-login post verificación
    private(set) var pendingSignUpEmail: String?
    private(set) var pendingSignUpPassword: String?

    static let shared = AuthService()

    private init() {
        Task { await checkAuthStatus() }
    }

    // MARK: - Session

    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                let user = try await Amplify.Auth.getCurrentUser()
                self.isSignedIn = true
                self.currentUser = user
                print("✅ Usuario autenticado: \(user.username)")
            } else {
                self.isSignedIn = false
                self.currentUser = nil
                print("ℹ️ Sesión no iniciada")
            }
        } catch {
            self.isSignedIn = false
            self.currentUser = nil
            print("ℹ️ Usuario no autenticado (error al consultar sesión): \(error)")
        }
    }

    // MARK: - Sign In

    /// Inicia sesión con email/contraseña (flujo "Ya tengo cuenta").
    /// Sugerencia: en tu LoginView, si esto retorna `true`, llama también `markSignedInFromLogin()`.
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = ""
        let username = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            // Evita conflicto si ya hay una sesión activa
            try await ensureSignedOutBeforeSignIn(targetUsername: username)

            // Anti “doble tap”: si ya quedó autenticado, refresca estado y termina
            let pre = try await Amplify.Auth.fetchAuthSession()
            if pre.isSignedIn {
                self.isLoading = false
                await checkAuthStatus()
                return true
            }

            print("🔍 Intentando login con email: \(username)")
            let result = try await Amplify.Auth.signIn(username: username, password: password)

            self.isLoading = false

            if result.isSignedIn {
                await checkAuthStatus()
                print("✅ Login exitoso")
                return true
            } else {
                switch result.nextStep {
                case .confirmSignUp:
                    self.errorMessage = "Usuario no confirmado. Revisa tu email."
                case .confirmSignInWithNewPassword:
                    self.errorMessage = "Se requiere nueva contraseña (primera vez)."
                case .confirmSignInWithSMSMFACode(_):
                    self.errorMessage = "Ingresa el código SMS de verificación."
                case .confirmSignInWithTOTPCode:
                    self.errorMessage = "Ingresa el código de tu app autenticadora."
                case .resetPassword:
                    self.errorMessage = "Debes restablecer la contraseña."
                default:
                    self.errorMessage = "Verificación adicional requerida."
                }
                return false
            }

        } catch let authErr as AuthError {
            self.isLoading = false
            self.errorMessage = authErr.errorDescription ?? "Error de autenticación"
            print("❌ AuthError:", authErr)
            return false

        } catch {
            self.isLoading = false
            self.errorMessage = "Error inesperado: \(error.localizedDescription)"
            return false
        }
    }

    /// Marca explícitamente que la sesión proviene de un login manual.
    /// Úsalo en tu LoginView tras un `signIn` exitoso.
    func markSignedInFromLogin() {
        didSignInFromLogin = true
    }

    // MARK: - Sign Up

    /// Registra al usuario y guarda credenciales para auto-login después de confirmar el email.
    func signUp(email: String, password: String, fullName: String) async -> Bool {
        isLoading = true
        errorMessage = ""

        do {
            let userAttributes = [
                AuthUserAttribute(.email, value: email),
                AuthUserAttribute(.name, value: fullName)
            ]
            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )

            self.isLoading = false

            // Guarda credenciales para auto-login tras confirmación
            stashPendingCredentials(email: email, password: password)

            if result.isSignUpComplete {
                print("✅ Usuario registrado (signUpComplete=true)")
                return true
            } else {
                print("📧 Registro creado. Verificación de email requerida.")
                return true
            }

        } catch let error as AuthError {
            self.isLoading = false
            self.errorMessage = error.errorDescription ?? "Error de registro"
            print("❌ Error en registro: \(error)")
            return false

        } catch {
            self.isLoading = false
            self.errorMessage = "Error inesperado"
            return false
        }
    }

    /// Confirma el código de verificación recibido por email.
    func confirmSignUp(email: String, confirmationCode: String) async -> Bool {
        isLoading = true
        errorMessage = ""

        do {
            let result = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: confirmationCode
            )

            self.isLoading = false

            if result.isSignUpComplete {
                print("✅ Email confirmado exitosamente")
                return true
            } else {
                self.errorMessage = "Error confirmando email"
                return false
            }

        } catch let error as AuthError {
            self.isLoading = false
            self.errorMessage = error.errorDescription ?? "Código inválido"
            print("❌ Error confirmando email: \(error)")
            return false

        } catch {
            self.isLoading = false
            self.errorMessage = "Código inválido"
            return false
        }
    }

    /// Reenvía el código de verificación de registro.
    func resendConfirmationCode(email: String) async {
        do {
            try await Amplify.Auth.resendSignUpCode(for: email)
            print("✅ Código reenviado")
        } catch {
            print("❌ Error reenviando código: \(error)")
        }
    }

    // MARK: - Auto login después de verificación

    /// Inicia sesión automáticamente con las credenciales guardadas durante el signUp,
    /// después de que el usuario confirme su email.
    @discardableResult
    func signInAfterVerification(email: String) async -> Bool {
        guard
            let e = pendingSignUpEmail,
            let p = pendingSignUpPassword,
            e.caseInsensitiveCompare(email) == .orderedSame
        else {
            print("⚠️ No hay credenciales pendientes para auto-login o email no coincide.")
            return false
        }

        let ok = await signIn(email: e, password: p)
        if ok {
            clearPendingCredentials()
            // Esta sesión NO proviene de login manual; es parte del flujo de registro
            didSignInFromLogin = false
        }
        return ok
    }

    // MARK: - Password reset

    func resetPassword(email: String) async -> Bool {
        do {
            _ = try await Amplify.Auth.resetPassword(for: email)
            print("✅ Email de recuperación enviado")
            return true
        } catch {
            print("❌ Error enviando recuperación: \(error)")
            return false
        }
    }

    func confirmResetPassword(email: String, newPassword: String, confirmationCode: String) async -> Bool {
        isLoading = true
        errorMessage = ""

        do {
            try await Amplify.Auth.confirmResetPassword(
                for: email,
                with: newPassword,
                confirmationCode: confirmationCode
            )

            self.isLoading = false
            print("✅ Contraseña restablecida exitosamente")
            return true
        } catch let error as AuthError {
            self.isLoading = false
            self.errorMessage = error.errorDescription ?? "Error restableciendo contraseña"
            print("❌ Error restableciendo contraseña: \(error)")
            return false
        } catch {
            self.isLoading = false
            self.errorMessage = "Error inesperado"
            return false
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            _ = await Amplify.Auth.signOut()
            self.isSignedIn = false
            self.currentUser = nil
            print("✅ Logout exitoso")
        } catch {
            print("❌ Error en logout: \(error)")
        }
    }

    // MARK: - Helpers internos

    private func stashPendingCredentials(email: String, password: String) {
        pendingSignUpEmail = email
        pendingSignUpPassword = password
        print("💾 Guardadas credenciales para auto-login post verificación.")
    }

    private func clearPendingCredentials() {
        pendingSignUpEmail = nil
        pendingSignUpPassword = nil
        print("🧹 Limpiadas credenciales pendientes.")
    }

    /// Si hay una sesión activa:
    /// - Si coincide con el mismo usuario de destino, no hace nada.
    /// - Si es otro usuario, cierra sesión para permitir el nuevo login.
    private func ensureSignedOutBeforeSignIn(targetUsername: String?) async throws {
        let session = try await Amplify.Auth.fetchAuthSession()
        if session.isSignedIn {
            let existing = try? await Amplify.Auth.getCurrentUser()
            if let existing, let target = targetUsername,
               existing.username.caseInsensitiveCompare(target) == .orderedSame {
                print("ℹ️ Ya autenticado como \(existing.username). Se omite signIn.")
                return
            }
            print("ℹ️ Había sesión activa (\(existing?.username ?? "desconocido")). Haciendo signOut...")
            _ = try await Amplify.Auth.signOut() // o signOut(options: .init(globalSignOut: true))
        }
    }
}
