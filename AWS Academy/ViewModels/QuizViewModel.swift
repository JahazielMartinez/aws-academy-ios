
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var answers: [Int] = []
    @Published var isLoading = false
    @Published var quizCompleted = false
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var totalQuestions: Int {
        questions.count > 0 ? questions.count : 5  // Default 5 preguntas
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex >= totalQuestions - 1
    }
    
    func loadQuiz(for service: Service? = nil) {
        isLoading = true
        
        // Simulación temporal - se reemplazará con llamada a AWS
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Crear preguntas temporales
            self.questions = [
                QuizQuestion(
                    id: "1",
                    question: "Pregunta de ejemplo",
                    options: ["Opción A", "Opción B", "Opción C", "Opción D"],
                    correctAnswer: 0,
                    explanation: "Explicación de la respuesta",
                    difficulty: "Básico"
                )
            ]
            self.isLoading = false
        }
    }
    
    func submitAnswer(_ answerIndex: Int) {
        answers.append(answerIndex)
        if answerIndex == currentQuestion?.correctAnswer {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
        } else {
            quizCompleted = true
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        answers = []
        quizCompleted = false
    }
}

struct QuizQuestion: Identifiable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let difficulty: String
}
