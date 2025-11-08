//
//  Social.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 3: Leaderboard & Social Features
//

import Foundation
import SwiftUI

// MARK: - Leaderboard Models

struct LeaderboardEntry: Identifiable, Codable {
    let id: String // userId
    let username: String
    let avatar: String // emoji
    let rank: Int
    let xp: Int // weekly or total depending on leaderboard type
    let level: Int
    let streakDays: Int
    let badgeCount: Int
    var isCurrentUser: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatar
        case rank
        case xp
        case level
        case streakDays
        case badgeCount
        case isCurrentUser
    }

    init(id: String, username: String, avatar: String, rank: Int, xp: Int, level: Int, streakDays: Int, badgeCount: Int, isCurrentUser: Bool = false) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.rank = rank
        self.xp = xp
        self.level = level
        self.streakDays = streakDays
        self.badgeCount = badgeCount
        self.isCurrentUser = isCurrentUser
    }

    // Sample data for previews and testing
    static func sample(rank: Int = 1, isCurrentUser: Bool = false) -> LeaderboardEntry {
        LeaderboardEntry(
            id: UUID().uuidString,
            username: "User\(rank)",
            avatar: ["👤", "🧑", "👨", "👩", "🧒"].randomElement() ?? "👤",
            rank: rank,
            xp: max(1000 - (rank * 10), 100),
            level: max(50 - rank, 1),
            streakDays: Int.random(in: 0...100),
            badgeCount: Int.random(in: 0...9),
            isCurrentUser: isCurrentUser
        )
    }

    static func sampleLeaderboard(count: Int = 100) -> [LeaderboardEntry] {
        (1...count).map { rank in
            sample(rank: rank, isCurrentUser: rank == 42)
        }
    }
}

enum LeaderboardType: String, CaseIterable {
    case weekly = "Weekly"
    case allTime = "All Time"
    case friends = "Friends"

    var icon: String {
        switch self {
        case .weekly: return "calendar"
        case .allTime: return "star.fill"
        case .friends: return "person.2.fill"
        }
    }

    var description: String {
        switch self {
        case .weekly: return "Top performers this week"
        case .allTime: return "Lifetime achievements"
        case .friends: return "Compete with friends"
        }
    }
}

// MARK: - Friend Models

struct Friend: Identifiable, Codable {
    let id: String // userId
    let username: String
    let avatar: String // emoji
    let level: Int
    let status: FriendStatus
    let lastActive: Date
    let streakDays: Int
    let friendSince: Date

    static func sample() -> Friend {
        Friend(
            id: UUID().uuidString,
            username: "Friend\(Int.random(in: 1...100))",
            avatar: ["👤", "🧑", "👨", "👩", "🧒"].randomElement() ?? "👤",
            level: Int.random(in: 1...50),
            status: FriendStatus.allCases.randomElement() ?? .offline,
            lastActive: Date().addingTimeInterval(-Double.random(in: 0...86400)),
            streakDays: Int.random(in: 0...100),
            friendSince: Date().addingTimeInterval(-Double.random(in: 0...86400*365))
        )
    }
}

enum FriendStatus: String, Codable, CaseIterable {
    case online
    case offline
    case away

    var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .gray
        case .away: return .orange
        }
    }

    var icon: String {
        switch self {
        case .online: return "circle.fill"
        case .offline: return "circle"
        case .away: return "moon.fill"
        }
    }
}

struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let fromUsername: String
    let fromAvatar: String
    let status: RequestStatus
    let createdAt: Date

    static func sample() -> FriendRequest {
        FriendRequest(
            id: UUID().uuidString,
            fromUserId: UUID().uuidString,
            toUserId: UUID().uuidString,
            fromUsername: "User\(Int.random(in: 1...100))",
            fromAvatar: ["👤", "🧑", "👨", "👩", "🧒"].randomElement() ?? "👤",
            status: .pending,
            createdAt: Date()
        )
    }
}

enum RequestStatus: String, Codable {
    case pending
    case accepted
    case declined

    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .declined: return .red
        }
    }
}

// MARK: - Challenge Models

struct Challenge: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let type: ChallengeType
    let goal: Int // target value
    let duration: TimeInterval
    let startDate: Date
    let endDate: Date
    let status: ChallengeStatus
    var fromProgress: Int
    var toProgress: Int
    var winnerId: String?

    var timeRemaining: TimeInterval {
        endDate.timeIntervalSince(Date())
    }

    var isActive: Bool {
        status == .active && timeRemaining > 0
    }

    static func sample() -> Challenge {
        let startDate = Date()
        let duration: TimeInterval = 86400 * 7 // 7 days

        return Challenge(
            id: UUID().uuidString,
            fromUserId: UUID().uuidString,
            toUserId: UUID().uuidString,
            type: .lessons,
            goal: 10,
            duration: duration,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(duration),
            status: .active,
            fromProgress: Int.random(in: 0...5),
            toProgress: Int.random(in: 0...5),
            winnerId: nil
        )
    }
}

enum ChallengeType: String, Codable, CaseIterable {
    case lessons
    case xp
    case streak
    case badges

    var icon: String {
        switch self {
        case .lessons: return "book.fill"
        case .xp: return "star.fill"
        case .streak: return "flame.fill"
        case .badges: return "rosette"
        }
    }

    var displayName: String {
        switch self {
        case .lessons: return "Most Lessons"
        case .xp: return "Highest XP"
        case .streak: return "Longest Streak"
        case .badges: return "Most Badges"
        }
    }

    var color: Color {
        switch self {
        case .lessons: return .blue
        case .xp: return .yellow
        case .streak: return .orange
        case .badges: return .purple
        }
    }
}

enum ChallengeStatus: String, Codable {
    case pending
    case active
    case completed
    case cancelled

    var color: Color {
        switch self {
        case .pending: return .orange
        case .active: return .green
        case .completed: return .blue
        case .cancelled: return .gray
        }
    }
}

// MARK: - Activity Feed Models

struct ActivityFeedItem: Identifiable, Codable {
    let id: String
    let userId: String
    let username: String
    let avatar: String
    let type: ActivityType
    let description: String
    let timestamp: Date
    let metadata: [String: String]?

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }

    static func sample() -> ActivityFeedItem {
        ActivityFeedItem(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            username: "User\(Int.random(in: 1...100))",
            avatar: ["👤", "🧑", "👨", "👩", "🧒"].randomElement() ?? "👤",
            type: ActivityType.allCases.randomElement() ?? .levelUp,
            description: "Reached Level 10!",
            timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
            metadata: nil
        )
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case levelUp
    case badgeUnlocked
    case streakMilestone
    case challengeWon
    case missionCompleted

    var icon: String {
        switch self {
        case .levelUp: return "arrow.up.circle.fill"
        case .badgeUnlocked: return "star.circle.fill"
        case .streakMilestone: return "flame.fill"
        case .challengeWon: return "trophy.fill"
        case .missionCompleted: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .levelUp: return .blue
        case .badgeUnlocked: return .yellow
        case .streakMilestone: return .orange
        case .challengeWon: return .purple
        case .missionCompleted: return .green
        }
    }
}
