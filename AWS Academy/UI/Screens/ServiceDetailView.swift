import SwiftUI

struct ServiceDetailView: View {
    let service: Service
    @State private var selectedMode: ContentMode = .basic
    @State private var showingQuiz = false
    @State private var isBookmarked = false
    @State private var currentLayer = 1
    
    enum ContentMode: String, CaseIterable {
        case basic = "Básico"
        case advanced = "Avanzado"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Header del servicio
                    ServiceHeader(service: service)
                    
                    // Selector de modo
                    Picker("Modo", selection: $selectedMode) {
                        ForEach(ContentMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Theme.paddingM)
                    
                    // Contenido según el modo
                    if selectedMode == .basic {
                        BasicContentView(service: service)
                    } else {
                        AdvancedContentView(
                            service: service,
                            currentLayer: $currentLayer
                        )
                    }
                    
                    // Botón de Quiz
                    NavigationLink(destination: QuizQuestionView(service: service)) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                            Text("Tomar Quiz")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.awsOrange)
                        .cornerRadius(Theme.cornerRadiusM)
                    }
                    .padding(.horizontal, Theme.paddingM)
                    .padding(.bottom, Theme.paddingL)
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle(service.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isBookmarked.toggle() }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(Theme.awsOrange)
                    }
                }
            }
        }
    }
}

struct ServiceHeader: View {
    let service: Service
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack(alignment: .top, spacing: Theme.paddingM) {
                Image(systemName: service.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Theme.awsOrange)
                
                VStack(alignment: .leading, spacing: Theme.paddingS) {
                    Text(service.fullName)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    
                    HStack(spacing: Theme.paddingM) {
                        Label("\(service.estimatedMinutes) min", systemImage: "clock")
                            .font(.caption)
                        
                        Label(service.difficulty.rawValue, systemImage: "chart.bar")
                            .font(.caption)
                    }
                    .foregroundColor(Theme.textTertiary)
                }
                
                Spacer()
            }
            
            if service.completionPercentage > 0 {
                VStack(alignment: .leading, spacing: Theme.paddingXS) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text("\(Int(service.completionPercentage))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.awsOrange)
                    }
                    
                    ProgressView(value: service.completionPercentage / 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Theme.awsOrange))
                }
            }
        }
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal, Theme.paddingM)
    }
}

struct BasicContentView: View {
    let service: Service
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // Contenido básico (se llenará desde AWS)
            ContentSection(
                title: "📚 Concepto",
                content: "Contenido se cargará desde AWS",
                icon: "book.fill"
            )
            
            ContentSection(
                title: "🧠 Analogía",
                content: "Contenido se cargará desde AWS",
                icon: "brain"
            )
            
            ContentSection(
                title: "🧪 Ejemplo",
                content: "Contenido se cargará desde AWS",
                icon: "flask.fill"
            )
            
            ContentSection(
                title: "🎯 Objetivo",
                content: "Contenido se cargará desde AWS",
                icon: "target"
            )
            
            FlashcardSection()
        }
        .padding(.horizontal, Theme.paddingM)
    }
}

struct AdvancedContentView: View {
    let service: Service
    @Binding var currentLayer: Int
    
    let layers = [
        "Concepto / Definición",
        "Teoría y fundamentos",
        "Práctica y uso real",
        "Alcances",
        "Límites y restricciones",
        "Costos y pricing",
        "Buenas prácticas",
        "Comparaciones",
        "Integraciones",
        "Casos de éxito",
        "Troubleshooting",
        "Profundidad técnica"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            // Selector de capa
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingS) {
                    ForEach(1...12, id: \.self) { layer in
                        LayerChip(
                            number: layer,
                            title: layers[layer - 1],
                            isSelected: currentLayer == layer,
                            action: { currentLayer = layer }
                        )
                    }
                }
                .padding(.horizontal, Theme.paddingM)
            }
            
            // Contenido de la capa
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                Text("Capa \(currentLayer): \(layers[currentLayer - 1])")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text("El contenido se cargará desde AWS Bedrock")
                    .font(.body)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(Theme.paddingM)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .padding(.horizontal, Theme.paddingM)
        }
    }
}

struct ContentSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.awsOrange)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .padding(Theme.paddingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.tertiaryBackground)
                .cornerRadius(Theme.cornerRadiusS)
        }
    }
}

struct FlashcardSection: View {
    @State private var isFlipped = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundColor(Theme.awsOrange)
                Text("🗂 Flashcard")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .fill(Theme.secondaryBackground)
                    .frame(height: 150)
                
                VStack(spacing: Theme.paddingM) {
                    Text(isFlipped ? "A:" : "Q:")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    Text(isFlipped ? "Respuesta desde AWS" : "Pregunta desde AWS")
                        .font(.body)
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    isFlipped.toggle()
                }
            }
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
    }
}

struct LayerChip: View {
    let number: Int
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : Theme.awsOrange)
                    .frame(width: 24, height: 24)
                    .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
        }
    }
}

struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailView(service: Service(
            name: "EC2",
            fullName: "Elastic Compute Cloud",
            description: "Servidores virtuales escalables en la nube",
            icon: "server.rack",
            difficulty: .intermediate,
            estimatedMinutes: 30,
            completionPercentage: 45
        ))
    }
}
