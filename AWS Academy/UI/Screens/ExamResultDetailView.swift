import SwiftUI

struct ExamResultDetailView: View {
    let examResult: ExamResult
    @State private var selectedFilter: ResultFilter = .all
    
    enum ResultFilter: String, CaseIterable {
        case all = "Todas"
        case correct = "Correctas"
        case incorrect = "Incorrectas"
        case flagged = "Marcadas"
    }
    
    var filteredQuestions: [QuestionResult] {
        switch selectedFilter {
        case .all:
            return examResult.questions
        case .correct:
            return examResult.questions.filter { $0.isCorrect }
        case .incorrect:
            return examResult.questions.filter { !$0.isCorrect }
        case .flagged:
            return examResult.questions.filter { $0.wasFlagged }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Summary card
                    resultSummary
                    
                    // Domain breakdown
                    domainBreakdown
                    
                    // Filter
                    filterSection
                    
                    // Questions review
                    questionsReview
                }
                .padding(.vertical)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Resultados del Examen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: generateShareText()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var resultSummary: some View {
        VStack(spacing: Theme.paddingM) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Puntuación Final")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(examResult.date, style: .date)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.2)
                        .foregroundColor(scoreColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(examResult.percentage / 100))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundColor(scoreColor)
                        .rotationEffect(Angle(degrees: 270))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(examResult.percentage))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text(examResult.passed ? "Aprobado" : "No aprobado")
                            .font(.caption2)
                            .foregroundColor(examResult.passed ? .green : .red)
                    }
                }
                .frame(width: 100, height: 100)
            }
            
            HStack(spacing: Theme.paddingXL) {
                StatItem(
                    title: "Correctas",
                    value: "\(examResult.correctCount)",
                    color: .green
                )
                
                StatItem(
                    title: "Incorrectas",
                    value: "\(examResult.incorrectCount)",
                    color: .red
                )
                
                StatItem(
                    title: "Tiempo",
                    value: examResult.duration,
                    color: Theme.awsOrange
                )
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal)
    }
    
    private var domainBreakdown: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Desglose por Dominio")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: Theme.paddingS) {
                ForEach(examResult.domainScores) { domain in
                    DomainScoreRow(domain: domain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var filterSection: some View {
        Picker("Filtro", selection: $selectedFilter) {
            ForEach(ResultFilter.allCases, id: \.self) { filter in
                Text("\(filter.rawValue) (\(countForFilter(filter)))")
                    .tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var questionsReview: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Revisión de Preguntas")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: Theme.paddingM) {
                ForEach(filteredQuestions) { question in
                    QuestionReviewCard(question: question)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var scoreColor: Color {
        if examResult.percentage >= 80 {
            return .green
        } else if examResult.percentage >= 70 {
            return Theme.awsOrange
        } else {
            return .red
        }
    }
    
    private func countForFilter(_ filter: ResultFilter) -> Int {
        switch filter {
        case .all:
            return examResult.questions.count
        case .correct:
            return examResult.questions.filter { $0.isCorrect }.count
        case .incorrect:
            return examResult.questions.filter { !$0.isCorrect }.count
        case .flagged:
            return examResult.questions.filter { $0.wasFlagged }.count
        }
    }
    
    private func generateShareText() -> String {
        "¡Obtuve \(Int(examResult.percentage))% en mi examen de práctica de AWS!"
    }
}

struct DomainScoreRow: View {
    let domain: DomainScore
    
    var body: some View {
        VStack(spacing: Theme.paddingS) {
            HStack {
                Text(domain.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(Int(domain.percentage))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(domain.percentage >= 70 ? .green : .red)
            }
            
            ProgressView(value: domain.percentage / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: domain.percentage >= 70 ? .green : .red))
        }
        .padding()
        .background(Theme.tertiaryBackground)
        .cornerRadius(Theme.cornerRadiusS)
    }
}

struct QuestionReviewCard: View {
    let question: QuestionResult
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Circle()
                        .fill(question.isCorrect ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text("Pregunta \(question.number)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    if question.wasFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: Theme.paddingM) {
                    Text(question.questionText)
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimary)
                    
                    VStack(alignment: .leading, spacing: Theme.paddingS) {
                        ForEach(question.options.indices, id: \.self) { index in
                            HStack {
                                if index == question.selectedAnswer {
                                    Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(question.isCorrect ? .green : .red)
                                } else if index == question.correctAnswer {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    Circle()
                                        .strokeBorder(Theme.textTertiary)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(question.options[index])
                                    .font(.caption)
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                    }
                    
                    if !question.isCorrect {
                        Text("Explicación: \(question.explanation)")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(Theme.cornerRadiusS)
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// Data models
struct ExamResult {
    let id: String
    let date: Date
    let percentage: Double
    let correctCount: Int
    let incorrectCount: Int
    let duration: String
    let passed: Bool
    let questions: [QuestionResult]
    let domainScores: [DomainScore]
}

struct QuestionResult: Identifiable {
    let id: String
    let number: Int
    let questionText: String
    let options: [String]
    let selectedAnswer: Int
    let correctAnswer: Int
    let isCorrect: Bool
    let wasFlagged: Bool
    let explanation: String
}

struct DomainScore: Identifiable {
    let id: String
    let name: String
    let percentage: Double
}

struct ExamResultDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExamResultDetailView(examResult: ExamResult(
            id: "1",
            date: Date(),
            percentage: 75,
            correctCount: 49,
            incorrectCount: 16,
            duration: "87 min",
            passed: true,
            questions: [],
            domainScores: [
                DomainScore(id: "1", name: "Cloud Concepts", percentage: 85),
                DomainScore(id: "2", name: "Security", percentage: 72),
                DomainScore(id: "3", name: "Technology", percentage: 68),
                DomainScore(id: "4", name: "Billing", percentage: 78)
            ]
        ))
    }
}
