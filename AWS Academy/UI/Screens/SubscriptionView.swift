import SwiftUI

struct SubscriptionView: View {
    @State private var selectedPlan: SubscriptionPlan = .free
    @State private var showingPayment = false
    
    enum SubscriptionPlan: String, CaseIterable {
        case free = "Gratis"
        case pro = "Pro"
        case premium = "Premium"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.paddingL) {
                    // Current plan
                    CurrentPlanCard()
                    
                    // Available plans
                    VStack(spacing: Theme.paddingM) {
                        PlanCard(
                            plan: .free,
                            title: "Plan Gratis",
                            price: "$0",
                            features: [
                                "Acceso básico a contenido",
                                "5 quizzes al día",
                                "Progreso limitado"
                            ],
                            isSelected: selectedPlan == .free,
                            action: { selectedPlan = .free }
                        )
                        
                        PlanCard(
                            plan: .pro,
                            title: "Plan Pro",
                            price: "$9.99/mes",
                            features: [
                                "Todo el contenido",
                                "Quizzes ilimitados",
                                "Certificados de práctica",
                                "Soporte prioritario"
                            ],
                            isSelected: selectedPlan == .pro,
                            isRecommended: true,
                            action: { selectedPlan = .pro }
                        )
                        
                        PlanCard(
                            plan: .premium,
                            title: "Plan Premium",
                            price: "$19.99/mes",
                            features: [
                                "Todo Pro incluido",
                                "Mentorías 1:1",
                                "Acceso anticipado",
                                "Contenido exclusivo",
                                "Grupos privados"
                            ],
                            isSelected: selectedPlan == .premium,
                            action: { selectedPlan = .premium }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Subscribe button
                    if selectedPlan != .free {
                        Button(action: { showingPayment = true }) {
                            Text("Actualizar Plan")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.awsOrange)
                                .cornerRadius(Theme.cornerRadiusM)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Benefits comparison
                    ComparisonTableView()
                }
                .padding(.vertical)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Planes y Precios")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPayment) {
                PaymentView()
            }
        }
    }
}

struct CurrentPlanCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Tu Plan Actual")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plan Gratis")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Activo desde Enero 2025")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$0")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.awsOrange)
                    
                    Text("/mes")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal)
    }
}

struct PlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let title: String
    let price: String
    let features: [String]
    let isSelected: Bool
    var isRecommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                if isRecommended {
                    Text("MÁS POPULAR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.awsOrange)
                        .cornerRadius(4)
                }
                
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Spacer()
                    
                    Text(price)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.awsOrange)
                }
                
                VStack(alignment: .leading, spacing: Theme.paddingS) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: Theme.paddingS) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text(feature)
                                .font(.subheadline)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                }
            }
            .padding()
            .background(Theme.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                    .stroke(isSelected ? Theme.awsOrange : Color.clear, lineWidth: 2)
            )
            .cornerRadius(Theme.cornerRadiusM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ComparisonTableView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingM) {
            Text("Comparación de Planes")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ComparisonRow(feature: "Contenido básico", free: true, pro: true, premium: true)
                Divider()
                ComparisonRow(feature: "Quizzes diarios", free: "5", pro: "∞", premium: "∞")
                Divider()
                ComparisonRow(feature: "Certificados", free: false, pro: true, premium: true)
                Divider()
                ComparisonRow(feature: "Mentoría", free: false, pro: false, premium: true)
                Divider()
                ComparisonRow(feature: "Grupos privados", free: false, pro: false, premium: true)
            }
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadiusM)
            .padding(.horizontal)
        }
    }
}

struct ComparisonRow: View {
    let feature: String
    let free: Any
    let pro: Any
    let premium: Any
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ComparisonCell(value: free)
            ComparisonCell(value: pro)
            ComparisonCell(value: premium)
        }
        .padding()
    }
    
    struct ComparisonCell: View {
        let value: Any
        
        var body: some View {
            Group {
                if let bool = value as? Bool {
                    Image(systemName: bool ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(bool ? .green : .red)
                } else if let text = value as? String {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .frame(width: 50)
        }
    }
}

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Proceso de pago")
                    .font(.largeTitle)
                    .padding()
                
                Text("Aquí se integraría el sistema de pagos")
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
            }
            .navigationTitle("Pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
