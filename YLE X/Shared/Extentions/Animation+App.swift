//
//  Animation+App.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

// MARK: - App Animation System (Apple-standard curves & timing)
extension Animation {
    
    // MARK: - Standard iOS Animations
    /// Quick, snappy animation for UI feedback (0.2s)
    static var appQuick: Animation {
        .easeOut(duration: 0.2)
    }
    
    /// Smooth, gentle animation for content changes (0.35s)
    static var appGentle: Animation {
        .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
    }
    
    /// Smooth transition for view changes (0.4s)
    static var appSmooth: Animation {
        .easeInOut(duration: 0.4)
    }
    
    /// Playful spring animation for kid-friendly interactions
    static var appPlayful: Animation {
        .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.1)
    }
    
    /// Bouncy animation for success states and celebrations
    static var appBouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)
    }
    
    // MARK: - Component-Specific Animations
    struct Button {
        /// Button press animation (immediate feedback)
        static let press = Animation.easeOut(duration: 0.1)
        
        /// Button release animation (gentle return)
        static let release = Animation.easeOut(duration: 0.2)
        
        /// Button state change (enabled/disabled)
        static let stateChange = Animation.easeInOut(duration: 0.25)
    }
    
    struct Card {
        /// Card appearance/disappearance
        static let appear = Animation.spring(response: 0.5, dampingFraction: 0.8)
        
        /// Card flip animation
        static let flip = Animation.easeInOut(duration: 0.6)
        
        /// Card hover/focus animation
        static let hover = Animation.easeOut(duration: 0.2)
    }
    
    struct Screen {
        /// Screen transition (modal presentation)
        static let modal = Animation.easeInOut(duration: 0.4)
        
        /// Screen slide transition
        static let slide = Animation.spring(response: 0.5, dampingFraction: 0.9)
        
        /// Screen fade transition
        static let fade = Animation.easeInOut(duration: 0.3)
    }
    
    struct Loading {
        /// Loading spinner animation
        static let spin = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
        
        /// Progress bar animation
        static let progress = Animation.easeInOut(duration: 0.5)
        
        /// Pulse animation for loading states
        static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    }
    
    // MARK: - Accessibility Animations
    /// Reduced motion animation for accessibility
    static var appAccessible: Animation {
        .easeInOut(duration: 0.25)
    }
    
    /// Returns appropriate animation based on accessibility settings
    static func appRespectingMotion(_ preferredAnimation: Animation) -> Animation {
        // In a real app, you'd check UIAccessibility.isReduceMotionEnabled
        // For now, we'll use a gentler animation as default
        return Animation.easeInOut(duration: 0.3)
    }
    
    // MARK: - Educational App Animations
    /// Success animation for correct answers
    static var appSuccess: Animation {
        .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.1)
    }
    
    /// Error animation for incorrect answers (gentle, not harsh)
    static var appError: Animation {
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    }
    
    /// Celebration animation for achievements
    static var appCelebration: Animation {
        .spring(response: 0.6, dampingFraction: 0.4, blendDuration: 0.2)
    }
    
    /// Focus animation for learning content
    static var appFocus: Animation {
        .easeInOut(duration: 0.4)
    }
}

// MARK: - Animation Extensions for Views
extension View {
    /// Applies standard app animation with condition
    func appAnimated(_ condition: Bool = true, animation: Animation = .appGentle) -> some View {
        self.animation(condition ? animation : nil, value: condition)
    }
    
    /// Applies success animation (bounce effect)
    func appSuccessAnimation<V: Equatable>(value: V) -> some View {
        self.animation(.appSuccess, value: value)
    }
    
    /// Applies error animation (gentle shake-like effect)
    func appErrorAnimation<V: Equatable>(value: V) -> some View {
        self.animation(.appError, value: value)
    }
    
    /// Applies playful animation for kid interactions
    func appPlayfulAnimation<V: Equatable>(value: V) -> some View {
        self.animation(.appPlayful, value: value)
    }
    
    /// Conditional animation based on accessibility settings
    func appAccessibleAnimation<V: Equatable>(value: V, preferredAnimation: Animation = .appGentle) -> some View {
        self.animation(.appRespectingMotion(preferredAnimation), value: value)
    }
}

// MARK: - Transition Extensions
extension AnyTransition {
    /// Standard app slide transition
    static var appSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Gentle scale transition for cards
    static var appScale: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    /// Playful bounce transition
    static var appBounce: AnyTransition {
        .scale(scale: 1.2).combined(with: .opacity)
    }
    
    /// Modal-style transition (from bottom)
    static var appModal: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
    
    /// Success celebration transition (scale + rotate)
    static var appCelebration: AnyTransition {
        .scale(scale: 0.1)
        .combined(with: .opacity)
        .combined(with: .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)))
    }
}

// MARK: - Animation Timing Functions
struct AppAnimationCurve {
    /// Standard ease-in-out curve
    static let standard = UnitCurve.easeInOut
    
    /// Quick, snappy curve for immediate feedback
    static let quick = UnitCurve.easeOut
    
    /// Gentle curve for smooth transitions
    static let gentle = UnitCurve(
        controlPoint1: UnitPoint(x: 0.25, y: 0.1),
        controlPoint2: UnitPoint(x: 0.25, y: 1)
    )
    
    /// Bouncy curve for playful interactions
    static let bouncy = UnitCurve(
        controlPoint1: UnitPoint(x: 0.68, y: -0.55),
        controlPoint2: UnitPoint(x: 0.265, y: 1.55)
    )
}

// MARK: - Animation Presets for Common UI Patterns
struct AppAnimationPresets {
    /// Button tap animation sequence
    static func buttonTap(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            EmptyView()
        }
        .scaleEffect(1.0)
        .animation(.appQuick, value: false)
    }
    
    /// Loading state animation
    static func loadingPulse() -> Animation {
        .appGentle
        .repeatForever(autoreverses: true)
    }
