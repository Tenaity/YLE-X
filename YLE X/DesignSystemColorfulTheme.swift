//
//  ColorfulTheme.swift
//  YLE X - Child-Friendly English Learning App
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Child-Friendly Color Palette
/// A comprehensive color system designed specifically for children's educational apps
/// Features high contrast, accessibility compliance, and engaging visual appeal
struct ChildFriendlyColors {
    
    // MARK: - Primary Colors (Bright and Engaging)
    static let primaryBlue = Color(hex: "#4A90E2")      // Friendly blue
    static let primaryGreen = Color(hex: "#7ED321")     // Success green
    static let primaryOrange = Color(hex: "#F5A623")    // Warning/attention orange
    static let primaryPurple = Color(hex: "#9013FE")    // Creative purple
    static let primaryPink = Color(hex: "#E91E63")      // Playful pink
    
    // MARK: - Pastel Background Colors (Gentle on Eyes)
    static let softBlue = Color(hex: "#E3F2FD")
    static let softGreen = Color(hex: "#E8F5E8")
    static let softYellow = Color(hex: "#FFF9C4")
    static let softPink = Color(hex: "#FCE4EC")
    static let softPurple = Color(hex: "#F3E5F5")
    
    // MARK: - Interactive States
    static let correctAnswer = Color(hex: "#4CAF50")    // Bright green for correct
    static let incorrectAnswer = Color(hex: "#FF5722")  // Orange-red for incorrect
    static let selectedState = Color(hex: "#2196F3")    // Blue for selected
    static let hoverState = Color(hex: "#FFC107")       // Yellow for hover
    
    // MARK: - Text Colors (High Contrast for Readability)
    static let primaryText = Color(hex: "#2C3E50")      // Dark blue-gray
    static let secondaryText = Color(hex: "#7F8C8D")    // Medium gray
    static let whiteText = Color.white
    static let buttonText = Color.white
    
    // MARK: - Functional Colors
    static let cardBackground = Color(hex: "#FFFFFF")
    static let appBackground = Color(hex: "#F8F9FA")
    static let shadow = Color.black.opacity(0.1)
    
    // MARK: - Brand Variations for Multi-Branding
    enum BrandTheme: CaseIterable {
        case ocean      // Blue theme
        case forest     // Green theme
        case sunshine   // Yellow/Orange theme
        case berry      // Pink/Purple theme
        case rainbow    // Multi-color theme
        
        var primaryColor: Color {
            switch self {
            case .ocean: return ChildFriendlyColors.primaryBlue
            case .forest: return ChildFriendlyColors.primaryGreen
            case .sunshine: return ChildFriendlyColors.primaryOrange
            case .berry: return ChildFriendlyColors.primaryPink
            case .rainbow: return ChildFriendlyColors.primaryPurple
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .ocean: return ChildFriendlyColors.softBlue
            case .forest: return ChildFriendlyColors.softGreen
            case .sunshine: return ChildFriendlyColors.softYellow
            case .berry: return ChildFriendlyColors.softPink
            case .rainbow: return ChildFriendlyColors.softPurple
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .ocean: return [primaryColor, Color(hex: "#1976D2")]
            case .forest: return [primaryColor, Color(hex: "#388E3C")]
            case .sunshine: return [primaryColor, Color(hex: "#FF8F00")]
            case .berry: return [primaryColor, Color(hex: "#C2185B")]
            case .rainbow: return [Color(hex: "#9C27B0"), Color(hex: "#673AB7"), Color(hex: "#3F51B5")]
            }
        }
        
        var name: String {
            switch self {
            case .ocean: return "Ocean Adventure"
            case .forest: return "Forest Friends"
            case .sunshine: return "Sunny Day"
            case .berry: return "Berry Sweet"
            case .rainbow: return "Rainbow Magic"
            }
        }
        
        var iconName: String {
            switch self {
            case .ocean: return "🌊"
            case .forest: return "🌲"
            case .sunshine: return "☀️"
            case .berry: return "🍓"
            case .rainbow: return "🌈"
            }
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Manager
/// Manages the current theme selection and provides theme switching capabilities
@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: ChildFriendlyColors.BrandTheme = .rainbow
    @Published var isDarkMode: Bool = false
    
    // Singleton instance
    static let shared = ThemeManager()
    
    private init() {
        // Load saved theme preference
        loadThemePreference()
    }
    
    func switchTheme(to theme: ChildFriendlyColors.BrandTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
        saveThemePreference()
    }
    
    private func loadThemePreference() {
        if let savedTheme = UserDefaults.standard.object(forKey: "selectedTheme") as? String,
           let theme = ChildFriendlyColors.BrandTheme.allCases.first(where: { "\($0)" == savedTheme }) {
            currentTheme = theme
        }
    }
    
    private func saveThemePreference() {
        UserDefaults.standard.set("\(currentTheme)", forKey: "selectedTheme")
    }
}

// MARK: - Gradient Styles
struct ChildFriendlyGradients {
    static func cardGradient(for theme: ChildFriendlyColors.BrandTheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                theme.primaryColor.opacity(0.1),
                theme.backgroundColor
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func buttonGradient(for theme: ChildFriendlyColors.BrandTheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: theme.gradientColors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static let rainbowGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "#FF6B6B"), // Red
            Color(hex: "#FF8E53"), // Orange
            Color(hex: "#FF6B9D"), // Pink
            Color(hex: "#C44569"), // Deep pink
            Color(hex: "#778BEB"), // Purple
            Color(hex: "#546DE5")  // Blue
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

