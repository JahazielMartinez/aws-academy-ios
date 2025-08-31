import SwiftUI

struct LeaderboardView: View {
    @State private var selectedPeriod: LeaderboardPeriod = .week
    @State private var selectedCategory: LeaderboardCategory = .general
    @State private var leaderboardData: [LeaderboardEntry] = []
    @State private var userRank: Int = 0
    
    enum LeaderboardPeriod: String, CaseIterable {
        case day = "Hoy"
        case week = "Semana"
        case month = "Mes"
        case allTime = "Siempre"
    }
    
    enum LeaderboardCategory: String, CaseIterable {
        case general = "General"
        case quizzes = "Quizzes"
        case study = "Estudio"
        case streak = "Racha"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                VStack(spacing: Theme.paddingM) {
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.paddingS) {
                            ForEach(LeaderboardCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Theme.backgroundColor)
                
                // User position card
                if userRank > 0 {
                    UserRankCard(rank: userRank)
                }
                
                // Leaderboard list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(leaderboardData) { entry in
                            LeaderboardRow(entry: entry)
                            Divider()
                        }
                    }
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Tabla de Clasificación")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadLeaderboard()
            }
            .onChange(of: selectedPeriod) { _, _ in
                loadLeaderboard()
            }
            .onChange(of: selectedCategory) { _, _ in
                loadLeaderboard()
            }
        }
    }
    
    private func loadLeaderboard() {
        // Cargar datos del leaderboard
        leaderboardData = [
            LeaderboardEntry(rank: 1, name: "Ana G.", score: 2450, avatar: "person.circle"),
            LeaderboardEntry(rank: 2, name: "Carlos M.", score: 2380, avatar: "person.circle"),
            LeaderboardEntry(rank: 3, name: "María L.", score: 2290, avatar: "person.circle")
        ]
        userRank = 42
    }
}

struct UserRankCard: View {
    let rank: Int
    
    var body: some View {
        HStack {
            Text("Tu posición")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            Spacer()
            
            HStack(spacing: Theme.paddingS) {
                Image(systemName: "arrow.up")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("#\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.awsOrange)
            }
        }
        .padding()
        .background(Theme.awsOrange.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Theme.awsOrange.opacity(0.3)),
            alignment: .bottom
        )
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return Color(white: 0.7)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return Theme.textPrimary
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            // Rank
            ZStack {
                if entry.rank <= 3 {
                    Image(systemName: "medal.fill")
                        .font(.title2)
                        .foregroundColor(rankColor)
                }
                Text("\(entry.rank)")
                    .font(entry.rank <= 3 ? .caption : .subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(entry.rank <= 3 ? .white : Theme.textPrimary)
            }
            .frame(width: 40)
            
            // Avatar
            Image(systemName: entry.avatar)
                .font(.title2)
                .foregroundColor(Theme.awsOrange)
            
            // Name
            Text(entry.name)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.score)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                Text("puntos")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding()
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let score: Int
    let avatar: String
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
