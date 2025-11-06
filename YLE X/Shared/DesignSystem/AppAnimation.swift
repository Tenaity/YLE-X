//
//  AppAnimation.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Animation system following Apple Design Guidelines
//

import SwiftUI

// MARK: - Animation Presets
extension Animation {
    // MARK: - Standard Animations
    /// Quick, snappy response animation
    static var appQuick: Animation {
        .easeOut(duration: 0.15)
    }

    /// Smooth, gentle transition
    static var appSmooth: Animation {
        .easeInOut(duration: 0.3)
    }

    /// Gentle spring animation
    static var appGentle: Animation {
        .spring(response: 0.5, dampingFraction: 0.7)
    }

    /// Bouncy spring animation
    static var appBouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.5)
    }
}

// MARK: - Transition Presets
extension AnyTransition {
    /// Standard slide transition
    static var appSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    /// Scale fade transition
    static var appScale: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    /// Modal transition from bottom
    static var appModal: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
}

// MARK: - View Modifier for Conditional Animation
extension View {
    /// Apply animation conditionally
    func appAnimated(_ condition: Bool = true, animation: Animation = .appSmooth) -> some View {
        self.animation(condition ? animation : nil, value: condition)
    }
}
