import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    @State private var showingSplash = true
    @State private var userJustRegistered = false
    
    var body: some View {
        Group {
            if showingSplash {
                SplashView()
                    .onAppear {
                        Task {
                            // Dar tiempo a que Amplify se configure
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
                            await authService.checkAuthStatus()
                            showingSplash = false
                        }
                    }
            } else if authService.isSignedIn {
                // Usuario autenticado
                if !appEnvironment.isOnboardingCompleted {
                    // Usuario nuevo - mostrar onboarding
                    OnboardingContainerView()
                        .environmentObject(appEnvironment)
                } else {
                    // Usuario existente - ir directo al home
                    MainTabView(selectedTab: $selectedTab)
                        .environmentObject(appEnvironment)
                }
            } else {
                // Usuario no autenticado - mostrar login
                LoginView()
                    .environmentObject(appEnvironment)
            }
        }
        .onChange(of: authService.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                // Cuando el usuario se autentica, crear el perfil
                let userId = authService.currentUser?.userId ?? "unknown"
                
                // Verificar si es usuario nuevo (recién registrado)
                let isNewUser = !UserDefaults.standard.bool(forKey: "user_\(userId)_exists")
                
                if isNewUser {
                    // Marcar como usuario existente para futuras sesiones
                    UserDefaults.standard.set(true, forKey: "user_\(userId)_exists")
                    // Resetear onboarding para usuario nuevo
                    appEnvironment.isOnboardingCompleted = false
                    UserDefaults.standard.set(false, forKey: "onboardingCompleted")
                } else {
                    // Usuario existente - saltar onboarding
                    appEnvironment.isOnboardingCompleted = true
                }
                
                // Crear perfil de usuario
                appEnvironment.currentUser = User(
                    id: userId,
                    name: "Usuario",
                    level: .beginner,
                    targetCertification: nil,
                    weeklyGoalMinutes: 60,
                    createdAt: Date(),
                    lastActiveAt: Date()
                )
            } else {
                appEnvironment.currentUser = nil
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#FF9900") ?? .orange)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "#FF9900") ?? .orange)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Inicio")
                    }
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "square.grid.2x2.fill" : "square.grid.2x2")
                        Text("Explorar")
                    }
                }
                .tag(1)
            
            ProgressDashboardView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "chart.line.uptrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        Text("Progreso")
                    }
                }
                .tag(2)
            
            AchievementsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "trophy.fill" : "trophy")
                        Text("Logros")
                    }
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                        Text("Perfil")
                    }
                }
                .tag(4)
        }
        .accentColor(Theme.awsOrange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
