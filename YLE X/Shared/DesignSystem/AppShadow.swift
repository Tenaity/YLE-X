//
//  AppShadow.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Shadow system following Apple Design Guidelines
//

import SwiftUI

// MARK: - Shadow Level
enum AppShadowLevel {
    case none, subtle, light, medium, heavy

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 2
        case .light: return 4
        case .medium: return 8
        case .heavy: return 16
        }
    }

    var opacity: Double {
        switch self {
        case .none: return 0
        case .subtle: return 0.05
        case .light: return 0.1
        case .medium: return 0.15
        case .heavy: return 0.2
        }
    }

    var offset: CGSize {
        switch self {
        case .none: return .zero
        case .subtle: return CGSize(width: 0, height: 1)
        case .light: return CGSize(width: 0, height: 2)
        case .medium: return CGSize(width: 0, height: 4)
        case .heavy: return CGSize(width: 0, height: 8)
        }
    }
}

// MARK: - View Modifier for Shadows
extension View {
    /// Apply shadow with specified level
    func appShadow(level: AppShadowLevel = .light) -> some View {
        self.shadow(
            color: Color.black.opacity(level.opacity),
            radius: level.radius,
            x: level.offset.width,
            y: level.offset.height
        )
    }
}
