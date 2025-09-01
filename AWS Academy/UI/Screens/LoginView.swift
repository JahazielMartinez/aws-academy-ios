import SwiftUI

// Estructura para manejar fuerza de contraseña
struct PasswordStrength {
    let score: Int
    let label: String
    let color: Color
    let progress: Double
}

func calculatePasswordStrength(_ password: String) -> PasswordStrength {
    var score = 0

    // Longitud
    if password.count >= 8 { score += 1 }
    if password.count >= 12 { score += 1 }

    // Tipos de caracteres
    if password.contains(where: { $0.isLowercase }) { score += 1 }
    if password.contains(where: { $0.isUppercase }) { score += 1 }
    if password.contains(where: { $0.isNumber }) { score += 1 }
    if password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) { score += 1 }

    switch score {
    case 0...1:
        return PasswordStrength(score: score, label: "Muy débil", color: .red, progress: 0.2)
    case 2...3:
        return PasswordStrength(score: score, label: "Débil", color: .orange, progress: 0.4)
    case 4...5:
        return PasswordStrength(score: score, label: "Buena", color: .yellow, progress: 0.7)
    case 6:
        return PasswordStrength(score: score, label: "Fuerte", color: .green, progress: 1.0)
    default:
        return PasswordStrength(score: score, label: "Muy fuerte", color: .green, progress: 1.0)
    }
}

struct LoginView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var authService = AuthService.shared

    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.awsOrange.opacity(0.1), Theme.backgroundColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.paddingXL) {
                        // Header
                        VStack(spacing: Theme.paddingM) {
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Theme.awsOrange)

                            Text("AWS Academy")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)

                            Text("Inicia sesión para continuar")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.top, 60)

                        // Form
                        VStack(spacing: Theme.paddingM) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)

                                TextField("tu@email.com", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)

                                SecureField("••••••••", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            HStack {
                                Spacer()
                                Button(action: { showingForgotPassword = true }) {
                                    Text("¿Olvidaste tu contraseña?")
                                        .font(.caption)
                                        .foregroundColor(Theme.awsOrange)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, Theme.paddingL)

                        // Botón de login
                        Button(action: {
                            Task { await login() }
                        }) {
                            HStack {
                                Spacer()
                                if authService.isLoading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Iniciar Sesión").fontWeight(.semibold)
                                }
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .background(email.isEmpty || password.isEmpty ? Color.gray : Theme.awsOrange)
                            .cornerRadius(Theme.cornerRadiusM)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        .padding(.horizontal, Theme.paddingL)

                        // Error
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, Theme.paddingL)
                        }

                        // Link a registro
                        HStack {
                            Text("¿No tienes cuenta?")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)

                            Button(action: { showingSignUp = true }) {
                                Text("Regístrate")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.awsOrange)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.bottom, Theme.paddingXL)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .sheet(isPresented: $showingSignUp) { SignUpView() }
            .sheet(isPresented: $showingForgotPassword) { ForgotPasswordView() }
        }
        // Si la sesión cambia a iniciada desde aquí, cerramos el Login
        .onChange(of: authService.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                appEnvironment.currentUser = User(
                    id: authService.currentUser?.userId ?? "unknown",
                    name: "Usuario",
                    level: .beginner,
                    targetCertification: nil,
                    weeklyGoalMinutes: 60,
                    createdAt: Date(),
                    lastActiveAt: Date()
                )
                dismiss()
            }
        }
    }

    private func login() async {
        // Marcar que esta sesión proviene de LOGIN antes de llamar a signIn
        // para que ContentView pueda saltar onboarding en el onChange de isSignedIn.
        authService.didSignInFromLogin = true

        let success = await authService.signIn(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        if success {
            // Opcional: asegurar flag (por si reusas este método)
            authService.markSignedInFromLogin()
            print("Login exitoso - Usuario autenticado")
        } else {
            // Si falló, revertimos el flag para no saltarnos onboarding por error
            authService.didSignInFromLogin = false
            print("Login falló: \(authService.errorMessage)")
        }
    }
}

// MARK: - SignUp

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared

    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    @State private var showingVerification = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    var passwordStrength: PasswordStrength { calculatePasswordStrength(password) }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !fullName.isEmpty &&
        password == confirmPassword && passwordStrength.score >= 2
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.paddingL) {
                    // Header
                    VStack(spacing: Theme.paddingM) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.awsOrange)

                        Text("Crear cuenta")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)

                        Text("Únete a AWS Academy")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.top, Theme.paddingL)

                    // Form
                    VStack(spacing: Theme.paddingM) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre completo")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)

                            TextField("Tu nombre completo", text: $fullName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correo electrónico")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)

                            TextField("tu@email.com", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)

                            HStack {
                                if isPasswordVisible {
                                    TextField("••••••••", text: $password)
                                } else {
                                    SecureField("••••••••", text: $password)
                                }

                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding()
                            .background(Theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadiusM)

                            // Barra de fuerza de contraseña
                            if !password.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Fuerza de la contraseña:")
                                            .font(.caption2)
                                            .foregroundColor(Theme.textSecondary)
                                        Spacer()
                                        Text(passwordStrength.label)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(passwordStrength.color)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Theme.tertiaryBackground)
                                                .frame(height: 4)
                                                .cornerRadius(2)

                                            Rectangle()
                                                .fill(passwordStrength.color)
                                                .frame(width: geometry.size.width * passwordStrength.progress, height: 4)
                                                .cornerRadius(2)
                                                .animation(.easeInOut(duration: 0.3), value: passwordStrength.progress)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar contraseña")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)

                            HStack {
                                if isConfirmPasswordVisible {
                                    TextField("••••••••", text: $confirmPassword)
                                } else {
                                    SecureField("••••••••", text: $confirmPassword)
                                }

                                Button(action: { isConfirmPasswordVisible.toggle() }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding()
                            .background(Theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadiusM)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                                    .stroke(
                                        password == confirmPassword && !confirmPassword.isEmpty ? .green :
                                        (!confirmPassword.isEmpty && password != confirmPassword ? .red : Color.clear),
                                        lineWidth: 1
                                    )
                            )
                        }

                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, Theme.paddingS)
                        }
                    }
                    .padding(.horizontal, Theme.paddingL)

                    // Botón Registrar
                    Button(action: {
                        Task { await signUp() }
                    }) {
                        HStack {
                            Spacer()
                            if authService.isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Crear cuenta").fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .background(isFormValid ? Theme.awsOrange : Color.gray)
                        .cornerRadius(Theme.cornerRadiusM)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isFormValid || authService.isLoading)
                    .padding(.horizontal, Theme.paddingL)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingVerification) {
                EmailVerificationView(email: email) {
                    // Al completar verificación, cerramos el registro.
                    dismiss()
                }
            }
        }
    }

    private func signUp() async {
        let success = await authService.signUp(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        if success { showingVerification = true }
    }
}

// MARK: - Utilidades

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Recuperar Contraseña")
                    .font(.largeTitle)
                    .padding()

                Text("Funcionalidad próximamente")
                    .foregroundColor(Theme.textSecondary)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AppEnvironment())
    }
}
