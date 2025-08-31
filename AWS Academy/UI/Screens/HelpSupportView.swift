import SwiftUI

struct HelpSupportView: View {
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory = .all
    
    enum HelpCategory: String, CaseIterable {
        case all = "Todos"
        case getStarted = "Comenzar"
        case account = "Cuenta"
        case content = "Contenido"
        case technical = "Técnico"
    }
    
    let faqItems = [
        FAQItem(
            question: "¿Cómo empiezo a estudiar para una certificación?",
            answer: "Ve a la sección de Certificación en el menú principal y selecciona tu certificación objetivo.",
            category: .getStarted
        ),
        FAQItem(
            question: "¿Puedo usar la app sin conexión?",
            answer: "Sí, puedes descargar contenido para estudiar offline desde la sección de Descargas.",
            category: .content
        ),
        FAQItem(
            question: "¿Cómo cambio mi contraseña?",
            answer: "Ve a Ajustes > Cuenta > Cambiar contraseña.",
            category: .account
        )
    ]
    
    var filteredFAQs: [FAQItem] {
        var items = faqItems
        
        if selectedCategory != .all {
            items = items.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            items = items.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // Quick actions
                    quickActionsSection
                    
                    // FAQ Section
                    faqSection
                    
                    // Contact section
                    contactSection
                }
                .padding(.vertical)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Ayuda y Soporte")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar ayuda...")
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Acciones Rápidas")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingM) {
                    QuickHelpCard(
                        icon: "book.closed",
                        title: "Guía de Inicio",
                        action: {}
                    )
                    
                    QuickHelpCard(
                        icon: "play.circle",
                        title: "Video Tutorial",
                        action: {}
                    )
                    
                    QuickHelpCard(
                        icon: "doc.text",
                        title: "Documentación",
                        action: {}
                    )
                    
                    QuickHelpCard(
                        icon: "bubble.left.and.bubble.right",
                        title: "Chat",
                        action: {}
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Preguntas Frecuentes")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.paddingS) {
                    ForEach(HelpCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // FAQ items
            VStack(spacing: Theme.paddingM) {
                ForEach(filteredFAQs) { item in
                    FAQCard(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("¿Necesitas más ayuda?")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: Theme.paddingM) {
                ContactCard(
                    icon: "envelope",
                    title: "Email",
                    subtitle: "support@awsacademy.com",
                    action: {}
                )
                
                ContactCard(
                    icon: "bubble.left",
                    title: "Chat en vivo",
                    subtitle: "Disponible 9AM - 6PM",
                    action: {}
                )
                
                ContactCard(
                    icon: "questionmark.circle",
                    title: "Centro de Ayuda",
                    subtitle: "Base de conocimientos completa",
                    action: {}
                )
            }
            .padding(.horizontal)
        }
    }
}

struct QuickHelpCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.paddingS) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Theme.awsOrange)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct FAQCard: View {
    let item: FAQItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(item.question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .padding([.horizontal, .bottom])
                    .padding(.top, -Theme.paddingS)
            }
        }
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct ContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.paddingM) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Theme.awsOrange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
        }
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let category: HelpSupportView.HelpCategory
}

struct HelpSupportView_Previews: PreviewProvider {
    static var previews: some View {
        HelpSupportView()
    }
}
