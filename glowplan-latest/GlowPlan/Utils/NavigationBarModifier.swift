import SwiftUI

// DEPRECATED - Please use GlowPlan/Extensions/NavigationBarExtension.swift instead
// This file is kept for backward compatibility but will be removed in a future update

@available(*, deprecated, message: "Use GlowNavigationBarModifier from NavigationBarExtension.swift instead")
struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    init(backgroundColor: UIColor, textColor: UIColor) {
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
    
    func body(content: Content) -> some View {
        content
    }
}

@available(*, deprecated, message: "Use navigationBarColor from NavigationBarExtension.swift instead")
extension View {
    func navigationBarColor(backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
} 