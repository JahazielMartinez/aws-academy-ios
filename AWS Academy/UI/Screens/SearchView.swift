import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedScope: SearchScope = .all
    @State private var recentSearches: [String] = []
    @State private var searchResults: SearchResults = SearchResults()
    @State private var isSearching = false
    
    enum SearchScope: String, CaseIterable {
        case all = "Todo"
        case services = "Servicios"
        case concepts = "Conceptos"
        case quizzes = "Quizzes"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar with scope
                VStack(spacing: Theme.paddingS) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.textSecondary)
                        
                        TextField("Buscar en AWS Academy...", text: $searchText)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Theme.secondaryBackground)
                    .cornerRadius(Theme.cornerRadiusM)
                    
                    Picker("Scope", selection: $selectedScope) {
                        ForEach(SearchScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Theme.backgroundColor)
                
                // Content
                if searchText.isEmpty {
                    recentSearchesView
                } else if isSearching {
                    ProgressView("Buscando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadRecentSearches()
        }
    }
    
    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.paddingL) {
                // Recent searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.paddingM) {
                        HStack {
                            Text("Búsquedas recientes")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Button("Limpiar") {
                                recentSearches.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(Theme.awsOrange)
                        }
                        
                        ForEach(recentSearches, id: \.self) { search in
                            Button(action: {
                                searchText = search
                                performSearch()
                            }) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                    
                                    Text(search)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textPrimary)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                // Popular searches
                VStack(alignment: .leading, spacing: Theme.paddingM) {
                    Text("Búsquedas populares")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Theme.paddingS) {
                        ForEach(["EC2", "S3", "Lambda", "DynamoDB", "VPC", "IAM"], id: \.self) { term in
                            Button(action: {
                                searchText = term
                                performSearch()
                            }) {
                                Text(term)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Theme.paddingS)
                                    .background(Theme.secondaryBackground)
                                    .cornerRadius(Theme.cornerRadiusS)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var searchResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.paddingL) {
                // Services results
                if !searchResults.services.isEmpty {
                    ResultSection(
                        title: "Servicios",
                        count: searchResults.services.count
                    ) {
                        ForEach(searchResults.services) { service in
                            NavigationLink(destination: ServiceDetailView(service: service)) {
                                ServiceSearchRow(service: service)
                            }
                        }
                    }
                }
                
                // Concepts results
                if !searchResults.concepts.isEmpty {
                    ResultSection(
                        title: "Conceptos",
                        count: searchResults.concepts.count
                    ) {
                        ForEach(searchResults.concepts) { concept in
                            ConceptSearchRow(concept: concept)
                        }
                    }
                }
                
                // Quizzes results
                if !searchResults.quizzes.isEmpty {
                    ResultSection(
                        title: "Quizzes",
                        count: searchResults.quizzes.count
                    ) {
                        ForEach(searchResults.quizzes) { quiz in
                            QuizSearchRow(quiz: quiz)
                        }
                    }
                }
                
                // No results
                if searchResults.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "Sin resultados",
                        message: "Intenta con otros términos de búsqueda"
                    )
                    .padding(.top, 100)
                }
            }
            .padding()
        }
    }
    
    private func performSearch() {
        isSearching = true
        
        // Agregar a búsquedas recientes
        if !searchText.isEmpty && !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
        }
        
        // Simular búsqueda
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Aquí se haría la búsqueda real en AWS
            searchResults = SearchResults()
            isSearching = false
        }
    }
    
    private func loadRecentSearches() {
        // Cargar búsquedas recientes
        recentSearches = ["EC2", "Lambda", "S3 Buckets"]
    }
}

struct ResultSection<Content: View>: View {
    let title: String
    let count: Int
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text("(\(count))")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            
            content()
        }
    }
}

struct ServiceSearchRow: View {
    let service: Service
    
    var body: some View {
        HStack {
            Image(systemName: service.icon)
                .foregroundColor(Theme.awsOrange)
            
            VStack(alignment: .leading) {
                Text(service.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                Text(service.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.textTertiary)
        }
        .padding(.vertical, 4)
    }
}

struct ConceptSearchRow: View {
    let concept: Concept
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading) {
                Text(concept.title)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                Text(concept.category)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct QuizSearchRow: View {
    let quiz: QuizItem
    
    var body: some View {
        HStack {
            Image(systemName: "questionmark.circle")
                .foregroundColor(.purple)
            
            VStack(alignment: .leading) {
                Text(quiz.title)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                Text("\(quiz.questionCount) preguntas")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SearchResults {
    var services: [Service] = []
    var concepts: [Concept] = []
    var quizzes: [QuizItem] = []
    
    var isEmpty: Bool {
        services.isEmpty && concepts.isEmpty && quizzes.isEmpty
    }
}

struct Concept: Identifiable {
    let id = UUID()
    let title: String
    let category: String
}

struct QuizItem: Identifiable {
    let id = UUID()
    let title: String
    let questionCount: Int
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
