
import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep = 0
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    ProgressView(value: Double(currentStep + 1), total: 4)
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
                        
                        Button(action: nextStep) {
                            Text(currentStep == 3 ? "Comenzar" : "Siguiente")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.awsOrange)
                                .cornerRadius(Theme.cornerRadiusM)
                        }
                        .disabled(!canProceed())
                    }
                    .padding(.horizontal, Theme.paddingL)
                    .padding(.bottom, Theme.paddingL)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                NotificationPermissionView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return viewModel.selectedLevel != nil
        case 2:
            return viewModel.selectedCertification != nil
        case 3:
            return viewModel.weeklyMinutes > 0
        default:
            return false
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    private func nextStep() {
        if currentStep < 3 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        viewModel.saveOnboardingData()
        appEnvironment.completeOnboarding() // Usar la nueva función
        navigateToHome = true
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
