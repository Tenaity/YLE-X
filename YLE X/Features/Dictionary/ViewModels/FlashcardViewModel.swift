//
//  FlashcardViewModel.swift
//  YLE X
//
//  Created on 11/18/25.
//  Manages flashcard sessions and progress tracking
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FlashcardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentSession: FlashcardSession?
    @Published var sessionResults: SessionResults?
    @Published var userProgress: [String: FlashcardProgress] = [:] // wordId: progress
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let db = Firestore.firestore()
    private var userId: String = "default_user" // TODO: Get from auth
    private var sessionStartTime = Date()

    // MARK: - Session Creation

    /// Start new flashcard session with category and level
    func startSession(
        category: VocabularyCategory,
        level: YLELevel,
        sessionType: FlashcardSession.SessionType = .new,
        maxCards: Int = 20
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch words for category only (Firestore limit: only 1 ARRAY_CONTAINS per query)
            let query: Query = db.collection("dictionaries")
                .whereField("categories", arrayContains: category.categoryId)

            print("🔍 Flashcard Query:")
            print("   Category: \(category.categoryId)")
            print("   Level: \(level.rawValue)")

            let snapshot = try await query.limit(to: maxCards * 3).getDocuments()
            print("   Documents found: \(snapshot.documents.count)")

            var words = snapshot.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }
            print("   Words decoded: \(words.count)")

            // Filter by level on client side
            words = words.filter { word in
                word.levels.contains(level.rawValue)
            }
            print("   After level filter: \(words.count)")

            // Limit to maxCards before session type filter
            if words.count > maxCards * 2 {
                words = Array(words.prefix(maxCards * 2))
            }

            // Filter based on session type
            let beforeFilterCount = words.count
            switch sessionType {
            case .new:
                // Show words not yet studied
                words = words.filter { word in
                    let progress = userProgress[word.id ?? ""]
                    return progress == nil || progress!.isNew
                }

            case .review:
                // Show words due for review
                words = words.filter { word in
                    guard let progress = userProgress[word.id ?? ""] else { return false }
                    return progress.isDueForReview && !progress.isMastered
                }

            case .mastery:
                // Show mastered words
                words = words.filter { word in
                    guard let progress = userProgress[word.id ?? ""] else { return false }
                    return progress.isMastered
                }

            case .practice:
                // Show all words (already filtered by query)
                break
            }
            print("   After \(sessionType) filter: \(words.count) (from \(beforeFilterCount))")

            // If no words found, set helpful error message
            if words.isEmpty {
                if snapshot.documents.isEmpty {
                    errorMessage = "No words found in Firebase for this category and level. Please import data first."
                } else if beforeFilterCount > 0 && words.count == 0 {
                    errorMessage = "No \(sessionType) cards available. Try different session type."
                } else {
                    errorMessage = "No cards available"
                }
            }

            // Shuffle cards for variety
            words.shuffle()

            // Limit to maxCards
            if words.count > maxCards {
                words = Array(words.prefix(maxCards))
            }

            // Create session
            currentSession = FlashcardSession(
                category: category,
                level: level,
                cards: words,
                sessionType: sessionType
            )

            sessionStartTime = Date()

        } catch {
            print("❌ Flashcard Error: \(error)")
            errorMessage = "Failed to load flashcards: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Card Actions (SM-2 4-Button System)

    /// Review card with quality rating (0=Again, 1=Hard, 2=Good, 3=Easy)
    func reviewCard(quality: Int) async {
        guard var session = currentSession,
              let word = session.currentCard,
              let wordId = word.id else { return }

        // Update session based on quality
        if quality == 0 {
            session.recordIncorrect()
        } else {
            session.recordCorrect()
        }
        currentSession = session

        // Update progress with SM-2 algorithm
        await updateProgressWithSM2(for: wordId, quality: quality, categoryId: session.category.categoryId, level: session.level.rawValue)

        // Check if session complete
        if session.isComplete {
            await completeSession()
        }

        // Play appropriate haptic
        if quality == 0 {
            HapticManager.shared.playError()
        } else if quality == 3 {
            HapticManager.shared.playSuccess()
        } else {
            HapticManager.shared.playLight()
        }
    }

    /// Mark current card as correct (legacy - maps to Good)
    func markCorrect() async {
        await reviewCard(quality: 2)  // Good
    }

    /// Mark current card as incorrect (legacy - maps to Again)
    func markIncorrect() async {
        await reviewCard(quality: 0)  // Again
    }

    /// Skip current card (no progress update)
    func skipCard() {
        guard var session = currentSession else { return }
        session.moveToNext()
        currentSession = session

        if session.isComplete {
            Task {
                await completeSession()
            }
        }
    }

    // MARK: - Progress Management (SM-2)

    /// Update user progress using SM-2 algorithm
    private func updateProgressWithSM2(for wordId: String, quality: Int, categoryId: String, level: String) async {
        var progress = userProgress[wordId] ?? FlashcardProgress(
            userId: userId,
            wordId: wordId,
            categoryId: categoryId,
            level: level
        )

        // Calculate next review using SM-2
        let result = SpacedRepetitionService.shared.calculateNextReview(
            currentEaseFactor: progress.easeFactor,
            currentInterval: progress.interval,
            quality: quality
        )

        // Update progress
        progress.updateAfterReview(
            quality: quality,
            newEaseFactor: result.easeFactor,
            newInterval: result.interval,
            nextReviewDate: result.nextReviewDate
        )

        // Save to local state
        userProgress[wordId] = progress

        // Save to Firebase (background)
        Task.detached {
            try? await self.saveProgressToFirebase(progress)
        }
    }

    /// Legacy update method (for backward compatibility)
    private func updateProgress(for wordId: String, isCorrect: Bool) async {
        await updateProgressWithSM2(
            for: wordId,
            quality: isCorrect ? 2 : 0,
            categoryId: currentSession?.category.categoryId ?? "",
            level: currentSession?.level.rawValue ?? ""
        )
    }

    /// Save progress to Firebase
    private func saveProgressToFirebase(_ progress: FlashcardProgress) async throws {
        let docRef = db.collection("flashcard_progress").document("\(userId)_\(progress.wordId)")
        try docRef.setData(from: progress, merge: true)
    }

    /// Load user progress from Firebase
    func loadUserProgress() async {
        isLoading = true

        do {
            let snapshot = try await db.collection("flashcard_progress")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()

            let progressList = snapshot.documents.compactMap {
                try? $0.data(as: FlashcardProgress.self)
            }

            // Convert to dictionary
            userProgress = Dictionary(
                uniqueKeysWithValues: progressList.map { ($0.wordId, $0) }
            )

        } catch {
            errorMessage = "Failed to load progress: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Session Completion

    /// Complete current session and calculate results
    private func completeSession() async {
        guard let session = currentSession else { return }

        // Calculate rewards
        let accuracy = session.accuracy
        let baseXP = 10 * session.cards.count
        let accuracyBonus = Int(accuracy / 10) * 5
        let xpEarned = baseXP + accuracyBonus

        let gemsEarned = session.correctAnswers >= 5 ? 10 : 5

        // Count newly mastered words
        let newlyMastered = session.cards.filter { word in
            guard let wordId = word.id,
                  let progress = userProgress[wordId] else { return false }
            return progress.isMastered && progress.totalReviews == 1
        }.count

        // Create results
        sessionResults = SessionResults(
            session: session,
            completedAt: Date(),
            xpEarned: xpEarned,
            gemsEarned: gemsEarned,
            newWordsMastered: newlyMastered
        )

        // Play completion haptic
        HapticManager.shared.playSuccess()
    }

    /// Reset current session
    func resetSession() {
        currentSession = nil
        sessionResults = nil
        sessionStartTime = Date()
    }

    // MARK: - Statistics

    /// Get overall statistics
    func getStatistics() -> UserStatistics {
        let allProgress = Array(userProgress.values)

        let totalWords = allProgress.count
        let masteredWords = allProgress.filter { $0.isMastered }.count
        let learningWords = allProgress.filter { !$0.isMastered && !$0.isNew }.count
        let newWords = allProgress.filter { $0.isNew }.count

        let totalReviews = allProgress.reduce(0) { $0 + $1.totalReviews }
        let totalCorrect = allProgress.reduce(0) { $0 + $1.correctCount }
        let totalIncorrect = allProgress.reduce(0) { $0 + $1.incorrectCount }

        let overallAccuracy = totalReviews > 0
            ? Double(totalCorrect) / Double(totalReviews) * 100
            : 0

        let currentStreak = allProgress.map { $0.streakDays }.max() ?? 0

        return UserStatistics(
            totalWords: totalWords,
            masteredWords: masteredWords,
            learningWords: learningWords,
            newWords: newWords,
            totalReviews: totalReviews,
            overallAccuracy: overallAccuracy,
            currentStreak: currentStreak
        )
    }

    /// Get words due for review today
    func getDueWords() -> [String] {
        return userProgress.values
            .filter { $0.isDueForReview }
            .map { $0.wordId }
    }

    // MARK: - SM-2 Helpers

    /// Get preview intervals for current card
    func getPreviewIntervals() -> [SpacedRepetitionService.ResponseQuality: String] {
        guard let word = currentSession?.currentCard,
              let wordId = word.id else {
            return [:]
        }

        let progress = userProgress[wordId]
        let easeFactor = progress?.easeFactor ?? 2.5
        let interval = progress?.interval ?? 0

        return SpacedRepetitionService.shared.getPreviewIntervals(
            currentEaseFactor: easeFactor,
            currentInterval: interval
        )
    }

    /// Get review statistics
    func getReviewStatistics() -> ReviewStatistics {
        return SpacedRepetitionService.shared.getReviewStatistics(userProgress)
    }
}

// MARK: - User Statistics

struct UserStatistics {
    let totalWords: Int
    let masteredWords: Int
    let learningWords: Int
    let newWords: Int
    let totalReviews: Int
    let overallAccuracy: Double
    let currentStreak: Int

    var masteryPercentage: Double {
        guard totalWords > 0 else { return 0 }
        return Double(masteredWords) / Double(totalWords) * 100
    }

    var formattedAccuracy: String {
        return String(format: "%.1f%%", overallAccuracy)
    }
}
