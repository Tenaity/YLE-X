//
//  SpacedRepetitionService.swift
//  YLE X
//
//  Created on 11/23/25.
//  SM-2 Spaced Repetition Algorithm for Flashcard Learning
//

import Foundation
import FirebaseFirestore

/// SM-2 Spaced Repetition Service
/// Implements the SuperMemo 2 algorithm for optimal flashcard review scheduling
class SpacedRepetitionService {
    static let shared = SpacedRepetitionService()

    private init() {}

    // MARK: - SM-2 Algorithm

    /// Calculate next review parameters based on user's response quality
    /// - Parameters:
    ///   - currentEaseFactor: Current ease factor (1.3 - 2.5)
    ///   - currentInterval: Current interval in days
    ///   - quality: User's response quality (0 = Again, 1 = Hard, 2 = Good, 3 = Easy)
    /// - Returns: Tuple with new ease factor, interval, and next review date
    func calculateNextReview(
        currentEaseFactor: Double,
        currentInterval: Int,
        quality: Int
    ) -> (easeFactor: Double, interval: Int, nextReviewDate: Date) {
        // SM-2 Algorithm Implementation
        var easeFactor = currentEaseFactor
        var interval = currentInterval

        // Update ease factor based on quality (0-3 scale)
        // Formula: EF' = EF + (0.1 - (2 - q) * (0.08 + (2 - q) * 0.02))
        let qualityFactor = Double(quality)
        easeFactor = easeFactor + (0.1 - (2.0 - qualityFactor) * (0.08 + (2.0 - qualityFactor) * 0.02))

        // Clamp ease factor between 1.3 and 2.5
        easeFactor = max(1.3, min(2.5, easeFactor))

        // Calculate new interval
        if quality == 0 {
            // Again: Reset to 1 day
            interval = 1
        } else if quality == 1 {
            // Hard: Short interval (3 days or current * 1.2)
            interval = max(3, Int(Double(currentInterval) * 1.2))
        } else if quality == 2 {
            // Good: Standard SM-2 progression
            if interval == 0 {
                interval = 1
            } else if interval == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
        } else {
            // Easy: Longer interval (current * easeFactor * 1.3)
            if interval == 0 {
                interval = 4
            } else {
                interval = Int(Double(interval) * easeFactor * 1.3)
            }
        }

        // Calculate next review date
        let nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()

        return (easeFactor: easeFactor, interval: interval, nextReviewDate: nextReviewDate)
    }

    // MARK: - Response Quality Mapping

    /// Response quality levels
    enum ResponseQuality: Int, CaseIterable {
        case again = 0  // Complete blackout, incorrect response
        case hard = 1   // Correct response but very difficult
        case good = 2   // Correct response with some difficulty
        case easy = 3   // Perfect response with no difficulty

        var title: String {
            switch self {
            case .again: return "Again"
            case .hard: return "Hard"
            case .good: return "Good"
            case .easy: return "Easy"
            }
        }

        var titleVi: String {
            switch self {
            case .again: return "Học lại"
            case .hard: return "Khó"
            case .good: return "Tốt"
            case .easy: return "Dễ"
            }
        }

        var description: String {
            switch self {
            case .again: return "I didn't remember"
            case .hard: return "Difficult to remember"
            case .good: return "I remembered"
            case .easy: return "Very easy"
            }
        }

        var descriptionVi: String {
            switch self {
            case .again: return "Chưa nhớ"
            case .hard: return "Khó nhớ"
            case .good: return "Đã nhớ"
            case .easy: return "Rất dễ"
            }
        }

        var color: String {
            switch self {
            case .again: return "#FF3B30"  // Red
            case .hard: return "#FF9500"  // Orange
            case .good: return "#34C759"  // Green
            case .easy: return "#007AFF"  // Blue
            }
        }

        var icon: String {
            switch self {
            case .again: return "arrow.counterclockwise"
            case .hard: return "exclamationmark.triangle.fill"
            case .good: return "checkmark.circle.fill"
            case .easy: return "star.fill"
            }
        }
    }

    // MARK: - Preview Intervals

    /// Get preview of next review time for each quality option
    /// - Parameters:
    ///   - currentEaseFactor: Current ease factor
    ///   - currentInterval: Current interval in days
    /// - Returns: Dictionary mapping quality to preview string
    func getPreviewIntervals(
        currentEaseFactor: Double,
        currentInterval: Int
    ) -> [ResponseQuality: String] {
        var previews: [ResponseQuality: String] = [:]

        for quality in ResponseQuality.allCases {
            let result = calculateNextReview(
                currentEaseFactor: currentEaseFactor,
                currentInterval: currentInterval,
                quality: quality.rawValue
            )
            previews[quality] = formatInterval(result.interval)
        }

        return previews
    }

    /// Format interval to human-readable string
    /// - Parameter days: Number of days
    /// - Returns: Formatted string (e.g., "1d", "3d", "2w", "1mo")
    private func formatInterval(_ days: Int) -> String {
        if days < 7 {
            return "\(days)d"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks)w"
        } else if days < 365 {
            let months = days / 30
            return "\(months)mo"
        } else {
            let years = days / 365
            return "\(years)y"
        }
    }

    // MARK: - Review Schedule Analysis

    /// Get cards due for review
    /// - Parameter allProgress: All user's flashcard progress
    /// - Returns: Array of card IDs due for review
    func getCardsDueForReview(_ allProgress: [String: FlashcardProgress]) -> [String] {
        let now = Date()
        return allProgress.filter { _, progress in
            progress.nextReviewDate <= now
        }.map { $0.key }
    }

    /// Get review statistics
    /// - Parameter allProgress: All user's flashcard progress
    /// - Returns: Statistics dictionary
    func getReviewStatistics(_ allProgress: [String: FlashcardProgress]) -> ReviewStatistics {
        let now = Date()
        let calendar = Calendar.current

        let dueToday = allProgress.filter { _, progress in
            calendar.isDateInToday(progress.nextReviewDate) || progress.nextReviewDate < now
        }.count

        let newCards = allProgress.filter { _, progress in
            progress.reviewCount == 0
        }.count

        let learning = allProgress.filter { _, progress in
            progress.reviewCount > 0 && progress.interval < 21  // Less than 3 weeks
        }.count

        let mature = allProgress.filter { _, progress in
            progress.interval >= 21  // 3 weeks or more
        }.count

        let totalReviews = allProgress.values.reduce(0) { $0 + $1.reviewCount }

        let averageEaseFactor = allProgress.isEmpty ? 2.5 :
            allProgress.values.reduce(0.0) { $0 + $1.easeFactor } / Double(allProgress.count)

        return ReviewStatistics(
            dueToday: dueToday,
            newCards: newCards,
            learning: learning,
            mature: mature,
            totalCards: allProgress.count,
            totalReviews: totalReviews,
            averageEaseFactor: averageEaseFactor
        )
    }
}

// MARK: - Review Statistics Model

struct ReviewStatistics {
    let dueToday: Int
    let newCards: Int
    let learning: Int
    let mature: Int
    let totalCards: Int
    let totalReviews: Int
    let averageEaseFactor: Double
}
