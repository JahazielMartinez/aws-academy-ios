import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var showingChangePassword = false
    @State private var showingDeleteAccount = false
    @State private var showingExportData = false
    @State private var twoFactorEnabled = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Account info
                Section("Información de Cuenta") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("usuario@ejemplo.com")
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    HStack {
                        Text("ID de Usuario")
                        Spacer()
                        Text("USR-12345")
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    HStack {
                        Text("Miembro desde")
                        Spacer()
                        Text("Enero 2025")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Security
                Section("Seguridad") {
                    Button(action: { showingChangePassword = true }) {
                        Label("Cambiar contraseña", systemImage: "key")
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    Toggle(isOn: $twoFactorEnabled) {
                        Label("Autenticación de dos factores", systemImage: "lock.shield")
                    }
                    .tint(Theme.awsOrange)
                    
                    NavigationLink(destination: LoginHistoryView()) {
                        Label("Historial de acceso", systemImage: "clock.arrow.circlepath")
                    }
                }
                
                // Privacy
                Section("Privacidad") {
                    NavigationLink(destination: DataManagementView()) {
                        Label("Gestión de datos", systemImage: "externaldrive")
                    }
                    
                    Button(action: { showingExportData = true }) {
                        Label("Exportar mis datos", systemImage: "square.and.arrow.up")
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    NavigationLink(destination: BlockedContentView()) {
                        Label("Contenido bloqueado", systemImage: "hand.raised")
                    }
                }
                
                // Danger zone
                Section {
                    Button(action: { showingDeleteAccount = true }) {
                        Label("Eliminar cuenta", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Zona de Peligro")
                } footer: {
                    Text("Esta acción es permanente y no se puede deshacer")
                        .font(.caption)
                }
            }
            .navigationTitle("Configuración de Cuenta")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }
            .alert("Eliminar Cuenta", isPresented: $showingDeleteAccount) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("¿Estás seguro? Se eliminarán todos tus datos y progreso de forma permanente.")
            }
            .alert("Exportar Datos", isPresented: $showingExportData) {
                Button("Cancelar", role: .cancel) { }
                Button("Exportar") {
                    exportData()
                }
            } message: {
                Text("Se enviará un archivo con todos tus datos a tu correo electrónico")
            }
        }
    }
    
    private func deleteAccount() {
        // Implementar eliminación de cuenta
    }
    
    private func exportData() {
        // Implementar exportación de datos
    }
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                SecureField("Contraseña actual", text: $currentPassword)
                SecureField("Nueva contraseña", text: $newPassword)
                SecureField("Confirmar contraseña", text: $confirmPassword)
                
                Section {
                    Text("• Mínimo 8 caracteres")
                    Text("• Al menos una mayúscula")
                    Text("• Al menos un número")
                    Text("• Al menos un símbolo")
                }
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            }
            .navigationTitle("Cambiar Contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        changePassword()
                    }
                    .fontWeight(.medium)
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            showingError = true
            return
        }
        
        // Implementar cambio de contraseña
        dismiss()
    }
}

struct LoginHistoryView: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("iOS App")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Text("IP: 192.168.1.1")
                        Text("•")
                        Text("Hace \(index + 1) días")
                    }
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Historial de Acceso")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BlockedContentView: View {
    var body: some View {
        Text("Sin contenido bloqueado")
            .navigationTitle("Contenido Bloqueado")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
            .environmentObject(AppEnvironment())
    }
}
