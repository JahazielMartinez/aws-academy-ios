import SwiftUI

struct OfflineManagerView: View {
    @State private var downloadedContent: [OfflineContent] = []
    @State private var availableContent: [OfflineContent] = []
    @State private var totalStorageUsed: String = "0 MB"
    @State private var isDownloading = false
    
    var body: some View {
        NavigationStack {
            List {
                // Storage summary
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Espacio utilizado")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                            Text(totalStorageUsed)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Button(action: clearAllDownloads) {
                            Text("Limpiar todo")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, Theme.paddingS)
                }
                
                // Downloaded content
                Section("Contenido descargado") {
                    if downloadedContent.isEmpty {
                        Text("No hay contenido descargado")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .padding(.vertical, Theme.paddingS)
                    } else {
                        ForEach(downloadedContent) { content in
                            OfflineContentRow(
                                content: content,
                                isDownloaded: true,
                                action: { removeContent(content) }
                            )
                        }
                    }
                }
                
                // Available for download
                Section("Disponible para descargar") {
                    if availableContent.isEmpty {
                        Text("Todo el contenido estará disponible próximamente")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .padding(.vertical, Theme.paddingS)
                    } else {
                        ForEach(availableContent) { content in
                            OfflineContentRow(
                                content: content,
                                isDownloaded: false,
                                action: { downloadContent(content) }
                            )
                        }
                    }
                }
                
                // Settings
                Section("Configuración") {
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Descargar solo con Wi-Fi")
                                .font(.subheadline)
                            Text("Ahorra datos móviles")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                    
                    Toggle(isOn: .constant(false)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Actualización automática")
                                .font(.subheadline)
                            Text("Actualiza el contenido cuando haya cambios")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .tint(Theme.awsOrange)
                }
            }
            .navigationTitle("Contenido Offline")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadOfflineContent()
        }
    }
    
    private func loadOfflineContent() {
        // Cargar contenido disponible y descargado
    }
    
    private func downloadContent(_ content: OfflineContent) {
        // Descargar contenido
    }
    
    private func removeContent(_ content: OfflineContent) {
        // Eliminar contenido descargado
    }
    
    private func clearAllDownloads() {
        // Limpiar todas las descargas
    }
}

struct OfflineContentRow: View {
    let content: OfflineContent
    let isDownloaded: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                
                HStack(spacing: Theme.paddingS) {
                    Text(content.type)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.awsOrange.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(content.size)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    if isDownloaded {
                        Text("• \(content.lastUpdated)")
                            .font(.caption)
                            .foregroundColor(Theme.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: isDownloaded ? "trash" : "arrow.down.circle")
                    .foregroundColor(isDownloaded ? .red : Theme.awsOrange)
            }
        }
        .padding(.vertical, 4)
    }
}

struct OfflineContent: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let size: String
    let lastUpdated: String
}

struct OfflineManagerView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineManagerView()
    }
}
