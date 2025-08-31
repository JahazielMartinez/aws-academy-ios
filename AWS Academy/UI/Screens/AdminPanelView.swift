import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = AdminViewModel()
    @State private var selectedSection: AdminSection = .content
    @State private var showingRegenerateAlert = false
    @State private var showingClearDataAlert = false
    @State private var selectedService: Service?
    
    enum AdminSection: String, CaseIterable {
        case content = "Contenido"
        case users = "Usuarios"
        case analytics = "Analítica"
        case settings = "Configuración"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Admin verification
                if !appEnvironment.adminModeEnabled {
                    UnauthorizedView()
                } else {
                    // Section selector
                    Picker("Sección", selection: $selectedSection) {
                        ForEach(AdminSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(Theme.paddingM)
                    
                    // Content based on section
                    ScrollView {
                        switch selectedSection {
                        case .content:
                            ContentManagementSection(
                                viewModel: viewModel,
                                selectedService: $selectedService,
                                showingRegenerateAlert: $showingRegenerateAlert
                            )
                        case .users:
                            UserManagementSection(viewModel: viewModel)
                        case .analytics:
                            AnalyticsSection(viewModel: viewModel)
                        case .settings:
                            SystemSettingsSection(
                                viewModel: viewModel,
                                showingClearDataAlert: $showingClearDataAlert
                            )
                        }
                    }
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Panel de Administración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        appEnvironment.adminModeEnabled = false
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Regenerar Contenido", isPresented: $showingRegenerateAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Regenerar", role: .destructive) {
                    if let service = selectedService {
                        viewModel.regenerateContent(for: service)
                    }
                }
            } message: {
                Text("¿Estás seguro? Esto regenerará todo el contenido del servicio usando AWS Bedrock.")
            }
            .alert("Limpiar Datos", isPresented: $showingClearDataAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpiar", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("¿Estás seguro? Esto eliminará todos los datos locales.")
            }
        }
    }
}

struct UnauthorizedView: View {
    var body: some View {
        VStack(spacing: Theme.paddingL) {
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(Theme.textTertiary)
            
            Text("Acceso Denegado")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text("No tienes permisos para acceder a esta sección")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct ContentManagementSection: View {
    @ObservedObject var viewModel: AdminViewModel
    @Binding var selectedService: Service?
    @Binding var showingRegenerateAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // Stats
            HStack(spacing: Theme.paddingM) {
                AdminStatCard(
                    title: "Servicios",
                    value: "\(viewModel.totalServices)",
                    icon: "cloud",
                    color: .blue
                )
                
                AdminStatCard(
                    title: "Contenido Generado",
                    value: "\(viewModel.generatedContent)",
                    icon: "doc.text.fill",
                    color: .green
                )
            }
            .padding(.horizontal, Theme.paddingM)
            
            // Content generation status
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Estado del Contenido")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                ForEach(viewModel.contentStatus) { status in
                    ContentStatusRow(
                        status: status,
                        onRegenerate: {
                            selectedService = status.service
                            showingRegenerateAlert = true
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.paddingM)
            
            // Bulk actions
            VStack(spacing: Theme.paddingM) {
                Button(action: viewModel.regenerateAllContent) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerar Todo el Contenido")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.awsOrange)
                    .cornerRadius(Theme.cornerRadiusM)
                }
                
                Button(action: viewModel.syncWithAWS) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                        Text("Sincronizar con AWS")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.awsOrange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.secondaryBackground)
                    .cornerRadius(Theme.cornerRadiusM)
                }
            }
            .padding(.horizontal, Theme.paddingM)
        }
        .padding(.vertical, Theme.paddingM)
    }
}

struct UserManagementSection: View {
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // User stats
            HStack(spacing: Theme.paddingM) {
                AdminStatCard(
                    title: "Usuarios Totales",
                    value: "\(viewModel.totalUsers)",
                    icon: "person.2",
                    color: .purple
                )
                
                AdminStatCard(
                    title: "Activos Hoy",
                    value: "\(viewModel.activeUsers)",
                    icon: "person.crop.circle.badge.checkmark",
                    color: .green
                )
            }
            .padding(.horizontal, Theme.paddingM)
            
            // User list
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Usuarios Recientes")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                ForEach(viewModel.recentUsers) { user in
                    UserRow(user: user)
                }
            }
            .padding(.horizontal, Theme.paddingM)
        }
        .padding(.vertical, Theme.paddingM)
    }
}

struct AnalyticsSection: View {
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // Key metrics
            VStack(spacing: Theme.paddingM) {
                AnalyticsCard(
                    title: "Tiempo Total de Estudio",
                    value: "\(viewModel.totalStudyHours) horas",
                    change: "+12%",
                    isPositive: true
                )
                
                AnalyticsCard(
                    title: "Quizzes Completados",
                    value: "\(viewModel.totalQuizzes)",
                    change: "+23%",
                    isPositive: true
                )
                
                AnalyticsCard(
                    title: "Tasa de Retención",
                    value: "\(viewModel.retentionRate)%",
                    change: "-2%",
                    isPositive: false
                )
                
                AnalyticsCard(
                    title: "Servicio Más Popular",
                    value: viewModel.mostPopularService,
                    change: "",
                    isPositive: true
                )
            }
            .padding(.horizontal, Theme.paddingM)
            
            // Export button
            Button(action: viewModel.exportAnalytics) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Exportar Reporte")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.awsOrange)
                .cornerRadius(Theme.cornerRadiusM)
            }
            .padding(.horizontal, Theme.paddingM)
        }
        .padding(.vertical, Theme.paddingM)
    }
}

struct SystemSettingsSection: View {
    @ObservedObject var viewModel: AdminViewModel
    @Binding var showingClearDataAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // AWS Configuration
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Configuración AWS")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                ConfigRow(label: "Región", value: viewModel.awsRegion)
                ConfigRow(label: "Estado de Bedrock", value: viewModel.bedrockStatus, isStatus: true)
                ConfigRow(label: "Estado de DynamoDB", value: viewModel.dynamoStatus, isStatus: true)
                ConfigRow(label: "Estado de S3", value: viewModel.s3Status, isStatus: true)
            }
            .padding(.horizontal, Theme.paddingM)
            
            // Cache management
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Gestión de Caché")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tamaño del Caché")
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                        Text(viewModel.cacheSize)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Limpiar") {
                        showingClearDataAlert = true
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .background(Theme.secondaryBackground)
                .cornerRadius(Theme.cornerRadiusM)
            }
            .padding(.horizontal, Theme.paddingM)
            
            // Environment
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Entorno")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Picker("Entorno", selection: $viewModel.environment) {
                    Text("Desarrollo").tag("dev")
                    Text("Producción").tag("prod")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal, Theme.paddingM)
        }
        .padding(.vertical, Theme.paddingM)
    }
}

// Supporting Views
struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            Spacer()
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ContentStatusRow: View {
    let status: ContentStatus
    let onRegenerate: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(status.service.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                
                HStack {
                    Circle()
                        .fill(status.isGenerated ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text(status.isGenerated ? "Generado" : "Pendiente")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    if status.isGenerated {
                        Text("• \(status.lastUpdated)")
                            .font(.caption)
                            .foregroundColor(Theme.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onRegenerate) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Theme.awsOrange)
            }
        }
        .padding()
        .background(Theme.tertiaryBackground)
        .cornerRadius(Theme.cornerRadiusS)
    }
}

struct UserRow: View {
    let user: AdminUser
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.awsOrange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.initials)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.awsOrange)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(user.level)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                
                Text(user.lastActive)
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Spacer()
            
            if !change.isEmpty {
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ConfigRow: View {
    let label: String
    let value: String
    var isStatus: Bool = false
    
    var statusColor: Color {
        value.lowercased().contains("activo") || value.lowercased().contains("connected") ? .green : .orange
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            Spacer()
            
            if isStatus {
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimary)
                }
            } else {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(.vertical, Theme.paddingS)
    }
}

// Data models for Admin
struct ContentStatus: Identifiable {
    let id = UUID()
    let service: Service
    let isGenerated: Bool
    let lastUpdated: String
}

struct AdminUser: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let level: String
    let lastActive: String
    
    var initials: String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }
}

struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPanelView()
            .environmentObject(AppEnvironment())
    }
}
