//
//  AppColor.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Color system following Apple Design Guidelines
//

import SwiftUI

// MARK: - Semantic Colors (Adaptive to light/dark mode)
extension Color {
    // MARK: - Text Colors
    /// Primary text color (labels, body text)
    static let appText = Color(.label)
    /// Secondary text color (subheadings, captions)
    static let appTextSecondary = Color(.secondaryLabel)
    /// Tertiary text color (very subtle text)
    static let appTextTertiary = Color(.tertiaryLabel)

    // MARK: - Background Colors
    /// Primary background color
    static let appBackground = Color(.systemBackground)
    /// Secondary background color (cards, grouped content)
    static let appBackgroundSecondary = Color(.secondarySystemBackground)
    /// Tertiary background color (grouped backgrounds)
    static let appBackgroundTertiary = Color(.tertiarySystemBackground)
    /// Grouped background
    static let appBackgroundGrouped = Color(.systemGroupedBackground)
    /// Secondary grouped background
    static let appBackgroundGroupedSecondary = Color(.secondarySystemGroupedBackground)

    // MARK: - Brand Colors (Primary palette)
    /// Primary brand color (CTA, focus)
    static let appPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)      // iOS Blue
    /// Secondary brand color (supporting element)
    static let appSecondary = Color(red: 0.5, green: 0.25, blue: 1.0)    // Purple
    /// Accent brand color (highlights, emphasis)
    static let appAccent = Color(red: 1.0, green: 0.6, blue: 0.0)        // Orange

    // MARK: - Status Colors (Semantic for states)
    /// Success state
    static let appSuccess = Color(red: 0.2, green: 0.84, blue: 0.29)     // Green
    /// Error/Destructive state
    static let appError = Color(red: 1.0, green: 0.23, blue: 0.19)       // Red
    /// Warning state
    static let appWarning = Color(red: 1.0, green: 0.58, blue: 0.0)      // Orange
    /// Information state
    static let appInfo = Color(red: 0.2, green: 0.68, blue: 1.0)         // Light Blue

    // MARK: - Divider & Separator
    /// Divider line color
    static let appDivider = Color(.separator)
    /// Opaque divider color
    static let appDividerOpaque = Color(.opaqueSeparator)

    // MARK: - Fill Colors (for components)
    /// Light fill (subtle background)
    static let appFillLight = Color(.systemFill)
    /// Secondary fill
    static let appFillSecondary = Color(.secondarySystemFill)
    /// Tertiary fill
    static let appFillTertiary = Color(.tertiarySystemFill)
    /// Quaternary fill
    static let appFillQuaternary = Color(.quaternarySystemFill)

    // MARK: - YLE Level Colors (for visual identification)
    /// Starters level color
    static let appLevelStarters = Color(red: 0.2, green: 0.84, blue: 0.29)      // Green
    /// Movers level color
    static let appLevelMovers = Color(red: 0.0, green: 0.48, blue: 1.0)         // Blue
    /// Flyers level color
    static let appLevelFlyers = Color(red: 0.7, green: 0.19, blue: 0.89)        // Purple

    // MARK: - Skill Colors (for visual differentiation)
    /// Listening skill
    static let appSkillListening = Color(red: 0.0, green: 0.68, blue: 1.0)      // Sky Blue
    /// Speaking skill
    static let appSkillSpeaking = Color(red: 1.0, green: 0.52, blue: 0.0)       // Orange
    /// Reading skill
    static let appSkillReading = Color(red: 0.1, green: 0.71, blue: 0.4)        // Green
    /// Writing skill
    static let appSkillWriting = Color(red: 0.6, green: 0.21, blue: 0.79)       // Purple
    /// Vocabulary skill
    static let appSkillVocabulary = Color(red: 1.0, green: 0.21, blue: 0.5)     // Pink
    /// Grammar skill
    static let appSkillGrammar = Color(red: 0.0, green: 0.81, blue: 0.82)       // Cyan

    // MARK: - Badge Colors (for achievements)
    /// Badge color - Starters level (Green)
    static let appBadgeStarters = Color(red: 0.2, green: 0.84, blue: 0.29)      // Green
    /// Badge color - Movers level (Blue)
    static let appBadgeMovers = Color(red: 0.0, green: 0.48, blue: 1.0)         // Blue
    /// Badge color - Flyers level (Purple)
    static let appBadgeFlyers = Color(red: 0.7, green: 0.19, blue: 0.89)        // Purple
    /// Badge color - Gold (Special achievement)
    static let appBadgeGold = Color(red: 1.0, green: 0.84, blue: 0.0)          // Gold
    /// Badge color - Silver (Secondary achievement)
    static let appBadgeSilver = Color(red: 0.75, green: 0.75, blue: 0.75)      // Silver
    /// Badge color - Bronze (Tertiary achievement)
    static let appBadgeBronze = Color(red: 0.8, green: 0.5, blue: 0.2)         // Bronze
}

// MARK: - Color Utilities
extension Color {
    /// Creates a color with opacity adjustment
    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }

    /// Returns the color in light mode variant
    static func appDynamic(light: Color, dark: Color) -> Color {
        Color(.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
