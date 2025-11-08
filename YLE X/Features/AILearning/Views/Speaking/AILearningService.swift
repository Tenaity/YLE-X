import Foundation
import SwiftUI

final class AILearningService: @unchecked Sendable {
    static let shared = AILearningService()
    private init() {}

    // Main API: produce a PronunciationScore using simple heuristics
    func analyzePronunciation(expected: String, actual: String) -> PronunciationScore {
        let expectedTokens = tokenizeAndNormalize(expected)
        let actualTokens = tokenizeAndNormalize(actual)

        // Alignment and per-word scoring
        var wordScores: [WordScore] = []
        var correctCount = 0
        var presentCount = 0
        var insertedCount = 0

        // Track matched actual indices to later detect extra insertions
        var matchedActualIndices = Set<Int>()

        let maxCount = max(expectedTokens.count, actualTokens.count)
        for index in 0..<maxCount {
            if index < expectedTokens.count && index < actualTokens.count {
                let expectedWord = expectedTokens[index]
                let actualWord = actualTokens[index]

                if expectedWord == actualWord {
                    wordScores.append(
                        WordScore(
                            word: actualWord,
                            expected: expectedWord,
                            accuracy: 100,
                            status: .correct,
                            suggestion: nil
                        )
                    )
                    correctCount += 1
                    presentCount += 1
                    matchedActualIndices.insert(index)
                } else {
                    let ratio = levenshteinDistanceRatio(s1: expectedWord, s2: actualWord) // 0...1
                    let percent = max(0, min(100, Int((ratio * 100).rounded())))
                    let status: WordStatus = ratio >= 0.6 ? .mispronounced : .mispronounced // keep mispronounced for any non-exact

                    wordScores.append(
                        WordScore(
                            word: actualWord,
                            expected: expectedWord,
                            accuracy: Double(percent),
                            status: status,
                            suggestion: ratio >= 0.6 ? nil : "Try: \(expectedWord)"
                        )
                    )
                    presentCount += 1
                    matchedActualIndices.insert(index)
                }
            } else if index < expectedTokens.count {
                // Omitted expected word
                let expectedWord = expectedTokens[index]
                wordScores.append(
                    WordScore(
                        word: "",
                        expected: expectedWord,
                        accuracy: 0,
                        status: .omitted,
                        suggestion: "Remember to say: \(expectedWord)"
                    )
                )
            } else if index < actualTokens.count {
                // Inserted extra word
                let actualWord = actualTokens[index]
                wordScores.append(
                    WordScore(
                        word: actualWord,
                        expected: actualWord,
                        accuracy: 0,
                        status: .inserted,
                        suggestion: "Extra word"
                    )
                )
                insertedCount += 1
                matchedActualIndices.insert(index)
            }
        }

        // Capture any additional inserted words that weren't aligned
        for (idx, actualWord) in actualTokens.enumerated() where !matchedActualIndices.contains(idx) {
            wordScores.append(
                WordScore(
                    word: actualWord,
                    expected: actualWord,
                    accuracy: 0,
                    status: .inserted,
                    suggestion: "Extra word"
                )
            )
            insertedCount += 1
        }

        // Aggregate metrics (all on 0...100 scale)
        let accuracy: Double = expectedTokens.isEmpty ? 100 : (Double(correctCount) / Double(expectedTokens.count)) * 100
        let completeness: Double = expectedTokens.isEmpty ? 100 : (Double(presentCount) / Double(expectedTokens.count)) * 100

        // Fluency heuristic: penalize insertions and breaks between fluent/non-fluent
        var breaks = 0
        var lastWasFluent: Bool? = nil
        for ws in wordScores {
            let fluent = (ws.status == .correct || ws.status == .mispronounced)
            if let last = lastWasFluent, last != fluent, ws.status != .inserted {
                breaks += 1
            }
            lastWasFluent = fluent
        }
        let fluencyRaw = max(0, 100 - (insertedCount * 10) - (breaks * 5))
        let fluency = Double(fluencyRaw)

        // Overall weighted score
        let overallScore = (0.5 * accuracy) + (0.3 * fluency) + (0.2 * completeness)

        // Feedback
        var feedback: [String] = []
        if accuracy < 60 {
            feedback.append("Pronunciation accuracy is low, please practice the correct sounds.")
        } else if accuracy < 85 {
            feedback.append("Good pronunciation, but there is room for improvement.")
        } else {
            feedback.append("Excellent pronunciation!")
        }

        if completeness < 80 {
            feedback.append("Some words were omitted, be sure to pronounce all words.")
        }

        if insertedCount > 0 {
            feedback.append("There are some extra words detected that were not expected.")
        }

        if fluency < 60 {
            feedback.append("Try to improve your fluency and smoothness of speech.")
        }

        return PronunciationScore(
            overallScore: overallScore,
            accuracy: accuracy,
            fluency: fluency,
            completeness: completeness,
            wordScores: wordScores,
            feedback: feedback
        )
    }

    // MARK: - Helpers

    private func tokenizeAndNormalize(_ text: String) -> [String] {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        return text
            .lowercased()
            .components(separatedBy: separators)
            .filter { !$0.isEmpty }
    }

    private func levenshteinDistanceRatio(s1: String, s2: String) -> Double {
        let distance = Self.levenshtein(s1: s1, s2: s2)
        let maxLen = max(s1.count, s2.count)
        guard maxLen > 0 else { return 1 }
        return 1 - (Double(distance) / Double(maxLen))
    }

    private static func levenshtein(s1: String, s2: String) -> Int {
        let a = Array(s1)
        let b = Array(s2)

        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }
}
