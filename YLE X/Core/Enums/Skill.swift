//
//  Skill.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

enum Skill: String, CaseIterable, Identifiable, Codable {
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    
    var id: String { rawValue }

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .listening:
            return "headphones"
        case .reading:
            return "book"
        case .writing:
            return "pencil"
        case .speaking:
            return "mic"
        case .vocabulary:
            return "character.book.closed"
        case .grammar:
            return "textformat"
        }
    }
    
    var emoji: String {
        switch self {
        case .listening:
            return "👂"
        case .reading:
            return "📖"
        case .writing:
            return "✏️"
        case .speaking:
            return "🗣️"
        case .vocabulary:
            return "📚"
        case .grammar:
            return "📝"
        }
    }
    
    var color: Color {
        switch self {
        case .listening:
            return .appSkillListening
        case .reading:
            return .appSkillReading
        case .writing:
            return .appSkillWriting
        case .speaking:
            return .appSkillSpeaking
        case .vocabulary:
            return .appSkillVocabulary
        case .grammar:
            return .appSkillGrammar
        }
    }

    var lightColor: Color {
        self.color.opacity(0.15)
    }
}

