//
//  QuizViewModel.swift
//  YLE X
//
//  Created on 11/18/25.
//  Manages quiz sessions and question generation
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentSession: QuizSession?
    @Published var quizResults: QuizResults?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showHint = false

    // MARK: - Private Properties

    private let db = Firestore.firestore()
    private var allWords: [DictionaryWord] = []

    // MARK: - Session Creation

    /// Start new quiz session
    func startQuiz(
        category: VocabularyCategory,
        level: YLELevel,
        mode: QuizSession.QuizMode,
        questionCount: Int = 10
    ) async {
        isLoading = true
        errorMessage = nil
        showHint = false

        do {
            // Fetch words for category and level
            let query = db.collection("dictionaries")
                .whereField("categories", arrayContains: category.categoryId)
                .whereField("levels", arrayContains: level.rawValue)

            let snapshot = try await query.limit(to: questionCount * 2).getDocuments()
            allWords = snapshot.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }

            guard allWords.count >= 4 else {
                errorMessage = "Not enough words available for quiz"
                isLoading = false
                return
            }

            // Select random words for questions
            let selectedWords = allWords.shuffled().prefix(questionCount)

            // Generate questions based on mode
            var questions: [QuizQuestion] = []

            for word in selectedWords {
                // Get distractors (wrong answers)
                let distractors = getDistractors(for: word, count: 3)

                let question: QuizQuestion

                switch mode {
                case .mixed:
                    question = generateRandomQuestion(for: word, distractors: distractors)

                case .multipleChoice:
                    question = QuizQuestion.generateMultipleChoice(
                        for: word,
                        with: distractors
                    )

                case .listening:
                    question = QuizQuestion.generateListening(
                        for: word,
                        with: distractors
                    )

                case .translation:
                    // Alternate between EN→VI and VI→EN
                    if Bool.random() {
                        question = QuizQuestion.generateTranslation(
                            for: word,
                            with: distractors
                        )
                    } else {
                        question = QuizQuestion.generateReverseTranslation(
                            for: word,
                            with: distractors
                        )
                    }
                }

                questions.append(question)
            }

            // Create session
            currentSession = QuizSession(
                category: category,
                level: level,
                quizMode: mode,
                questions: questions
            )

        } catch {
            errorMessage = "Failed to create quiz: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Question Generation

    /// Generate random question type
    private func generateRandomQuestion(
        for word: DictionaryWord,
        distractors: [DictionaryWord]
    ) -> QuizQuestion {
        let questionTypes: [QuizQuestion.QuestionType] = [
            .multipleChoice,
            .listening,
            .translation,
            .reverseTranslation
        ]

        let randomType = questionTypes.randomElement()!

        switch randomType {
        case .multipleChoice:
            return QuizQuestion.generateMultipleChoice(for: word, with: distractors)
        case .listening:
            return QuizQuestion.generateListening(for: word, with: distractors)
        case .translation:
            return QuizQuestion.generateTranslation(for: word, with: distractors)
        case .reverseTranslation:
            return QuizQuestion.generateReverseTranslation(for: word, with: distractors)
        case .fillInBlank:
            return QuizQuestion.generateFillInBlank(for: word)
                ?? QuizQuestion.generateMultipleChoice(for: word, with: distractors)
        case .matching:
            return QuizQuestion.generateMultipleChoice(for: word, with: distractors)
        }
    }

    /// Get distractor words (wrong answers) for a question
    private func getDistractors(for word: DictionaryWord, count: Int) -> [DictionaryWord] {
        // Filter words that are similar in POS or category
        let candidates = allWords.filter { candidate in
            guard candidate.id != word.id else { return false }

            // Prefer same POS
            let samePOS = candidate.partOfSpeech.contains(where: { word.partOfSpeech.contains($0) })

            // Prefer same category
            let sameCategory = candidate.categories.contains(where: { word.categories.contains($0) })

            return samePOS || sameCategory
        }

        // If not enough similar words, use any words
        if candidates.count < count {
            return allWords.filter { $0.id != word.id }
                .shuffled()
                .prefix(count)
                .map { $0 }
        }

        return candidates.shuffled().prefix(count).map { $0 }
    }

    // MARK: - Answer Submission

    /// Submit answer for current question
    func submitAnswer(_ answer: String) {
        guard var session = currentSession,
              let question = session.currentQuestion else { return }

        session.submitAnswer(answer)
        currentSession = session

        // Check if correct for haptic feedback
        if question.isCorrect(answer) {
            HapticManager.shared.playSuccess()
        } else {
            HapticManager.shared.playError()
        }

        // Check if session complete
        if session.isComplete {
            completeQuiz()
        }
    }

    /// Skip current question
    func skipQuestion() {
        guard var session = currentSession else { return }
        session.skipQuestion()
        currentSession = session

        HapticManager.shared.playLight()

        if session.isComplete {
            completeQuiz()
        }
    }

    /// Toggle hint visibility
    func toggleHint() {
        showHint.toggle()
        HapticManager.shared.playLight()
    }

    // MARK: - Quiz Completion

    /// Complete quiz and calculate results
    private func completeQuiz() {
        guard let session = currentSession else { return }

        let accuracy = session.accuracy
        let score = session.score
        let totalQuestions = session.questions.count

        // Calculate XP based on accuracy
        let baseXP = totalQuestions * 10
        let accuracyBonus = Int(accuracy / 10) * 5
        let xpEarned = baseXP + accuracyBonus

        // Calculate gems
        let gemsEarned: Int
        switch accuracy {
        case 95...100:
            gemsEarned = 20
        case 80..<95:
            gemsEarned = 15
        case 60..<80:
            gemsEarned = 10
        default:
            gemsEarned = 5
        }

        // Calculate streak (mock for now)
        let streak = score >= totalQuestions / 2 ? 1 : 0

        // Create results
        quizResults = QuizResults(
            session: session,
            completedAt: Date(),
            xpEarned: xpEarned,
            gemsEarned: gemsEarned,
            streak: streak
        )

        // Save to Firebase (background)
        Task.detached {
            try? await self.saveQuizResults()
        }

        HapticManager.shared.playSuccess()
    }

    /// Save quiz results to Firebase
    private func saveQuizResults() async throws {
        guard let results = quizResults else { return }

        let data: [String: Any] = [
            "userId": "default_user",
            "categoryId": results.session.category.categoryId,
            "level": results.session.level.rawValue,
            "quizMode": results.session.quizMode.rawValue,
            "score": results.session.score,
            "totalQuestions": results.session.questions.count,
            "accuracy": results.session.accuracy,
            "xpEarned": results.xpEarned,
            "gemsEarned": results.gemsEarned,
            "duration": results.formattedDuration,
            "completedAt": Timestamp(date: results.completedAt)
        ]

        try await db.collection("quiz_results").addDocument(data: data)
    }

    /// Reset quiz
    func resetQuiz() {
        currentSession = nil
        quizResults = nil
        showHint = false
        errorMessage = nil
    }

    // MARK: - Statistics

    /// Get user quiz statistics
    func getUserStatistics() async -> QuizStatistics {
        do {
            let snapshot = try await db.collection("quiz_results")
                .whereField("userId", isEqualTo: "default_user")
                .getDocuments()

            let results = snapshot.documents

            let totalQuizzes = results.count
            var totalScore = 0
            var totalQuestions = 0
            var totalXP = 0
            var totalGems = 0

            for doc in results {
                if let score = doc.data()["score"] as? Int,
                   let questions = doc.data()["totalQuestions"] as? Int,
                   let xp = doc.data()["xpEarned"] as? Int,
                   let gems = doc.data()["gemsEarned"] as? Int {
                    totalScore += score
                    totalQuestions += questions
                    totalXP += xp
                    totalGems += gems
                }
            }

            let averageAccuracy = totalQuestions > 0
                ? Double(totalScore) / Double(totalQuestions) * 100
                : 0

            return QuizStatistics(
                totalQuizzes: totalQuizzes,
                averageAccuracy: averageAccuracy,
                totalXPEarned: totalXP,
                totalGemsEarned: totalGems
            )

        } catch {
            return QuizStatistics(
                totalQuizzes: 0,
                averageAccuracy: 0,
                totalXPEarned: 0,
                totalGemsEarned: 0
            )
        }
    }
}

// MARK: - Quiz Statistics

struct QuizStatistics {
    let totalQuizzes: Int
    let averageAccuracy: Double
    let totalXPEarned: Int
    let totalGemsEarned: Int

    var formattedAccuracy: String {
        return String(format: "%.1f%%", averageAccuracy)
    }

    var performanceLevel: String {
        switch averageAccuracy {
        case 90...100: return "Expert"
        case 75..<90: return "Advanced"
        case 60..<75: return "Intermediate"
        case 40..<60: return "Beginner"
        default: return "Novice"
        }
    }

    var performanceEmoji: String {
        switch averageAccuracy {
        case 90...100: return "🏆"
        case 75..<90: return "⭐"
        case 60..<75: return "👍"
        case 40..<60: return "💪"
        default: return "🌱"
        }
    }
}
