//
//  AppSpacing.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

// MARK: - App Spacing System (Based on 4pt grid)
struct AppSpacing {
    // MARK: - Base Spacing (4pt grid system)
    static let xxxs: CGFloat = 2.0   // 2pt - Minimal spacing
    static let xxs: CGFloat = 4.0    // 4pt - Very tight
    static let xs: CGFloat = 8.0     // 8pt - Tight
    static let sm: CGFloat = 12.0    // 12pt - Small
    static let md: CGFloat = 16.0    // 16pt - Medium (default)
    static let lg: CGFloat = 24.0    // 24pt - Large
    static let xl: CGFloat = 32.0    // 32pt - Extra large
    static let xxl: CGFloat = 48.0   // 48pt - XXL
    static let xxxl: CGFloat = 64.0  // 64pt - XXXL
    
    // MARK: - Semantic Spacing (Readable names)
    static let minimal = xxxs        // For very tight layouts
    static let tight = xs            // For compact UI elements  
    static let comfortable = md      // For general use
    static let spacious = lg         // For breathing room
    static let generous = xl         // For clear separation
    
    // MARK: - Component-Specific Spacing
    struct Button {
        static let paddingHorizontal = md     // 16pt
        static let paddingVertical = sm       // 12pt
        static let cornerRadius = xs          // 8pt
        static let spacing = xs               // 8pt between buttons
    }
    
    struct Card {
        static let padding = lg               // 24pt internal padding
        static let spacing = md               // 16pt between cards  
        static let cornerRadius = sm          // 12pt
        static let shadowOffset = xxxs        // 2pt
    }
    
    struct Screen {
        static let horizontalMargin = lg      // 24pt side margins
        static let verticalMargin = md        // 16pt top/bottom margins
        static let sectionSpacing = xl        // 32pt between sections
    }
    
    struct List {
        static let itemSpacing = md           // 16pt between list items
        static let itemPadding = md           // 16pt internal item padding
        static let groupSpacing = lg          // 24pt between groups
    }
    
    struct Navigation {
        static let barHeight: CGFloat = 44.0  // Standard nav bar height
        static let tabBarHeight: CGFloat = 49.0 // Standard tab bar height
        static let buttonSpacing = lg         // 24pt between nav buttons
    }
    
    // MARK: - Kid-Friendly Spacing (Larger touch targets)
    struct KidFriendly {
        static let buttonMinSize: CGFloat = 44.0    // Minimum touch target
        static let buttonPadding = lg               // 24pt for easier tapping
        static let elementSpacing = lg              // 24pt between elements
        static let cardPadding = xl                 // 32pt internal padding
    }
    
    // MARK: - Accessibility Spacing
    struct Accessibility {
        static let minTouchTarget: CGFloat = 44.0   // Apple's minimum
        static let recommendedTouchTarget: CGFloat = 60.0 // Recommended for accessibility
        static let elementSpacing = xl              // 32pt for clear separation
    }
}

// MARK: - Spacing Extensions for SwiftUI
extension EdgeInsets {
    // MARK: - Symmetric Insets
    static let appTiny = EdgeInsets(top: AppSpacing.xxs, leading: AppSpacing.xxs, bottom: AppSpacing.xxs, trailing: AppSpacing.xxs)
    static let appSmall = EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.xs, bottom: AppSpacing.xs, trailing: AppSpacing.xs)
    static let appMedium = EdgeInsets(top: AppSpacing.md, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md)
    static let appLarge = EdgeInsets(top: AppSpacing.lg, leading: AppSpacing.lg, bottom: AppSpacing.lg, trailing: AppSpacing.lg)
    
    // MARK: - Screen-Level Insets
    static let appScreen = EdgeInsets(
        top: AppSpacing.Screen.verticalMargin,
        leading: AppSpacing.Screen.horizontalMargin,
        bottom: AppSpacing.Screen.verticalMargin,
        trailing: AppSpacing.Screen.horizontalMargin
    )
    
    // MARK: - Card Insets
    static let appCard = EdgeInsets(
        top: AppSpacing.Card.padding,
        leading: AppSpacing.Card.padding,
        bottom: AppSpacing.Card.padding,
        trailing: AppSpacing.Card.padding
    )
}

// MARK: - SwiftUI View Extensions
extension View {
    // MARK: - Quick Padding Applications
    func appPadding(_ spacing: AppSpacingSize = .medium) -> some View {
        switch spacing {
        case .tiny: return self.padding(AppSpacing.xxs)
        case .small: return self.padding(AppSpacing.xs)
        case .medium: return self.padding(AppSpacing.md)
        case .large: return self.padding(AppSpacing.lg)
        case .extraLarge: return self.padding(AppSpacing.xl)
        }
    }
    
    // MARK: - Component-Specific Padding
    func appScreenPadding() -> some View {
        self.padding(.horizontal, AppSpacing.Screen.horizontalMargin)
            .padding(.vertical, AppSpacing.Screen.verticalMargin)
    }
    
    func appCardPadding() -> some View {
        self.padding(AppSpacing.Card.padding)
    }
    
    func appButtonPadding() -> some View {
        self.padding(.horizontal, AppSpacing.Button.paddingHorizontal)
            .padding(.vertical, AppSpacing.Button.paddingVertical)
    }
}

// MARK: - Spacing Size Enum
enum AppSpacingSize {
    case tiny, small, medium, large, extraLarge
}
