import SwiftUI

struct EmailVerificationView: View {
    let email: String
    let onVerificationSuccess: () -> Void
    @StateObject private var authService = AuthService.shared
    @State private var verificationCode = ""
    @State private var showingSuccess = false
    @State private var countdown = 3
    @State private var timer: Timer?
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    init(email: String, onVerificationSuccess: @escaping () -> Void = {}) {
        self.email = email
        self.onVerificationSuccess = onVerificationSuccess
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.paddingXL) {
                Spacer()
                
                VStack(spacing: Theme.paddingM) {
                    Image(systemName: showingSuccess ? "checkmark.circle.fill" : "envelope.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(showingSuccess ? .green : Theme.awsOrange)
                        .animation(.spring(), value: showingSuccess)
                    
                    Text(showingSuccess ? "¡Verificado!" : "Verifica tu email")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    if showingSuccess {
                        VStack(spacing: Theme.paddingS) {
                            Text("Tu email ha sido verificado exitosamente")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Configurando tu cuenta en \(countdown) segundos...")
                                .font(.caption)
                                .foregroundColor(Theme.awsOrange)
                        }
                    } else {
                        VStack(spacing: Theme.paddingS) {
                            Text("Hemos enviado un código de verificación a:")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text(email)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.awsOrange)
                        }
                    }
                }
                
                if !showingSuccess {
                    VStack(spacing: Theme.paddingM) {
                        // Cajas individuales para el código
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(getBoxBorderColor(index: index), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.secondaryBackground)
                                        )
                                        .frame(width: 45, height: 55)
                                    
                                    Text(getDigitAt(index: index))
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.textPrimary)
                                }
                            }
                        }
                        .overlay(
                            // TextField invisible para manejar el input
                            TextField("", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .opacity(0)
                                .focused($isTextFieldFocused)
                                .onChange(of: verificationCode) { _, newValue in
                                    // Solo números y máximo 6 dígitos
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered.count <= 6 {
                                        verificationCode = filtered
                                    } else {
                                        verificationCode = String(filtered.prefix(6))
                                    }
                                    
                                    // Auto-verificar cuando se complete
                                    if verificationCode.count == 6 {
                                        Task {
                                            await confirmEmail()
                                        }
                                    }
                                }
                        )
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
                        
                        Text("Toca las cajas para ingresar el código")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            Task {
                                await confirmEmail()
                            }
                        }) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Verificar código")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(verificationCode.count == 6 ? Theme.awsOrange : Color.gray)
                        .cornerRadius(Theme.cornerRadiusM)
                        .disabled(verificationCode.count != 6 || authService.isLoading)
                        
                        Button("Reenviar código") {
                            Task {
                                await resendCode()
                            }
                        }
                        .foregroundColor(Theme.awsOrange)
                    }
                    .padding(.horizontal, Theme.paddingL)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showingSuccess {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                // Auto-focus en el campo de texto
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    private func getDigitAt(index: Int) -> String {
        if index < verificationCode.count {
            return String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)])
        }
        return ""
    }
    
    private func getBoxBorderColor(index: Int) -> Color {
        if isTextFieldFocused && index == verificationCode.count {
            return Theme.awsOrange
        } else if index < verificationCode.count {
            return Theme.awsOrange.opacity(0.7)
        } else {
            return Theme.textTertiary.opacity(0.3)
        }
    }
    
    private func confirmEmail() async {
        let success = await authService.confirmSignUp(email: email, confirmationCode: verificationCode)
        if success {
            showingSuccess = true
            isTextFieldFocused = false // Ocultar teclado
            startCountdown()
        }
    }
    
    private func resendCode() async {
        verificationCode = ""
        await authService.resendConfirmationCode(email: email)
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer?.invalidate()
                onVerificationSuccess()
                dismiss()
            }
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(email: "test@example.com")
    }
}
