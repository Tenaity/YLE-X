//
//  Constants.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  App-wide constants
//

import Foundation

// MARK: - App Constants
struct AppConstants {
    // MARK: - General
    static let appName = "YLE X"
    static let appVersion = "1.0.0"
    static let appBuild = "1"

    // MARK: - Exercise Settings
    static let defaultExerciseCount = 10
    static let maxExerciseCount = 20
    static let minExerciseCount = 5

    // MARK: - Timing
    static let animationDuration = 0.3
    static let shortDelay = 0.1
    static let mediumDelay = 0.3
    static let longDelay = 0.5

    // MARK: - User Defaults Keys
    struct UserDefaults {
        static let soundEnabled = "app.sound.enabled"
        static let hapticEnabled = "app.haptic.enabled"
        static let onboardingCompleted = "app.onboarding.completed"
        static let currentLevel = "app.user.level"
    }
}
