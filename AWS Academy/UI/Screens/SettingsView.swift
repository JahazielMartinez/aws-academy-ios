import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var notificationsEnabled = true
    @State private var dailyReminderTime = Date()
    @State private var weeklyGoalMinutes = 60
    @State private var offlineContentSize = "0 MB"
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Perfil
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.awsOrange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Usuario")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Nivel: Principiante")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, Theme.paddingS)
                    
                    NavigationLink(destination: ProfileEditView()) {
                        Label("Editar perfil", systemImage: "pencil")
                    }
                }
                
                // Objetivos de aprendizaje
                Section("Objetivos de aprendizaje") {
                    NavigationLink(destination: GoalsEditView()) {
                        HStack {
                            Label("Certificación objetivo", systemImage: "trophy")
                            Spacer()
                            Text("Cloud Practitioner")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    HStack {
                        Label("Meta semanal", systemImage: "target")
                        Spacer()
                        Picker("", selection: $weeklyGoalMinutes) {
                            Text("30 min").tag(30)
                            Text("1 hora").tag(60)
                            Text("2 horas").tag(120)
                            Text("3 horas").tag(180)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Notificaciones
                Section("Notificaciones") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Recordatorios de estudio", systemImage: "bell")
                    }
                    .tint(Theme.awsOrange)
                    
                    if notificationsEnabled {
                        DatePicker(
                            "Hora del recordatorio",
                            selection: $dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                // Contenido offline
                Section("Contenido offline") {
                    NavigationLink(destination: OfflineManagerView()) {
                        HStack {
                            Label("Gestionar descargas", systemImage: "arrow.down.circle")
                            Spacer()
                            Text(offlineContentSize)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    Button(action: clearCache) {
                        Label("Limpiar caché", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // Legal
                Section("Legal") {
                    NavigationLink(destination: LegalView(type: .privacy)) {
                        Label("Política de privacidad", systemImage: "lock")
                    }
                    
                    NavigationLink(destination: LegalView(type: .terms)) {
                        Label("Términos de servicio", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("Acerca de", systemImage: "info.circle")
                    }
                }
                
                // Cuenta
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        Label("Cerrar sesión", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: { showingDeleteAccountAlert = true }) {
                        Label("Eliminar cuenta", systemImage: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .alert("Cerrar sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar sesión", role: .destructive) {
                    logout()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .alert("Eliminar cuenta", isPresented: $showingDeleteAccountAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Esta acción es irreversible. Se eliminarán todos tus datos y progreso.")
            }
        }
    }
    
    private func clearCache() {
        // Limpiar caché local
    }
    
    private func logout() {
        // Cerrar sesión
        appEnvironment.currentUser = nil
        appEnvironment.isOnboardingCompleted = false
    }
    
    private func deleteAccount() {
        // Eliminar cuenta
    }
}

// Las vistas ahora están definidas en archivos separados

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppEnvironment())
    }
}
