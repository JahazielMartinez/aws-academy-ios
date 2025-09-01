import SwiftUI

struct EmailVerificationView: View {
    let email: String
    let onVerificationSuccess: () -> Void

    @StateObject private var authService = AuthService.shared

    @State private var verificationCode = ""
    @State private var showingSuccess = false
    @State private var countdown = 3
    @State private var attemptsLeft = 3

    @State private var resendTimer = 0
    @State private var canResend = true

    @State private var timer: Timer?
    @State private var resendCountdownTimer: Timer?

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

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

                            if attemptsLeft < 3 {
                                Text("Intentos restantes: \(attemptsLeft)")
                                    .font(.caption)
                                    .foregroundColor(attemptsLeft == 1 ? .red : .orange)
                                    .padding(.top, 4)
                            }
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
                                .shake(authService.errorMessage.contains("Invalid") ? 1 : 0)
                            }
                        }
                        .overlay(
                            TextField("", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .opacity(0)
                                .focused($isTextFieldFocused)
                                .onChange(of: verificationCode) { _, newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    verificationCode = String(filtered.prefix(6))
                                    if verificationCode.count == 6 {
                                        Task { await confirmEmail() }
                                    }
                                }
                        )
                        .onTapGesture { isTextFieldFocused = true }

                        Text("Toca las cajas para ingresar el código")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)

                        if !authService.errorMessage.isEmpty {
                            Text(getFriendlyErrorMessage(authService.errorMessage))
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: { Task { await confirmEmail() } }) {
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
                        .background(verificationCode.count == 6 && attemptsLeft > 0 ? Theme.awsOrange : Color.gray)
                        .cornerRadius(Theme.cornerRadiusM)
                        .disabled(verificationCode.count != 6 || authService.isLoading || attemptsLeft <= 0)

                        Button(canResend ? "Reenviar código" : "Reenviar en \(resendTimer)s") {
                            Task { await resendCode() }
                        }
                        .foregroundColor(canResend ? Theme.awsOrange : Theme.textSecondary)
                        .disabled(!canResend)
                    }
                    .padding(.horizontal, Theme.paddingL)
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showingSuccess {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") { dismiss() }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
            .onDisappear {
                // Limpieza de timers
                timer?.invalidate()
                resendCountdownTimer?.invalidate()
            }
        }
    }

    // MARK: - Helpers UI

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

    private func getFriendlyErrorMessage(_ error: String) -> String {
        if error.contains("Invalid verification code") || error.contains("Código inválido") {
            return "El código que ingresaste no es correcto. Verifica e inténtalo de nuevo."
        } else if error.contains("CodeMismatchException") {
            return "El código no coincide. Por favor verifica e inténtalo nuevamente."
        } else if error.contains("ExpiredCodeException") {
            return "El código ha expirado. Solicita un nuevo código."
        }
        return "Hubo un problema con la verificación. Inténtalo de nuevo."
    }

    // MARK: - Actions

    private func confirmEmail() async {
        if attemptsLeft <= 0 { return }

        let success = await authService.confirmSignUp(email: email, confirmationCode: verificationCode)
        if success {
            showingSuccess = true
            isTextFieldFocused = false
            startCountdown()
        } else {
            attemptsLeft -= 1
            verificationCode = ""
            if attemptsLeft <= 0 {
                // Cierra la pantalla después de mostrar el error un momento
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }

    private func resendCode() async {
        await authService.resendConfirmationCode(email: email)

        attemptsLeft = 3
        canResend = false
        resendTimer = 60

        resendCountdownTimer?.invalidate()
        resendCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                canResend = true
                resendCountdownTimer?.invalidate()
            }
        }
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer?.invalidate()
                Task {
                    // Auto-login usando credenciales guardadas en AuthService tras el signUp
                    _ = await authService.signInAfterVerification(email: email)

                    // Notifica a ContentView que el registro finalizó
                    NotificationCenter.default.post(name: .userDidRegister, object: nil)

                    onVerificationSuccess()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

extension View {
    func shake(_ shake: CGFloat) -> some View {
        self.modifier(ShakeEffect(animatableData: shake))
    }
}
