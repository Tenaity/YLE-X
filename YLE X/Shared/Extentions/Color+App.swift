//
//  Color+App.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

extension Color {
    // MARK: - Semantic Colors (Dynamic)
    static let appPrimaryText = Color(.label)
    static let appSecondaryText = Color(.secondaryLabel)
    static let appTertiaryText = Color(.tertiaryLabel)
    static let appBackground = Color(.systemBackground)
    static let appCardBackground = Color(.secondarySystemBackground)
    static let appGroupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Status Colors (Kid-Friendly & Accessible)
    static let appSuccess = Color(red: 0.2, green: 0.8, blue: 0.4) // Vibrant green
    static let appError = Color(red: 1.0, green: 0.4, blue: 0.4)   // Soft red (not harsh)
    static let appWarning = Color(red: 1.0, green: 0.7, blue: 0.2) // Friendly orange
    static let appInfo = Color(red: 0.3, green: 0.6, blue: 1.0)    // Bright blue
    
    // MARK: - Brand Colors (Vibrant & Educational)
    static let appPrimary = Color(red: 0.0, green: 0.5, blue: 1.0)    // Bright blue
    static let appSecondary = Color(red: 0.6, green: 0.3, blue: 0.9)  // Purple
    static let appAccent = Color(red: 1.0, green: 0.6, blue: 0.0)     // Warm orange
    
    // MARK: - YLE Level Colors (Age-Appropriate Branding)
    static let startersGreen = Color(red: 0.2, green: 0.8, blue: 0.3)      // Fresh green
    static let startersLightGreen = Color(red: 0.8, green: 0.95, blue: 0.8) // Light green bg
    
    static let moversBlue = Color(red: 0.1, green: 0.6, blue: 1.0)         // Sky blue  
    static let moversLightBlue = Color(red: 0.85, green: 0.95, blue: 1.0)   // Light blue bg
    
    static let flyersPurple = Color(red: 0.7, green: 0.3, blue: 0.9)       // Vibrant purple
    static let flyersLightPurple = Color(red: 0.95, green: 0.9, blue: 1.0) // Light purple bg
    
    // MARK: - Skill Colors (Distinctive & Memorable)
    static let listeningBlue = Color(red: 0.0, green: 0.7, blue: 1.0)      // Clear blue
    static let speakingOrange = Color(red: 1.0, green: 0.5, blue: 0.1)     // Energetic orange
    static let readingGreen = Color(red: 0.1, green: 0.7, blue: 0.4)       // Forest green
    static let writingPurple = Color(red: 0.6, green: 0.2, blue: 0.8)      // Deep purple
    static let vocabularyPink = Color(red: 1.0, green: 0.3, blue: 0.6)     // Bright pink
    static let grammarCyan = Color(red: 0.0, green: 0.8, blue: 0.8)        // Turquoise
    
    // MARK: - Gradient Colors (for backgrounds and effects)
    static let gradientStart = Color(red: 0.9, green: 0.95, blue: 1.0)     // Very light blue
    static let gradientEnd = Color(red: 1.0, green: 0.95, blue: 0.9)       // Very light orange
    
    // MARK: - Interactive Colors (Hover/Press states)
    static let buttonHover = Color.black.opacity(0.05)
    static let buttonPressed = Color.black.opacity(0.1)
    
    // MARK: - Shadow Colors
    static let shadowLight = Color.black.opacity(0.08)
    static let shadowMedium = Color.black.opacity(0.12)
    static let shadowHeavy = Color.black.opacity(0.16)
}

// MARK: - Color Accessibility Helpers
extension Color {
    /// Returns a color that ensures proper contrast in both light and dark mode
    static func dynamicColor(light: Color, dark: Color) -> Color {
        Color(.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    /// Kid-friendly pastel variants for backgrounds
    var pastelVariant: Color {
        self.opacity(0.15)
    }
    
    /// Accessible contrast variant
    var accessibleVariant: Color {
        Color(.init { traitCollection in
            let baseColor = UIColor(self)
            return traitCollection.userInterfaceStyle == .dark ? 
                baseColor.withAlphaComponent(0.9) : baseColor
        })
    }
}