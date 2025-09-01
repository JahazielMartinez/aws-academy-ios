import Foundation
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    static let shared = AuthService()
    
    private init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            let user = try await Amplify.Auth.getCurrentUser()
            
            self.isSignedIn = session.isSignedIn
            self.currentUser = user
            
            print("✅ Usuario autenticado: \(user.username)")
        } catch {
            self.isSignedIn = false
            self.currentUser = nil
            print("ℹ️ Usuario no autenticado")
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = ""
        let username = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            // ✅ Evita el error "already signedIn"
            try await ensureSignedOutBeforeSignIn(targetUsername: username)

            // Anti “doble tap”: si tras el helper seguimos autenticados, salimos OK
            let pre = try await Amplify.Auth.fetchAuthSession()
            if pre.isSignedIn {
                self.isLoading = false
                await checkAuthStatus()
                return true
            }

            print("🔍 Intentando login con email: \(username)")
            let result = try await Amplify.Auth.signIn(username: username, password: password)

            if result.isSignedIn {
                self.isLoading = false
                await checkAuthStatus()
                print("✅ Login exitoso")
                return true
            } else {
                self.isLoading = false
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
            
            if result.isSignUpComplete {
                print("✅ Usuario registrado exitosamente")
                return true
            } else {
                print("📧 Verificación de email requerida")
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
    
    func resendConfirmationCode(email: String) async {
        do {
            try await Amplify.Auth.resendSignUpCode(for: email)
            print("✅ Código reenviado")
        } catch {
            print("❌ Error reenviando código: \(error)")
        }
    }
    
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
    
    private func ensureSignedOutBeforeSignIn(targetUsername: String?) async throws {
        let session = try await Amplify.Auth.fetchAuthSession()
        if session.isSignedIn {
            // Ya hay un usuario autenticado
            let existing = try? await Amplify.Auth.getCurrentUser()
            // Si es el mismo, no intentes signIn de nuevo
            if let existing, let target = targetUsername,
               existing.username.caseInsensitiveCompare(target) == .orderedSame {
                print("ℹ️ Ya autenticado como \(existing.username). Se omite signIn.")
                return
            }
            // Si es distinto, cierra sesión primero (opción: globalSignOut si quieres revocar en servidor)
            print("ℹ️ Había sesión activa (\(existing?.username ?? "desconocido")). Haciendo signOut...")
            _ = try await Amplify.Auth.signOut() // o: try await Amplify.Auth.signOut(options: .init(globalSignOut: true))
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
}
