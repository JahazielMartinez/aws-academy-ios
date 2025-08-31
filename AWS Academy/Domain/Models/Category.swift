import Foundation

struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var icon: String
    var color: String
    var subcategories: [Subcategory]?
    var serviceCount: Int
    
    init(id: String = UUID().uuidString,
         name: String = "",
         description: String = "",
         icon: String = "cloud.fill",
         color: String = "#FF9900",
         subcategories: [Subcategory]? = nil,
         serviceCount: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.subcategories = subcategories
        self.serviceCount = serviceCount
    }
}

struct Subcategory: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var services: [String] // IDs de servicios
}
