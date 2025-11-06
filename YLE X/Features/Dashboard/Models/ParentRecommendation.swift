//
//  ParentRecommendation.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

struct ParentRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
}

enum RecommendationType {
    case encouragement, skillFocus, timeManagement, parentTips
    
    var emoji: String {
        switch self {
        case .encouragement: return "🌟"
        case .skillFocus: return "🎯"
        case .timeManagement: return "⏰"
        case .parentTips: return "💡"
        }
    }
    
    var color: Color {
        switch self {
            case .encouragement: return .appSuccess
            case .skillFocus: return .appPrimaryText
            case .timeManagement: return .appSecondaryText
            case .parentTips: return .vocabularyPink
        }
    }
}
