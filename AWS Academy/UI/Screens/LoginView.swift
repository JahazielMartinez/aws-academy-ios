import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var showError = false
    
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
                        
                        VStack(spacing: Theme.paddingM) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                
                                TextField("tu@email.com", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
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
                            }
                        }
                        .padding(.horizontal, Theme.paddingL)
                        
                        Button(action: {
                            Task {
                                await login()
                            }
                        }) {
                            if authService.isLoading {
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
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Error message
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, Theme.paddingL)
                        }
                        
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
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
        .onChange(of: authService.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                // Usuario autenticado exitosamente
                appEnvironment.currentUser = User(
                    id: authService.currentUser?.userId ?? "unknown",
                    name: "Usuario",
                    level: .beginner,
                    targetCertification: nil,
                    weeklyGoalMinutes: 60,
                    createdAt: Date(),
                    lastActiveAt: Date()
                )
            }
        }
    }
    
    private func login() async {
        let success = await authService.signIn(email: email, password: password)
        if success {
            print("Login exitoso - Usuario autenticado")
        } else {
            print("Login falló: \(authService.errorMessage)")
        }
    }
}

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
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !fullName.isEmpty &&
        password == confirmPassword && password.count >= 8
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
                            }
                            .padding()
                            .background(Theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadiusM)
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
                            }
                            .padding()
                            .background(Theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadiusM)
                        }
                        
                        // Password requirements
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Requisitos de contraseña:")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            HStack {
                                Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(password.count >= 8 ? .green : Theme.textSecondary)
                                Text("Mínimo 8 caracteres")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            HStack {
                                Image(systemName: password != confirmPassword || confirmPassword.isEmpty ? "circle" : "checkmark.circle.fill")
                                    .foregroundColor(password == confirmPassword && !confirmPassword.isEmpty ? .green : Theme.textSecondary)
                                Text("Las contraseñas coinciden")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(.top, Theme.paddingS)
                        
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, Theme.paddingS)
                        }
                    }
                    .padding(.horizontal, Theme.paddingL)
                    
                    // Register button
                    Button(action: {
                        Task {
                            await signUp()
                        }
                    }) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Crear cuenta")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(isFormValid ? Theme.awsOrange : Color.gray)
                    .cornerRadius(Theme.cornerRadiusM)
                    .disabled(!isFormValid || authService.isLoading)
                    .padding(.horizontal, Theme.paddingL)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingVerification) {
                EmailVerificationView(email: email) {
                    // Callback cuando se verifica exitosamente
                    dismiss()
                }
            }
        }
    }
    
    private func signUp() async {
        let success = await authService.signUp(email: email, password: password, fullName: fullName)
        if success {
            showingVerification = true
        }
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

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var step: ResetStep = .enterEmail
    @State private var showingSuccess = false
    
    enum ResetStep {
        case enterEmail
        case enterCode
        case enterNewPassword
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.paddingXL) {
                    // Header
                    VStack(spacing: Theme.paddingM) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.awsOrange)
                        
                        Text("Recuperar contraseña")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text(stepDescription)
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.paddingL)
                    
                    // Content based on step
                    VStack(spacing: Theme.paddingM) {
                        switch step {
                        case .enterEmail:
                            emailStep
                        case .enterCode:
                            codeStep
                        case .enterNewPassword:
                            passwordStep
                        }
                    }
                    .padding(.horizontal, Theme.paddingL)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .alert("Contraseña actualizada", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tu contraseña ha sido actualizada exitosamente. Ya puedes iniciar sesión.")
            }
        }
    }
    
    private var stepDescription: String {
        switch step {
        case .enterEmail:
            return "Ingresa tu email para recibir un código de recuperación"
        case .enterCode:
            return "Ingresa el código que enviamos a \(email)"
        case .enterNewPassword:
            return "Crea una nueva contraseña segura"
        }
    }
    
    private var emailStep: some View {
        VStack(spacing: Theme.paddingM) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Correo electrónico")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                TextField("tu@email.com", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                Task {
                    await sendResetCode()
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Enviar código")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(email.isEmpty ? Color.gray : Theme.awsOrange)
            .cornerRadius(Theme.cornerRadiusM)
            .disabled(email.isEmpty || authService.isLoading)
        }
    }
    
    private var codeStep: some View {
        VStack(spacing: Theme.paddingM) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Código de verificación")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                TextField("000000", text: $resetCode)
                    .font(.title2)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                step = .enterNewPassword
            }) {
                Text("Verificar código")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(resetCode.count >= 4 ? Theme.awsOrange : Color.gray)
            .cornerRadius(Theme.cornerRadiusM)
            .disabled(resetCode.count < 4)
            
            Button("Reenviar código") {
                Task {
                    await sendResetCode()
                }
            }
            .foregroundColor(Theme.awsOrange)
        }
    }
    
    private var passwordStep: some View {
        VStack(spacing: Theme.paddingM) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Nueva contraseña")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                SecureField("••••••••", text: $newPassword)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirmar contraseña")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                SecureField("••••••••", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                Task {
                    await confirmReset()
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Actualizar contraseña")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(isPasswordValid ? Theme.awsOrange : Color.gray)
            .cornerRadius(Theme.cornerRadiusM)
            .disabled(!isPasswordValid || authService.isLoading)
        }
    }
    
    private var isPasswordValid: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 8
    }
    
    private func sendResetCode() async {
        let success = await authService.resetPassword(email: email)
        if success {
            step = .enterCode
        }
    }
    
    private func confirmReset() async {
        // Aquí implementarías confirmResetPassword cuando agregues la función al AuthService
        showingSuccess = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppEnvironment())
    }
}


