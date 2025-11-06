//
//  UserProgress.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

struct UserProgress: Codable {
    let userId: String
    var level: YLELevel
    var completedExercises: [String] // Exercise IDs
    var vocabularyMastered: [String] // VocabularyItem IDs
    var skillScores: [Skill: Double] // Sẽ hoạt động vì Skill giờ đã Codable
    var lastActivity: Date
    
}
