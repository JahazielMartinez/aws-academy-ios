import SwiftUI

struct BookmarksView: View {
    @State private var bookmarks: [Bookmark] = []
    @State private var selectedFilter: BookmarkFilter = .all
    
    enum BookmarkFilter: String, CaseIterable {
        case all = "Todos"
        case services = "Servicios"
        case concepts = "Conceptos"
        case examples = "Ejemplos"
    }
    
    var filteredBookmarks: [Bookmark] {
        switch selectedFilter {
        case .all:
            return bookmarks
        case .services:
            return bookmarks.filter { $0.type == .service }
        case .concepts:
            return bookmarks.filter { $0.type == .concept }
        case .examples:
            return bookmarks.filter { $0.type == .example }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter tabs
                Picker("Filtro", selection: $selectedFilter) {
                    ForEach(BookmarkFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Bookmarks list
                if filteredBookmarks.isEmpty {
                    EmptyStateView(
                        icon: "bookmark",
                        title: "Sin marcadores",
                        message: "Los elementos que marques aparecerán aquí"
                    )
                } else {
                    List {
                        ForEach(filteredBookmarks) { bookmark in
                            BookmarkRow(bookmark: bookmark)
                        }
                        .onDelete(perform: deleteBookmarks)
                    }
                }
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Marcadores")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadBookmarks()
            }
        }
    }
    
    private func loadBookmarks() {
        // Cargar marcadores guardados
        bookmarks = [
            Bookmark(
                id: "1",
                title: "EC2 - Elastic Compute Cloud",
                description: "Servidores virtuales en la nube",
                type: .service,
                serviceId: "ec2",
                dateAdded: Date()
            )
        ]
    }
    
    private func deleteBookmarks(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
    }
}

struct BookmarkRow: View {
    let bookmark: Bookmark
    
    var body: some View {
        NavigationLink(destination: destinationView(for: bookmark)) {
            HStack(spacing: Theme.paddingM) {
                Image(systemName: bookmark.type.icon)
                    .font(.title3)
                    .foregroundColor(Theme.awsOrange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(bookmark.description)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                    
                    Text(bookmark.dateAdded, style: .date)
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private func destinationView(for bookmark: Bookmark) -> some View {
        switch bookmark.type {
        case .service:
            if let serviceId = bookmark.serviceId {
                ServiceDetailView(service: Service(id: serviceId, name: bookmark.title))
            }
        case .concept, .example:
            Text(bookmark.title)
        }
    }
}

struct Bookmark: Identifiable {
    let id: String
    let title: String
    let description: String
    let type: BookmarkType
    let serviceId: String?
    let dateAdded: Date
    
    enum BookmarkType {
        case service
        case concept
        case example
        
        var icon: String {
            switch self {
            case .service:
                return "cloud"
            case .concept:
                return "lightbulb"
            case .example:
                return "flask"
            }
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
