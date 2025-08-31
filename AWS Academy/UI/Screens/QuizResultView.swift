import SwiftUI

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int
    @Environment(\.dismiss) var dismiss
    @State private var navigateToHome = false
    @State private var showingShareSheet = false
    
    var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    var performanceLevel: (title: String, message: String, color: Color, icon: String) {
        switch percentage {
        case 90...100:
            return ("¡Excelente!", "Dominas este tema perfectamente", .green, "star.fill")
        case 70..<90:
            return ("¡Muy bien!", "Buen conocimiento del tema", .blue, "hand.thumbsup.fill")
        case 50..<70:
            return ("Bien", "Sigue practicando para mejorar", .orange, "arrow.up.circle.fill")
        default:
            return ("Necesitas repasar", "Revisa el contenido nuevamente", .red, "arrow.clockwise")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Theme.awsOrange.opacity(0.1), Theme.backgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.paddingXL) {
                        // Result animation
                        ResultCircle(percentage: percentage)
                            .padding(.top, Theme.paddingXL)
                        
                        // Performance message
                        VStack(spacing: Theme.paddingM) {
                            HStack {
                                Image(systemName: performanceLevel.icon)
                                    .font(.title2)
                                Text(performanceLevel.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(performanceLevel.color)
                            
                            Text(performanceLevel.message)
                                .font(.body)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Score details
                        HStack(spacing: Theme.paddingXL) {
                            ScoreCard(
                                title: "Correctas",
                                value: "\(score)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            ScoreCard(
                                title: "Incorrectas",
                                value: "\(totalQuestions - score)",
                                icon: "xmark.circle.fill",
                                color: .red
                            )
                            
                            ScoreCard(
                                title: "Precisión",
                                value: "\(Int(percentage))%",
                                icon: "target",
                                color: Theme.awsOrange
                            )
                        }
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Statistics
                        VStack(alignment: .leading, spacing: Theme.paddingM) {
                            Text("Estadísticas")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            
                            StatRow(label: "Tiempo total", value: "2:45 min")
                            StatRow(label: "Tiempo promedio", value: "33 seg/pregunta")
                            StatRow(label: "Racha actual", value: "3 días")
                        }
                        .padding(Theme.paddingM)
                        .background(Theme.secondaryBackground)
                        .cornerRadius(Theme.cornerRadiusM)
                        .padding(.horizontal, Theme.paddingL)
                        
                        // Action buttons
                        VStack(spacing: Theme.paddingM) {
                            NavigationLink(destination: QuizHistoryView()) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("Ver historial")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.awsOrange)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.secondaryBackground)
                                .cornerRadius(Theme.cornerRadiusM)
                            }
                            
                            Button(action: { showingShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Compartir resultado")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.awsOrange)
                                .cornerRadius(Theme.cornerRadiusM)
                            }
                            
                            Button(action: { navigateToHome = true }) {
                                Text("Volver al inicio")
                                    .font(.body)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(.horizontal, Theme.paddingL)
                        .padding(.bottom, Theme.paddingXL)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct ResultCircle: View {
    let percentage: Double
    @State private var animatedPercentage: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.1)
                .foregroundColor(Theme.awsOrange)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animatedPercentage / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(Theme.awsOrange)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 1.5), value: animatedPercentage)
            
            VStack(spacing: Theme.paddingS) {
                Text("\(Int(animatedPercentage))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text("de respuestas correctas")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            animatedPercentage = percentage
        }
    }
}

struct ScoreCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

struct QuizResultView_Previews: PreviewProvider {
    static var previews: some View {
        QuizResultView(score: 7, totalQuestions: 10)
    }
}
