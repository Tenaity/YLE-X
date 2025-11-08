//
//  ProgramSelectionStore.swift
//  YLE X
//
//  Created by Coding Agent on 5/8/24.
//

import Foundation
import Combine

@MainActor
final class ProgramSelectionStore: ObservableObject {
    // MARK: - Published State
    @Published private(set) var selectedLevel: YLELevel

    // MARK: - Storage
    private let storageKey = "app.programSelection.currentLevel"
    private let onboardingKey = "app.onboarding.selectedLevel"
    private let userDefaults: UserDefaults

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let storedValue = userDefaults.string(forKey: storageKey),
           let storedLevel = YLELevel(rawValue: storedValue) {
            selectedLevel = storedLevel
        } else if let onboardingValue = userDefaults.string(forKey: onboardingKey),
                  let onboardingLevel = YLELevel(rawValue: onboardingValue) {
            selectedLevel = onboardingLevel
        } else {
            selectedLevel = .starters
        }
    }

    // MARK: - Public API
    func select(level: YLELevel) {
        guard selectedLevel != level else { return }
        selectedLevel = level
        persist(level)
    }

    // MARK: - Persistence
    private func persist(_ level: YLELevel) {
        userDefaults.set(level.rawValue, forKey: storageKey)
        userDefaults.set(level.rawValue, forKey: onboardingKey)
    }
}
