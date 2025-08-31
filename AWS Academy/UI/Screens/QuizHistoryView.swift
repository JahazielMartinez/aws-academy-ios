import SwiftUI

struct QuizHistoryView: View {
    @State private var selectedFilter: QuizFilter = .all
    @State private var quizHistory: [QuizRecord] = []
    
    enum QuizFilter: String, CaseIterable {
        case all = "Todos"
        case week = "Esta semana"
        case month = "Este mes"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Stats summary
                    QuizStatsSummary()
                    
                    // Filter
                    Picker("Filtro", selection: $selectedFilter) {
                        ForEach(QuizFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Theme.paddingM)
                    
                    // History list
                    VStack(spacing: Theme.paddingM) {
                        if quizHistory.isEmpty {
                            EmptyStateView(
                                icon: "doc.text.magnifyingglass",
                                title: "Sin historial",
                                message: "Completa quizzes para ver tu historial aquí"
                            )
                            .padding(.top, 50)
                        } else {
                            ForEach(quizHistory) { record in
                                QuizRecordCard(record: record)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.paddingM)
                }
                .padding(.vertical, Theme.paddingM)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Historial de Quizzes")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadQuizHistory()
        }
    }
    
    private func loadQuizHistory() {
        // Cargar historial desde AWS/Local
    }
}

struct QuizStatsSummary: View {
    var body: some View {
        VStack(spacing: Theme.paddingM) {
            HStack(spacing: Theme.paddingM) {
                StatCard(
                    title: "Total Quizzes",
                    value: "0",
                    trend: "+0",
                    icon: "doc.text",
                    color: .blue
                )
                
                StatCard(
                    title: "Promedio",
                    value: "0%",
                    trend: "+0%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
            
            HStack(spacing: Theme.paddingM) {
                StatCard(
                    title: "Racha",
                    value: "0 días",
                    trend: "🔥",
                    icon: "flame",
                    color: .orange
                )
                
                StatCard(
                    title: "Mejor puntaje",
                    value: "0%",
                    trend: "⭐",
                    icon: "trophy",
                    color: Theme.awsOrange
                )
            }
        }
        .padding(.horizontal, Theme.paddingM)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text(trend)
                    .font(.caption2)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color.opacity(0.7))
        }
        .padding(Theme.paddingM)
        .frame(maxWidth: .infinity)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct QuizRecordCard: View {
    let record: QuizRecord
    
    var scoreColor: Color {
        switch record.percentage {
        case 80...100:
            return .green
        case 60..<80:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.serviceName)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(record.date, style: .date)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: Theme.paddingS) {
                    Label("\(record.questions) preguntas", systemImage: "questionmark.circle")
                        .font(.caption2)
                    
                    Label("\(record.duration) min", systemImage: "clock")
                        .font(.caption2)
                }
                .foregroundColor(Theme.textTertiary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(record.percentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
                
                Text("\(record.correctAnswers)/\(record.questions)")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct QuizRecord: Identifiable {
    let id = UUID()
    let serviceName: String
    let date: Date
    let questions: Int
    let correctAnswers: Int
    let duration: Int // en minutos
    
    var percentage: Double {
        Double(correctAnswers) / Double(questions) * 100
    }
}

struct QuizHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        QuizHistoryView()
    }
}
