//
//  LearningPathProgress.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//

import Foundation

// MARK: - Linear Path Progress (Main Quest)
struct LinearPathProgress: Identifiable, Codable {
    let id: String  // Usually userId
    let userId: String
    var currentPhase: YLELevel     // Starters, Movers, or Flyers
    var currentRound: Int          // 1-20 per phase
    var roundsCompleted: [String]  // Array of round/lesson IDs completed
    var bossesDefeated: [String]   // Array of boss battle IDs completed
    var totalXPEarned: Int
    var totalGemsEarned: Int
    var createdAt: Date
    var lastUpdatedAt: Date

    // MARK: - Computed Properties
    var progressPercentage: Double {
        let totalRounds = 20  // Each phase has 20 rounds
        let currentPhaseProgress = Double(roundsCompleted.count) / Double(totalRounds)
        return currentPhaseProgress
    }

    var isCurrentPhaseCompleted: Bool {
        roundsCompleted.count >= 20
    }

    var roundsUntilBoss: Int {
        let completedCount = roundsCompleted.count % 20
        return max(0, 20 - completedCount)
    }

    var canUnlockNextPhase: Bool {
        isCurrentPhaseCompleted && !bossesDefeated.isEmpty && currentPhase != .flyers
    }

    // Total rounds across all phases
    var totalRoundsCompleted: Int {
        roundsCompleted.count
    }

    // Which phase is next
    var nextPhase: YLELevel? {
        switch currentPhase {
        case .starters: return .movers
        case .movers: return .flyers
        case .flyers: return nil
        }
    }

    // MARK: - Initialization
    init(
        userId: String,
        currentPhase: YLELevel = .starters,
        currentRound: Int = 1,
        roundsCompleted: [String] = [],
        bossesDefeated: [String] = [],
        totalXPEarned: Int = 0,
        totalGemsEarned: Int = 0
    ) {
        self.id = userId
        self.userId = userId
        self.currentPhase = currentPhase
        self.currentRound = currentRound
        self.roundsCompleted = roundsCompleted
        self.bossesDefeated = bossesDefeated
        self.totalXPEarned = totalXPEarned
        self.totalGemsEarned = totalGemsEarned
        self.createdAt = Date()
        self.lastUpdatedAt = Date()
    }
}

// MARK: - Sandbox Progress (Side Quest)
struct SandboxProgress: Identifiable, Codable {
    let id: String  // Usually userId
    let userId: String
    var unlockedIslands: [String]     // Island category IDs like "vocab_island", "skills_workshop"
    var unlockedTopics: [String]      // Topic IDs like "vocab_animals", "vocab_school"
    var unlockedSkills: [String]      // Skill workshop IDs like "ipa_workshop", "fluency_lab"
    var unlockedGames: [String]       // Game IDs like "spelling_bee", "word_match"
    var completedActivities: [String] // Activity IDs completed
    var activityScores: [String: Int] // Activity ID → score mapping
    var topicProgress: [String: TopicProgress]  // Track progress per topic
    var totalGemsSpent: Int           // Gems used to unlock items
    var totalActivitiesCompleted: Int
    var createdAt: Date
    var lastUpdatedAt: Date

    // MARK: - Computed Properties
    var totalIslandsDiscovered: Int {
        unlockedIslands.count
    }

    var totalTopicsUnlocked: Int {
        unlockedTopics.count
    }

    var averageActivityScore: Double {
        guard !activityScores.isEmpty else { return 0 }
        let sum = activityScores.values.reduce(0, +)
        return Double(sum) / Double(activityScores.count)
    }

    var discoveryPercentage: Double {
        // Assume there are 12 total islands to discover
        let totalIslands = 12.0
        return Double(unlockedIslands.count) / totalIslands
    }

    // MARK: - Initialization
    init(
        userId: String,
        unlockedIslands: [String] = [],
        unlockedTopics: [String] = [],
        unlockedSkills: [String] = [],
        unlockedGames: [String] = [],
        completedActivities: [String] = [],
        activityScores: [String: Int] = [:],
        topicProgress: [String: TopicProgress] = [:],
        totalGemsSpent: Int = 0
    ) {
        self.id = userId
        self.userId = userId
        self.unlockedIslands = unlockedIslands
        self.unlockedTopics = unlockedTopics
        self.unlockedSkills = unlockedSkills
        self.unlockedGames = unlockedGames
        self.completedActivities = completedActivities
        self.activityScores = activityScores
        self.topicProgress = topicProgress
        self.totalGemsSpent = totalGemsSpent
        self.totalActivitiesCompleted = completedActivities.count
        self.createdAt = Date()
        self.lastUpdatedAt = Date()
    }
}

// MARK: - Topic Progress (Nested within SandboxProgress)
struct TopicProgress: Identifiable, Codable {
    let id: String  // Topic ID
    let topicName: String  // e.g., "Animals", "School"
    var easyCompleted: Int  // 0-5
    var mediumCompleted: Int  // 0-5
    var hardCompleted: Int   // 0-5
    var bestScore: Int
    var averageScore: Double
    var lastCompletedAt: Date?

    // Computed properties
    var totalCompleted: Int {
        easyCompleted + mediumCompleted + hardCompleted
    }

    var totalAvailable: Int {
        15  // 5 easy + 5 medium + 5 hard per topic
    }

    var completionPercentage: Double {
        Double(totalCompleted) / Double(totalAvailable)
    }

    var isMastered: Bool {
        easyCompleted == 5 && mediumCompleted == 5 && hardCompleted == 5
    }

    // MARK: - Initialization
    init(
        topicId: String,
        topicName: String,
        easyCompleted: Int = 0,
        mediumCompleted: Int = 0,
        hardCompleted: Int = 0
    ) {
        self.id = topicId
        self.topicName = topicName
        self.easyCompleted = easyCompleted
        self.mediumCompleted = mediumCompleted
        self.hardCompleted = hardCompleted
        self.bestScore = 0
        self.averageScore = 0.0
        self.lastCompletedAt = nil
    }
}

// MARK: - Combined Learning Path State
struct LearningPathState: Identifiable, Codable {
    let id: String  // Usually userId
    let userId: String
    var linearProgress: LinearPathProgress
    var sandboxProgress: SandboxProgress
    var totalXP: Int  // Aggregated from both paths
    var totalGems: Int  // Current gems available (earned from linear, spent in sandbox)
    var currentLevel: Int  // User level based on totalXP (e.g., Level 5)
    var lastUpdatedAt: Date

    // MARK: - Computed Properties
    var gemsAvailable: Int {
        let earned = linearProgress.totalGemsEarned
        let spent = sandboxProgress.totalGemsSpent
        return earned - spent
    }

    var combinedCompletionPercentage: Double {
        let linearPercent = linearProgress.progressPercentage * 0.6  // 60% weight
        let sandboxPercent = sandboxProgress.discoveryPercentage * 0.4  // 40% weight
        return linearPercent + sandboxPercent
    }

    // MARK: - Initialization
    init(
        userId: String,
        linearProgress: LinearPathProgress? = nil,
        sandboxProgress: SandboxProgress? = nil
    ) {
        self.id = userId
        self.userId = userId
        self.linearProgress = linearProgress ?? LinearPathProgress(userId: userId)
        self.sandboxProgress = sandboxProgress ?? SandboxProgress(userId: userId)
        self.totalXP = self.linearProgress.totalXPEarned + (self.sandboxProgress.completedActivities.count * 10)  // Simple calculation
        self.totalGems = self.linearProgress.totalGemsEarned - self.sandboxProgress.totalGemsSpent
        self.currentLevel = max(1, self.totalXP / 250)  // Every 250 XP = 1 level
        self.lastUpdatedAt = Date()
    }
}
