import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep = 0
    @State private var navigateToNotifications = false
    @State private var buttonPressed = false
    
    private let totalSteps = 4 // Welcome, Level, Goal, Time
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
                        .padding(.horizontal, Theme.paddingL)
                        .padding(.top, Theme.paddingM)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        OnboardingWelcomeView()
                            .tag(0)
                        
                        OnboardingLevelView(selectedLevel: $viewModel.selectedLevel)
                            .tag(1)
                        
                        OnboardingGoalView(selectedCertification: $viewModel.selectedCertification)
                            .tag(2)
                        
                        OnboardingTimeView(weeklyMinutes: $viewModel.weeklyMinutes)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Navigation buttons
                    HStack(spacing: Theme.paddingM) {
                        if currentStep > 0 {
                            Button(action: previousStep) {
                                Text("Anterior")
                                    .font(.body)
                                    .foregroundColor(Theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.secondaryBackground)
                                    .cornerRadius(Theme.cornerRadiusM)
                            }
                        }
                        
                        Button(action: {
                            buttonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                buttonPressed = false
                                nextStep()
                            }
                        }) {
                            Text(getButtonTitle())
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canProceed() ? Theme.awsOrange : Color.gray)
                                .cornerRadius(Theme.cornerRadiusM)
                                .scaleEffect(buttonPressed ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: buttonPressed)
                        }
                        .disabled(!canProceed())
                    }
                    .padding(.horizontal, Theme.paddingL)
                    .padding(.bottom, Theme.paddingL)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationPermissionView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func getButtonTitle() -> String {
        switch currentStep {
        case 0: return "Comenzar"
        case totalSteps - 1: return "Continuar"
        default: return "Siguiente"
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 0: return true // Welcome - siempre puede continuar
        case 1: return viewModel.selectedLevel != nil
        case 2: return viewModel.selectedCertification != nil
        case 3: return viewModel.weeklyMinutes > 0
        default: return false
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    
    private func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        viewModel.saveOnboardingData()
        navigateToNotifications = true
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingContainerView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.light)
            
            OnboardingContainerView()
                .environmentObject(AppEnvironment())
                .preferredColorScheme(.dark)
        }
    }
}
