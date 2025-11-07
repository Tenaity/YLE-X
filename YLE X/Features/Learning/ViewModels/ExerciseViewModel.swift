//
//  ExerciseViewModel.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ExerciseViewModel: ObservableObject {
    let lesson: Lesson
    private let lessonService = LessonService.shared

    @Published var exercises: [LessonExercise] = []
    @Published var currentExerciseIndex = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var currentScore = 0
    @Published var correctAnswersCount = 0
    @Published var isLoading = false

    var currentExercise: LessonExercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var hasNextExercise: Bool {
        currentExerciseIndex < exercises.count - 1
    }

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex + 1) / Double(exercises.count)
    }

    var isLastAnswerCorrect: Bool {
        selectedAnswer == currentExercise?.correctAnswer
    }

    init(lesson: Lesson) {
        self.lesson = lesson
    }

    // MARK: - Load Exercises
    func loadExercises() async {
        guard let lessonId = lesson.id else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            exercises = try await lessonService.fetchExercises(for: lessonId)
            // Shuffle for variety
            exercises.shuffle()
        } catch {
            print("Error loading exercises: \(error)")
        }
    }

    // MARK: - Select Answer
    func selectAnswer(_ answer: String) {
        guard !showFeedback else { return }
        selectedAnswer = answer
    }

    // MARK: - Submit Answer
    func submitAnswer() {
        guard let answer = selectedAnswer,
              let exercise = currentExercise else { return }

        showFeedback = true

        if answer == exercise.correctAnswer {
            correctAnswersCount += 1
            currentScore += exercise.points
        }
    }

    // MARK: - Move to Next Exercise
    func moveToNextExercise() {
        guard hasNextExercise else { return }

        currentExerciseIndex += 1
        selectedAnswer = nil
        showFeedback = false
    }

    // MARK: - Generate Result
    func generateResult() -> LessonResult {
        let totalPoints = exercises.reduce(0) { $0 + $1.points }
        let percentage = totalPoints > 0 ? Double(currentScore) / Double(totalPoints) : 0
        let stars = lessonService.calculateStars(percentage: percentage)

        // Calculate XP (base XP + bonus for stars)
        let xpEarned = lesson.xpReward + (stars * 10)

        // Check if new record
        let previousProgress = lessonService.getProgress(for: lesson.id ?? "")
        let isNewRecord = (previousProgress?.score ?? 0) < currentScore

        return LessonResult(
            lesson: lesson,
            score: currentScore,
            totalPoints: totalPoints,
            correctAnswers: correctAnswersCount,
            totalQuestions: exercises.count,
            xpEarned: xpEarned,
            stars: stars,
            isNewRecord: isNewRecord
        )
    }

    // MARK: - Reset
    func reset() {
        currentExerciseIndex = 0
        selectedAnswer = nil
        showFeedback = false
        currentScore = 0
        correctAnswersCount = 0
        exercises.shuffle()
    }
}
