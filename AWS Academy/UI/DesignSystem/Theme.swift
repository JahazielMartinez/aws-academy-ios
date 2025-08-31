
import SwiftUI

struct Theme {
    // Colores que se adaptan automáticamente a light/dark mode
    static let primaryColor = Color("AccentColor")
    static let backgroundColor = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // AWS Brand Colors
    static let awsOrange = Color(red: 255/255, green: 153/255, blue: 0/255)
    static let awsDarkBlue = Color(red: 35/255, green: 47/255, blue: 62/255)
    
    // Spacing
    static let paddingXS: CGFloat = 4
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let paddingXL: CGFloat = 32
    
    // Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
}
