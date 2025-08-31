import SwiftUI

struct ProgressByCategoryView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var selectedCategory: UUID? = nil
    @State private var sortOption: SortOption = .progress
    
    enum SortOption: String, CaseIterable {
        case progress = "Progreso"
        case name = "Nombre"
        case time = "Tiempo"
    }
    
    var body: some View {
        NavigationStack {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            contentStack
        }
        .background(Theme.backgroundColor)
        .navigationTitle("Progreso por Categoría")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadCategoryProgress()
        }
    }
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: Theme.paddingL) {
            summarySection
            sortSection
            categoriesSection
        }
        .padding(.vertical, Theme.paddingM)
    }
    
    private var summarySection: some View {
        OverallProgressSummary(viewModel: viewModel)
    }
    
    private var sortSection: some View {
        HStack {
            Text("Ordenar por:")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            sortPicker
        }
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var sortPicker: some View {
        Picker("Ordenar", selection: $sortOption) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    private var categoriesSection: some View {
        VStack(spacing: Theme.paddingM) {
            categoryCards
        }
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var categoryCards: some View {
        ForEach(viewModel.sortedCategories(by: sortOption)) { category in
            categoryCard(for: category)
        }
    }
    
    private func categoryCard(for category: CategoryProgress) -> some View {
        ExpandableCategoryCard(
            category: category,
            isExpanded: selectedCategory == category.id,
            onTap: {
                handleCategoryTap(category.id)
            }
        )
    }
    
    private func handleCategoryTap(_ categoryId: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedCategory == categoryId {
                selectedCategory = nil
            } else {
                selectedCategory = categoryId
            }
        }
    }
}

struct OverallProgressSummary: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        mainContainer
    }
    
    private var mainContainer: some View {
        VStack(spacing: Theme.paddingM) {
            progressCircle
            statsRow
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.paddingL)
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
        .padding(.horizontal, Theme.paddingM)
    }
    
    private var progressCircle: some View {
        ZStack {
            backgroundCircle
            progressArc
            centerText
        }
        .frame(width: 120, height: 120)
    }
    
    private var backgroundCircle: some View {
        Circle()
            .stroke(lineWidth: 12)
            .opacity(0.1)
            .foregroundColor(Theme.awsOrange)
    }
    
    private var progressArc: some View {
        Circle()
            .trim(from: 0.0, to: progressValue)
            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
            .foregroundColor(Theme.awsOrange)
            .rotationEffect(Angle(degrees: 270))
            .animation(.easeInOut(duration: 0.5), value: viewModel.overallProgress)
    }
    
    private var progressValue: CGFloat {
        CGFloat(min(viewModel.overallProgress / 100.0, 1.0))
    }
    
    private var centerText: some View {
        VStack(spacing: 4) {
            Text("\(Int(viewModel.overallProgress))%")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            
            Text("Completado")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: Theme.paddingXL) {
            serviceStat
            categoryStat
            timeStat
        }
    }
    
    private var serviceStat: some View {
        ProgressStatItem(
            value: "\(viewModel.totalServicesCompleted)",
            label: "Servicios"
        )
    }
    
    private var categoryStat: some View {
        ProgressStatItem(
            value: "\(viewModel.totalCategories)",
            label: "Categorías"
        )
    }
    
    private var timeStat: some View {
        ProgressStatItem(
            value: "\(viewModel.totalHours)h",
            label: "Estudiadas"
        )
    }
}

struct ProgressStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            valueText
            labelText
        }
    }
    
    private var valueText: some View {
        Text(value)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Theme.textPrimary)
    }
    
    private var labelText: some View {
        Text(label)
            .font(.caption)
            .foregroundColor(Theme.textSecondary)
    }
}


struct ExpandableCategoryCard: View {
    let category: CategoryProgress
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        cardContainer
    }
    
    private var cardContainer: some View {
        VStack(spacing: 0) {
            mainCard
            expandedSection
        }
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
    
    private var mainCard: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardContent: some View {
        VStack(spacing: Theme.paddingM) {
            headerRow
            progressBar
        }
        .padding(Theme.paddingM)
    }
    
    private var headerRow: some View {
        HStack(spacing: Theme.paddingM) {
            iconView
            infoSection
            Spacer()
            progressSection
        }
    }
    
    private var iconView: some View {
        Image(systemName: category.icon)
            .font(.title2)
            .foregroundColor(categoryColor)
            .frame(width: 40)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            categoryName
            categoryStats
        }
    }
    
    private var categoryName: some View {
        Text(category.name)
            .font(.headline)
            .foregroundColor(Theme.textPrimary)
    }
    
    private var categoryStats: some View {
        HStack(spacing: Theme.paddingS) {
            servicesText
            bulletSeparator
            timeText
        }
    }
    
    private var servicesText: some View {
        Text("\(category.completedServices)/\(category.totalServices) servicios")
            .font(.caption)
            .foregroundColor(Theme.textSecondary)
    }
    
    private var bulletSeparator: some View {
        Text("•")
            .foregroundColor(Theme.textTertiary)
    }
    
    private var timeText: some View {
        Text("\(category.timeSpent) min")
            .font(.caption)
            .foregroundColor(Theme.textSecondary)
    }
    
    private var progressSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            percentageText
            chevronIcon
        }
    }
    
    private var percentageText: some View {
        Text("\(Int(category.percentage))%")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(Theme.awsOrange)
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.down")
            .font(.caption)
            .foregroundColor(Theme.textSecondary)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
    }
    
    private var progressBar: some View {
        ProgressView(value: progressValue)
            .progressViewStyle(LinearProgressViewStyle(tint: categoryColor))
    }
    
    private var progressValue: Double {
        min(category.percentage / 100.0, 1.0)
    }
    
    @ViewBuilder
    private var expandedSection: some View {
        if isExpanded {
            expandedContent
        }
    }
    
    private var expandedContent: some View {
        VStack(spacing: 0) {
            dividerLine
            expandedBody
        }
    }
    
    private var dividerLine: some View {
        Divider()
            .background(Theme.textTertiary.opacity(0.2))
    }
    
    private var expandedBody: some View {
        VStack(spacing: Theme.paddingS) {
            servicesList
            viewAllLink
        }
        .padding(Theme.paddingM)
        .padding(.top, -Theme.paddingS)
    }
    
    private var servicesList: some View {
        VStack(spacing: Theme.paddingS) {
            ForEach(0..<3, id: \.self) { index in
                ServiceProgressRow(
                    name: "Servicio \(index + 1)",
                    progress: Double.random(in: 0...100),
                    isCompleted: index == 0
                )
            }
        }
    }
    
    private var viewAllLink: some View {
        NavigationLink(destination: destinationView) {
            HStack {
                linkText
                arrowIcon
            }
            .padding(.top, Theme.paddingS)
        }
    }
    
    private var destinationView: some View {
        SubcategoriesView(category: Category(name: category.name))
    }
    
    private var linkText: some View {
        Text("Ver todos los servicios")
            .font(.subheadline)
            .foregroundColor(Theme.awsOrange)
    }
    
    private var arrowIcon: some View {
        Image(systemName: "arrow.right")
            .font(.caption)
            .foregroundColor(Theme.awsOrange)
    }
    
    private var categoryColor: Color {
        Color(hex: category.color) ?? Theme.awsOrange
    }
}

struct ServiceProgressRow: View {
    let name: String
    let progress: Double
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            progressIndicator
            serviceNameText
            Spacer()
            progressText
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var progressIndicator: some View {
        if isCompleted {
            completedIcon
        } else {
            progressCircle
        }
    }
    
    private var completedIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.caption)
    }
    
    private var progressCircle: some View {
        CircularProgressView(progress: progressValue)
            .frame(width: 16, height: 16)
    }
    
    private var progressValue: Double {
        min(progress / 100.0, 1.0)
    }
    
    private var serviceNameText: some View {
        Text(name)
            .font(.subheadline)
            .foregroundColor(Theme.textPrimary)
    }
    
    private var progressText: some View {
        Text("\(Int(progress))%")
            .font(.caption)
            .foregroundColor(Theme.textSecondary)
    }
}

struct ProgressByCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressByCategoryView()
    }
}
