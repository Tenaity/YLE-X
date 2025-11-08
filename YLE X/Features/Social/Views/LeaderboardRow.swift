//
//  LeaderboardRow.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 3: Leaderboard Row Component
//

import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    private var rankColor: Color {
        switch entry.rank {
        case 1...3:
            return .appBadgeGold
        case 4...10:
            return .appAccent
        default:
            return .appTextSecondary
        }
    }

    private var backgroundColor: Color {
        entry.isCurrentUser ?
        Color.appPrimary.opacity(0.08) :
        Color.appBackgroundSecondary
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Rank Badge
            rankBadge

            // Avatar
            Text(entry.avatar)
                .font(.system(size: 36))

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppSpacing.xs) {
                    Text(entry.username)
                        .font(.system(size: 16, weight: entry.isCurrentUser ? .bold : .semibold))
                        .foregroundColor(.appText)

                    if entry.isCurrentUser {
                        Text("(You)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appPrimary)
                    }
                }

                HStack(spacing: AppSpacing.sm) {
                    // Level
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.appBadgeGold)
                        Text("Lv \(entry.level)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }

                    // Streak
                    if entry.streakDays > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 10))
                            Text("\(entry.streakDays)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }

                    // Badges
                    if entry.badgeCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "rosette")
                                .font(.system(size: 10))
                                .foregroundColor(.appPrimary)
                            Text("\(entry.badgeCount)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
            }

            Spacer()

            // XP Display
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.xp.formatted())")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appAccent)
                Text("XP")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                    .textCase(.uppercase)
            }
        }
        .padding(AppSpacing.md)
        .background(backgroundColor)
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(
                    entry.isCurrentUser ?
                    Color.appPrimary.opacity(0.3) :
                    Color.clear,
                    lineWidth: 2
                )
        )
        .appShadow(level: entry.isCurrentUser ? .medium : .subtle)
    }

    // MARK: - Rank Badge

    private var rankBadge: some View {
        ZStack {
            Circle()
                .fill(rankColor.opacity(0.15))
                .frame(width: 44, height: 44)

            Text("#\(entry.rank)")
                .font(.system(size: entry.rank < 10 ? 16 : 14, weight: .bold))
                .foregroundColor(rankColor)
        }
    }
}

// MARK: - Preview

#Preview("Regular Entry") {
    VStack {
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 5))
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 42, isCurrentUser: true))
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 99))
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Top 3") {
    VStack {
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 1))
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 2))
        LeaderboardRow(entry: LeaderboardEntry.sample(rank: 3))
    }
    .padding()
    .background(Color.appBackground)
}
