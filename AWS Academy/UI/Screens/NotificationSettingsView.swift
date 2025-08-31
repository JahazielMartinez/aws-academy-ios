import SwiftUI

struct NotificationSettingsView: View {
    @State private var studyReminders = true
    @State private var reminderTime = Date()
    @State private var quizReminders = true
    @State private var achievementAlerts = true
    @State private var weeklyReports = true
    @State private var promotionalEmails = false
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
    var body: some View {
        NavigationStack {
            Form {
                // Study reminders
                Section("Recordatorios de Estudio") {
                    Toggle(isOn: $studyReminders) {
                        Label("Recordatorio diario", systemImage: "bell")
                    }
                    .tint(Theme.awsOrange)
                    
                    if studyReminders {
                        DatePicker(
                            "Hora",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        
                        HStack {
                            Text("Días")
                            Spacer()
                            Text("Todos los días")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                
                // Activity notifications
                Section("Notificaciones de Actividad") {
                    Toggle(isOn: $quizReminders) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quiz diario")
                            Text("Recuérdame hacer el quiz del día")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                    
                    Toggle(isOn: $achievementAlerts) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Logros")
                            Text("Notificarme cuando desbloquee logros")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                    
                    Toggle(isOn: $weeklyReports) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Resumen semanal")
                            Text("Recibir resumen de progreso")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                }
                
                // Communication preferences
                Section("Comunicaciones") {
                    Toggle(isOn: $promotionalEmails) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Actualizaciones de AWS")
                            Text("Noticias y nuevos servicios")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                }
                
                // Notification style
                Section("Estilo de Notificación") {
                    Toggle(isOn: $soundEnabled) {
                        Label("Sonido", systemImage: "speaker.wave.2")
                    }
                    .tint(Theme.awsOrange)
                    
                    Toggle(isOn: $vibrationEnabled) {
                        Label("Vibración", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .tint(Theme.awsOrange)
                    
                    HStack {
                        Label("Vista previa", systemImage: "bell.badge")
                        Spacer()
                        Text("Banner")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Quiet hours
                Section("Horario Silencioso") {
                    NavigationLink(destination: QuietHoursView()) {
                        HStack {
                            Label("Configurar horario", systemImage: "moon")
                            Spacer()
                            Text("Desactivado")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct QuietHoursView: View {
    @State private var enabled = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        Form {
            Toggle("Activar horario silencioso", isOn: $enabled)
                .tint(Theme.awsOrange)
            
            if enabled {
                DatePicker("Inicio", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("Fin", selection: $endTime, displayedComponents: .hourAndMinute)
            }
        }
        .navigationTitle("Horario Silencioso")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
