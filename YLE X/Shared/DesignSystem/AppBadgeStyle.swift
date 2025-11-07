//
//  AppBadgeStyle.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Badge styling system for achievements and badges
//

import SwiftUI

// MARK: - Badge Style View
struct AppBadgeView: View {
    let badge: Badge
    var size: AppBadgeSize = .medium

    var body: some View {
        let badgeColor = Color(hex: badge.color)

        return VStack(spacing: AppSpacing.xs) {
            // Emoji
            Text(badge.emoji)
                .font(.system(size: size.emojiSize))

            // Name
            Text(badge.name)
                .font(size.nameFont)
                .foregroundColor(.appText)
                .lineLimit(1)
        }
        .frame(width: size.width, height: size.height)
        .padding(size.padding)
        .background(badgeColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(badgeColor, lineWidth: 1.5)
        )
        .cornerRadius(AppRadius.md)
        .appShadow(level: .subtle)
    }
}

// MARK: - Badge Size
enum AppBadgeSize {
    case small, medium, large

    var width: CGFloat {
        switch self {
        case .small: return 80
        case .medium: return 100
        case .large: return 120
        }
    }

    var height: CGFloat {
        switch self {
        case .small: return 80
        case .medium: return 100
        case .large: return 120
        }
    }

    var emojiSize: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 32
        case .large: return 40
        }
    }

    var nameFont: Font {
        switch self {
        case .small: return .appCaptionSmall
        case .medium: return .appCalloutSmall
        case .large: return .appHeadlineSmall
        }
    }

    var padding: CGFloat {
        switch self {
        case .small: return AppSpacing.xs
        case .medium: return AppSpacing.sm
        case .large: return AppSpacing.md
        }
    }
}

// MARK: - Badge List View
struct AppBadgeGridView: View {
    let badges: [Badge]
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
            ForEach(badges) { badge in
                AppBadgeView(badge: badge, size: .medium)
            }
        }
        .padding(AppSpacing.lg)
    }
}

// MARK: - Badge Preview
#Preview {
    VStack(spacing: AppSpacing.lg) {
        Text("Badge Styles")
            .appTitleMedium()

        HStack(spacing: AppSpacing.md) {
            AppBadgeView(badge: .sampleBadge(level: "appBadgeStarters"), size: .small)
            AppBadgeView(badge: .sampleBadge(level: "appBadgeMovers"), size: .medium)
            AppBadgeView(badge: .sampleBadge(level: "appBadgeFlyers"), size: .large)
        }

        HStack(spacing: AppSpacing.md) {
            AppBadgeView(badge: .sampleBadge(level: "appBadgeGold"), size: .medium)
            AppBadgeView(badge: .sampleBadge(level: "appBadgeSilver"), size: .medium)
            AppBadgeView(badge: .sampleBadge(level: "appBadgeBronze"), size: .medium)
        }
    }
    .appPadding(.large)
    .background(Color.appBackground)
}
