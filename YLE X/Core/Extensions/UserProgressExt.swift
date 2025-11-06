//
//  UserProgressExt.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

extension UserProgress {
    init(userId: String, level: YLELevel = .starters) {
        self.userId = userId
        self.level = level
        self.completedExercises = []
        self.vocabularyMastered = []
        self.skillScores = [:]
        self.lastActivity = Date()
    }
}
