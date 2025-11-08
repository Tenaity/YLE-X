import Foundation
import SwiftUI

final class AILearningService: @unchecked Sendable {
    static let shared = AILearningService()
    private init() {}

    func analyzePronunciation(expected: String, actual: String) -> PronunciationScore {
        let expectedTokens = tokenizeAndNormalize(expected)
        let actualTokens = tokenizeAndNormalize(actual)

        enum WordStatus {
            case correct
            case mispronounced
            case omitted
            case inserted
        }

        struct WordScore {
            let word: String
            let expected: String
            let status: WordStatus
            let accuracy: Double
        }

        var wordScores: [WordScore] = []

        var insertedIndices = Set<Int>()
        var omittedCount = 0
        var correctCount = 0
        var presentCount = 0
        var insertedCount = 0

        // Map to track which actual tokens are matched
        var matchedActualIndices = Set<Int>()

        // Align expected and actual by index position
        let maxCount = max(expectedTokens.count, actualTokens.count)
        for index in 0..<maxCount {
            if index < expectedTokens.count && index < actualTokens.count {
                let expectedWord = expectedTokens[index]
                let actualWord = actualTokens[index]
                if expectedWord == actualWord {
                    wordScores.append(WordScore(word: actualWord, expected: expectedWord, status: .correct, accuracy: 1))
                    correctCount += 1
                    presentCount += 1
                    matchedActualIndices.insert(index)
                } else {
                    let levRatio = levenshteinDistanceRatio(s1: expectedWord, s2: actualWord)
                    if levRatio < 1 {
                        wordScores.append(WordScore(word: actualWord, expected: expectedWord, status: .mispronounced, accuracy: levRatio))
                        presentCount += 1
                        matchedActualIndices.insert(index)
                    } else {
                        wordScores.append(WordScore(word: "", expected: expectedWord, status: .omitted, accuracy: 0))
                        omittedCount += 1
                    }
                }
            } else if index < expectedTokens.count {
                let expectedWord = expectedTokens[index]
                wordScores.append(WordScore(word: "", expected: expectedWord, status: .omitted, accuracy: 0))
                omittedCount += 1
            } else if index < actualTokens.count {
                let actualWord = actualTokens[index]
                wordScores.append(WordScore(word: actualWord, expected: actualWord, status: .inserted, accuracy: 0))
                insertedCount += 1
                matchedActualIndices.insert(index)
            }
        }

        // Check for inserted words not aligned by index (e.g. extra words in actual)
        for (index, actualWord) in actualTokens.enumerated() {
            if !matchedActualIndices.contains(index) {
                wordScores.append(WordScore(word: actualWord, expected: actualWord, status: .inserted, accuracy: 0))
                insertedCount += 1
            }
        }

        // Accuracy: percentage of expected tokens marked correct
        let accuracy: Double = expectedTokens.isEmpty ? 1.0 : Double(correctCount) / Double(expectedTokens.count)

        // Completeness: percentage of expected tokens present in any status except omitted
        let completeness: Double = expectedTokens.isEmpty ? 1.0 : Double(presentCount) / Double(expectedTokens.count)

        // Fluency: continuity of correct/near-correct runs
        // Calculate breaks = number of transitions between correct/mispronounced and omitted/inserted
        var breaks = 0
        var lastWasFluent = false
        for wordScore in wordScores {
            let fluent = (wordScore.status == .correct || wordScore.status == .mispronounced)
            if lastWasFluent != fluent && wordScore.status != .inserted {
                breaks += 1
            }
            lastWasFluent = fluent
        }
        var fluencyRaw = 100 - (insertedCount * 10) - (breaks * 5)
        if fluencyRaw < 0 { fluencyRaw = 0 }
        if fluencyRaw > 100 { fluencyRaw = 100 }
        let fluency = Double(fluencyRaw)

        // OverallScore: weighted average
        let overallScore = 0.5 * accuracy + 0.3 * (fluency / 100) + 0.2 * completeness

        // Feedback generation
        var feedback: [String] = []
        if accuracy < 0.6 {
            feedback.append("Pronunciation accuracy is low, please practice the correct sounds.")
        } else if accuracy < 0.85 {
            feedback.append("Good pronunciation, but there is room for improvement.")
        } else {
            feedback.append("Excellent pronunciation!")
        }

        if completeness < 0.8 {
            feedback.append("Some words were omitted, be sure to pronounce all words.")
        }

        if insertedCount > 0 {
            feedback.append("There are some extra words detected that were not expected.")
        }

        if fluency < 60 {
            feedback.append("Try to improve your fluency and smoothness of speech.")
        }

        // Convert WordScore array to [PronunciationWordScore]
        let resultWordScores: [PronunciationWordScore] = wordScores.map { ws in
            let wordString: String
            let expectedString: String
            switch ws.status {
            case .inserted:
                wordString = ws.word
                expectedString = ws.expected
            case .omitted:
                wordString = ""
                expectedString = ws.expected
            default:
                wordString = ws.word
                expectedString = ws.expected
            }
            return PronunciationWordScore(
                word: wordString,
                expected: expectedString,
                status: ws.statusToPronunciationWordScoreStatus(),
                accuracy: ws.accuracy
            )
        }

        return PronunciationScore(
            accuracy: accuracy,
            completeness: completeness,
            fluency: fluency / 100,
            overallScore: overallScore,
            feedback: feedback,
            wordScores: resultWordScores
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

        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

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

private extension AILearningService.WordStatus {
    func toPronunciationWordScoreStatus() -> PronunciationWordScore.Status {
        switch self {
        case .correct: return .correct
        case .mispronounced: return .mispronounced
        case .omitted: return .omitted
        case .inserted: return .inserted
        }
    }
}

private extension AILearningService.WordScore {
    func statusToPronunciationWordScoreStatus() -> PronunciationWordScore.Status {
        switch status {
        case .correct: return .correct
        case .mispronounced: return .mispronounced
        case .omitted: return .omitted
        case .inserted: return .inserted
        }
    }
}
