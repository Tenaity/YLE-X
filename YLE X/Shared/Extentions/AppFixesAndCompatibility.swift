//
//  AppFixesAndCompatibility.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

// MARK: - Temporary compatibility fixes for compilation errors

// Fix 1: Navigation Bar Title Display Mode compatibility
extension View {
    func appNavigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(displayMode)
        #else
        return self
        #endif
    }
}

// Fix 2: Color opacity compatibility
extension Color {
    func appOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}

// Fix 3: Button style compatibility  
extension View {
    func appButtonStyle<S: ButtonStyle>(_ style: S) -> some View {
        return self.buttonStyle(style)
    }
}

// Fix 4: Animation compatibility
extension Animation {
    static var appCompatibleGentle: Animation {
        return Animation.easeInOut(duration: 0.35)
    }
    
    static var appCompatibleQuick: Animation {
        return Animation.easeOut(duration: 0.2)
    }
}

// Fix 5: Transition compatibility
extension AnyTransition {
    static var appCompatibleModal: AnyTransition {
        return AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }
}