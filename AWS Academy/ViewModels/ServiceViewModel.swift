import SwiftUI

class ServiceViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var featuredServices: [Service] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadServices(for categoryId: String) {
        isLoading = true
        
        // Simulación temporal - se reemplazará con llamada a AWS
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.services = []  // Se llenará desde AWS
            self.isLoading = false
        }
    }
    
    func filteredServices(for subcategoryId: String) -> [Service] {
        if subcategoryId == "all" {
            return services
        }
        // Filtrar por subcategoría
        return services.filter { service in
            // Lógica de filtrado
            true
        }
    }
    
    func loadServiceDetail(serviceId: String) {
        // Cargar detalles completos del servicio desde AWS
    }
    
    func generateContent(for service: Service, mode: String) {
        // Llamar a AWS Bedrock para generar contenido
    }
}
