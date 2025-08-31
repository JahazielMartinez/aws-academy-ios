import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var selectedTab = 0
    @State private var showingSplash = true
    @State private var showingOnboarding = false
    @State private var showingLogin = false
    
    var body: some View {
        if showingSplash {
            SplashView()
                .onAppear {
                    // Simular carga y decidir navegación
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingSplash = false
                        checkUserStatus()
                    }
                }
        } else if showingLogin {
            LoginView()
                .environmentObject(appEnvironment)
        } else if showingOnboarding {
            OnboardingContainerView()
                .environmentObject(appEnvironment)
        } else {
            // Vista principal con TabBar
            MainTabView(selectedTab: $selectedTab)
                .environmentObject(appEnvironment)
        }
    }
    
    private func checkUserStatus() {
        // Verificar si el usuario está logueado
        if appEnvironment.currentUser == nil {
            // No hay usuario, mostrar login
            showingLogin = true
        } else if !appEnvironment.isOnboardingCompleted {
            // Usuario existe pero no ha completado onboarding
            showingOnboarding = true
        }
        // Si hay usuario y completó onboarding, se muestra MainTabView
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
        
        // Configurar apariencia del TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Colores para los items
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
