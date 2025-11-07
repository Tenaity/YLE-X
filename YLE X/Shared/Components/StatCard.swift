//
//  StatCard.swift
//  YLE X
//
//  Created by Tenaity on 7/11/25.
//

import SwiftUI

public struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let color: Color

    public init(icon: String, title: String, value: String, subtitle: String? = nil, color: Color) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .cornerRadius(AppRadius.md)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appText)

                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }
}
