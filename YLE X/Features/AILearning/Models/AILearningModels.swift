//
//  AILearningModels.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: AI-Powered Learning System
//

import Foundation
import SwiftUI

// MARK: - Speech Recognition Models

struct SpeechResult {
    let transcription: String
    let confidence: Double
    let duration: TimeInterval
    let isFinal: Bool
    let timestamp: Date
}

struct PronunciationScore {
    let overallScore: Double        // 0-100
    let accuracy: Double            // Word-level correctness (0-100)
    let fluency: Double             // Speaking smoothness (0-100)
    let completeness: Double        // All words spoken (0-100)
    let wordScores: [WordScore]     // Individual word analysis
    let feedback: [String]          // Improvement tips

    var grade: ScoreGrade {
        switch overallScore {
        case 90...100: return .excellent
        case 75..<90: return .good
        case 60..<75: return .fair
        case 0..<60: return .needsWork
        default: return .needsWork
        }
    }
}

struct WordScore: Identifiable {
    let id = UUID()
    let word: String
    let expected: String
    let accuracy: Double            // 0-100
    let status: WordStatus
    let suggestion: String?
}

enum WordStatus {
    case correct
    case mispronounced
    case omitted
    case inserted

    var color: Color {
        switch self {
        case .correct: return .appSuccess
        case .mispronounced: return .appWarning
        case .omitted, .inserted: return .appError
        }
    }

    var icon: String {
        switch self {
        case .correct: return "checkmark.circle.fill"
        case .mispronounced: return "exclamationmark.triangle.fill"
        case .omitted: return "minus.circle.fill"
        case .inserted: return "plus.circle.fill"
        }
    }
}

enum ScoreGrade: String {
    case excellent = "Excellent!"
    case good = "Good Job!"
    case fair = "Keep Practicing"
    case needsWork = "Needs Work"

    var emoji: String {
        switch self {
        case .excellent: return "🎉"
        case .good: return "😊"
        case .fair: return "😐"
        case .needsWork: return "😕"
        }
    }

    var color: Color {
        switch self {
        case .excellent: return .appSuccess
        case .good: return .appAccent
        case .fair: return .appWarning
        case .needsWork: return .appError
        }
    }
}

// MARK: - Phoneme Models

struct Phoneme: Identifiable, Codable {
    let id: String
    let symbol: String              // IPA symbol
    let type: PhonemeType
    let examples: [String]          // ["cat", "bat", "mat"]
    let description: String
    let tips: String                // Pronunciation tips
    let similarSounds: [String]     // Related phonemes to compare

    static func sample() -> Phoneme {
        Phoneme(
            id: "vowel_short_a",
            symbol: "æ",
            type: .shortVowel,
            examples: ["cat", "bat", "mat", "hat"],
            description: "Short 'a' sound as in 'cat'",
            tips: "Open your mouth wide and keep your tongue low",
            similarSounds: ["e", "ʌ"]
        )
    }
}

enum PhonemeType: String, Codable {
    case shortVowel = "Short Vowel"
    case longVowel = "Long Vowel"
    case diphthong = "Diphthong"
    case plosive = "Plosive"
    case fricative = "Fricative"
    case affricate = "Affricate"
    case nasal = "Nasal"
    case liquid = "Liquid"
    case glide = "Glide"

    var category: String {
        switch self {
        case .shortVowel, .longVowel, .diphthong:
            return "Vowel"
        default:
            return "Consonant"
        }
    }

    var color: Color {
        switch self {
        case .shortVowel, .longVowel, .diphthong:
            return .appPrimary
        case .plosive, .fricative, .affricate:
            return .appSecondary
        default:
            return .appAccent
        }
    }
}

// MARK: - Vocabulary Models

struct VocabularyCard: Identifiable, Codable {
    let id: String
    let word: String
    let ipaUK: String
    let ipaUS: String
    let definition: String
    let examples: [String]
    let imageURL: String?
    let level: YLELevel
    let topic: VocabularyTopic
    let partOfSpeech: PartOfSpeech
    let difficulty: Int             // 1-10

    // Spaced Repetition Data
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?
    var masteryLevel: MasteryLevel

    init(
        id: String,
        word: String,
        ipaUK: String,
        ipaUS: String,
        definition: String,
        examples: [String],
        imageURL: String? = nil,
        level: YLELevel,
        topic: VocabularyTopic,
        partOfSpeech: PartOfSpeech,
        difficulty: Int,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewDate: Date? = nil,
        masteryLevel: MasteryLevel = .learning
    ) {
        self.id = id
        self.word = word
        self.ipaUK = ipaUK
        self.ipaUS = ipaUS
        self.definition = definition
        self.examples = examples
        self.imageURL = imageURL
        self.level = level
        self.topic = topic
        self.partOfSpeech = partOfSpeech
        self.difficulty = difficulty
        self.easeFactor = easeFactor
        self.interval = interval
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.lastReviewDate = lastReviewDate
        self.masteryLevel = masteryLevel
    }

    static func sample() -> VocabularyCard {
        VocabularyCard(
            id: UUID().uuidString,
            word: "cat",
            ipaUK: "/kæt/",
            ipaUS: "/kæt/",
            definition: "A small domesticated carnivorous mammal",
            examples: [
                "I have a cat at home.",
                "The cat is sleeping on the sofa.",
                "My cat loves to play with yarn."
            ],
            imageURL: nil,
            level: YLELevel.starters,
            topic: VocabularyTopic.animals,
            partOfSpeech: PartOfSpeech.noun,
            difficulty: 1
        )
    }
}

enum VocabularyTopic: String, Codable, CaseIterable {
    case animals = "Animals"
    case food = "Food & Drink"
    case family = "Family & Friends"
    case school = "School & Study"
    case home = "Home & Furniture"
    case clothes = "Clothes & Colors"
    case body = "Body & Health"
    case sports = "Sports & Hobbies"
    case weather = "Weather & Nature"
    case travel = "Travel & Places"

    var icon: String {
        switch self {
        case .animals: return "pawprint.fill"
        case .food: return "fork.knife"
        case .family: return "person.2.fill"
        case .school: return "book.fill"
        case .home: return "house.fill"
        case .clothes: return "tshirt.fill"
        case .body: return "heart.fill"
        case .sports: return "figure.run"
        case .weather: return "cloud.sun.fill"
        case .travel: return "airplane"
        }
    }
}

enum PartOfSpeech: String, Codable {
    case noun = "Noun"
    case verb = "Verb"
    case adjective = "Adjective"
    case adverb = "Adverb"
    case preposition = "Preposition"
    case conjunction = "Conjunction"
    case pronoun = "Pronoun"
    case interjection = "Interjection"
}

enum MasteryLevel: String, Codable {
    case learning = "Learning"
    case familiar = "Familiar"
    case mastered = "Mastered"

    var color: Color {
        switch self {
        case .learning: return .appWarning
        case .familiar: return .appAccent
        case .mastered: return .appSuccess
        }
    }

    var icon: String {
        switch self {
        case .learning: return "book.fill"
        case .familiar: return "star.fill"
        case .mastered: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Speaking Exercise Models

struct SpeakingExercise: Identifiable, Codable {
    let id: String
    let type: ExerciseType
    let targetText: String
    let ipaText: String
    let difficulty: ExerciseDifficulty
    let tips: [String]
    let maxAttempts: Int

    static func sample() -> SpeakingExercise {
        SpeakingExercise(
            id: UUID().uuidString,
            type: .sentenceReading,
            targetText: "Hello, how are you today?",
            ipaText: "/həˈləʊ haʊ ɑː juː təˈdeɪ/",
            difficulty: .beginner,
            tips: [
                "Speak clearly and at a natural pace",
                "Focus on correct word stress",
                "Take a breath before starting"
            ],
            maxAttempts: 3
        )
    }
}

enum ExerciseType: String, Codable {
    case wordRepetition = "Word Practice"
    case sentenceReading = "Sentence Reading"
    case conversation = "Conversation"
    case storyReading = "Story Reading"

    var icon: String {
        switch self {
        case .wordRepetition: return "text.bubble.fill"
        case .sentenceReading: return "text.alignleft"
        case .conversation: return "message.fill"
        case .storyReading: return "book.fill"
        }
    }
}

enum ExerciseDifficulty: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var color: Color {
        switch self {
        case .beginner: return .appSuccess
        case .intermediate: return .appWarning
        case .advanced: return .appError
        }
    }
}

// MARK: - Audio Recording Models

struct AudioRecording: Identifiable {
    let id = UUID()
    let url: URL
    let duration: TimeInterval
    let timestamp: Date
    let waveformSamples: [Float]
}
