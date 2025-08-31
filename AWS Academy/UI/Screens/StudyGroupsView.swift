import SwiftUI

struct StudyGroupsView: View {
    @State private var myGroups: [StudyGroup] = []
    @State private var recommendedGroups: [StudyGroup] = []
    @State private var showingCreateGroup = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.paddingL) {
                    // My groups
                    if !myGroups.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.paddingM) {
                            Text("Mis Grupos")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Theme.paddingM) {
                                    ForEach(myGroups) { group in
                                        NavigationLink(destination: StudyGroupDetailView(group: group)) {
                                            MyGroupCard(group: group)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Recommended groups
                    VStack(alignment: .leading, spacing: Theme.paddingM) {
                        HStack {
                            Text("Grupos Recomendados")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Button("Ver todos") {
                                // Ver todos los grupos
                            }
                            .font(.subheadline)
                            .foregroundColor(Theme.awsOrange)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: Theme.paddingM) {
                            ForEach(recommendedGroups) { group in
                                GroupCard(group: group)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Grupos de Estudio")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar grupos...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateGroup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.awsOrange)
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView()
            }
            .onAppear {
                loadGroups()
            }
        }
    }
    
    private func loadGroups() {
        myGroups = [
            StudyGroup(
                id: "1",
                name: "Cloud Practitioner 2025",
                description: "Preparación para el examen",
                memberCount: 12,
                isPrivate: false,
                nextSession: Date(),
                certification: "Cloud Practitioner"
            )
        ]
        
        recommendedGroups = [
            StudyGroup(
                id: "2",
                name: "Solutions Architect Study",
                description: "Grupo de estudio para SA Associate",
                memberCount: 25,
                isPrivate: false,
                nextSession: nil,
                certification: "Solutions Architect"
            )
        ]
    }
}

struct MyGroupCard: View {
    let group: StudyGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingS) {
            HStack {
                Image(systemName: group.isPrivate ? "lock.fill" : "person.3.fill")
                    .font(.caption)
                    .foregroundColor(Theme.awsOrange)
                
                Text("\(group.memberCount) miembros")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Text(group.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
            
            if let nextSession = group.nextSession {
                Label("Próxima sesión", systemImage: "calendar")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                
                Text(nextSession, style: .relative)
                    .font(.caption)
                    .foregroundColor(Theme.awsOrange)
            }
        }
        .frame(width: 150)
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct GroupCard: View {
    let group: StudyGroup
    
    var body: some View {
        HStack(spacing: Theme.paddingM) {
            // Group icon
            ZStack {
                Circle()
                    .fill(Theme.awsOrange.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.3.fill")
                    .foregroundColor(Theme.awsOrange)
            }
            
            // Group info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(group.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    if group.isPrivate {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Text(group.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                
                HStack {
                    Label("\(group.memberCount)", systemImage: "person.2")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                    
                    if let cert = group.certification {
                        Text("•")
                            .foregroundColor(Theme.textTertiary)
                        Text(cert)
                            .font(.caption2)
                            .foregroundColor(Theme.awsOrange)
                    }
                }
            }
            
            Spacer()
            
            Button("Unirse") {
                // Unirse al grupo
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.awsOrange)
            .cornerRadius(Theme.cornerRadiusS)
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadiusM)
    }
}

struct StudyGroupDetailView: View {
    let group: StudyGroup
    @State private var messages: [GroupMessage] = []
    @State private var newMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                LazyVStack(spacing: Theme.paddingM) {
                    ForEach(messages) { message in
                        MessageRow(message: message)
                    }
                }
                .padding()
            }
            
            // Input
            HStack {
                TextField("Escribe un mensaje...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Theme.awsOrange)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
            .background(Theme.secondaryBackground)
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GroupSettingsView(group: group)) {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
    
    private func sendMessage() {
        // Enviar mensaje
        newMessage = ""
    }
}

struct MessageRow: View {
    let message: GroupMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.paddingS) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(Theme.awsOrange.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.author)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
                
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Spacer()
        }
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var description = ""
    @State private var isPrivate = false
    @State private var selectedCertification: String?
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre del grupo", text: $groupName)
                TextField("Descripción", text: $description)
                
                Toggle("Grupo privado", isOn: $isPrivate)
                    .tint(Theme.awsOrange)
                
                Picker("Certificación objetivo", selection: $selectedCertification) {
                    Text("Ninguna").tag(nil as String?)
                    Text("Cloud Practitioner").tag("Cloud Practitioner" as String?)
                    Text("Solutions Architect").tag("Solutions Architect" as String?)
                }
            }
            .navigationTitle("Nuevo Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        createGroup()
                    }
                    .disabled(groupName.isEmpty)
                }
            }
        }
    }
    
    private func createGroup() {
        // Crear grupo
        dismiss()
    }
}

struct GroupSettingsView: View {
    let group: StudyGroup
    
    var body: some View {
        Form {
            Section("Información") {
                HStack {
                    Text("Miembros")
                    Spacer()
                    Text("\(group.memberCount)")
                        .foregroundColor(Theme.textSecondary)
                }
                
                HStack {
                    Text("Creado")
                    Spacer()
                    Text("Hace 2 semanas")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Section("Sesiones") {
                Button("Programar sesión") {
                    // Programar sesión
                }
            }
            
            Section {
                Button("Salir del grupo") {
                    // Salir del grupo
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StudyGroup: Identifiable {
    let id: String
    let name: String
    let description: String
    let memberCount: Int
    let isPrivate: Bool
    let nextSession: Date?
    let certification: String?
}

struct GroupMessage: Identifiable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: Date
}

struct StudyGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        StudyGroupsView()
    }
}
