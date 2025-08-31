import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Theme.awsOrange.opacity(0.1), Theme.backgroundColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.paddingXL) {
                        // Logo
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
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                
                                TextField("tu@email.com", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                
                                SecureField("••••••••", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Forgot password
                            HStack {
                                Spacer()
                                Button(action: { showingForgotPassword = true }) {
                                    Text("¿Olvidaste tu contraseña?")
                                        .font(.caption)
                                        .foregroundColor(Theme.awsOrange)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Login button
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Iniciar Sesión")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Theme.awsOrange)
                        .cornerRadius(Theme.cornerRadiusM)
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Theme.textTertiary.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("O")
                                .font(.caption)
                                .foregroundColor(Theme.textTertiary)
                                .padding(.horizontal, Theme.paddingS)
                            
                            Rectangle()
                                .fill(Theme.textTertiary.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Social login buttons
                        VStack(spacing: Theme.paddingM) {
                            SocialLoginButton(
                                title: "Continuar con Apple",
                                icon: "apple.logo",
                                action: loginWithApple
                            )
                            
                            SocialLoginButton(
                                title: "Continuar con Google",
                                icon: "globe",
                                action: loginWithGoogle
                            )
                        }
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Sign up
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
                        }
                        .padding(.bottom, Theme.paddingXL)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
    private func login() {
        isLoading = true
        
        // Simular login - se reemplazará con AWS Cognito
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // Por ahora, login exitoso siempre
            appEnvironment.currentUser = User(
                id: UUID().uuidString,
                name: "Usuario",
                level: .beginner,
                targetCertification: nil,
                weeklyGoalMinutes: 60,
                createdAt: Date(),
                lastActiveAt: Date()
            )
        }
    }
    
    private func loginWithApple() {
        // Implementar Sign in with Apple
    }
    
    private func loginWithGoogle() {
        // Implementar Google Sign In
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Registro")
                    .font(.largeTitle)
                    .padding()
                
                Text("Funcionalidad próximamente")
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
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
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppEnvironment())
    }
}
