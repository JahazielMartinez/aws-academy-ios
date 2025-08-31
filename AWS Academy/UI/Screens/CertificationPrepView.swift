import SwiftUI

struct CertificationPrepDetailView: View {
    @State private var selectedCertification = "cloud-practitioner"
    @State private var showingPracticeExam = false
    @State private var examProgress: ExamProgress = ExamProgress()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Certification selector
                    certificationSelector
                    
                    // Progress overview
                    progressOverview
                    
                    // Study sections
                    studySections
                    
                    // Practice exams
                    practiceExamsSection
                    
                    // Resources
                    resourcesSection
                }
                .padding(.vertical, Theme.paddingM)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Preparación de Certificación")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var certificationSelector: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Certificación objetivo")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    CertCardItem(
                        id: "cloud-practitioner",
                        name: "Cloud Practitioner",
                        level: "Foundational",
                        isSelected: selectedCertification == "cloud-practitioner",
                        action: { selectedCertification = "cloud-practitioner" }
                    )
                    
                    CertCardItem(
                        id: "solutions-architect",
                        name: "Solutions Architect",
                        level: "Associate",
                        isSelected: selectedCertification == "solutions-architect",
                        action: { selectedCertification = "solutions-architect" }
                    )
                    
                    CertCardItem(
                        id: "developer",
                        name: "Developer",
                        level: "Associate",
                        isSelected: selectedCertification == "developer",
                        action: { selectedCertification = "developer" }
                    )
                }
            }
        }
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var progressOverview: some View {
        VStack(spacing: Theme.paddingM) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tu preparación")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("AWS Cloud Practitioner")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.2)
                        .foregroundColor(Theme.awsOrange)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(examProgress.readiness / 100))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(Theme.awsOrange)
                        .rotationEffect(Angle(degrees: 270))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(examProgress.readiness))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("Listo")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .frame(width: 80, height: 80)
            }
            
            HStack(spacing: Theme.paddingM) {
                PrepStatCard(
                    title: "Dominios",
                    value: "\(examProgress.domainsCompleted)/4",
                    icon: "checkmark.shield.fill",
                    color: .green
                )
                
                PrepStatCard(
                    title: "Práctica",
                    value: "\(examProgress.practiceExamsTaken)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                PrepStatCard(
                    title: "Promedio",
                    value: "\(examProgress.averageScore)%",
                    icon: "chart.bar.fill",
                    color: Theme.awsOrange
                )
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var studySections: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Dominios del examen")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            VStack(spacing: Theme.paddingM) {
                DomainCard(
                    domain: "Cloud Concepts",
                    weight: "26%",
                    progress: 75,
                    topics: 12
                )
                
                DomainCard(
                    domain: "Security and Compliance",
                    weight: "25%",
                    progress: 60,
                    topics: 15
                )
                
                DomainCard(
                    domain: "Technology",
                    weight: "33%",
                    progress: 45,
                    topics: 20
                )
                
                DomainCard(
                    domain: "Billing and Pricing",
                    weight: "16%",
                    progress: 80,
                    topics: 8
                )
            }
            .padding(.horizontal, Theme.paddingM)
        }
    }
    
    private var practiceExamsSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack {
                Text("Exámenes de práctica")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button(action: { showingPracticeExam = true }) {
                    Text("Comenzar")
                        .font(.subheadline)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            .padding(.horizontal, Theme.paddingM)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    PracticeExamCard(
                        title: "Examen Completo",
                        questions: 65,
                        time: 90,
                        bestScore: nil
                    )
                    
                    PracticeExamCard(
                        title: "Quiz Rápido",
                        questions: 20,
                        time: 30,
                        bestScore: 85
                    )
                    
                    PracticeExamCard(
                        title: "Por Dominio",
                        questions: 15,
                        time: 20,
                        bestScore: 72
                    )
                }
                .padding(.horizontal, Theme.paddingM)
            }
        }
    }
    
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Recursos")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            VStack(spacing: Theme.paddingS) {
                ResourceRow(
                    icon: "book.fill",
                    title: "Guía oficial del examen",
                    description: "Documento PDF de AWS"
                )
                
                ResourceRow(
                    icon: "video.fill",
                    title: "Videos recomendados",
                    description: "12 videos de preparación"
                )
                
                ResourceRow(
                    icon: "doc.richtext.fill",
                    title: "Notas de estudio",
                    description: "Resúmenes por dominio"
                )
            }
            .padding(.horizontal, Theme.paddingM)
        }
    }
}

struct CertCardItem: View {
    let id: String
    let name: String
    let level: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.paddingS) {
                Image(systemName: "medal.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Theme.awsOrange)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Theme.textPrimary)
                
                Text(level)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.textSecondary)
            }
            .frame(width: 120, height: 100)
            .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct PrepStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DomainCard: View {
    let domain: String
    let weight: String
    let progress: Double
    let topics: Int
    
    var body: some View {
        NavigationLink(destination: DomainDetailView(domain: domain)) {
            VStack(spacing: Theme.paddingM) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(domain)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.textPrimary)
                        
                        HStack {
                            Text("Peso: \(weight)")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            Text("•")
                                .foregroundColor(Theme.textTertiary)
                            
                            Text("\(topics) temas")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor(progress))
                }
                
                ProgressView(value: progress / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor(progress)))
            }
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
    
    private func progressColor(_ progress: Double) -> Color {
        switch progress {
        case 80...100:
            return .green
        case 50..<80:
            return Theme.awsOrange
        default:
            return .red
        }
    }
}

struct PracticeExamCard: View {
    let title: String
    let questions: Int
    let time: Int
    let bestScore: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Label("\(questions) preguntas", systemImage: "questionmark.circle")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Label("\(time) minutos", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            if let score = bestScore {
                HStack {
                    Text("Mejor: \(score)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.awsOrange)
                    
                    Spacer()
                    
                    Text("Reintentar")
                        .font(.caption)
                        .foregroundColor(Theme.awsOrange)
                }
            } else {
                Button(action: {}) {
                    Text("Comenzar")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Theme.awsOrange)
                        .cornerRadius(6)
                }
            }
        }
        .frame(width: 150)
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ResourceRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.awsOrange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.textTertiary)
        }
        .padding(.vertical, Theme.paddingS)
    }
}

struct ExamProgress {
    var readiness: Double = 65
    var domainsCompleted: Int = 2
    var practiceExamsTaken: Int = 3
    var averageScore: Int = 72
}

struct DomainDetailView: View {
    let domain: String
    
    var body: some View {
        Text("Detalles del dominio: \(domain)")
            .navigationTitle(domain)
    }
}

// Vista simple para el acceso rápido desde Home
struct CertificationPrepView: View {
    var body: some View {
        CertificationPrepDetailView()
    }
}

struct CertificationPrepDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CertificationPrepDetailView()
    }
}
