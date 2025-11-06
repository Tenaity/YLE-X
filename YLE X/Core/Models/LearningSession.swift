//
//  LearningSession.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

struct LearningSession: Identifiable, Codable {
    let id: String
    let userId: String
    let level: YLELevel
    let skill: Skill // Sẽ hoạt động vì Skill giờ đã Codable
    let exercises: [Exercise]
    let startTime: Date
    var endTime: Date?
    var score: Double?
    var completed: Bool = false
    
}
