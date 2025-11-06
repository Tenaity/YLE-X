//
//  ExerciseSessionViewModel.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import Combine

@MainActor
class ExerciseSessionViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var totalAnswers: Int = 0
    let totalExercises: Int = 10
    
    func recordCorrectAnswer() {
        correctAnswers += 1
        totalAnswers += 1
    }
    
    func recordIncorrectAnswer() {
        totalAnswers += 1
    }
    
    func moveToNextExercise() {
        currentIndex += 1
    }
    
    var accuracy: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }
}
