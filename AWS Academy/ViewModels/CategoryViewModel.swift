
import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadCategories() {
        isLoading = true
        
        // Simulación temporal - se reemplazará con llamada a AWS
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.categories = []  // Se llenará desde AWS
            self.isLoading = false
        }
    }
    
    func loadSubcategories(for categoryId: String) {
        // Cargar subcategorías desde AWS
    }
}
