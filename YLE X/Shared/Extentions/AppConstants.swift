//
//  AppConstants.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

// MARK: - App Constants
struct AppConstants {
    // MARK: - General
    static let appName = "YLE X"
    static let appVersion = "1.0.0"
    
    // MARK: - Exercise Settings
    static let defaultExerciseCount = 10
    static let maxExerciseCount = 20
    static let minExerciseCount = 5
    
    // MARK: - Animation Durations
    static let shortAnimation: Double = 0.2
    static let mediumAnimation: Double = 0.3
    static let longAnimation: Double = 0.5
    
    // MARK: - URL Schemes
    static let appURLScheme = "yle-x"
    
    // MARK: - Keys
    struct UserDefaults {
        static let soundEnabled = "sound_enabled"
        static let musicEnabled = "music_enabled"
        static let hapticEnabled = "haptic_enabled"
        static let onboardingCompleted = "onboarding_completed"
    }
}