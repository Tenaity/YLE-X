//
//  YLELevel.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

enum YLELevel: String, CaseIterable, Identifiable, Codable {
    case starters = "Starters"
    case movers = "Movers"
    case flyers = "Flyers"
    
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
        case .starters: return .startersGreen
        case .movers: return .moversBlue
        case .flyers: return .flyersPurple
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .starters: return .startersLightGreen
        case .movers: return .moversLightBlue
        case .flyers: return .flyersLightPurple
        }
    }
}
