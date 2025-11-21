//
//  YLELevel.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

enum YLELevel: String, CaseIterable, Identifiable, Codable {
    case starters = "starters"
    case movers = "movers"
    case flyers = "flyers"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .starters: return "YLE Starters"
        case .movers: return "YLE Movers"
        case .flyers: return "YLE Flyers"
        }
    }
    
    var description: String {
        switch self {
        case .starters:
            return "For beginners (ages 7-8)"
        case .movers:
            return "For elementary level (ages 8-11)"
        case .flyers:
            return "For pre-intermediate level (ages 9-12)"
        }
    }
    
    var emoji: String {
        switch self {
        case .starters: return "🌱"
        case .movers: return "🚀"
        case .flyers: return "✈️"
        }
    }
    
    var ageRange: String {
        switch self {
        case .starters: return "7-8 tuổi"
        case .movers: return "8-11 tuổi"
        case .flyers: return "9-12 tuổi"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .starters: return .appLevelStarters
        case .movers: return .appLevelMovers
        case .flyers: return .appLevelFlyers
        }
    }

    var secondaryColor: Color {
        switch self {
        case .starters: return .appLevelStarters.opacity(0.15)
        case .movers: return .appLevelMovers.opacity(0.15)
        case .flyers: return .appLevelFlyers.opacity(0.15)
        }
    }

    // MARK: - Additional Properties (for Dictionary feature)

    var displayName: String {
        switch self {
        case .starters: return "Starters"
        case .movers: return "Movers"
        case .flyers: return "Flyers"
        }
    }

    var displayNameVi: String {
        switch self {
        case .starters: return "Sơ Cấp"
        case .movers: return "Trung Cấp"
        case .flyers: return "Cao Cấp"
        }
    }

    var icon: String {
        return emoji  // Reuse existing emoji property
    }

    var color: String {
        switch self {
        case .starters: return "#33D633"  // Green
        case .movers: return "#0077FF"    // Blue
        case .flyers: return "#B330E3"    // Purple
        }
    }

    /// Order index for sorting
    var order: Int {
        switch self {
        case .starters: return 0
        case .movers: return 1
        case .flyers: return 2
        }
    }
}
