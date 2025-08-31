
import SwiftUI

struct QuizQuestionView: View {
    var service: Service? = nil
    @StateObject private var viewModel = QuizViewModel()
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    @State private var navigateToResults = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Cargando quiz...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Progress bar
                        QuizProgressBar(
                            current: viewModel.currentQuestionIndex + 1,
                            total: viewModel.totalQuestions
                        )
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: Theme.paddingL) {
                                // Question header
                                QuestionHeader(
                                    questionNumber: viewModel.currentQuestionIndex + 1,
                                    totalQuestions: viewModel.totalQuestions,
                                    difficulty: viewModel.currentQuestion?.difficulty ?? "Básico"
                                )
                                
                                // Question
                                Text(viewModel.currentQuestion?.question ?? "Pregunta se cargará desde AWS")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.textPrimary)
                                    .padding(.horizontal, Theme.paddingM)
                                
                                // Answer options
                                VStack(spacing: Theme.paddingM) {
                                    ForEach(0..<4) { index in
                                        AnswerOption(
                                            text: viewModel.currentQuestion?.options[index] ?? "Opción \(index + 1)",
                                            isSelected: selectedAnswer == index,
                                            isCorrect: showingResult && index == viewModel.currentQuestion?.correctAnswer,
                                            isIncorrect: showingResult && selectedAnswer == index && index != viewModel.currentQuestion?.correctAnswer,
                                            action: {
                                                if !showingResult {
                                                    selectedAnswer = index
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, Theme.paddingM)
                                
                                // Explanation (if showing result)
                                if showingResult {
                                    ExplanationCard(
                                        explanation: viewModel.currentQuestion?.explanation ?? "Explicación se cargará desde AWS"
                                    )
                                    .padding(.horizontal, Theme.paddingM)
                                }
                            }
                            .padding(.vertical, Theme.paddingL)
                        }
                        
                        // Bottom button
                        Button(action: handleButtonAction) {
                            Text(buttonTitle)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedAnswer != nil ? Theme.awsOrange : Color.gray)
                                .cornerRadius(Theme.cornerRadiusM)
                        }
                        .disabled(selectedAnswer == nil)
                        .padding(Theme.paddingM)
                    }
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salir") {
                        // Mostrar alerta de confirmación
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToResults) {
                QuizResultView(score: viewModel.score, totalQuestions: viewModel.totalQuestions)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            viewModel.loadQuiz(for: service)
        }
    }
    
    private var buttonTitle: String {
        if showingResult {
            return viewModel.isLastQuestion ? "Ver resultados" : "Siguiente pregunta"
        } else {
            return "Verificar respuesta"
        }
    }
    
    private func handleButtonAction() {
        if showingResult {
            if viewModel.isLastQuestion {
                navigateToResults = true
            } else {
                viewModel.nextQuestion()
                selectedAnswer = nil
                showingResult = false
            }
        } else {
            if let answer = selectedAnswer {
                viewModel.submitAnswer(answer)
                showingResult = true
            }
        }
    }
}

struct QuizProgressBar: View {
    let current: Int
    let total: Int
    
    var progress: Double {
        Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            HStack {
                Text("Pregunta \(current) de \(total)")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.awsOrange)
            }
            .padding(.horizontal, Theme.paddingM)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
                .padding(.horizontal, Theme.paddingM)
        }
        .padding(.vertical, Theme.paddingS)
        .background(Theme.secondaryBackground)
    }
}

struct QuestionHeader: View {
    let questionNumber: Int
    let totalQuestions: Int
    let difficulty: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PREGUNTA \(questionNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: Theme.paddingS) {
                    DifficultyBadge(difficulty: difficulty)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, Theme.paddingM)
    }
}

struct DifficultyBadge: View {
    let difficulty: String
    
    var color: Color {
        switch difficulty.lowercased() {
        case "fácil", "básico":
            return .green
        case "intermedio":
            return .orange
        case "difícil", "avanzado":
            return .red
        default:
            return Theme.awsOrange
        }
    }
    
    var body: some View {
        Text(difficulty)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.paddingS)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

struct AnswerOption: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isIncorrect {
            return Color.red.opacity(0.2)
        } else if isSelected {
            return Theme.awsOrange.opacity(0.2)
        } else {
            return Theme.secondaryBackground
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isIncorrect {
            return Color.red
        } else if isSelected {
            return Theme.awsOrange
        } else {
            return Color.clear
        }
    }
    
    var icon: String? {
        if isCorrect {
            return "checkmark.circle.fill"
        } else if isIncorrect {
            return "xmark.circle.fill"
        }
        return nil
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.paddingM) {
                Text(text)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding(Theme.paddingM)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(Theme.cornerRadiusM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExplanationCard: View {
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Theme.awsOrange)
                Text("Explicación")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text(explanation)
                .font(.body)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(Theme.paddingM)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct QuizQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuizQuestionView()
    }
}
