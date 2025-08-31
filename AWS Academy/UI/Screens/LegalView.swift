import SwiftUI

struct LegalView: View {
    let type: LegalType
    
    enum LegalType {
        case privacy
        case terms
        
        var title: String {
            switch self {
            case .privacy:
                return "Política de Privacidad"
            case .terms:
                return "Términos de Servicio"
            }
        }
        
        var content: String {
            switch self {
            case .privacy:
                return """
                Política de Privacidad
                
                Última actualización: \(Date().formatted(date: .abbreviated, time: .omitted))
                
                Esta política de privacidad describe cómo AWS Academy recopila, usa y protege tu información personal.
                
                El contenido completo se cargará desde AWS.
                """
            case .terms:
                return """
                Términos de Servicio
                
                Última actualización: \(Date().formatted(date: .abbreviated, time: .omitted))
                
                Al usar AWS Academy, aceptas estos términos de servicio.
                
                El contenido completo se cargará desde AWS.
                """
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(type.content)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .padding(Theme.paddingL)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Theme.backgroundColor)
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LegalView(type: .privacy)
            LegalView(type: .terms)
        }
    }
}
