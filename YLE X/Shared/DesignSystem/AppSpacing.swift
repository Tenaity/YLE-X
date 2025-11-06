//
//  AppSpacing.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Spacing system following Apple Design Guidelines (8pt base)
//

import SwiftUI

// MARK: - Spacing Scale (8pt grid system)
struct AppSpacing {
    // MARK: - Base Scale (8pt grid)
    static let xs2: CGFloat = 4.0      // 4pt - Extra tight
    static let xs: CGFloat = 8.0       // 8pt - Tight
    static let sm: CGFloat = 12.0      // 12pt - Small
    static let md: CGFloat = 16.0      // 16pt - Medium (default)
    static let lg: CGFloat = 24.0      // 24pt - Large
    static let xl: CGFloat = 32.0      // 32pt - Extra large
    static let xl2: CGFloat = 48.0     // 48pt - Double extra large
    static let xl3: CGFloat = 64.0     // 64pt - Triple extra large

    // MARK: - Component Spacing
    struct component {
        static let buttonPaddingHorizontal = AppSpacing.md
        static let buttonPaddingVertical = AppSpacing.sm
        static let buttonSpacing = AppSpacing.xs
        static let buttonMinHeight: CGFloat = 44.0     // Apple minimum

        static let cardPadding = AppSpacing.lg
        static let cardSpacing = AppSpacing.md
        static let cardMinHeight: CGFloat = 64.0

        static let listItemPadding = AppSpacing.md
        static let listItemSpacing = AppSpacing.md
        static let listGroupSpacing = AppSpacing.lg

        static let screenHorizontalMargin = AppSpacing.lg
        static let screenVerticalMargin = AppSpacing.md
        static let screenSectionSpacing = AppSpacing.xl
    }

    // MARK: - Navigation Spacing
    struct navigation {
        static let barHeight: CGFloat = 44.0
        static let tabBarHeight: CGFloat = 49.0
        static let buttonSpacing = AppSpacing.lg
        static let itemSpacing = AppSpacing.md
    }

    // MARK: - Accessibility (Minimum touch target)
    struct accessibility {
        static let minTouchTarget: CGFloat = 44.0      // Apple minimum
        static let recommendedTouchTarget: CGFloat = 60.0
    }
}

// MARK: - View Modifiers for Spacing
extension View {
    /// Apply standard app padding
    func appPadding(_ size: AppPaddingSize = .medium) -> some View {
        let value = size.value
        return self.padding(value)
    }

    /// Apply horizontal padding only
    func appPaddingHorizontal(_ size: AppPaddingSize = .medium) -> some View {
        let value = size.value
        return self.padding(.horizontal, value)
    }

    /// Apply vertical padding only
    func appPaddingVertical(_ size: AppPaddingSize = .medium) -> some View {
        let value = size.value
        return self.padding(.vertical, value)
    }

    /// Apply screen-level padding
    func appScreenPadding() -> some View {
        self.padding(.horizontal, AppSpacing.component.screenHorizontalMargin)
            .padding(.vertical, AppSpacing.component.screenVerticalMargin)
    }

    /// Apply card padding
    func appCardPadding() -> some View {
        self.padding(AppSpacing.component.cardPadding)
    }

    /// Apply button padding
    func appButtonPadding() -> some View {
        self.padding(.horizontal, AppSpacing.component.buttonPaddingHorizontal)
            .padding(.vertical, AppSpacing.component.buttonPaddingVertical)
    }
}

// MARK: - Padding Size Enum
enum AppPaddingSize {
    case xs2, xs, small, medium, large, xl, xl2, xl3

    var value: CGFloat {
        switch self {
        case .xs2: return AppSpacing.xs2
        case .xs: return AppSpacing.xs
        case .small: return AppSpacing.sm
        case .medium: return AppSpacing.md
        case .large: return AppSpacing.lg
        case .xl: return AppSpacing.xl
        case .xl2: return AppSpacing.xl2
        case .xl3: return AppSpacing.xl3
        }
    }
}

// MARK: - EdgeInsets Extensions
extension EdgeInsets {
    static let appXs = EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.xs, bottom: AppSpacing.xs, trailing: AppSpacing.xs)
    static let appSmall = EdgeInsets(top: AppSpacing.sm, leading: AppSpacing.sm, bottom: AppSpacing.sm, trailing: AppSpacing.sm)
    static let appMedium = EdgeInsets(top: AppSpacing.md, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md)
    static let appLarge = EdgeInsets(top: AppSpacing.lg, leading: AppSpacing.lg, bottom: AppSpacing.lg, trailing: AppSpacing.lg)
    static let appXl = EdgeInsets(top: AppSpacing.xl, leading: AppSpacing.xl, bottom: AppSpacing.xl, trailing: AppSpacing.xl)

    static let appScreen = EdgeInsets(
        top: AppSpacing.component.screenVerticalMargin,
        leading: AppSpacing.component.screenHorizontalMargin,
        bottom: AppSpacing.component.screenVerticalMargin,
        trailing: AppSpacing.component.screenHorizontalMargin
    )

    static let appCard = EdgeInsets(
        top: AppSpacing.component.cardPadding,
        leading: AppSpacing.component.cardPadding,
        bottom: AppSpacing.component.cardPadding,
        trailing: AppSpacing.component.cardPadding
    )
}
