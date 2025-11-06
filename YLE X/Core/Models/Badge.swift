//
//  Badge.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI

struct Badge: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let colorName: String // Color name from Design System
    let earnedDate: Date

    var color: Color {
        switch colorName {
        // Level badges
        case "appBadgeStarters": return .appBadgeStarters
        case "appBadgeMovers": return .appBadgeMovers
        case "appBadgeFlyers": return .appBadgeFlyers

        // Achievement level badges
        case "appBadgeGold": return .appBadgeGold
        case "appBadgeSilver": return .appBadgeSilver
        case "appBadgeBronze": return .appBadgeBronze

        // Fallback
        default: return .appTextSecondary
        }
    }
}

// MARK: - Badge Factory (Sample badges)
extension Badge {
    static func sampleBadge(level: String = "appBadgeStarters") -> Badge {
        Badge(
            id: UUID().uuidString,
            name: "First Step",
            description: "Complete your first exercise",
            emoji: "🌱",
            colorName: level,
            earnedDate: Date()
        )
    }
}
