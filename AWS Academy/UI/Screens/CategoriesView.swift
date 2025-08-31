import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var searchText = ""
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if viewModel.categories.isEmpty {
                    EmptyStateView(
                        icon: "cloud",
                        title: "Sin categorías",
                        message: "Las categorías se cargarán desde AWS"
                    )
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Theme.paddingM) {
                        ForEach(filteredCategories) { category in
                            NavigationLink(destination: SubcategoriesView(category: category)) {
                                CategoryDetailCard(category: category)
                            }
                        }
                    }
                    .padding(Theme.paddingM)
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Categorías AWS")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar categorías")
            .onAppear {
                viewModel.loadCategories()
            }
        }
    }
}

struct CategoryDetailCard: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            VStack(alignment: .center, spacing: Theme.paddingS) {
                Image(systemName: category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: category.color) ?? Theme.awsOrange)
                
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .font(.caption2)
                    Text("\(category.serviceCount) servicios")
                        .font(.caption2)
                }
                .foregroundColor(Theme.textTertiary)
            }
        }
        .padding(Theme.paddingM)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
