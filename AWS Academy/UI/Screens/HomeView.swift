import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Header con saludo
                    headerSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Progreso del día
                    if let progress = viewModel.dailyProgress {
                        progressSection(progress)
                    }
                    
                    // Continuar aprendiendo
                    if !viewModel.recentServices.isEmpty {
                        continueSection
                    }
                    
                    // Categorías destacadas
                    featuredSection
                    
                    // Quiz rápido
                    quickQuizSection
                }
                .padding(.horizontal, Theme.paddingM)
                .padding(.top, Theme.paddingM)
                .padding(.bottom, 100) // Espacio para el TabBar
            }
            .background(Theme.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(Theme.awsOrange)
                        Text("AWS Academy")
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Theme.paddingM) {
                        // Notificaciones
                        Button(action: {}) {
                            Image(systemName: "bell.badge")
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        // Admin panel (solo si está habilitado)
                        if appEnvironment.adminModeEnabled {
                            NavigationLink(destination: AdminPanelView()) {
                                Image(systemName: "gearshape.2.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadHomeData()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            Text(viewModel.greeting)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(viewModel.currentStreak) días de racha")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text(viewModel.motivationalMessage)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.vertical, Theme.paddingS)
    }
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.paddingM) {
                QuickActionCard(
                    title: "Quiz Rápido",
                    icon: "questionmark.circle.fill",
                    color: .purple,
                    destination: AnyView(QuizQuestionView())
                )
                
                QuickActionCard(
                    title: "Mi Ruta",
                    icon: "map.fill",
                    color: .green,
                    destination: AnyView(LearningPathDetailView())
                )
                
                QuickActionCard(
                    title: "Offline",
                    icon: "arrow.down.circle.fill",
                    color: .blue,
                    destination: AnyView(OfflineManagerView())
                )
                
                QuickActionCard(
                    title: "Certificación",
                    icon: "trophy.fill",
                    color: Theme.awsOrange,
                    destination: AnyView(CertificationPrepDetailView())
                )
            }
        }
    }
    
    private func progressSection(_ progress: DailyProgress) -> some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Text("Hoy")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(progress.minutesStudied) / \(viewModel.dailyGoalMinutes) min")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            ProgressView(value: Double(progress.minutesStudied) / Double(viewModel.dailyGoalMinutes))
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
            
            HStack(spacing: Theme.paddingM) {
                MiniStatCard(
                    value: "\(progress.minutesStudied)",
                    label: "Minutos",
                    icon: "clock.fill"
                )
                
                MiniStatCard(
                    value: "\(progress.lessonsCompleted)",
                    label: "Lecciones",
                    icon: "book.fill"
                )
                
                MiniStatCard(
                    value: "\(progress.quizzesCompleted)",
                    label: "Quizzes",
                    icon: "checkmark.circle.fill"
                )
                
                MiniStatCard(
                    value: "\(progress.streak)",
                    label: "Racha",
                    icon: "flame.fill"
                )
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
    
    private var continueSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Continuar aprendiendo")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    ForEach(viewModel.recentServices) { service in
                        NavigationLink(destination: ServiceDetailView(service: service)) {
                            ServiceCard(service: service, isCompact: true)
                        }
                    }
                }
            }
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack {
                Text("Categorías destacadas")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: CategoriesView()) {
                    Text("Ver todas")
                        .font(.subheadline)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.paddingM) {
                ForEach(viewModel.featuredCategories.prefix(4)) { category in
                    NavigationLink(destination: SubcategoriesView(category: category)) {
                        CompactCategoryCard(category: category)
                    }
                }
            }
        }
    }
    
    private var quickQuizSection: some View {
        NavigationLink(destination: QuizQuestionView()) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.paddingS) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(Theme.awsOrange)
                        
                        Text("Desafío del día")
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    Text("5 preguntas sobre los servicios que estás aprendiendo")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundColor(Theme.awsOrange)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Theme.awsOrange.opacity(0.1), Theme.awsOrange.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: Theme.paddingS) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary)
            }
            .frame(width: 80, height: 80)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.awsOrange)
            
            Text(value)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompactCategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(Color(hex: category.color) ?? Theme.awsOrange)
            
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
            
            Text("\(category.serviceCount)")
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

// Las vistas ahora están definidas en archivos separados

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppEnvironment())
    }
}
