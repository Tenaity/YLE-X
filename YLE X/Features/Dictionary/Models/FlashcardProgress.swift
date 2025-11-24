//
//  FlashcardProgress.swift
//  YLE X
//
//  Created on 11/18/25.
//  Updated on 11/23/25 - Enhanced with SM-2 Algorithm
//  Tracks user progress for flashcard study using spaced repetition
//

import Foundation
import FirebaseFirestore

struct FlashcardProgress: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let wordId: String
    let categoryId: String
    let level: String

    // MARK: - SM-2 Spaced Repetition Data

    /// Current ease factor (1.3 - 2.5)
    /// Higher = easier card, longer intervals
    var easeFactor: Double

    /// Current interval in days
    var interval: Int

    /// Number of times reviewed
    var reviewCount: Int

    /// Next review date
    var nextReviewDate: Date

    /// Last review date
    var lastReviewDate: Date?

    /// Date when card was first added to deck
    let createdDate: Date

    // MARK: - Performance Tracking

    /// Total correct answers
    var correctCount: Int

    /// Total incorrect answers (Again responses)
    var incorrectCount: Int

    /// Current streak of consecutive correct answers
    var currentStreak: Int

    /// Best streak achieved
    var bestStreak: Int

    /// Last quality rating (0-3: Again, Hard, Good, Easy)
    var lastQuality: Int?

    // MARK: - Legacy Support (for backward compatibility)

    var masteryLevel: Int {
        // Convert interval to mastery level (0-5)
        switch interval {
        case 0: return 0      // New
        case 1...5: return 1  // Learning
        case 6...20: return 2 // Familiar
        case 21...60: return 3 // Comfortable
        case 61...180: return 4 // Proficient
        default: return 5     // Mastered
        }
    }

    var totalReviews: Int { reviewCount }
    var lastReviewed: Date { lastReviewDate ?? createdDate }
    var streakDays: Int { currentStreak }

    // MARK: - Computed Properties

    var accuracyPercentage: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }

    var isNew: Bool {
        reviewCount == 0
    }

    var isDueForReview: Bool {
        Date() >= nextReviewDate
    }

    var isMastered: Bool {
        interval >= 180  // 6 months
    }

    var isLearning: Bool {
        interval < 21  // Less than 3 weeks
    }

    var isMature: Bool {
        interval >= 21  // 3 weeks or more
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

    var successRate: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total)
    }

    // MARK: - Initializer

    init(
        userId: String,
        wordId: String,
        categoryId: String,
        level: String,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        reviewCount: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewDate: Date? = nil,
        createdDate: Date = Date(),
        correctCount: Int = 0,
        incorrectCount: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        lastQuality: Int? = nil
    ) {
        self.userId = userId
        self.wordId = wordId
        self.categoryId = categoryId
        self.level = level
        self.easeFactor = easeFactor
        self.interval = interval
        self.reviewCount = reviewCount
        self.nextReviewDate = nextReviewDate
        self.lastReviewDate = lastReviewDate
        self.createdDate = createdDate
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastQuality = lastQuality
    }

    // MARK: - Spaced Repetition Logic (SM-2 Algorithm)

    /// Update progress after review using SM-2 algorithm
    mutating func updateAfterReview(quality: Int, newEaseFactor: Double, newInterval: Int, nextReviewDate: Date) {
        self.easeFactor = newEaseFactor
        self.interval = newInterval
        self.nextReviewDate = nextReviewDate
        self.lastReviewDate = Date()
        self.reviewCount += 1
        self.lastQuality = quality

        // Update performance tracking
        if quality == 0 {
            // Again: incorrect
            incorrectCount += 1
            currentStreak = 0
        } else {
            // Hard/Good/Easy: correct
            correctCount += 1
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        }
    }

    /// Legacy method: Update after correct (maps to Good quality)
    mutating func updateAfterCorrect() {
        let result = SpacedRepetitionService.shared.calculateNextReview(
            currentEaseFactor: easeFactor,
            currentInterval: interval,
            quality: 2  // Good
        )
        updateAfterReview(
            quality: 2,
            newEaseFactor: result.easeFactor,
            newInterval: result.interval,
            nextReviewDate: result.nextReviewDate
        )
    }

    /// Legacy method: Update after incorrect (maps to Again quality)
    mutating func updateAfterIncorrect() {
        let result = SpacedRepetitionService.shared.calculateNextReview(
            currentEaseFactor: easeFactor,
            currentInterval: interval,
            quality: 0  // Again
        )
        updateAfterReview(
            quality: 0,
            newEaseFactor: result.easeFactor,
            newInterval: result.interval,
            nextReviewDate: result.nextReviewDate
        )
    }

    // MARK: - Firestore Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case wordId
        case categoryId
        case level
        case easeFactor
        case interval
        case reviewCount
        case nextReviewDate
        case lastReviewDate
        case createdDate
        case correctCount
        case incorrectCount
        case currentStreak
        case bestStreak
        case lastQuality
    }

    // MARK: - Static Samples

    static let sample = FlashcardProgress(
        userId: "user123",
        wordId: "cat",
        categoryId: "animals",
        level: "starters",
        easeFactor: 2.3,
        interval: 10,
        reviewCount: 7,
        correctCount: 5,
        incorrectCount: 2,
        currentStreak: 3,
        bestStreak: 3,
        lastQuality: 2
    )

    static let sampleNew = FlashcardProgress(
        userId: "user123",
        wordId: "dog",
        categoryId: "animals",
        level: "starters"
    )

    static let sampleMature = FlashcardProgress(
        userId: "user123",
        wordId: "apple",
        categoryId: "food_and_drink",
        level: "starters",
        easeFactor: 2.5,
        interval: 30,
        reviewCount: 15,
        correctCount: 14,
        incorrectCount: 1,
        currentStreak: 10,
        bestStreak: 10,
        lastQuality: 3
    )
}

// MARK: - Firestore Collection Extension

extension FlashcardProgress {
    static let collectionName = "flashcardProgress"

    /// Generate document ID: userId_wordId
    static func documentId(userId: String, wordId: String) -> String {
        return "\(userId)_\(wordId)"
    }

    /// Get document ID for this progress
    var documentId: String {
        Self.documentId(userId: userId, wordId: wordId)
    }
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
