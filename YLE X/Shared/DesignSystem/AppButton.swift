//
//  AppButton.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

// MARK: - Modern App Button with Kid-Friendly Design
struct AppButton: View {
    // MARK: - Properties
    let title: String
    var emoji: String? = nil
    var icon: String? = nil
    var style: AppButtonStyle = .primary
    var size: AppButtonSize = .medium
    let action: () -> Void
    
    // MARK: - State
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            HapticManager.shared.playLight()
            action()
        }) {
            HStack(spacing: size.iconSpacing) {
                // Leading content (emoji or icon)
                if let emoji = emoji {
                    Text(emoji)
                        .font(size.emojiFont)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                        .foregroundColor(style.foregroundColor)
                }
                
                // Title
                Text(title)
                    .font(size.textFont)
                    .fontWeight(.semibold)
                    .foregroundColor(style.foregroundColor)
            }
            .frame(maxWidth: size == .fullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
            .appShadow(level: shadowLevel)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.appQuick) {
                isPressed = pressing
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.appQuick) {
                isHovered = hovering
            }
        }
        .accessibilityLabel(title)
        .accessibilityHint("Nhấn để thực hiện \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
    
    private var shadowLevel: AppShadowLevel {
        if isPressed {
            return .subtle
        } else if isHovered {
            return .medium
        } else {
            return style.defaultShadow
        }
    }
}

// MARK: - Button Style Enum
enum AppButtonStyle {
    case primary, secondary, tertiary, success, warning, error, ghost, outline
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .appPrimary
        case .secondary: return .appSecondary
        case .tertiary: return .appCardBackground
        case .success: return .appSuccess
        case .warning: return .appWarning
        case .error: return .appError
        case .ghost: return .clear
        case .outline: return .clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary, .success, .warning, .error: return .white
        case .tertiary, .ghost, .outline: return .appPrimaryText
        }
    }
    
    var borderColor: Color {
        switch self {
        case .outline: return .appPrimaryText.opacity(0.3)
        default: return .clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outline: return 1.5
        default: return 0
        }
    }
    
    var defaultShadow: AppShadowLevel {
        switch self {
        case .primary, .success, .warning, .error: return .light
        case .secondary: return .subtle
        case .tertiary, .ghost, .outline: return .none
        }
    }
}

// MARK: - Button Size Enum
enum AppButtonSize {
    case small, medium, large, extraLarge, fullWidth
    
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        case .extraLarge: return 60
        case .fullWidth: return 52
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return AppSpacing.md
        case .medium: return AppSpacing.lg
        case .large: return AppSpacing.xl
        case .extraLarge: return AppSpacing.xl
        case .fullWidth: return AppSpacing.lg
        }
    }
    
    var textFont: Font {
        switch self {
        case .small: return .appLabelMedium
        case .medium: return .appLabelLarge
        case .large: return .appTitleSmall
        case .extraLarge: return .appTitleMedium
        case .fullWidth: return .appLabelLarge
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small: return .system(size: 14, weight: .medium)
        case .medium: return .system(size: 16, weight: .medium)
        case .large: return .system(size: 18, weight: .medium)
        case .extraLarge: return .system(size: 20, weight: .medium)
        case .fullWidth: return .system(size: 16, weight: .medium)
        }
    }
    
    var emojiFont: Font {
        switch self {
        case .small: return .system(size: 16)
        case .medium: return .system(size: 18)
        case .large: return .system(size: 20)
        case .extraLarge: return .system(size: 22)
        case .fullWidth: return .system(size: 18)
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return AppRadius.small
        case .medium: return AppRadius.medium
        case .large: return AppRadius.large
        case .extraLarge: return AppRadius.large
        case .fullWidth: return AppRadius.medium
        }
    }
    
    var iconSpacing: CGFloat {
        switch self {
        case .small: return AppSpacing.xs
        case .medium: return AppSpacing.sm
        case .large: return AppSpacing.md
        case .extraLarge: return AppSpacing.md
        case .fullWidth: return AppSpacing.sm
        }
    }
}

// MARK: - Specialized App Buttons
struct AppPrimaryButton: View {
    let title: String
    var emoji: String? = nil
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        AppButton(title: title, emoji: emoji, icon: icon, style: .primary, size: .fullWidth, action: action)
    }
}

struct AppSecondaryButton: View {
    let title: String
    var emoji: String? = nil
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        AppButton(title: title, emoji: emoji, icon: icon, style: .secondary, size: .medium, action: action)
    }
}

struct AppIconButton: View {
    let icon: String
    var size: AppButtonSize = .medium
    var style: AppButtonStyle = .tertiary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.iconFont)
                .foregroundColor(style.foregroundColor)
                .frame(width: size.height, height: size.height)
                .background(
                    Circle()
                        .fill(style.backgroundColor)
                )
                .appShadow(level: style.defaultShadow)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Kid-Friendly Button Variants
struct AppKidButton: View {
    let title: String
    let emoji: String
    var color: Color = .appPrimary
    let action: () -> Void
    
    var body: some View {
        AppButton(
            title: title,
            emoji: emoji,
            style: .primary,
            size: .extraLarge,
            action: action
        )
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge)
                .fill(color)
                .appKidFriendlyShadow()
        )
    }
}

// MARK: - Button Previews
struct AppButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.lg) {
            AppButton(title: "Primary Button", emoji: "🎉", style: .primary, size: .fullWidth, action: {})
            AppButton(title: "Secondary", icon: "star.fill", style: .secondary, size: .medium, action: {})
            AppButton(title: "Success", style: .success, size: .large, action: {})
            AppIconButton(icon: "heart.fill", style: .tertiary, action: {})
            AppKidButton(title: "Kid Friendly", emoji: "🌟", color: .appSuccess, action: {})
        }
        .padding()
        .background(Color.appBackground)
    }
}
