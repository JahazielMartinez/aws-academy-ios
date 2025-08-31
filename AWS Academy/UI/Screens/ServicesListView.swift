import SwiftUI

struct ServicesListView: View {
    @StateObject private var viewModel = ServiceViewModel()
    @State private var searchText = ""
    @State private var selectedCategory = "all"
    @State private var selectedDifficulty: Service.Difficulty?
    @State private var showingFilters = false
    
    var filteredServices: [Service] {
        var services = viewModel.services
        
        if !searchText.isEmpty {
            services = services.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedCategory != "all" {
            services = services.filter { $0.category == selectedCategory }
        }
        
        if let difficulty = selectedDifficulty {
            services = services.filter { $0.difficulty == difficulty }
        }
        
        return services
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters bar
                if showingFilters {
                    filtersBar
                }
                
                // Services list
                ScrollView {
                    if filteredServices.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No se encontraron servicios",
                            message: "Intenta ajustar los filtros o buscar otro término"
                        )
                        .padding(.top, 100)
                    } else {
                        LazyVStack(spacing: Theme.paddingM) {
                            ForEach(filteredServices) { service in
                                NavigationLink(destination: ServiceDetailView(service: service)) {
                                    ServiceCard(service: service)
                                }
                            }
                        }
                        .padding(Theme.paddingM)
                    }
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Todos los Servicios")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar servicios...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: showingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(Theme.awsOrange)
                    }
                }
            }
            .onAppear {
                viewModel.loadServices(for: "all")
            }
        }
    }
    
    private var filtersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.paddingS) {
                // Category filter
                Menu {
                    Button("Todas", action: { selectedCategory = "all" })
                    Divider()
                    ForEach(["Compute", "Storage", "Database", "Networking", "Security"], id: \.self) { category in
                        Button(category, action: { selectedCategory = category })
                    }
                } label: {
                    FilterChipLabel(
                        title: selectedCategory == "all" ? "Categoría" : selectedCategory,
                        isActive: selectedCategory != "all"
                    )
                }
                
                // Difficulty filter
                Menu {
                    Button("Todas", action: { selectedDifficulty = nil })
                    Divider()
                    ForEach(Service.Difficulty.allCases, id: \.self) { difficulty in
                        Button(difficulty.rawValue, action: { selectedDifficulty = difficulty })
                    }
                } label: {
                    FilterChipLabel(
                        title: selectedDifficulty?.rawValue ?? "Dificultad",
                        isActive: selectedDifficulty != nil
                    )
                }
                
                // Clear filters
                if selectedCategory != "all" || selectedDifficulty != nil {
                    Button(action: clearFilters) {
                        Label("Limpiar", systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, Theme.paddingM)
            .padding(.vertical, Theme.paddingS)
        }
        .background(Theme.secondaryBackground)
    }
    
    private func clearFilters() {
        selectedCategory = "all"
        selectedDifficulty = nil
    }
}

struct FilterChipLabel: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Image(systemName: "chevron.down")
                .font(.caption)
        }
        .font(.subheadline)
        .foregroundColor(isActive ? .white : Theme.textPrimary)
        .padding(.horizontal, Theme.paddingM)
        .padding(.vertical, Theme.paddingS)
        .background(isActive ? Theme.awsOrange : Theme.tertiaryBackground)
        .cornerRadius(Theme.cornerRadiusS)
    }
}

struct ServicesListView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesListView()
    }
}
