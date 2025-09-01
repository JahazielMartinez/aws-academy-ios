import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var authService = AuthService.shared

    @State private var selectedTab = 0
    @State private var showingSplash = true
    @State private var isFirstLaunch = false
    @State private var userJustRegistered = false

    var body: some View {
        Group {
            if showingSplash {
                // 1) Splash
                SplashView()
                    .onAppear {
                        Task {
                            // Mantén un splash corto y determinista
                            try? await Task.sleep(nanoseconds: 2_000_000_000)

                            // Detectar primer arranque (solo una vez por instalación)
                            isFirstLaunch = !UserDefaults.standard.bool(
                                forKey: "hasLaunchedBefore"
                            )
                            if isFirstLaunch {
                                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            }

                            // Refrescar estado de auth (restaurar sesión si existe)
                            await authService.checkAuthStatus()

                            showingSplash = false
                        }
                    }

            } else if authService.isSignedIn {
                // 2) Usuario autenticado
                if !appEnvironment.isOnboardingCompleted && (userJustRegistered || (isNewUser() && !authService.didSignInFromLogin)) {
                    // Usuario recién registrado O usuario nuevo sin onboarding completado
                    OnboardingContainerView()
                        .environmentObject(appEnvironment)
                } else {
                    // SIEMPRE mostrar MainTabView con TabBar si:
                    // - Onboarding completado, O
                    // - Usuario existente que hizo login, O
                    // - Cualquier otro caso con usuario autenticado
                    MainTabView(selectedTab: $selectedTab)
                        .environmentObject(appEnvironment)
                }

            } else if isFirstLaunch {
                // 3) Primera vez y sin sesión ➜ pantalla de bienvenida
                WelcomeFirstTimeView()
                    .environmentObject(appEnvironment)

            } else {
                // 4) No es primer arranque y sin sesión ➜ login directo
                LoginView()
                    .environmentObject(appEnvironment)
            }
        }
        // ✅ Listener global: el registro exitoso puede dispararse desde EmailVerificationView
        .onReceive(NotificationCenter.default.publisher(for: .userDidRegister)) { _ in
            userJustRegistered = true
        }
        // ✅ Reaccionar a cambios de sesión
        .onChange(of: authService.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                let userId = authService.currentUser?.userId ?? "unknown"

                appEnvironment.currentUser = User(
                    id: userId,
                    name: "Usuario",
                    level: .beginner,
                    targetCertification: nil,
                    weeklyGoalMinutes: 60,
                    createdAt: Date(),
                    lastActiveAt: Date()
                )

                // Si vino de LOGIN (no de registro), saltar onboarding y marcar usuario existente
                if authService.didSignInFromLogin {
                    appEnvironment.completeOnboarding()
                    UserDefaults.standard.set(true, forKey: "user_\(userId)_exists")
                }
            } else {
                appEnvironment.currentUser = nil
                userJustRegistered = false
            }
        }
    }

    // Determina si el usuario autenticado es "nuevo" en este dispositivo (para decidir si mostrar onboarding)
    private func isNewUser() -> Bool {
        let userId = authService.currentUser?.userId ?? "unknown"
        return !UserDefaults.standard.bool(forKey: "user_\(userId)_exists")
    }
}

// MARK: - Bienvenida (primera vez)

struct WelcomeFirstTimeView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var authService = AuthService.shared

    @State private var showingSignUp = false
    @State private var showingLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.awsOrange.opacity(0.1), Theme.backgroundColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: Theme.paddingXL) {
                    Spacer()

                    VStack(spacing: Theme.paddingM) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.awsOrange)

                        Text("¡Bienvenido!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)

                        Text("AWS Academy")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.awsOrange)
                    }

                    VStack(spacing: Theme.paddingM) {
                        Text("Parece que es tu primera vez aquí")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Crea una cuenta para comenzar tu aprendizaje en AWS")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.paddingL)
                    }

                    Spacer()

                    VStack(spacing: Theme.paddingM) {
                        Button(action: { showingSignUp = true }) {
                            HStack {
                                Spacer()
                                Text("Crear cuenta").fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .background(Theme.awsOrange)
                            .cornerRadius(Theme.cornerRadiusM)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { showingLogin = true }) {
                            HStack {
                                Spacer()
                                Text("Ya tengo cuenta")
                                Spacer()
                            }
                            .foregroundColor(Theme.textSecondary)
                            .frame(height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, Theme.paddingL)
                    .padding(.bottom, Theme.paddingL)
                }
            }
            .fullScreenCover(isPresented: $showingSignUp) {
                SignUpView()
            }
            .fullScreenCover(isPresented: $showingLogin) {
                LoginView()
                    .environmentObject(appEnvironment)
            }
        }
    }
}

// MARK: - Tabs principales

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appEnvironment: AppEnvironment

    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            Color(hex: "#FF9900") ?? .orange
        )
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

// MARK: - Previews

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
