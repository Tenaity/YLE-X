//
//  DesignSystem.swift
//  YLE X
//
//  Intended path: Core/Utils/
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary Colors - Bright and cheerful for children
    static let kidsPrimary = Color(red: 0.2, green: 0.7, blue: 0.9) // Bright blue
    static let kidsSecondary = Color(red: 1.0, green: 0.6, blue: 0.2) // Orange
    static let kidsAccent = Color(red: 0.9, green: 0.3, blue: 0.5) // Pink
    
    // Level Colors - Each level has its own color scheme
    static let startersGreen = Color(red: 0.3, green: 0.8, blue: 0.4)
    static let startersLightGreen = Color(red: 0.8, green: 0.95, blue: 0.8)
    
    static let moversBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    static let moversLightBlue = Color(red: 0.8, green: 0.9, blue: 0.98)
    
    static let flyersPurple = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let flyersLightPurple = Color(red: 0.9, green: 0.85, blue: 0.98)
    
    // Skill Colors - Distinct colors for each skill
    static let listeningBlue = Color(red: 0.3, green: 0.7, blue: 0.9)
    static let speakingOrange = Color(red: 1.0, green: 0.5, blue: 0.2)
    static let readingGreen = Color(red: 0.2, green: 0.8, blue: 0.3)
    static let writingPurple = Color(red: 0.7, green: 0.3, blue: 0.9)
    static let vocabularyPink = Color(red: 0.9, green: 0.4, blue: 0.6)
    static let grammarCyan = Color(red: 0.3, green: 0.8, blue: 0.8)
    
    // UI Colors
    static let kidsBackground = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let kidsCardBackground = Color.white
    static let kidsSuccess = Color(red: 0.2, green: 0.8, blue: 0.3)
    static let kidsWarning = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let kidsError = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Text Colors
    static let kidsPrimaryText = Color(red: 0.2, green: 0.2, blue: 0.3)
    static let kidsSecondaryText = Color(red: 0.5, green: 0.5, blue: 0.6)
}

// MARK: - Typography
extension Font {
    // Child-friendly fonts - larger sizes for readability
    static let kidsLargeTitle = Font.custom("SF Pro Display", size: 32, relativeTo: .largeTitle).weight(.bold)
    static let kidsTitle = Font.custom("SF Pro Display", size: 24, relativeTo: .title).weight(.semibold)
    static let kidsHeadline = Font.custom("SF Pro Display", size: 20, relativeTo: .headline).weight(.medium)
    static let kidsBody = Font.custom("SF Pro Text", size: 18, relativeTo: .body).weight(.regular)
    static let kidsCaption = Font.custom("SF Pro Text", size: 14, relativeTo: .caption).weight(.medium)
    
    // Fun display fonts for special elements
    static let kidsDisplayLarge = Font.custom("SF Pro Rounded", size: 36, relativeTo: .largeTitle).weight(.heavy)
    static let kidsDisplayMedium = Font.custom("SF Pro Rounded", size: 28, relativeTo: .title).weight(.bold)
}

// MARK: - Spacing System
enum KidsSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius System
enum KidsRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let circle: CGFloat = 50
}

// MARK: - Shadow System
extension View {
    func kidsShadow(level: ShadowLevel = .medium) -> some View {
        switch level {
        case .light:
            return self.shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        case .medium:
            return self.shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        case .heavy:
            return self.shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
        }
    }
}

enum ShadowLevel {
    case light, medium, heavy
}

// MARK: - Animation System
extension Animation {
    static let kidsBounce = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let kidsGentle = Animation.easeInOut(duration: 0.3)
    static let kidsPlayful = Animation.interpolatingSpring(stiffness: 300, damping: 15)
}

// MARK: - Icon System
enum KidsIcons {
    static let star = "star.fill"
    static let heart = "heart.fill"
    static let trophy = "trophy.fill"
    static let medal = "medal.fill"
    static let gift = "gift.fill"
    static let sparkles = "sparkles"
    static let balloon = "balloon.fill"
    static let party = "party.popper.fill"
    
    // Navigation
    static let home = "house.fill"
    static let practice = "gamecontroller.fill"
    static let progress = "chart.line.uptrend.xyaxis"
    static let profile = "person.crop.circle.fill"
    static let settings = "gearshape.fill"
    
    // Skills
    static let listening = "ear.fill"
    static let speaking = "mic.fill"
    static let reading = "book.pages.fill"
    static let writing = "pencil"
    static let vocabulary = "textbook.closed.fill"
    static let grammar = "puzzlepiece.fill"
    
    // Actions
    static let play = "play.circle.fill"
    static let pause = "pause.circle.fill"
    static let next = "arrow.right.circle.fill"
    static let previous = "arrow.left.circle.fill"
    static let check = "checkmark.circle.fill"
    static let close = "xmark.circle.fill"
}

// MARK: - Accessibility Helpers
extension View {
    func kidsAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    func kidsAccessibilityValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
}
