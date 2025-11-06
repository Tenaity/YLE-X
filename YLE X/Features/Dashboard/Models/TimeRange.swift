//
//  TimeRange.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case week, month, quarter
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .week: return "Tuần"
        case .month: return "Tháng"
        case .quarter: return "Quý"
        }
    }
}
