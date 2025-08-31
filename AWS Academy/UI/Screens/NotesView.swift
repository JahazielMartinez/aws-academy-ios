import SwiftUI

struct NotesView: View {
    @State private var notes: [Note] = []
    @State private var searchText = ""
    @State private var showingNewNote = false
    @State private var selectedNote: Note?
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteRow(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, prompt: "Buscar notas...")
            .navigationTitle("Mis Notas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Theme.awsOrange)
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NewNoteView { newNote in
                    notes.append(newNote)
                }
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    private func loadNotes() {
        // Cargar notas guardadas
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                if let service = note.relatedService {
                    Text(service)
                        .font(.caption)
                        .foregroundColor(Theme.awsOrange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.awsOrange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
            
            Text(note.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(Theme.textTertiary)
        }
        .padding(.vertical, 4)
    }
}

struct NoteDetailView: View {
    let note: Note
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    
    init(note: Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.paddingM) {
                if isEditing {
                    TextField("Título", text: $editedTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 300)
                } else {
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(note.content)
                        .font(.body)
                        .foregroundColor(Theme.textPrimary)
                }
                
                if let service = note.relatedService {
                    Label(service, systemImage: "link")
                        .font(.caption)
                        .foregroundColor(Theme.awsOrange)
                }
            }
            .padding()
        }
        .navigationTitle("Nota")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Guardar" : "Editar") {
                    isEditing.toggle()
                    if !isEditing {
                        saveNote()
                    }
                }
            }
        }
    }
    
    private func saveNote() {
        // Guardar cambios
    }
}

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var relatedService: String?
    let onSave: (Note) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Título", text: $title)
                
                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section("Relacionado con") {
                    Picker("Servicio", selection: $relatedService) {
                        Text("Ninguno").tag(nil as String?)
                        Text("EC2").tag("EC2" as String?)
                        Text("S3").tag("S3" as String?)
                        // Más servicios...
                    }
                }
            }
            .navigationTitle("Nueva Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let newNote = Note(
                            id: UUID().uuidString,
                            title: title,
                            content: content,
                            relatedService: relatedService,
                            createdAt: Date()
                        )
                        onSave(newNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

struct Note: Identifiable {
    let id: String
    var title: String
    var content: String
    var relatedService: String?
    let createdAt: Date
    var updatedAt: Date?
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}
