import SwiftUI

struct PracticeExamView: View {
    @State private var currentQuestion = 0
    @State private var totalQuestions = 65
    @State private var answers: [Int: Int] = [:]
    @State private var flaggedQuestions: Set<Int> = []
    @State private var timeRemaining = 5400 // 90 minutos en segundos
    @State private var showingReview = false
    @State private var showingSubmit = false
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Exam header
                examHeader
                
                // Question content
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.paddingL) {
                        questionSection
                        answersSection
                    }
                    .padding()
                }
                
                // Navigation bar
                examNavigationBar
            }
            .navigationTitle("Examen de Práctica")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Pausar") {
                        pauseExam()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Revisar") {
                        showingReview = true
                    }
                }
            }
            .sheet(isPresented: $showingReview) {
                ExamReviewView(
                    answers: answers,
                    flagged: flaggedQuestions,
                    totalQuestions: totalQuestions,
                    onSelectQuestion: { question in
                        currentQuestion = question
                        showingReview = false
                    }
                )
            }
            .alert("Enviar Examen", isPresented: $showingSubmit) {
                Button("Cancelar", role: .cancel) { }
                Button("Enviar", role: .destructive) {
                    submitExam()
                }
            } message: {
                Text("¿Estás seguro? Has respondido \(answers.count) de \(totalQuestions) preguntas")
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private var examHeader: some View {
        HStack {
            // Timer
            HStack {
                Image(systemName: "clock")
                Text(timeString(from: timeRemaining))
                    .fontWeight(.medium)
            }
            .foregroundColor(timeRemaining < 600 ? .red : Theme.textPrimary)
            
            Spacer()
            
            // Progress
            Text("\(currentQuestion + 1) / \(totalQuestions)")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            // Flag button
            Button(action: toggleFlag) {
                Image(systemName: flaggedQuestions.contains(currentQuestion) ? "flag.fill" : "flag")
                    .foregroundColor(Theme.awsOrange)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
    }
    
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Pregunta \(currentQuestion + 1)")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            
            Text("¿Cuál de los siguientes servicios de AWS proporciona una base de datos NoSQL completamente administrada?")
                .font(.body)
                .foregroundColor(Theme.textPrimary)
        }
    }
    
    private var answersSection: some View {
        VStack(spacing: Theme.paddingM) {
            ForEach(0..<4) { index in
                AnswerButton(
                    text: "Opción \(index + 1)",
                    isSelected: answers[currentQuestion] == index,
                    action: {
                        answers[currentQuestion] = index
                    }
                )
            }
        }
    }
    
    private var examNavigationBar: some View {
        HStack(spacing: Theme.paddingM) {
            Button(action: previousQuestion) {
                Image(systemName: "chevron.left")
                Text("Anterior")
            }
            .disabled(currentQuestion == 0)
            
            Spacer()
            
            if currentQuestion == totalQuestions - 1 {
                Button(action: { showingSubmit = true }) {
                    Text("Enviar Examen")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Theme.awsOrange)
                .cornerRadius(Theme.cornerRadiusS)
            } else {
                Button(action: nextQuestion) {
                    Text("Siguiente")
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                submitExam()
            }
        }
    }
    
    private func pauseExam() {
        timer?.invalidate()
    }
    
    private func toggleFlag() {
        if flaggedQuestions.contains(currentQuestion) {
            flaggedQuestions.remove(currentQuestion)
        } else {
            flaggedQuestions.insert(currentQuestion)
        }
    }
    
    private func previousQuestion() {
        if currentQuestion > 0 {
            currentQuestion -= 1
        }
    }
    
    private func nextQuestion() {
        if currentQuestion < totalQuestions - 1 {
            currentQuestion += 1
        }
    }
    
    private func submitExam() {
        timer?.invalidate()
        // Navegar a resultados
    }
    
    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .strokeBorder(isSelected ? Theme.awsOrange : Theme.textTertiary, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Theme.awsOrange : Color.clear)
                    )
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(isSelected ? .white : Color.clear)
                            .frame(width: 8, height: 8)
                    )
                
                Text(text)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Theme.awsOrange.opacity(0.1) : Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExamReviewView: View {
    let answers: [Int: Int]
    let flagged: Set<Int>
    let totalQuestions: Int
    let onSelectQuestion: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Theme.paddingM) {
                    ForEach(0..<totalQuestions, id: \.self) { question in
                        QuestionGridItem(
                            number: question + 1,
                            isAnswered: answers[question] != nil,
                            isFlagged: flagged.contains(question),
                            action: {
                                onSelectQuestion(question)
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Revisar Examen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuestionGridItem: View {
    let number: Int
    let isAnswered: Bool
    let isFlagged: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusS)
                    .fill(isAnswered ? Theme.awsOrange.opacity(0.2) : Theme.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusS)
                            .strokeBorder(isAnswered ? Theme.awsOrange : Theme.textTertiary.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(spacing: 2) {
                    if isFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    Text("\(number)")
                        .font(.subheadline)
                        .fontWeight(isAnswered ? .medium : .regular)
                        .foregroundColor(isAnswered ? Theme.awsOrange : Theme.textPrimary)
                }
            }
            .frame(width: 50, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PracticeExamView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeExamView()
    }
}
