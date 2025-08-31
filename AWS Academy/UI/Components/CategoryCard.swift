
import SwiftUI

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            Image(systemName: category.icon)
                .font(.title)
                .foregroundColor(Color(hex: category.color) ?? Theme.awsOrange)
                .frame(height: 40)
            
            Text(category.name)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
            
            Text("\(category.serviceCount) servicios")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.paddingM)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

// Extension para hex colors
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        
        if length == 6 {
            let r = Double((rgb & 0xFF0000) >> 16) / 255.0
            let g = Double((rgb & 0x00FF00) >> 8) / 255.0
            let b = Double(rgb & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else {
            return nil
        }
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(category: Category(
            name: "Compute",
            description: "Servicios de cómputo",
            icon: "cpu",
            color: "#FF9900",
            serviceCount: 12
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
