//
//  ContentService.swift
//  YLE X
//
// Intended Path: Core/Services/
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation

// MARK: - Content Service
final class ContentService {
    static let shared = ContentService()
    private init() {}
    
    // MARK: - Vocabulary Loading
    func loadVocabulary(for level: YLELevel, topic: String?) async throws -> [VocabularyItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock data for demonstration
        let mockVocabulary = createMockVocabulary(for: level, topic: topic)
        return mockVocabulary
    }
    
    // MARK: - Exercise Loading
    func loadExercises(for level: YLELevel, skill: Skill) async throws -> [Exercise] {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        let mockExercises = createMockExercises(for: level, skill: skill)
        return mockExercises
    }
    
    // MARK: - Mock Data Creation
    private func createMockVocabulary(for level: YLELevel, topic: String?) -> [VocabularyItem] {
        let topics = topic != nil ? [topic!] : ["Animals", "Colors", "Family", "Food"]
        var vocabulary: [VocabularyItem] = []
        
        for currentTopic in topics {
            let words = getWordsForTopic(currentTopic, level: level)
            
            for (index, word) in words.enumerated() {
                let item = VocabularyItem(
                    id: UUID().uuidString,
                    word: word.word,
                    meaning: word.meaning,
                    example: word.example,
                    imageName: "\(currentTopic.lowercased())_\(index + 1)",
                    audioName: word.word.lowercased().replacingOccurrences(of: " ", with: "_"),
                    level: level,
                    topic: currentTopic
                )
                vocabulary.append(item)
            }
        }
        
        return vocabulary
    }
    
    private func createMockExercises(for level: YLELevel, skill: Skill) -> [Exercise] {
        var exercises: [Exercise] = []
        let exerciseCount = level == .starters ? 5 : (level == .movers ? 8 : 12)
        
        for i in 1...exerciseCount {
            let exercise = Exercise(
                id: UUID().uuidString,
                level: level,
                skill: skill,
                question: "What is the correct answer for question \(i)?",
                options: ["Option A", "Option B", "Option C", "Option D"],
                correctIndex: Int.random(in: 0...3),
                explanation: "explanation",
                audioName: "audioName",
                imageName: "imageName"
            )
        }
        
        return exercises
    }
    
    // MARK: - Helper Methods
    private func getWordsForTopic(_ topic: String, level: YLELevel) -> [(word: String, meaning: String, example: String?)] {
        switch topic {
        case "Animals":
            return [
                ("Cat", "Con mèo", "I have a black cat."),
                ("Dog", "Con chó", "The dog is very friendly."),
                ("Bird", "Con chim", "The bird flies in the sky."),
                ("Fish", "Con cá", "Fish live in water.")
            ]
        case "Colors":
            return [
                ("Red", "Màu đỏ", "The apple is red."),
                ("Blue", "Màu xanh dương", "The sky is blue."),
                ("Green", "Màu xanh lá", "Grass is green."),
                ("Yellow", "Màu vàng", "The sun is yellow.")
            ]
        case "Family":
            return [
                ("Mother", "Mẹ", "My mother is kind."),
                ("Father", "Bố", "My father is strong."),
                ("Sister", "Chị/Em gái", "I love my sister."),
                ("Brother", "Anh/Em trai", "My brother is funny.")
            ]
        default:
            return [
                ("Hello", "Xin chào", "Hello, how are you?"),
                ("Thank you", "Cảm ơn", "Thank you for helping me.")
            ]
        }
    }
}
