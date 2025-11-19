//
//  QuizQuestion.swift
//  YLE X
//
//  Created on 11/18/25.
//  Quiz question models with multiple question types
//

import Foundation

// MARK: - Quiz Question

struct QuizQuestion: Identifiable {
    let id = UUID()
    let word: DictionaryWord
    let type: QuestionType
    let question: String
    let correctAnswer: String
    let options: [String]  // For multiple choice
    let hint: String?

    enum QuestionType {
        case multipleChoice      // Definition → Word
        case listening           // Audio → Word
        case translation         // English → Vietnamese
        case reverseTranslation  // Vietnamese → English
        case fillInBlank         // Sentence with blank
        case matching            // Match word to image/definition

        var icon: String {
            switch self {
            case .multipleChoice: return "list.bullet.circle.fill"
            case .listening: return "speaker.wave.3.fill"
            case .translation: return "translate"
            case .reverseTranslation: return "arrow.left.arrow.right"
            case .fillInBlank: return "text.cursor"
            case .matching: return "link.circle.fill"
            }
        }

        var displayName: String {
            switch self {
            case .multipleChoice: return "Multiple Choice"
            case .listening: return "Listening"
            case .translation: return "Translation"
            case .reverseTranslation: return "Reverse Translation"
            case .fillInBlank: return "Fill in the Blank"
            case .matching: return "Matching"
            }
        }
    }

    // MARK: - Validation

    func isCorrect(_ answer: String) -> Bool {
        return answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            == correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Question Generators

    /// Generate multiple choice question (Definition → Word)
    static func generateMultipleChoice(
        for word: DictionaryWord,
        with distractors: [DictionaryWord]
    ) -> QuizQuestion {
        let question = "What is the meaning of this word?\n\n\"\(word.definitionEn)\""

        var options = [word.word]
        options.append(contentsOf: distractors.prefix(3).map { $0.word })
        options.shuffle()

        return QuizQuestion(
            word: word,
            type: .multipleChoice,
            question: question,
            correctAnswer: word.word,
            options: options,
            hint: "Think about: \(word.primaryPos)"
        )
    }

    /// Generate listening question (Audio → Word)
    static func generateListening(
        for word: DictionaryWord,
        with distractors: [DictionaryWord]
    ) -> QuizQuestion {
        let question = "Listen and choose the correct word"

        var options = [word.word]
        options.append(contentsOf: distractors.prefix(3).map { $0.word })
        options.shuffle()

        return QuizQuestion(
            word: word,
            type: .listening,
            question: question,
            correctAnswer: word.word,
            options: options,
            hint: "IPA: \(word.pronunciation.british.ipa)"
        )
    }

    /// Generate translation question (English → Vietnamese)
    static func generateTranslation(
        for word: DictionaryWord,
        with distractors: [DictionaryWord]
    ) -> QuizQuestion {
        let question = "What is the Vietnamese translation?\n\n\(word.word)"

        var options = [word.translationVi]
        options.append(contentsOf: distractors.prefix(3).map { $0.translationVi })
        options.shuffle()

        return QuizQuestion(
            word: word,
            type: .translation,
            question: question,
            correctAnswer: word.translationVi,
            options: options,
            hint: "Part of speech: \(word.primaryPos)"
        )
    }

    /// Generate reverse translation question (Vietnamese → English)
    static func generateReverseTranslation(
        for word: DictionaryWord,
        with distractors: [DictionaryWord]
    ) -> QuizQuestion {
        let question = "What is the English word for?\n\n\(word.translationVi)"

        var options = [word.word]
        options.append(contentsOf: distractors.prefix(3).map { $0.word })
        options.shuffle()

        return QuizQuestion(
            word: word,
            type: .reverseTranslation,
            question: question,
            correctAnswer: word.word,
            options: options,
            hint: "It's a \(word.primaryPos)"
        )
    }

    /// Generate fill in blank question
    static func generateFillInBlank(for word: DictionaryWord) -> QuizQuestion? {
        guard let example = word.examples.first else { return nil }

        // Replace word with blank
        let sentence = example.sentence
        let blank = "________"
        let questionText = sentence.replacingOccurrences(
            of: word.word,
            with: blank,
            options: .caseInsensitive
        )

        // If no replacement happened, word not in example
        guard questionText.contains(blank) else { return nil }

        return QuizQuestion(
            word: word,
            type: .fillInBlank,
            question: "Fill in the blank:\n\n\(questionText)",
            correctAnswer: word.word,
            options: [],  // Text input, no options
            hint: "Translation: \(word.translationVi)"
        )
    }
}

// MARK: - Quiz Session

struct QuizSession: Identifiable {
    let id = UUID()
    let category: VocabularyCategory
    let level: YLELevel
    let quizMode: QuizMode
    var questions: [QuizQuestion]
    var currentIndex: Int = 0
    var answers: [UUID: String] = [:]  // questionId: answer
    var startTime: Date = Date()

    enum QuizMode: String, CaseIterable {
        case mixed = "Mixed"
        case multipleChoice = "Multiple Choice"
        case listening = "Listening"
        case translation = "Translation"

        var icon: String {
            switch self {
            case .mixed: return "shuffle"
            case .multipleChoice: return "list.bullet.circle.fill"
            case .listening: return "speaker.wave.3.fill"
            case .translation: return "translate"
            }
        }

        var description: String {
            switch self {
            case .mixed: return "All question types"
            case .multipleChoice: return "Definition → Word"
            case .listening: return "Audio → Word"
            case .translation: return "English ↔ Vietnamese"
            }
        }
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isComplete: Bool {
        return currentIndex >= questions.count
    }

    var score: Int {
        var correct = 0
        for (questionId, answer) in answers {
            if let question = questions.first(where: { $0.id == questionId }),
               question.isCorrect(answer) {
                correct += 1
            }
        }
        return correct
    }

    var accuracy: Double {
        guard !answers.isEmpty else { return 0 }
        return Double(score) / Double(answers.count) * 100
    }

    mutating func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        answers[question.id] = answer
        currentIndex += 1
    }

    mutating func skipQuestion() {
        currentIndex += 1
    }
}

// MARK: - Quiz Results

struct QuizResults: Identifiable {
    let id = UUID()
    let session: QuizSession
    let completedAt: Date
    let xpEarned: Int
    let gemsEarned: Int
    let streak: Int

    var formattedDuration: String {
        let duration = completedAt.timeIntervalSince(session.startTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var grade: Grade {
        let accuracy = session.accuracy
        switch accuracy {
        case 95...100: return .perfect
        case 85..<95: return .excellent
        case 70..<85: return .good
        case 50..<70: return .fair
        default: return .needsImprovement
        }
    }

    enum Grade {
        case perfect
        case excellent
        case good
        case fair
        case needsImprovement

        var emoji: String {
            switch self {
            case .perfect: return "🌟"
            case .excellent: return "🎉"
            case .good: return "👍"
            case .fair: return "💪"
            case .needsImprovement: return "📚"
            }
        }

        var title: String {
            switch self {
            case .perfect: return "Perfect!"
            case .excellent: return "Excellent!"
            case .good: return "Good Job!"
            case .fair: return "Keep Practicing!"
            case .needsImprovement: return "Keep Learning!"
            }
        }

        var message: String {
            switch self {
            case .perfect: return "You're amazing! 100% correct!"
            case .excellent: return "Outstanding work!"
            case .good: return "You're doing great!"
            case .fair: return "You're improving!"
            case .needsImprovement: return "Practice makes perfect!"
            }
        }

        var color: String {
            switch self {
            case .perfect: return "#FFD700"  // Gold
            case .excellent: return "#00D084" // Green
            case .good: return "#4A90E2"     // Blue
            case .fair: return "#FF9500"     // Orange
            case .needsImprovement: return "#FF6B6B" // Red
            }
        }
    }

    // MARK: - Answer Review

    struct AnswerReview: Identifiable {
        let id = UUID()
        let question: QuizQuestion
        let userAnswer: String?
        let isCorrect: Bool

        var status: String {
            if userAnswer == nil {
                return "Skipped"
            }
            return isCorrect ? "Correct" : "Incorrect"
        }

        var statusIcon: String {
            if userAnswer == nil {
                return "forward.fill"
            }
            return isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
        }

        var statusColor: String {
            if userAnswer == nil {
                return "#8E8E93" // Gray
            }
            return isCorrect ? "#00D084" : "#FF6B6B"
        }
    }

    func getAnswerReviews() -> [AnswerReview] {
        return session.questions.map { question in
            let userAnswer = session.answers[question.id]
            let isCorrect = userAnswer.map { question.isCorrect($0) } ?? false

            return AnswerReview(
                question: question,
                userAnswer: userAnswer,
                isCorrect: isCorrect
            )
        }
    }
}
