import SwiftUI

struct SubcategoriesView: View {
    let category: Category
    @StateObject private var viewModel = ServiceViewModel()
    @State private var selectedSubcategory: String = "all"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Header de categoría
                    CategoryHeader(category: category)
                    
                    // Filtro de subcategorías si existen
                    if let subcategories = category.subcategories, !subcategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.paddingS) {
                                FilterChip(
                                    title: "Todos",
                                    isSelected: selectedSubcategory == "all",
                                    action: { selectedSubcategory = "all" }
                                )
                                
                                ForEach(subcategories) { subcategory in
                                    FilterChip(
                                        title: subcategory.name,
                                        isSelected: selectedSubcategory == subcategory.id,
                                        action: { selectedSubcategory = subcategory.id }
                                    )
                                }
                            }
                            .padding(.horizontal, Theme.paddingM)
                        }
                    }
                    
                    // Lista de servicios
                    VStack(spacing: Theme.paddingM) {
                        if viewModel.services.isEmpty {
                            EmptyStateView(
                                icon: "tray",
                                title: "Sin servicios",
                                message: "Los servicios se cargarán desde AWS"
                            )
                            .padding(.top, 50)
                        } else {
                            ForEach(viewModel.filteredServices(for: selectedSubcategory)) { service in
                                NavigationLink(destination: ServiceDetailView(service: service)) {
                                    ServiceCard(service: service)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.paddingM)
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadServices(for: category.id)
            }
        }
    }
}

struct CategoryHeader: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            Image(systemName: category.icon)
                .font(.system(size: 50))
                .foregroundColor(Color(hex: category.color) ?? Theme.awsOrange)
            
            VStack(alignment: .leading, spacing: Theme.paddingXS) {
                Text(category.description)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                
                Text("\(category.serviceCount) servicios disponibles")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, Theme.paddingM)
        .padding(.vertical, Theme.paddingS)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .white : Theme.textPrimary)
                .padding(.horizontal, Theme.paddingM)
                .padding(.vertical, Theme.paddingS)
                .background(isSelected ? Theme.awsOrange : Theme.secondaryBackground)
                .cornerRadius(Theme.cornerRadiusS)
        }
    }
}

struct SubcategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        SubcategoriesView(category: Category(
            name: "Compute",
            description: "Servicios de cómputo en la nube",
            icon: "cpu",
            color: "#FF9900",
            serviceCount: 15
        ))
    }
}
