import SwiftUI

struct GoalsEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCertification = "cloud-practitioner"
    @State private var weeklyGoalMinutes = 60
    @State private var dailyReminderEnabled = true
    @State private var reminderTime = Date()
    @State private var targetDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                // Certification goal
                Section("Certificación Objetivo") {
                    Picker("Certificación", selection: $selectedCertification) {
                        Text("Cloud Practitioner").tag("cloud-practitioner")
                        Text("Solutions Architect Associate").tag("solutions-architect")
                        Text("Developer Associate").tag("developer")
                        Text("SysOps Administrator").tag("sysops")
                        Text("Solutions Architect Pro").tag("solutions-architect-pro")
                        Text("DevOps Engineer Pro").tag("devops-pro")
                    }
                    
                    DatePicker(
                        "Fecha objetivo",
                        selection: $targetDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
                
                // Study time goal
                Section("Meta de Estudio") {
                    VStack(alignment: .leading, spacing: Theme.paddingM) {
                        HStack {
                            Text("Tiempo semanal")
                            Spacer()
                            Text("\(formatTime(weeklyGoalMinutes))")
                                .foregroundColor(Theme.awsOrange)
                                .fontWeight(.medium)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(weeklyGoalMinutes) },
                                set: { weeklyGoalMinutes = Int($0) }
                            ),
                            in: 30...600,
                            step: 30
                        )
                        .accentColor(Theme.awsOrange)
                        
                        HStack {
                            Text("30 min")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            Text("10 horas")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        Text("Aproximadamente \(weeklyGoalMinutes / 7) minutos al día")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Daily reminder
                Section("Recordatorios") {
                    Toggle(isOn: $dailyReminderEnabled) {
                        Text("Recordatorio diario")
                    }
                    .tint(Theme.awsOrange)
                    
                    if dailyReminderEnabled {
                        DatePicker(
                            "Hora del recordatorio",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                // Motivational preferences
                Section("Preferencias de Motivación") {
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mensajes motivacionales")
                            Text("Recibe mensajes de ánimo")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                    
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Celebrar logros")
                            Text("Notificaciones cuando alcances metas")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                }
            }
            .navigationTitle("Objetivos de Aprendizaje")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveGoals()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) minutos"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) horas"
            } else {
                return "\(hours)h \(mins)min"
            }
        }
    }
    
    private func saveGoals() {
        UserDefaults.standard.set(selectedCertification, forKey: "targetCertification")
        UserDefaults.standard.set(weeklyGoalMinutes, forKey: "weeklyGoalMinutes")
        dismiss()
    }
}

struct GoalsEditView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsEditView()
    }
}
