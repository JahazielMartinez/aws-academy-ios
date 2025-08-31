import SwiftUI

struct LearningPathDetailView: View {
    @State private var selectedPath: LearningPath?
    @State private var currentStep: Int = 0
    @State private var completedSteps: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Header
                    pathHeader
                    
                    // Current certification goal
                    certificationGoalCard
                    
                    // Learning path
                    pathTimeline
                    
                    // Recommended next steps
                    recommendedSection
                }
                .padding(.vertical, Theme.paddingM)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Mi Ruta de Aprendizaje")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadLearningPath()
            }
        }
    }
    
    private var pathHeader: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Tu camino personalizado hacia AWS")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            HStack {
                ProgressView(value: Double(completedSteps.count), total: 12)
                    .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
                
                Text("\(completedSteps.count)/12")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var certificationGoalCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.paddingS) {
                Label("Meta actual", systemImage: "trophy.fill")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Text("AWS Cloud Practitioner")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Tiempo estimado: 3 meses")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Cambiar")
                    .font(.caption)
                    .foregroundColor(Theme.awsOrange)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var pathTimeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tu ruta")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
                .padding(.bottom, Theme.paddingM)
            
            ForEach(0..<12, id: \.self) { index in
                PathStepRow(
                    step: PathStep(
                        id: index,
                        title: "Paso \(index + 1)",
                        description: "Descripción del paso",
                        services: ["EC2", "S3"],
                        estimatedHours: 5,
                        isCompleted: completedSteps.contains(index),
                        isCurrent: index == currentStep
                    ),
                    isLast: index == 11
                )
            }
        }
    }
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Recomendado para ti")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    ForEach(0..<3) { index in
                        RecommendedCard(
                            title: "Servicio Recomendado \(index + 1)",
                            reason: "Basado en tu progreso",
                            icon: "star.fill",
                            color: Theme.awsOrange
                        )
                    }
                }
                .padding(.horizontal, Theme.paddingM)
            }
        }
    }
    
    private func loadLearningPath() {
        // Cargar ruta desde AWS
        completedSteps = [0, 1, 2]
        currentStep = 3
    }
}

struct PathStepRow: View {
    let step: PathStep
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.paddingM) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(step.isCompleted ? Color.green : (step.isCurrent ? Theme.awsOrange : Theme.tertiaryBackground))
                        .frame(width: 32, height: 32)
                    
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else if step.isCurrent {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(step.isCompleted ? Color.green.opacity(0.3) : Theme.tertiaryBackground)
                        .frame(width: 2, height: 80)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: Theme.paddingS) {
                HStack {
                    Text(step.title)
                        .font(.subheadline)
                        .fontWeight(step.isCurrent ? .bold : .medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    if step.isCurrent {
                        Text("ACTUAL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.awsOrange)
                            .cornerRadius(4)
                    }
                }
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                HStack {
                    ForEach(step.services, id: \.self) { service in
                        Text(service)
                            .font(.caption2)
                            .foregroundColor(Theme.awsOrange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.awsOrange.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Text("\(step.estimatedHours)h")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
            }
            .padding(.bottom, Theme.paddingM)
            
            Spacer()
        }
        .padding(.horizontal, Theme.paddingM)
        .opacity(step.isCompleted ? 0.7 : 1.0)
    }
}

struct PathStep {
    let id: Int
    let title: String
    let description: String
    let services: [String]
    let estimatedHours: Int
    let isCompleted: Bool
    let isCurrent: Bool
}

struct LearningPath {
    let id: String
    let name: String
    let certification: String
    let steps: [PathStep]
    let totalHours: Int
    let estimatedWeeks: Int
}

struct RecommendedCard: View {
    let title: String
    let reason: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
            
            Text(reason)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(width: 150)
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

// Vista simple para el acceso rápido desde Home
struct LearningPathView: View {
    var body: some View {
        LearningPathDetailView()
    }
}

struct LearningPathDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LearningPathDetailView()
    }
}
