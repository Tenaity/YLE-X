//
//  LeaderboardService.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 3: Leaderboard System
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()

    @Published var weeklyLeaderboard: [LeaderboardEntry] = []
    @Published var allTimeLeaderboard: [LeaderboardEntry] = []
    @Published var friendsLeaderboard: [LeaderboardEntry] = []
    @Published var currentUserRank: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    init() {}

    // MARK: - Fetch Leaderboards

    func fetchWeeklyLeaderboard() async throws {
        isLoading = true
        errorMessage = nil

        do {
            // Get top 100 users by weekly XP
            let snapshot = try await db.collection("userLevels")
                .order(by: "weeklyXP", descending: true)
                .limit(to: 100)
                .getDocuments()

            var entries: [LeaderboardEntry] = []
            let currentUserId = Auth.auth().currentUser?.uid

            for (index, document) in snapshot.documents.enumerated() {
                let data = document.data()
                let userId = document.documentID
                let username = data["username"] as? String ?? "User"
                let avatar = data["avatar"] as? String ?? "👤"
                let weeklyXP = data["weeklyXP"] as? Int ?? 0
                let level = data["currentLevel"] as? Int ?? 1
                let streakDays = data["streakDays"] as? Int ?? 0
                let badgeCount = (data["badgesUnlocked"] as? [String])?.count ?? 0

                let entry = LeaderboardEntry(
                    id: userId,
                    username: username,
                    avatar: avatar,
                    rank: index + 1,
                    xp: weeklyXP,
                    level: level,
                    streakDays: streakDays,
                    badgeCount: badgeCount,
                    isCurrentUser: userId == currentUserId
                )

                entries.append(entry)

                if userId == currentUserId {
                    currentUserRank = index + 1
                }
            }

            weeklyLeaderboard = entries
            isLoading = false
        } catch {
            errorMessage = "Failed to load weekly leaderboard: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    func fetchAllTimeLeaderboard() async throws {
        isLoading = true
        errorMessage = nil

        do {
            // Get top 100 users by total XP
            let snapshot = try await db.collection("userLevels")
                .order(by: "totalXP", descending: true)
                .limit(to: 100)
                .getDocuments()

            var entries: [LeaderboardEntry] = []
            let currentUserId = Auth.auth().currentUser?.uid

            for (index, document) in snapshot.documents.enumerated() {
                let data = document.data()
                let userId = document.documentID
                let username = data["username"] as? String ?? "User"
                let avatar = data["avatar"] as? String ?? "👤"
                let totalXP = data["totalXP"] as? Int ?? 0
                let level = data["currentLevel"] as? Int ?? 1
                let streakDays = data["streakDays"] as? Int ?? 0
                let badgeCount = (data["badgesUnlocked"] as? [String])?.count ?? 0

                let entry = LeaderboardEntry(
                    id: userId,
                    username: username,
                    avatar: avatar,
                    rank: index + 1,
                    xp: totalXP,
                    level: level,
                    streakDays: streakDays,
                    badgeCount: badgeCount,
                    isCurrentUser: userId == currentUserId
                )

                entries.append(entry)

                if userId == currentUserId {
                    currentUserRank = index + 1
                }
            }

            allTimeLeaderboard = entries
            isLoading = false
        } catch {
            errorMessage = "Failed to load all-time leaderboard: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    func fetchFriendsLeaderboard() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "LeaderboardService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        isLoading = true
        errorMessage = nil

        do {
            // Get friend IDs
            let friendsSnapshot = try await db.collection("friendships")
                .document(currentUserId)
                .collection("friends")
                .getDocuments()

            let friendIds = friendsSnapshot.documents.map { $0.documentID }

            guard !friendIds.isEmpty else {
                friendsLeaderboard = []
                isLoading = false
                return
            }

            // Fetch user levels for friends
            var entries: [LeaderboardEntry] = []

            for friendId in friendIds {
                let doc = try await db.collection("userLevels").document(friendId).getDocument()

                if let data = doc.data() {
                    let username = data["username"] as? String ?? "Friend"
                    let avatar = data["avatar"] as? String ?? "👤"
                    let totalXP = data["totalXP"] as? Int ?? 0
                    let level = data["currentLevel"] as? Int ?? 1
                    let streakDays = data["streakDays"] as? Int ?? 0
                    let badgeCount = (data["badgesUnlocked"] as? [String])?.count ?? 0

                    let entry = LeaderboardEntry(
                        id: friendId,
                        username: username,
                        avatar: avatar,
                        rank: 0, // Will be set after sorting
                        xp: totalXP,
                        level: level,
                        streakDays: streakDays,
                        badgeCount: badgeCount,
                        isCurrentUser: friendId == currentUserId
                    )

                    entries.append(entry)
                }
            }

            // Add current user
            let currentUserDoc = try await db.collection("userLevels").document(currentUserId).getDocument()
            if let data = currentUserDoc.data() {
                let username = data["username"] as? String ?? "You"
                let avatar = data["avatar"] as? String ?? "👤"
                let totalXP = data["totalXP"] as? Int ?? 0
                let level = data["currentLevel"] as? Int ?? 1
                let streakDays = data["streakDays"] as? Int ?? 0
                let badgeCount = (data["badgesUnlocked"] as? [String])?.count ?? 0

                let entry = LeaderboardEntry(
                    id: currentUserId,
                    username: username,
                    avatar: avatar,
                    rank: 0,
                    xp: totalXP,
                    level: level,
                    streakDays: streakDays,
                    badgeCount: badgeCount,
                    isCurrentUser: true
                )

                entries.append(entry)
            }

            // Sort by XP and assign ranks
            entries.sort { $0.xp > $1.xp }
            for (index, _) in entries.enumerated() {
                entries[index] = LeaderboardEntry(
                    id: entries[index].id,
                    username: entries[index].username,
                    avatar: entries[index].avatar,
                    rank: index + 1,
                    xp: entries[index].xp,
                    level: entries[index].level,
                    streakDays: entries[index].streakDays,
                    badgeCount: entries[index].badgeCount,
                    isCurrentUser: entries[index].isCurrentUser
                )

                if entries[index].isCurrentUser {
                    currentUserRank = index + 1
                }
            }

            friendsLeaderboard = entries
            isLoading = false
        } catch {
            errorMessage = "Failed to load friends leaderboard: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    // MARK: - User Rank Lookup

    func fetchUserRank(userId: String, type: LeaderboardType) async throws -> Int? {
        do {
            let fieldName = type == .weekly ? "weeklyXP" : "totalXP"

            // Get user's XP
            let userDoc = try await db.collection("userLevels").document(userId).getDocument()
            guard let userXP = userDoc.data()?[fieldName] as? Int else {
                return nil
            }

            // Count users with higher XP
            let snapshot = try await db.collection("userLevels")
                .whereField(fieldName, isGreaterThan: userXP)
                .getDocuments()

            return snapshot.documents.count + 1
        } catch {
            print("Error fetching user rank: \(error)")
            return nil
        }
    }

    // MARK: - Real-time Updates

    func startListening(type: LeaderboardType) {
        stopListening()

        let fieldName: String
        switch type {
        case .weekly:
            fieldName = "weeklyXP"
        case .allTime:
            fieldName = "totalXP"
        case .friends:
            // Friends leaderboard requires special handling
            Task {
                try? await fetchFriendsLeaderboard()
            }
            return
        }

        let listener = db.collection("userLevels")
            .order(by: fieldName, descending: true)
            .limit(to: 100)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let snapshot = snapshot else { return }

                Task { @MainActor in
                    var entries: [LeaderboardEntry] = []
                    let currentUserId = Auth.auth().currentUser?.uid

                    for (index, document) in snapshot.documents.enumerated() {
                        let data = document.data()
                        let userId = document.documentID
                        let username = data["username"] as? String ?? "User"
                        let avatar = data["avatar"] as? String ?? "👤"
                        let xp = data[fieldName] as? Int ?? 0
                        let level = data["currentLevel"] as? Int ?? 1
                        let streakDays = data["streakDays"] as? Int ?? 0
                        let badgeCount = (data["badgesUnlocked"] as? [String])?.count ?? 0

                        let entry = LeaderboardEntry(
                            id: userId,
                            username: username,
                            avatar: avatar,
                            rank: index + 1,
                            xp: xp,
                            level: level,
                            streakDays: streakDays,
                            badgeCount: badgeCount,
                            isCurrentUser: userId == currentUserId
                        )

                        entries.append(entry)

                        if userId == currentUserId {
                            self.currentUserRank = index + 1
                        }
                    }

                    if type == .weekly {
                        self.weeklyLeaderboard = entries
                    } else {
                        self.allTimeLeaderboard = entries
                    }
                }
            }

        listeners.append(listener)
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    // MARK: - Weekly Reset (Cloud Function would handle this)

    func resetWeeklyXP() async throws {
        // This would typically be called by a Cloud Function on schedule
        // For testing purposes, we can manually reset

        let batch = db.batch()
        let snapshot = try await db.collection("userLevels").getDocuments()

        for document in snapshot.documents {
            let ref = db.collection("userLevels").document(document.documentID)
            batch.updateData(["weeklyXP": 0], forDocument: ref)
        }

        try await batch.commit()
    }

    deinit {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
