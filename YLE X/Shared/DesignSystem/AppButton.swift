//
//  AppButton.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Button component following Apple Design Guidelines
//

import SwiftUI

// MARK: - AppButton (Primary Component)
struct AppButton: View {
    // MARK: - Configuration
    let title: String
    var icon: String?
    var size: AppButtonSize = .medium
    var style: AppButtonStyle = .primary
    let action: () -> Void

    // MARK: - State
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.playLight()
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: size == .fullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.paddingHorizontal)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .cornerRadius(AppRadius.component.button)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.component.button)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .appShadow(level: isPressed ? .subtle : style.shadowLevel)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeOut(duration: 0.15)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .disabled(!style.isEnabled)
        .opacity(style.isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Button Size
enum AppButtonSize {
    case small, medium, large, fullWidth

    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        case .fullWidth: return 44
        }
    }

    var font: Font {
        switch self {
        case .small: return .appHeadlineSmall
        case .medium: return .appHeadlineMedium
        case .large: return .appHeadlineLarge
        case .fullWidth: return .appHeadlineMedium
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .fullWidth: return 16
        }
    }

    var paddingHorizontal: CGFloat {
        switch self {
        case .small: return AppSpacing.sm
        case .medium: return AppSpacing.md
        case .large: return AppSpacing.lg
        case .fullWidth: return AppSpacing.md
        }
    }
}

// MARK: - Button Style
enum AppButtonStyle {
    case primary, secondary, tertiary, destructive, plain

    var backgroundColor: Color {
        switch self {
        case .primary: return .appPrimary
        case .secondary: return .appBackgroundSecondary
        case .tertiary: return .appFillLight
        case .destructive: return .appError
        case .plain: return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .destructive: return .white
        case .secondary, .tertiary: return .appText
        case .plain: return .appPrimary
        }
    }

    var borderColor: Color {
        switch self {
        case .plain: return .appText.opacity(0.3)
        default: return .clear
        }
    }

    var borderWidth: CGFloat {
        self == .plain ? 1.5 : 0
    }

    var shadowLevel: AppShadowLevel {
        switch self {
        case .primary, .destructive: return .light
        case .secondary: return .subtle
        case .tertiary, .plain: return .none
        }
    }

    var isEnabled: Bool {
        self != .destructive  // Destructive can be disabled
    }
}

// MARK: - Specialized Button Variants
struct AppPrimaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        AppButton(title: title, icon: icon, size: .fullWidth, style: .primary, action: action)
    }
}

struct AppSecondaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        AppButton(title: title, icon: icon, size: .medium, style: .secondary, action: action)
    }
}

struct AppTertiaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        AppButton(title: title, icon: icon, size: .medium, style: .tertiary, action: action)
    }
}

struct AppDestructiveButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        AppButton(title: title, icon: icon, size: .fullWidth, style: .destructive, action: action)
    }
}

struct AppIconButton: View {
    let icon: String
    var size: AppButtonSize = .medium
    var style: AppButtonStyle = .tertiary
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.playLight()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(style.foregroundColor)
                .frame(
                    width: size.height,
                    height: size.height
                )
                .background(style.backgroundColor)
                .cornerRadius(size.height / 2)
                .appShadow(level: style.shadowLevel)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppSpacing.lg) {
        AppButton(title: "Primary Button", size: .fullWidth, style: .primary, action: {})
        AppButton(title: "Secondary", size: .medium, style: .secondary, action: {})
        AppButton(title: "Tertiary", size: .medium, style: .tertiary, action: {})
        AppButton(title: "Destructive", size: .fullWidth, style: .destructive, action: {})

        HStack(spacing: AppSpacing.md) {
            AppIconButton(icon: "heart.fill", style: .primary, action: {})
            AppIconButton(icon: "star.fill", style: .secondary, action: {})
            AppIconButton(icon: "xmark", style: .tertiary, action: {})
        }
    }
    .appPadding(.large)
    .background(Color.appBackground)
}
