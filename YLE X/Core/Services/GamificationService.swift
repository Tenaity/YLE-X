//
//  GamificationService.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class GamificationService: ObservableObject {
    static let shared = GamificationService()

    @Published var userLevel: UserLevel?
    @Published var unlockedBadges: [String: Badge] = [:]
    @Published var availableBadges: [Badge] = []
    @Published var dailyMissions: [Mission] = []
    @Published var weeklyMissions: [Mission] = []
    @Published var virtualPet: VirtualPet?
    @Published var isLoading = false
    @Published var error: Error?

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    private init() {}

    // MARK: - User Level Management
    func initializeUserLevel(userId: String) async throws {
        let userLevelRef = db.collection("userLevels").document(userId)
        let doc = try await userLevelRef.getDocument()

        if doc.exists {
            userLevel = try doc.data(as: UserLevel.self)
        } else {
            let newLevel = UserLevel(
                userId: userId,
                currentLevel: 1,
                totalXP: 0,
                streakDays: 0,
                lastLoginDate: Date(),
                badgesUnlocked: [],
                missionProgress: [:],
                petId: nil
            )
            try userLevelRef.setData(from: newLevel)
            userLevel = newLevel
        }
    }

    func addXP(_ amount: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var level = userLevel else { return }

        level.totalXP += amount
        let oldLevel = level.currentLevel

        // Check level up
        while level.totalXP >= level.nextLevelXP && level.currentLevel < 100 {
            level.currentLevel += 1
        }

        try db.collection("userLevels").document(userId).setData(from: level)
        self.userLevel = level

        // Haptic feedback for level up
        if level.currentLevel > oldLevel {
            HapticManager.shared.playSuccess()
        }
    }

    // MARK: - Badge Management
    func fetchAllBadges() async throws {
        isLoading = true
        defer { isLoading = false }

        let snapshot = try await db.collection("badges").getDocuments()
        availableBadges = try snapshot.documents.compactMap { doc in
            try doc.data(as: Badge.self)
        }

        print("[GamificationService] Fetched \(availableBadges.count) badges")
    }

    func unlockBadge(_ badgeId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var level = userLevel else { return }

        // Check if already unlocked
        guard !level.badgesUnlocked.contains(badgeId) else { return }

        // Add badge to unlocked
        level.badgesUnlocked.append(badgeId)

        // Find badge and get reward
        if let badge = availableBadges.first(where: { $0.id == badgeId }) {
            try await addXP(badge.xpReward)
            unlockedBadges[badgeId] = badge
            HapticManager.shared.playSuccess()
        }

        try await db.collection("userLevels").document(userId).updateData([
            "badgesUnlocked": level.badgesUnlocked
        ])
    }

    // MARK: - Mission Management
    func fetchMissions() async throws {
        isLoading = true
        defer { isLoading = false }

        let snapshot = try await db.collection("missions").getDocuments()
        let allMissions = try snapshot.documents.compactMap { doc in
            try doc.data(as: Mission.self)
        }

        dailyMissions = allMissions.filter { $0.category == "daily" }
        weeklyMissions = allMissions.filter { $0.category == "weekly" || $0.category == "special" || $0.category == "skill" }

        print("[GamificationService] Fetched \(dailyMissions.count) daily missions and \(weeklyMissions.count) weekly missions")
    }

    func updateMissionProgress(missionId: String, amount: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              var level = userLevel else { return }

        // Initialize if not exists
        if level.missionProgress[missionId] == nil {
            if let mission = (dailyMissions + weeklyMissions).first(where: { $0.id == missionId }) {
                level.missionProgress[missionId] = MissionProgress(
                    missionId: missionId,
                    completed: 0,
                    total: 0,
                    isCompleted: false
                )
            }
        }

        // Update progress
        if var progress = level.missionProgress[missionId] {
            progress.completed = min(progress.completed + amount, progress.total)

            // Check completion
            if progress.completed >= progress.total && !progress.isCompleted {
                progress.isCompleted = true
                progress.claimedAt = Date()

                // Award XP
                if let mission = (dailyMissions + weeklyMissions).first(where: { $0.id == missionId }) {
                    try await addXP(mission.reward.xp)
                }

                HapticManager.shared.playSuccess()
            }

            level.missionProgress[missionId] = progress
        }

        try db.collection("userLevels").document(userId).setData(from: level)
        self.userLevel = level
    }

    // MARK: - Virtual Pet Management
    func adoptPet(type: VirtualPet.PetType, name: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let pet = VirtualPet(
            userId: userId,
            type: type,
            name: name,
            level: 1,
            happiness: 75,
            health: 100,
            experience: 0,
            adoptedAt: Date(),
            lastFedAt: Date(),
            lastPlayedAt: Date()
        )

        try db.collection("virtualPets").document(userId).setData(from: pet)
        self.virtualPet = pet

        HapticManager.shared.playSuccess()
    }

    func fetchVirtualPet() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let doc = try await db.collection("virtualPets").document(userId).getDocument()
        if doc.exists {
            virtualPet = try doc.data(as: VirtualPet.self)
        }
    }

    func feedPet() async throws {
        guard var pet = virtualPet,
              let userId = Auth.auth().currentUser?.uid else { return }

        pet.health = min(pet.health + 20, 100)
        pet.happiness = min(pet.happiness + 10, 100)
        pet.lastFedAt = Date()

        try db.collection("virtualPets").document(userId).setData(from: pet)
        self.virtualPet = pet

        HapticManager.shared.playLight()
    }

    func playWithPet() async throws {
        guard var pet = virtualPet,
              let userId = Auth.auth().currentUser?.uid else { return }

        pet.happiness = min(pet.happiness + 25, 100)
        pet.health = max(pet.health - 5, 0)
        pet.experience += 10
        pet.lastPlayedAt = Date()

        try db.collection("virtualPets").document(userId).setData(from: pet)
        self.virtualPet = pet

        HapticManager.shared.playMedium()
    }

    // MARK: - Cleanup
    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    deinit {
        // Remove listeners on cleanup
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
