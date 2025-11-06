//
//  LearningActivity.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

struct LearningActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let skill: Skill
    let date: Date
    let pointsEarned: Int
    let accuracy: Double
}
