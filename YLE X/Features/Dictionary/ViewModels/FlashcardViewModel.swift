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
            // Fetch words for category and level
            var query: Query = db.collection("dictionaries")
                .whereField("categories", arrayContains: category.categoryId)
                .whereField("levels", arrayContains: level.rawValue)

            let snapshot = try await query.limit(to: maxCards).getDocuments()
            var words = snapshot.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }

            // Filter based on session type
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

            // Shuffle cards for variety
            words.shuffle()

            // Create session
            currentSession = FlashcardSession(
                category: category,
                level: level,
                cards: words,
                sessionType: sessionType
            )

            sessionStartTime = Date()

        } catch {
            errorMessage = "Failed to load flashcards: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Card Actions

    /// Mark current card as correct
    func markCorrect() async {
        guard var session = currentSession,
              let word = session.currentCard,
              let wordId = word.id else { return }

        // Update session
        session.recordCorrect()
        currentSession = session

        // Update progress
        await updateProgress(for: wordId, isCorrect: true)

        // Check if session complete
        if session.isComplete {
            await completeSession()
        }

        // Play success haptic
        HapticManager.shared.playSuccess()
    }

    /// Mark current card as incorrect
    func markIncorrect() async {
        guard var session = currentSession,
              let word = session.currentCard,
              let wordId = word.id else { return }

        // Update session
        session.recordIncorrect()
        currentSession = session

        // Update progress
        await updateProgress(for: wordId, isCorrect: false)

        // Check if session complete
        if session.isComplete {
            await completeSession()
        }

        // Play error haptic
        HapticManager.shared.playError()
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

    // MARK: - Progress Management

    /// Update user progress for a word
    private func updateProgress(for wordId: String, isCorrect: Bool) async {
        var progress = userProgress[wordId] ?? FlashcardProgress(
            userId: userId,
            wordId: wordId
        )

        if isCorrect {
            progress.updateAfterCorrect()
        } else {
            progress.updateAfterIncorrect()
        }

        // Save to local state
        userProgress[wordId] = progress

        // Save to Firebase (background)
        Task.detached {
            try? await self.saveProgressToFirebase(progress)
        }
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
