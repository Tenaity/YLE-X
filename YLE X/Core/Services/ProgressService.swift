//
//  ProgressService.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class ProgressService: ObservableObject {
    static let shared = ProgressService()

    @Published var learningPathState: LearningPathState?
    @Published var linearProgress: LinearPathProgress?
    @Published var sandboxProgress: SandboxProgress?
    @Published var isLoading = false
    @Published var error: Error?

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    private init() {}

    // MARK: - Fetch Learning Path State
    func fetchLearningPathState() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Try to fetch existing state
            let doc = try await db.collection("userProgress")
                .document(userId)
                .collection("pathProgress")
                .document("learningPathState")
                .getDocument()

            if doc.exists {
                let state = try doc.data(as: LearningPathState.self)
                self.learningPathState = state
                self.linearProgress = state.linearProgress
                self.sandboxProgress = state.sandboxProgress
            } else {
                // Create new state if doesn't exist
                let state = LearningPathState(userId: userId)
                try await saveLearningPathState(state)
                self.learningPathState = state
                self.linearProgress = state.linearProgress
                self.sandboxProgress = state.sandboxProgress
            }
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Save Learning Path State
    func saveLearningPathState(_ state: LearningPathState) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        var updatingState = state
        updatingState.lastUpdatedAt = Date()

        try db.collection("userProgress")
            .document(userId)
            .collection("pathProgress")
            .document("learningPathState")
            .setData(from: updatingState, merge: true)

        self.learningPathState = updatingState
        self.linearProgress = updatingState.linearProgress
        self.sandboxProgress = updatingState.sandboxProgress

        // Also update user's totalXP and gems in main users collection
        try await updateUserGamificationStats(userId: userId, state: updatingState)
    }

    // MARK: - Linear Path Methods

    /// Complete a round in the linear path
    func completeLinearRound(
        roundId: String,
        xpEarned: Int,
        gemsEarned: Int
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var linear = state.linearProgress

        // Add round to completed list
        if !linear.roundsCompleted.contains(roundId) {
            linear.roundsCompleted.append(roundId)
        }

        // Update rewards
        linear.totalXPEarned += xpEarned
        linear.totalGemsEarned += gemsEarned
        linear.lastUpdatedAt = Date()

        // Check if phase should be completed
        if linear.roundsCompleted.count % 20 == 0 {
            linear.currentRound = 1
            // Don't auto-advance phase - user must defeat boss
        } else {
            linear.currentRound += 1
        }

        // Update state and save
        var updatedState = state
        updatedState.linearProgress = linear
        updatedState.totalXP += xpEarned
        updatedState.totalGems = linear.totalGemsEarned - state.sandboxProgress.totalGemsSpent

        try await saveLearningPathState(updatedState)
    }

    /// Complete a boss battle
    func defeatBoss(
        bossId: String,
        xpEarned: Int,
        gemsEarned: Int
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var linear = state.linearProgress

        // Add boss to defeated list
        if !linear.bossesDefeated.contains(bossId) {
            linear.bossesDefeated.append(bossId)
        }

        // Update rewards
        linear.totalXPEarned += xpEarned
        linear.totalGemsEarned += gemsEarned
        linear.lastUpdatedAt = Date()

        // Advance to next phase if available
        if linear.currentPhase != .flyers {
            if let nextPhase = linear.nextPhase {
                linear.currentPhase = nextPhase
                linear.currentRound = 1
                linear.roundsCompleted = []  // Reset for new phase
            }
        }

        // Update state and save
        var updatedState = state
        updatedState.linearProgress = linear
        updatedState.totalXP += xpEarned
        updatedState.totalGems = linear.totalGemsEarned - state.sandboxProgress.totalGemsSpent

        try await saveLearningPathState(updatedState)
    }

    // MARK: - Sandbox Path Methods

    /// Unlock an island (category)
    func unlockIsland(
        islandId: String,
        gemsCost: Int = 0
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var sandbox = state.sandboxProgress

        // Check if user has enough gems
        let availableGems = state.linearProgress.totalGemsEarned - sandbox.totalGemsSpent
        guard availableGems >= gemsCost else {
            throw NSError(domain: "ProgressService", code: 402, userInfo: [NSLocalizedDescriptionKey: "Not enough gems"])
        }

        // Unlock island
        if !sandbox.unlockedIslands.contains(islandId) {
            sandbox.unlockedIslands.append(islandId)
        }

        if gemsCost > 0 {
            sandbox.totalGemsSpent += gemsCost
        }

        sandbox.lastUpdatedAt = Date()

        // Update state and save
        var updatedState = state
        updatedState.sandboxProgress = sandbox

        try await saveLearningPathState(updatedState)
    }

    /// Unlock a topic/skill within an island
    func unlockTopic(
        topicId: String,
        topicName: String,
        gemsCost: Int = 0
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var sandbox = state.sandboxProgress

        // Check gems
        let availableGems = state.linearProgress.totalGemsEarned - sandbox.totalGemsSpent
        guard availableGems >= gemsCost else {
            throw NSError(domain: "ProgressService", code: 402, userInfo: [NSLocalizedDescriptionKey: "Not enough gems"])
        }

        // Unlock topic
        if !sandbox.unlockedTopics.contains(topicId) {
            sandbox.unlockedTopics.append(topicId)
        }

        // Initialize topic progress if not exists
        if sandbox.topicProgress[topicId] == nil {
            sandbox.topicProgress[topicId] = TopicProgress(topicId: topicId, topicName: topicName)
        }

        if gemsCost > 0 {
            sandbox.totalGemsSpent += gemsCost
        }

        sandbox.lastUpdatedAt = Date()

        // Update state and save
        var updatedState = state
        updatedState.sandboxProgress = sandbox

        try await saveLearningPathState(updatedState)
    }

    /// Complete an activity in sandbox
    func completeActivity(
        activityId: String,
        score: Int,
        xpEarned: Int
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var sandbox = state.sandboxProgress

        // Add to completed activities
        if !sandbox.completedActivities.contains(activityId) {
            sandbox.completedActivities.append(activityId)
            sandbox.totalActivitiesCompleted += 1
        }

        // Record score
        sandbox.activityScores[activityId] = score

        sandbox.lastUpdatedAt = Date()

        // Update state
        var updatedState = state
        updatedState.sandboxProgress = sandbox
        updatedState.totalXP += xpEarned

        try await saveLearningPathState(updatedState)
    }

    /// Update topic progress
    func updateTopicProgress(
        topicId: String,
        difficulty: String,  // "easy", "medium", "hard"
        completed: Bool
    ) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var state = learningPathState else {
            throw NSError(domain: "ProgressService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])
        }

        var sandbox = state.sandboxProgress

        guard var topicProg = sandbox.topicProgress[topicId] else {
            throw NSError(domain: "ProgressService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Topic not found"])
        }

        if completed {
            switch difficulty.lowercased() {
            case "easy":
                if topicProg.easyCompleted < 5 {
                    topicProg.easyCompleted += 1
                }
            case "medium":
                if topicProg.mediumCompleted < 5 {
                    topicProg.mediumCompleted += 1
                }
            case "hard":
                if topicProg.hardCompleted < 5 {
                    topicProg.hardCompleted += 1
                }
            default:
                break
            }
        }

        topicProg.lastCompletedAt = Date()
        sandbox.topicProgress[topicId] = topicProg
        sandbox.lastUpdatedAt = Date()

        // Update state and save
        var updatedState = state
        updatedState.sandboxProgress = sandbox

        try await saveLearningPathState(updatedState)
    }

    // MARK: - Real-time Listener
    func startListeningToProgress() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let listener = db.collection("userProgress")
            .document(userId)
            .collection("pathProgress")
            .document("learningPathState")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else { return }

                Task { @MainActor in
                    do {
                        let state = try snapshot.data(as: LearningPathState.self)
                        self.learningPathState = state
                        self.linearProgress = state.linearProgress
                        self.sandboxProgress = state.sandboxProgress
                    } catch {
                        self.error = error
                    }
                }
            }

        listeners.append(listener)
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    // MARK: - Helper Methods
    private func updateUserGamificationStats(userId: String, state: LearningPathState) async throws {
        try await db.collection("users")
            .document(userId)
            .setData([
                "totalXP": state.totalXP,
                "gems": state.gemsAvailable,
                "level": state.currentLevel,
                "lastUpdated": FieldValue.serverTimestamp()
            ], merge: true)
    }

    /// Get progress summary for dashboard
    func getProgressSummary() -> (linearPercent: Double, sandboxPercent: Double, totalXP: Int, gems: Int) {
        guard let state = learningPathState else {
            return (0, 0, 0, 0)
        }

        return (
            linearPercent: state.linearProgress.progressPercentage * 100,
            sandboxPercent: state.sandboxProgress.discoveryPercentage * 100,
            totalXP: state.totalXP,
            gems: state.gemsAvailable
        )
    }

    /// Check if user has enough gems to unlock something
    func hasEnoughGems(_ amount: Int) -> Bool {
        guard let state = learningPathState else { return false }
        return state.gemsAvailable >= amount
    }
}
