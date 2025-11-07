//
//  Lesson.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Lesson Model
struct Lesson: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let level: String  // "starters", "movers", "flyers"
    let skill: String  // "vocabulary", "listening", etc.
    let order: Int
    let xpReward: Int
    let isLocked: Bool
    let thumbnailEmoji: String
    let estimatedMinutes: Int
    let totalExercises: Int

    var ylelevel: YLELevel? {
        YLELevel(rawValue: level.capitalized)
    }

    var skillType: Skill? {
        Skill(rawValue: skill.capitalized)
    }
}

// MARK: - Lesson Exercise Model
struct LessonExercise: Identifiable, Codable {
    @DocumentID var id: String?
    let lessonId: String
    let type: ExerciseType
    let question: String
    let emoji: String?
    let imageUrl: String?
    let audioUrl: String?
    let options: [String]
    let correctAnswer: String
    let order: Int
    let points: Int

    enum ExerciseType: String, Codable {
        case multipleChoice = "multipleChoice"
        case fillBlank = "fillBlank"
        case matching = "matching"
        case speaking = "speaking"
    }
}

// MARK: - User Lesson Progress
struct UserLessonProgress: Codable {
    let lessonId: String
    let completed: Bool
    let score: Int
    let stars: Int  // 1-3 stars
    let attempts: Int
    let completedAt: Date?
    let exercisesCompleted: [String]

    var completionPercentage: Double {
        guard let lesson = LessonService.shared.getCachedLesson(lessonId) else { return 0 }
        return Double(exercisesCompleted.count) / Double(lesson.totalExercises)
    }
}

// MARK: - Lesson Result
struct LessonResult {
    let lesson: Lesson
    let score: Int
    let totalPoints: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let xpEarned: Int
    let stars: Int
    let isNewRecord: Bool

    var percentage: Double {
        Double(score) / Double(totalPoints)
    }

    var performanceLevel: PerformanceLevel {
        switch percentage {
        case 0.9...1.0: return .excellent
        case 0.7..<0.9: return .good
        case 0.5..<0.7: return .average
        default: return .needsImprovement
        }
    }

    enum PerformanceLevel: String {
        case excellent = "Excellent! 🌟"
        case good = "Good Job! 👍"
        case average = "Keep Trying! 💪"
        case needsImprovement = "Practice More! 📚"
    }
}
