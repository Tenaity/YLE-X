//
//  AppGradient.swift
//  YLE X
//
//  Modern Gradient System - iOS 17 Style
//  Created by Senior iOS Designer on 11/8/25.
//

import SwiftUI

// MARK: - Gradient Presets
extension LinearGradient {

    // MARK: - Primary Gradients

    /// Vibrant blue gradient (Primary brand)
    static var appPrimary: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.48, blue: 1.0),    // iOS Blue
                Color(red: 0.3, green: 0.68, blue: 1.0)     // Light Blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Purple magic gradient (Secondary brand)
    static var appSecondary: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.5, green: 0.25, blue: 1.0),    // Purple
                Color(red: 0.7, green: 0.45, blue: 1.0)     // Light Purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Sunset gradient (Accent/Energy)
    static var appAccent: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.0),     // Orange
                Color(red: 1.0, green: 0.8, blue: 0.2)      // Yellow
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Success & Achievement Gradients

    /// Green success gradient
    static var appSuccess: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.84, blue: 0.29),   // Green
                Color(red: 0.4, green: 0.94, blue: 0.49)    // Light Green
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Gold achievement gradient
    static var appGold: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.84, blue: 0.0),    // Gold
                Color(red: 1.0, green: 0.92, blue: 0.4),    // Light Gold
                Color(red: 1.0, green: 0.84, blue: 0.0)     // Gold
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Level Gradients

    /// Starters level gradient (Green energy)
    static var appLevelStarters: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.84, blue: 0.29),   // Green
                Color(red: 0.4, green: 0.94, blue: 0.49),   // Light Green
                Color(red: 0.0, green: 0.68, blue: 1.0)     // Sky Blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Movers level gradient (Blue adventure)
    static var appLevelMovers: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.48, blue: 1.0),    // Blue
                Color(red: 0.3, green: 0.68, blue: 1.0),    // Light Blue
                Color(red: 0.5, green: 0.25, blue: 1.0)     // Purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Flyers level gradient (Purple mastery)
    static var appLevelFlyers: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.5, green: 0.25, blue: 1.0),    // Purple
                Color(red: 0.7, green: 0.19, blue: 0.89),   // Magenta
                Color(red: 1.0, green: 0.21, blue: 0.5)     // Pink
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Background Gradients

    /// Subtle background gradient (Light theme)
    static var appBackgroundLight: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 1.0),   // Very light blue
                Color(red: 1.0, green: 1.0, blue: 1.0)      // White
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle background gradient (Dark theme)
    static var appBackgroundDark: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.08),  // Dark blue
                Color(red: 0.08, green: 0.08, blue: 0.12)   // Darker blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Card glass gradient (Glassmorphism)
    static var appGlass: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.7),
                Color.white.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Special Effect Gradients

    /// Rainbow gradient (Celebrations, achievements)
    static var appRainbow: LinearGradient {
        LinearGradient(
            colors: [
                Color.red,
                Color.orange,
                Color.yellow,
                Color.green,
                Color.blue,
                Color.purple
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Shimmer effect gradient (Loading states)
    static var appShimmer: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.0),
                Color.white.opacity(0.5),
                Color.white.opacity(0.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Cosmic gradient (Premium, special)
    static var appCosmic: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.0, blue: 0.3),     // Deep purple
                Color(red: 0.3, green: 0.0, blue: 0.5),     // Purple
                Color(red: 0.0, green: 0.2, blue: 0.5),     // Blue
                Color(red: 0.0, green: 0.4, blue: 0.6)      // Cyan
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Angular Gradient Presets
extension AngularGradient {

    /// Circular rainbow (For progress rings, badges)
    static var appCircularRainbow: AngularGradient {
        AngularGradient(
            colors: [
                Color.red,
                Color.orange,
                Color.yellow,
                Color.green,
                Color.blue,
                Color.purple,
                Color.red
            ],
            center: .center,
            startAngle: .zero,
            endAngle: .degrees(360)
        )
    }

    /// Circular glow (For XP rings)
    static var appCircularGlow: AngularGradient {
        AngularGradient(
            colors: [
                Color.appPrimary,
                Color.appAccent,
                Color.appSecondary,
                Color.appPrimary
            ],
            center: .center,
            startAngle: .zero,
            endAngle: .degrees(360)
        )
    }
}

// MARK: - Radial Gradient Presets
extension RadialGradient {

    /// Spotlight effect (For featured items)
    static var appSpotlight: RadialGradient {
        RadialGradient(
            colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.0)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
    }

    /// Glow effect (For buttons, badges)
    static var appGlow: RadialGradient {
        RadialGradient(
            colors: [
                Color.appAccent.opacity(0.5),
                Color.appAccent.opacity(0.0)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 50
        )
    }
}

// MARK: - Gradient View Modifiers
extension View {

    /// Apply gradient overlay
    func gradientOverlay(_ gradient: LinearGradient) -> some View {
        self.overlay(gradient.mask(self))
    }

    /// Apply gradient background
    func gradientBackground(_ gradient: LinearGradient) -> some View {
        self.background(gradient)
    }

    /// Apply animated shimmer effect
    func shimmerEffect(isAnimating: Bool = true) -> some View {
        self.modifier(ShimmerEffect(isAnimating: isAnimating))
    }
}

// MARK: - Shimmer Animation Modifier
struct ShimmerEffect: ViewModifier {
    let isAnimating: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient.appShimmer
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .mask(content)
            )
            .onAppear {
                guard isAnimating else { return }
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

// MARK: - Gradient Card Background
struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content

    init(gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }

    var body: some View {
        content
            .background(
                ZStack {
                    gradient

                    // Add subtle texture overlay
                    Color.white.opacity(0.05)
                        .blendMode(.overlay)
                }
            )
    }
}
