////
////  ParentModels.swift
////  YLE X
////
////  Created by Tenaity on 6/11/25.
////
//
//import Foundation
//import SwiftUI
//
//// MARK: - Learning Data Model
//struct LearningData: Identifiable {
//    let id = UUID()
//    let date: Date
//    let minutes: Double
//    
//    var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd"
//        return formatter.string(from: date)
//    }
//    
//    var dayOfWeek: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEE"
//        return formatter.string(from: date)
//    }
//}
//
//// MARK: - Learning Activity Model
//struct LearningActivity: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let skill: Skill
//    let date: Date
//    let pointsEarned: Int
//    let accuracy: Double
//    
//    var timeAgo: String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        return formatter.localizedString(for: date, relativeTo: Date())
//    }
//    
//    var accuracyPercentage: String {
//        return "\(Int(accuracy * 100))%"
//    }
//}
//
//// MARK: - Badge Model
//struct Badge: Identifiable {
//    let id: String
//    let name: String
//    let description: String
//    let emoji: String
//    let colorName: String
//    let earnedDate: Date
//    
//    var color: Color {
//        switch colorName {
//        case "startersGreen": return .startersGreen
//        case "moversBlue": return .moversBlue
//        case "flyersPurple": return .flyersPurple
//        case "kidsSecondary": return .appSecondary
//        default: return .appPrimary
//        }
//    }
//    
//    var timeAgo: String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: earnedDate, relativeTo: Date())
//    }
//}
//
//// MARK: - Parent Recommendation Model
//struct ParentRecommendation: Identifiable {
//    let id = UUID()
//    let type: RecommendationType
//    let title: String
//    let description: String
//    
//    var icon: String {
//        switch type {
//        case .encouragement: return "star.fill"
//        case .skillFocus: return "target"
//        case .timeManagement: return "clock.fill"
//        case .parentTips: return "lightbulb.fill"
//        }
//    }
//    
//    var color: Color {
//        switch type {
//        case .encouragement: return .appSuccess
//        case .skillFocus: return .appWarning
//        case .timeManagement: return .appInfo
//        case .parentTips: return .appSecondary
//        }
//    }
//}
//
//// MARK: - Recommendation Type Enum
//enum RecommendationType: String, CaseIterable {
//    case encouragement = "encouragement"
//    case skillFocus = "skill_focus"
//    case timeManagement = "time_management"
//    case parentTips = "parent_tips"
//    
//    var title: String {
//        switch self {
//        case .encouragement: return "Khuyến khích"
//        case .skillFocus: return "Tập trung kỹ năng"
//        case .timeManagement: return "Quản lý thời gian"
//        case .parentTips: return "Lời khuyên cho phụ huynh"
//        }
//    }
//}
//
//// MARK: - Time Range Model
//struct TimeRange: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let days: Int
//    
//    static let week = TimeRange(title: "7 ngày", days: 7)
//    static let month = TimeRange(title: "30 ngày", days: 30)
//    static let threeMonths = TimeRange(title: "3 tháng", days: 90)
//    
//    static let allRanges = [week, month, threeMonths]
//}
