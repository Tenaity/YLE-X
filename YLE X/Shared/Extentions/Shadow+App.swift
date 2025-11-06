//
//  Shadow+App.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

// MARK: - Shadow System (iOS-style depth & shadows)
enum AppShadowLevel {
    case none, subtle, light, medium, heavy, dramatic
    
    // MARK: - Shadow Properties
    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 2
        case .light: return 4
        case .medium: return 8
        case .heavy: return 16
        case .dramatic: return 24
        }
    }
    
    var opacity: Double {
        switch self {
        case .none: return 0
        case .subtle: return 0.05
        case .light: return 0.1
        case .medium: return 0.15
        case .heavy: return 0.2
        case .dramatic: return 0.25
        }
    }
    
    var offset: CGSize {
        switch self {
        case .none: return .zero
        case .subtle: return CGSize(width: 0, height: 1)
        case .light: return CGSize(width: 0, height: 2)
        case .medium: return CGSize(width: 0, height: 4)
        case .heavy: return CGSize(width: 0, height: 8)
        case .dramatic: return CGSize(width: 0, height: 12)
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .clear
        case .subtle: return Color.shadowLight
        case .light: return Color.shadowLight
        case .medium: return Color.shadowMedium
        case .heavy: return Color.shadowMedium
        case .dramatic: return Color.shadowHeavy
        }
    }
}

// MARK: - Component-Specific Shadow Presets
struct AppShadow {
    // MARK: - UI Component Shadows
    struct Card {
        static let resting = AppShadowLevel.light
        static let hover = AppShadowLevel.medium
        static let pressed = AppShadowLevel.subtle
        static let floating = AppShadowLevel.heavy
    }
    
    struct Button {
        static let resting = AppShadowLevel.subtle
        static let hover = AppShadowLevel.light
        static let pressed = AppShadowLevel.none
        static let primary = AppShadowLevel.medium
    }
    
    struct Modal {
        static let sheet = AppShadowLevel.heavy
        static let alert = AppShadowLevel.medium
        static let fullScreen = AppShadowLevel.dramatic
    }
    
    struct Navigation {
        static let bar = AppShadowLevel.subtle
        static let tab = AppShadowLevel.subtle
    }
    
    // MARK: - Educational App Specific Shadows
    struct Educational {
        static let exercise = AppShadowLevel.light        // Exercise cards
        static let achievement = AppShadowLevel.medium    // Achievement badges
        static let focus = AppShadowLevel.heavy          // Focused learning content
        static let celebration = AppShadowLevel.dramatic  // Success animations
    }
    
    // MARK: - Kid-Friendly Shadows (Softer, more playful)
    struct KidFriendly {
        static let toy = AppShadowLevel.medium     // Playful, toy-like depth
        static let game = AppShadowLevel.light     // Game elements
        static let reward = AppShadowLevel.heavy   // Rewards and achievements
    }
}

// MARK: - View Extensions for Shadows
extension View {
    /// Applies app shadow with specified level
    func appShadow(level: AppShadowLevel) -> some View {
        self.shadow(
            color: level.color.opacity(level.opacity),
            radius: level.radius,
            x: level.offset.width,
            y: level.offset.height
        )
    }
    
    /// Applies component-specific shadow
    func appCardShadow(state: CardShadowState = .resting) -> some View {
        let level: AppShadowLevel = {
            switch state {
            case .resting: return AppShadow.Card.resting
            case .hover: return AppShadow.Card.hover
            case .pressed: return AppShadow.Card.pressed
            case .floating: return AppShadow.Card.floating
            }
        }()
        return self.appShadow(level: level)
    }
    
    func appButtonShadow(state: ButtonShadowState = .resting) -> some View {
        let level: AppShadowLevel = {
            switch state {
            case .resting: return AppShadow.Button.resting
            case .hover: return AppShadow.Button.hover
            case .pressed: return AppShadow.Button.pressed
            case .primary: return AppShadow.Button.primary
            }
        }()
        return self.appShadow(level: level)
    }
    
    /// Applies kid-friendly shadow (softer, more playful)
    func appKidFriendlyShadow() -> some View {
        self.appShadow(level: AppShadow.KidFriendly.toy)
    }
    
    /// Applies educational content shadow
    func appEducationalShadow(type: EducationalShadowType = .exercise) -> some View {
        let level: AppShadowLevel = {
            switch type {
            case .exercise: return AppShadow.Educational.exercise
            case .achievement: return AppShadow.Educational.achievement
            case .focus: return AppShadow.Educational.focus
            case .celebration: return AppShadow.Educational.celebration
            }
        }()
        return self.appShadow(level: level)
    }
    
    /// Applies Liquid Glass-style shadow (modern iOS design)
    func appLiquidGlassShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Shadow State Enums
enum CardShadowState {
    case resting, hover, pressed, floating
}

enum ButtonShadowState {
    case resting, hover, pressed, primary
}

enum EducationalShadowType {
    case exercise, achievement, focus, celebration
}
