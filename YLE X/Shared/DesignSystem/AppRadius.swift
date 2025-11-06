//
//  AppRadius.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Corner radius system following Apple Design Guidelines
//

import SwiftUI

// MARK: - Radius Scale
struct AppRadius {
    // MARK: - Base Scale
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = .infinity

    // MARK: - Component Radius
    struct component {
        static let button = AppRadius.sm
        static let card = AppRadius.md
        static let input = AppRadius.xs
        static let modal = AppRadius.lg
        static let sheet = AppRadius.lg
    }
}

// MARK: - View Modifiers for Radius
extension View {
    /// Apply corner radius
    func appCornerRadius(_ radius: AppRadiusSize = .medium) -> some View {
        self.cornerRadius(radius.value)
    }

    /// Apply clipped corner radius (better performance)
    func appClippedCornerRadius(_ radius: AppRadiusSize = .medium) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius.value))
    }

    /// Apply button radius
    func appButtonRadius() -> some View {
        self.cornerRadius(AppRadius.component.button)
    }

    /// Apply card radius
    func appCardRadius() -> some View {
        self.cornerRadius(AppRadius.component.card)
    }

    /// Apply input radius
    func appInputRadius() -> some View {
        self.cornerRadius(AppRadius.component.input)
    }
}

// MARK: - Radius Size Enum
enum AppRadiusSize {
    case none, xs, small, medium, large, xl, full

    var value: CGFloat {
        switch self {
        case .none: return AppRadius.none
        case .xs: return AppRadius.xs
        case .small: return AppRadius.sm
        case .medium: return AppRadius.md
        case .large: return AppRadius.lg
        case .xl: return AppRadius.xl
        case .full: return AppRadius.full
        }
    }
}

// MARK: - RoundedRectangle Extensions
extension RoundedRectangle {
    static var appButton: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.component.button)
    }

    static var appCard: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.component.card)
    }

    static var appInput: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.component.input)
    }
}
