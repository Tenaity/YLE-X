//
//  LearningSessionExt.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

extension LearningSession {
    init(id: String = UUID().uuidString,
         userId: String,
         level: YLELevel,
         skill: Skill,
         exercises: [Exercise]) {
        self.id = id
        self.userId = userId
        self.level = level
        self.skill = skill
        self.exercises = exercises
        self.startTime = Date()
    }
}
