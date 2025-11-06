//
//  AppRadius.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

// MARK: - Corner Radius System (iOS-style)
struct AppRadius {
    // MARK: - Standard Radius Values
    static let none: CGFloat = 0        // No rounding
    static let tiny: CGFloat = 4        // Subtle rounding
    static let small: CGFloat = 8       // Small elements
    static let medium: CGFloat = 12     // Standard elements
    static let large: CGFloat = 16      // Cards, buttons
    static let xlarge: CGFloat = 20     // Large cards
    static let xxlarge: CGFloat = 28    // Hero elements
    static let circle: CGFloat = 50     // Circular elements
    
    // MARK: - Component-Specific Radius
    struct Button {
        static let small = AppRadius.small      // 8pt - Small buttons
        static let medium = AppRadius.medium    // 12pt - Standard buttons
        static let large = AppRadius.large      // 16pt - Primary buttons
        static let pill: CGFloat = 25           // Pill-shaped buttons
    }
    
    struct Card {
        static let small = AppRadius.medium     // 12pt - Small cards
        static let medium = AppRadius.large     // 16pt - Standard cards
        static let large = AppRadius.xlarge     // 20pt - Large cards
    }
    
    struct Input {
        static let textField = AppRadius.small  // 8pt - Text fields
        static let searchBar = AppRadius.large  // 16pt - Search bars
    }
    
    struct Modal {
        static let sheet = AppRadius.large      // 16pt - Bottom sheets
        static let alert = AppRadius.medium     // 12pt - Alerts
    }
    
    // MARK: - Kid-Friendly Radius (More playful, rounded)
    struct KidFriendly {
        static let button = AppRadius.large     // 16pt - Friendly buttons
        static let card = AppRadius.xlarge      // 20pt - Playful cards
        static let image = AppRadius.medium     // 12pt - Images
    }
}

// MARK: - Shape Extensions
extension RoundedRectangle {
    // MARK: - Quick Shape Creation
    static func appShape(_ radius: AppRadiusSize = .medium) -> RoundedRectangle {
        switch radius {
        case .none: return RoundedRectangle(cornerRadius: AppRadius.none)
        case .tiny: return RoundedRectangle(cornerRadius: AppRadius.tiny)
        case .small: return RoundedRectangle(cornerRadius: AppRadius.small)
        case .medium: return RoundedRectangle(cornerRadius: AppRadius.medium)
        case .large: return RoundedRectangle(cornerRadius: AppRadius.large)
        case .xlarge: return RoundedRectangle(cornerRadius: AppRadius.xlarge)
        case .circle: return RoundedRectangle(cornerRadius: AppRadius.circle)
        }
    }
    
    // MARK: - Component Shapes
    static var appButton: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.Button.medium)
    }
    
    static var appCard: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.Card.medium)
    }
    
    static var appInput: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.Input.textField)
    }
}

// MARK: - View Extensions for Corner Radius
extension View {
    // MARK: - Corner Radius Modifiers
    func appCornerRadius(_ radius: AppRadiusSize = .medium) -> some View {
        switch radius {
        case .none: return self.cornerRadius(AppRadius.none)
        case .tiny: return self.cornerRadius(AppRadius.tiny)
        case .small: return self.cornerRadius(AppRadius.small)
        case .medium: return self.cornerRadius(AppRadius.medium)
        case .large: return self.cornerRadius(AppRadius.large)
        case .xlarge: return self.cornerRadius(AppRadius.xlarge)
        case .circle: return self.cornerRadius(AppRadius.circle)
        }
    }
    
    // MARK: - Component-Specific Radius
    func appButtonRadius() -> some View {
        self.cornerRadius(AppRadius.Button.medium)
    }
    
    func appCardRadius() -> some View {
        self.cornerRadius(AppRadius.Card.medium)
    }
    
    func appInputRadius() -> some View {
        self.cornerRadius(AppRadius.Input.textField)
    }
    
    // MARK: - Clipped Corner Radius (Better performance for complex views)
    func appClippedCornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    func appClippedCornerRadius(_ radius: AppRadiusSize = .medium) -> some View {
        let radiusValue: CGFloat = {
            switch radius {
            case .none: return AppRadius.none
            case .tiny: return AppRadius.tiny
            case .small: return AppRadius.small
            case .medium: return AppRadius.medium
            case .large: return AppRadius.large
            case .xlarge: return AppRadius.xlarge
            case .circle: return AppRadius.circle
            }
        }()
        return self.clipShape(RoundedRectangle(cornerRadius: radiusValue))
    }
}

// MARK: - Radius Size Enum
enum AppRadiusSize {
    case none, tiny, small, medium, large, xlarge, circle
}

// MARK: - Advanced Shape Modifiers
extension View {
    /// Creates a rounded rectangle with different corner radii
    func appRoundedCorners(_ corners: UIRectCorner, radius: CGFloat) -> some View {
        self.clipShape(
            RoundedCornerShape(corners: corners, radius: radius)
        )
    }
    
    /// Kid-friendly shape with extra rounding
    func appKidFriendlyShape() -> some View {
        self.appClippedCornerRadius(.xlarge)
    }
}

// MARK: - Custom Rounded Corner Shape
struct RoundedCornerShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Liquid Glass Shape (Modern iOS Design)
struct LiquidGlassShape: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        // Create a path with slightly more rounded corners for glass effect
        let adjustedRadius = min(radius, min(rect.width, rect.height) / 2)
        return Path(
            roundedRect: rect,
            cornerRadius: adjustedRadius
        )
    }
}

extension View {
    func appLiquidGlassShape(radius: CGFloat = AppRadius.large) -> some View {
        self.clipShape(LiquidGlassShape(radius: radius))
    }
}
