import SwiftUI

struct FlashcardsView: View {
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var flashcards: [FlashcardModel] = []
    @State private var selectedCategory = "all"
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.paddingL) {
                // Progress
                HStack {
                    Text("\(currentIndex + 1) / \(flashcards.count)")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    
                    Spacer()
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Theme.awsOrange)
                    }
                }
                .padding(.horizontal, Theme.paddingL)
                
                // Flashcard
                if !flashcards.isEmpty && currentIndex < flashcards.count {
                    FlashcardItem(
                        flashcard: flashcards[currentIndex],
                        isFlipped: $isFlipped,
                        offset: $offset,
                        onSwipeLeft: markAsIncorrect,
                        onSwipeRight: markAsCorrect
                    )
                } else {
                    EmptyStateView(
                        icon: "rectangle.stack",
                        title: "Sin tarjetas",
                        message: "No hay tarjetas disponibles en esta categoría"
                    )
                }
                
                // Controls
                HStack(spacing: Theme.paddingXL) {
                    Button(action: markAsIncorrect) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: { isFlipped.toggle() }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.awsOrange)
                    }
                    
                    Button(action: markAsCorrect) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, Theme.paddingXL)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Tarjetas de Estudio")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                FlashcardSettingsView(selectedCategory: $selectedCategory)
            }
            .onAppear {
                loadFlashcards()
            }
        }
    }
    
    private func loadFlashcards() {
        // Cargar desde AWS
        flashcards = [
            FlashcardModel(
                id: "1",
                question: "¿Qué es EC2?",
                answer: "Amazon Elastic Compute Cloud - Servidores virtuales escalables en la nube",
                category: "Compute",
                difficulty: .basic
            )
        ]
    }
    
    private func markAsCorrect() {
        moveToNext()
    }
    
    private func markAsIncorrect() {
        moveToNext()
    }
    
    private func moveToNext() {
        if currentIndex < flashcards.count - 1 {
            currentIndex += 1
            isFlipped = false
        }
    }
}

struct FlashcardItem: View {
    let flashcard: FlashcardModel
    @Binding var isFlipped: Bool
    @Binding var offset: CGSize
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusL)
                .fill(Theme.secondaryBackground)
                .shadow(radius: 10)
            
            VStack(spacing: Theme.paddingL) {
                Text(isFlipped ? "Respuesta" : "Pregunta")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text(isFlipped ? flashcard.answer : flashcard.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                HStack {
                    Label(flashcard.category, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    Spacer()
                    
                    Text(flashcard.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(height: 400)
        .padding(.horizontal, Theme.paddingL)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 10)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        if value.translation.width > 0 {
                            onSwipeRight()
                        } else {
                            onSwipeLeft()
                        }
                    }
                    withAnimation(.spring()) {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
    }
}

struct FlashcardSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: String
    @State private var shuffleCards = true
    @State private var showAnswer = false
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Categoría", selection: $selectedCategory) {
                    Text("Todas").tag("all")
                    Text("Compute").tag("compute")
                    Text("Storage").tag("storage")
                    Text("Database").tag("database")
                }
                
                Toggle("Mezclar tarjetas", isOn: $shuffleCards)
                Toggle("Mostrar respuesta primero", isOn: $showAnswer)
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FlashcardModel: Identifiable {
    let id: String
    let question: String
    let answer: String
    let category: String
    let difficulty: Service.Difficulty
}

struct FlashcardsView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardsView()
    }
}
