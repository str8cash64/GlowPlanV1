import SwiftUI
import UIKit

// Navigation bar modifier to apply custom colors
public struct GlowNavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    public init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = textColor
    }
    
    public func body(content: Content) -> some View {
        content
    }
}

public extension View {
    func applyGlowNavigationBarStyle(backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(GlowNavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
} 