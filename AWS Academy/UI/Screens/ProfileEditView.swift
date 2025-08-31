import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var level: User.ExperienceLevel = .beginner
    @State private var bio = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Photo section
                Section {
                    HStack {
                        Spacer()
                        
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            ZStack {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Theme.secondaryBackground)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(Theme.textSecondary)
                                        )
                                }
                                
                                Circle()
                                    .strokeBorder(Theme.awsOrange, lineWidth: 3)
                                    .frame(width: 100, height: 100)
                            }
                        }
                        .onChange(of: selectedImage) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    profileImage = image
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, Theme.paddingS)
                }
                
                // Personal info
                Section("Información Personal") {
                    TextField("Nombre completo", text: $name)
                    
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Picker("Nivel de experiencia", selection: $level) {
                        ForEach(User.ExperienceLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                // Bio
                Section("Acerca de ti") {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                }
                
                // Preferences
                Section("Preferencias") {
                    HStack {
                        Text("Idioma")
                        Spacer()
                        Text("Español")
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    HStack {
                        Text("Zona horaria")
                        Spacer()
                        Text("GMT-6")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Account actions
                Section {
                    Button(action: changePassword) {
                        Text("Cambiar contraseña")
                            .foregroundColor(Theme.awsOrange)
                    }
                    
                    Button(action: signOut) {
                        Text("Cerrar sesión")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveProfile()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("Perfil actualizado", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tus cambios han sido guardados exitosamente")
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
        email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        showingSaveAlert = true
    }
    
    private func changePassword() {
        // Implementar cambio de contraseña
    }
    
    private func signOut() {
        // Implementar cierre de sesión
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}
