//
//  ExerciseExt.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

extension Exercise {
    init(
         level: YLELevel,
         skill: Skill,
         question: String,
         options: [String],
         correctIndex: Int,
         explanation: String? = nil,
         audioName: String? = nil,
         imageName: String? = nil) {
             self.init(id: UUID().uuidString,
                       level: level,
                       skill: skill,
                       question: question,
                       options: options,
                       correctIndex: correctIndex,
                       explanation: explanation,
                       audioName: audioName,
                       imageName:imageName
             )
    }
}
