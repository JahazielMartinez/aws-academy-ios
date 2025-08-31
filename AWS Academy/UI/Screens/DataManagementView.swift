import SwiftUI

struct DataManagementView: View {
    @State private var cacheSize = "145 MB"
    @State private var downloadedContent = "89 MB"
    @State private var userData = "12 MB"
    @State private var showingClearCache = false
    @State private var showingDeleteDownloads = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Storage overview
                Section("Uso de Almacenamiento") {
                    StorageRow(
                        title: "Caché",
                        size: cacheSize,
                        icon: "internaldrive",
                        color: .blue
                    )
                    
                    StorageRow(
                        title: "Contenido descargado",
                        size: downloadedContent,
                        icon: "arrow.down.circle",
                        color: .green
                    )
                    
                    StorageRow(
                        title: "Datos de usuario",
                        size: userData,
                        icon: "person.circle",
                        color: .orange
                    )
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.medium)
                        Spacer()
                        Text("246 MB")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Data management actions
                Section("Gestión de Datos") {
                    Button(action: { showingClearCache = true }) {
                        HStack {
                            Label("Limpiar caché", systemImage: "trash")
                            Spacer()
                            Text(cacheSize)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    Button(action: { showingDeleteDownloads = true }) {
                        HStack {
                            Label("Eliminar descargas", systemImage: "xmark.circle")
                            Spacer()
                            Text(downloadedContent)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    NavigationLink(destination: BackupRestoreView()) {
                        Label("Copia de seguridad", systemImage: "icloud.and.arrow.up")
                    }
                }
                
                // Privacy settings
                Section("Privacidad") {
                    Toggle("Análisis de uso", isOn: .constant(true))
                        .tint(Theme.awsOrange)
                    
                    Toggle("Personalización", isOn: .constant(true))
                        .tint(Theme.awsOrange)
                    
                    Toggle("Compartir progreso", isOn: .constant(false))
                        .tint(Theme.awsOrange)
                }
                
                // Data export
                Section("Exportar Datos") {
                    Button(action: exportAllData) {
                        Label("Exportar todos mis datos", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: exportProgress) {
                        Label("Exportar progreso", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }
            }
            .navigationTitle("Gestión de Datos")
            .navigationBarTitleDisplayMode(.large)
            .alert("Limpiar Caché", isPresented: $showingClearCache) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpiar", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("Se eliminarán \(cacheSize) de datos temporales. Esto no afectará tu progreso.")
            }
            .alert("Eliminar Descargas", isPresented: $showingDeleteDownloads) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteDownloads()
                }
            } message: {
                Text("Se eliminarán \(downloadedContent) de contenido descargado. Podrás volver a descargarlo cuando lo necesites.")
            }
        }
    }
    
    private func clearCache() {
        cacheSize = "0 MB"
    }
    
    private func deleteDownloads() {
        downloadedContent = "0 MB"
    }
    
    private func exportAllData() {
        // Exportar todos los datos
    }
    
    private func exportProgress() {
        // Exportar progreso
    }
}

struct StorageRow: View {
    let title: String
    let size: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
            
            Spacer()
            
            Text(size)
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct BackupRestoreView: View {
    @State private var lastBackup: Date?
    @State private var autoBackup = true
    @State private var showingRestore = false
    
    var body: some View {
        Form {
            Section("Última copia de seguridad") {
                if let date = lastBackup {
                    HStack {
                        Text("Fecha")
                        Spacer()
                        Text(date, style: .date)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    HStack {
                        Text("Hora")
                        Spacer()
                        Text(date, style: .time)
                            .foregroundColor(Theme.textSecondary)
                    }
                } else {
                    Text("Sin copias de seguridad")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Section("Configuración") {
                Toggle("Copia automática", isOn: $autoBackup)
                    .tint(Theme.awsOrange)
                
                if autoBackup {
                    HStack {
                        Text("Frecuencia")
                        Spacer()
                        Text("Diaria")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            
            Section {
                Button("Hacer copia ahora") {
                    performBackup()
                }
                
                Button("Restaurar desde copia") {
                    showingRestore = true
                }
                .foregroundColor(.orange)
            }
        }
        .navigationTitle("Copia de Seguridad")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Restaurar Datos", isPresented: $showingRestore) {
            Button("Cancelar", role: .cancel) { }
            Button("Restaurar") {
                restoreBackup()
            }
        } message: {
            Text("Esto reemplazará todos tus datos actuales con la última copia de seguridad")
        }
    }
    
    private func performBackup() {
        lastBackup = Date()
    }
    
    private func restoreBackup() {
        // Restaurar desde backup
    }
}

struct DataManagementView_Previews: PreviewProvider {
    static var previews: some View {
        DataManagementView()
    }
}
