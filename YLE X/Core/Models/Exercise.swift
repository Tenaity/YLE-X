//
//  Exercise.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id: String
    let level: YLELevel
    let skill: Skill
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?
    let audioName: String?
    let imageName: String?
    
    
    var correctAnswer: String {
        guard correctIndex >= 0 && correctIndex < options.count else { return "" }
        return options[correctIndex]
    }
}
