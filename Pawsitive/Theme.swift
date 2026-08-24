import SwiftUI

extension Color {
    static let pawsitivePrimary = Color(red: 1.0, green: 0.6, blue: 0.11) // Warm Sunset Orange
    static let pawsitiveSecondary = Color(red: 1.0, green: 0.44, blue: 0.3) // Peach
}

struct Theme {
    static let gradientStart = Color.pawsitivePrimary
    static let gradientEnd = Color.pawsitiveSecondary
    
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [gradientStart, gradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
}
