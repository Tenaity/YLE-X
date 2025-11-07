//
//  HomeViewModel.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = "Emily"
    @Published var currentStreak: Int = 7
    @Published var todayMinutes: Int = 15
    @Published var dailyGoal: Int = 30
    @Published var totalXP: Int = 1250
    @Published var currentLevel: YLELevel = .starters
    @Published var recentBadges: [BadgeItem] = []

    // MARK: - Computed Properties
    var dailyProgress: Double {
        min(Double(todayMinutes) / Double(dailyGoal), 1.0)
    }

    var xpToNextLevel: Int {
        let nextLevelXP = 2000
        return nextLevelXP - totalXP
    }

    var xpProgress: Double {
        let currentLevelXP = 1000
        let nextLevelXP = 2000
        let progress = Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return min(max(progress, 0), 1.0)
    }

    // MARK: - Skill Progress
    private var skillProgressData: [Skill: Double] = [
        .listening: 0.75,
        .reading: 0.60,
        .writing: 0.45,
        .speaking: 0.80,
        .vocabulary: 0.90,
        .grammar: 0.55
    ]

    // MARK: - Initialization
    init() {
        loadUserData()
        setupRecentBadges()
    }

    // MARK: - Public Methods
    func selectLevel(_ level: YLELevel) {
        currentLevel = level
        HapticManager.shared.playLight()
        // TODO: Save selection and update curriculum
    }

    func getSkillProgress(_ skill: Skill) -> Double {
        skillProgressData[skill] ?? 0.0
    }

    // MARK: - Private Methods
    private func loadUserData() {
        // TODO: Load from Firebase/UserDefaults
        // For now using mock data
    }

    private func setupRecentBadges() {
        recentBadges = [
            BadgeItem(name: "First Step", emoji: "👣", color: .appLevelStarters),
            BadgeItem(name: "Word Master", emoji: "📚", color: .appSkillVocabulary),
            BadgeItem(name: "7 Day Streak", emoji: "🔥", color: .appAccent),
            BadgeItem(name: "Perfect Score", emoji: "💯", color: .appBadgeGold),
            BadgeItem(name: "Early Bird", emoji: "🌅", color: .appPrimary)
        ]
    }
}
