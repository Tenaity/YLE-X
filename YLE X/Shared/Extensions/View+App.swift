//
//  View+App.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  View extensions for common modifiers
//

import SwiftUI

// MARK: - View Accessibility Extensions
extension View {
    /// Add accessibility label
    func appAccessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(label)
    }

    /// Add accessibility hint
    func appAccessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(hint)
    }

    /// Mark as button for accessibility
    func appAsButton() -> some View {
        self.accessibilityAddTraits(.isButton)
    }

    /// Mark as header for accessibility
    func appAsHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }
}

// MARK: - View Layout Extensions
extension View {
    /// Make view take full width
    func fullWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }

    /// Make view take full height
    func fullHeight() -> some View {
        self.frame(maxHeight: .infinity)
    }

    /// Make view square with given size
    func square(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    /// Make view circle
    func circle(_ size: CGFloat) -> some View {
        self.square(size)
            .clipShape(Circle())
    }
}

// MARK: - View Conditional Extensions
extension View {
    /// Apply modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply one of two modifiers based on condition
    @ViewBuilder
    func ifElse<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        trueTransform: (Self) -> TrueContent,
        falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}
