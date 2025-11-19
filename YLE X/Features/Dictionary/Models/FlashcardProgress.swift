//
//  FlashcardProgress.swift
//  YLE X
//
//  Created on 11/18/25.
//  Tracks user progress for flashcard study using spaced repetition
//

import Foundation
import FirebaseFirestore

struct FlashcardProgress: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let wordId: String
    var masteryLevel: Int // 0-5 (0=new, 5=mastered)
    var correctCount: Int
    var incorrectCount: Int
    var lastReviewed: Date
    var nextReviewDate: Date
    var streakDays: Int
    var totalReviews: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case wordId
        case masteryLevel
        case correctCount
        case incorrectCount
        case lastReviewed
        case nextReviewDate
        case streakDays
        case totalReviews
    }

    // MARK: - Computed Properties

    var accuracyPercentage: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }

    var isNew: Bool {
        return totalReviews == 0
    }

    var isDueForReview: Bool {
        return Date() >= nextReviewDate
    }

    var isMastered: Bool {
        return masteryLevel >= 5
    }

    var masteryDescription: String {
        switch masteryLevel {
        case 0: return "New"
        case 1: return "Learning"
        case 2: return "Familiar"
        case 3: return "Comfortable"
        case 4: return "Proficient"
        case 5: return "Mastered"
        default: return "Unknown"
        }
    }

    var masteryEmoji: String {
        switch masteryLevel {
        case 0: return "🌱"
        case 1: return "🌿"
        case 2: return "🍃"
        case 3: return "🌳"
        case 4: return "🌲"
        case 5: return "⭐"
        default: return "❓"
        }
    }

    // MARK: - Initializer

    init(
        userId: String,
        wordId: String,
        masteryLevel: Int = 0,
        correctCount: Int = 0,
        incorrectCount: Int = 0,
        lastReviewed: Date = Date(),
        nextReviewDate: Date = Date(),
        streakDays: Int = 0,
        totalReviews: Int = 0
    ) {
        self.userId = userId
        self.wordId = wordId
        self.masteryLevel = masteryLevel
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.lastReviewed = lastReviewed
        self.nextReviewDate = nextReviewDate
        self.streakDays = streakDays
        self.totalReviews = totalReviews
    }

    // MARK: - Spaced Repetition Logic

    /// Calculate next review date based on mastery level (SM-2 Algorithm simplified)
    mutating func updateAfterCorrect() {
        correctCount += 1
        totalReviews += 1
        lastReviewed = Date()

        // Increase mastery level (max 5)
        if masteryLevel < 5 {
            masteryLevel += 1
        }

        // Update streak
        let calendar = Calendar.current
        if calendar.isDateInToday(lastReviewed) || calendar.isDateInYesterday(lastReviewed) {
            streakDays += 1
        } else {
            streakDays = 1
        }

        // Calculate next review date using spaced repetition intervals
        let intervals: [Int: TimeInterval] = [
            0: 1 * 60,           // 1 minute (new)
            1: 10 * 60,          // 10 minutes
            2: 1 * 3600,         // 1 hour
            3: 24 * 3600,        // 1 day
            4: 3 * 24 * 3600,    // 3 days
            5: 7 * 24 * 3600     // 1 week (mastered)
        ]

        let interval = intervals[masteryLevel] ?? 24 * 3600
        nextReviewDate = Date().addingTimeInterval(interval)
    }

    mutating func updateAfterIncorrect() {
        incorrectCount += 1
        totalReviews += 1
        lastReviewed = Date()

        // Decrease mastery level (min 0)
        if masteryLevel > 0 {
            masteryLevel -= 1
        }

        // Reset streak
        streakDays = 0

        // Review again soon (5 minutes)
        nextReviewDate = Date().addingTimeInterval(5 * 60)
    }

    // MARK: - Static Samples

    static let sample = FlashcardProgress(
        userId: "user123",
        wordId: "word_cat",
        masteryLevel: 2,
        correctCount: 5,
        incorrectCount: 2,
        lastReviewed: Date(),
        nextReviewDate: Date().addingTimeInterval(3600),
        streakDays: 3,
        totalReviews: 7
    )
}

// MARK: - Flashcard Session

struct FlashcardSession: Identifiable {
    let id = UUID()
    let category: VocabularyCategory
    let level: YLELevel
    var cards: [DictionaryWord]
    var currentIndex: Int = 0
    var correctAnswers: Int = 0
    var incorrectAnswers: Int = 0
    var startTime: Date = Date()
    var sessionType: SessionType = .new

    enum SessionType {
        case new         // New words
        case review      // Due for review
        case practice    // Free practice
        case mastery     // Mastered words only
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }

    var currentCard: DictionaryWord? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var isComplete: Bool {
        return currentIndex >= cards.count
    }

    var accuracy: Double {
        let total = correctAnswers + incorrectAnswers
        guard total > 0 else { return 0 }
        return Double(correctAnswers) / Double(total) * 100
    }

    var duration: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }

    mutating func moveToNext() {
        if currentIndex < cards.count {
            currentIndex += 1
        }
    }

    mutating func recordCorrect() {
        correctAnswers += 1
        moveToNext()
    }

    mutating func recordIncorrect() {
        incorrectAnswers += 1
        moveToNext()
    }
}

// MARK: - Session Results

struct SessionResults: Identifiable {
    let id = UUID()
    let session: FlashcardSession
    let completedAt: Date
    let xpEarned: Int
    let gemsEarned: Int
    let newWordsMastered: Int

    var formattedDuration: String {
        let minutes = Int(session.duration) / 60
        let seconds = Int(session.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var performanceRating: String {
        let accuracy = session.accuracy
        switch accuracy {
        case 90...100: return "Perfect! 🌟"
        case 75..<90: return "Great! 🎉"
        case 60..<75: return "Good! 👍"
        case 40..<60: return "Keep Practicing! 💪"
        default: return "Try Again! 📚"
        }
    }

    var performanceEmoji: String {
        let accuracy = session.accuracy
        switch accuracy {
        case 90...100: return "🌟"
        case 75..<90: return "🎉"
        case 60..<75: return "👍"
        case 40..<60: return "💪"
        default: return "📚"
        }
    }
}
