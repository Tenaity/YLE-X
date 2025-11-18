//
//  AppGlass.swift
//  YLE X
//
//  Glassmorphism Design System - iOS 17 Style
//  Created by Senior iOS Designer on 11/8/25.
//

import SwiftUI

// MARK: - Glass Style Enum
enum GlassStyle {
    case ultraThin
    case thin
    case regular
    case thick
    case ultraThick

    var material: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .thin: return .thinMaterial
        case .regular: return .regularMaterial
        case .thick: return .thickMaterial
        case .ultraThick: return .ultraThickMaterial
        }
    }

    var borderOpacity: Double {
        switch self {
        case .ultraThin: return 0.1
        case .thin: return 0.15
        case .regular: return 0.2
        case .thick: return 0.25
        case .ultraThick: return 0.3
        }
    }
}

// MARK: - Glass Effect Modifier
struct GlassEffect: ViewModifier {
    let style: GlassStyle
    let tint: Color?
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Glassmorphism background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(style.material)

                    // Optional tint
                    if let tint = tint {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tint.opacity(0.1))
                    }

                    // Subtle border for depth
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(style.borderOpacity),
                                    Color.white.opacity(style.borderOpacity * 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
    }
}

// MARK: - View Extension for Glass
extension View {

    /// Apply glassmorphism effect
    func glassEffect(
        style: GlassStyle = .regular,
        tint: Color? = nil,
        cornerRadius: CGFloat = AppRadius.lg
    ) -> some View {
        self.modifier(GlassEffect(style: style, tint: tint, cornerRadius: cornerRadius))
    }

    /// Premium glass card with shadow
    func premiumGlassCard(
        style: GlassStyle = .regular,
        cornerRadius: CGFloat = AppRadius.xl
    ) -> some View {
        self
            .padding(AppSpacing.lg)
            .glassEffect(style: style, cornerRadius: cornerRadius)
            .appShadow(level: .medium)
    }
}

// MARK: - Frosted Glass Background
struct FrostedGlassBackground: View {
    let style: GlassStyle
    let tint: Color?

    init(style: GlassStyle = .regular, tint: Color? = nil) {
        self.style = style
        self.tint = tint
    }

    var body: some View {
        ZStack {
            // Base blur
            Rectangle()
                .fill(style.material)

            // Tint overlay
            if let tint = tint {
                Rectangle()
                    .fill(tint.opacity(0.15))
                    .blendMode(.overlay)
            }

            // Noise texture for realism
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .blendMode(.overlay)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Card Component
struct GlassCard<Content: View>: View {
    let content: Content
    let style: GlassStyle
    let cornerRadius: CGFloat
    let padding: CGFloat

    init(
        style: GlassStyle = .regular,
        cornerRadius: CGFloat = AppRadius.xl,
        padding: CGFloat = AppSpacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(style.material)

                    // Highlight gradient on top edge
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 1)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .frame(maxHeight: .infinity, alignment: .top)

                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(style.borderOpacity),
                                    Color.white.opacity(style.borderOpacity * 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .appShadow(level: .light)
    }
}

// MARK: - Neumorphism Style (Alternative to Glass)
struct NeumorphicEffect: ViewModifier {
    let lightShadowColor: Color
    let darkShadowColor: Color
    let cornerRadius: CGFloat

    init(
        lightShadowColor: Color = Color.white.opacity(0.7),
        darkShadowColor: Color = Color.black.opacity(0.2),
        cornerRadius: CGFloat = AppRadius.lg
    ) {
        self.lightShadowColor = lightShadowColor
        self.darkShadowColor = darkShadowColor
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.appBackgroundSecondary)
                        .shadow(color: darkShadowColor, radius: 10, x: 5, y: 5)
                        .shadow(color: lightShadowColor, radius: 10, x: -5, y: -5)
                }
            )
    }
}

extension View {
    /// Apply neumorphic design
    func neumorphic(cornerRadius: CGFloat = AppRadius.lg) -> some View {
        self.modifier(NeumorphicEffect(cornerRadius: cornerRadius))
    }
}

// MARK: - Gradient Glass Card (Premium)
struct GradientGlassCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    let cornerRadius: CGFloat

    init(
        gradient: LinearGradient,
        cornerRadius: CGFloat = AppRadius.xl,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.content = content()
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background(
                ZStack {
                    // Gradient background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(gradient)

                    // Glass overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)

                    // Highlight
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                }
            )
            .appShadow(level: .heavy)
    }
}
