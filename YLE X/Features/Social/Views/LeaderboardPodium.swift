//
//  LeaderboardPodium.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 3: Leaderboard Podium Component
//

import SwiftUI

struct LeaderboardPodium: View {
    let topThree: [LeaderboardEntry]

    private var first: LeaderboardEntry? {
        topThree.first { $0.rank == 1 }
    }

    private var second: LeaderboardEntry? {
        topThree.first { $0.rank == 2 }
    }

    private var third: LeaderboardEntry? {
        topThree.first { $0.rank == 3 }
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Title
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appBadgeGold)
                Text("Top 3")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)
            }

            // Podium Display
            HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                // 2nd Place
                if let second = second {
                    podiumCard(entry: second, height: 140, medal: "🥈")
                } else {
                    emptyPodium(rank: 2, height: 140)
                }

                // 1st Place (Tallest)
                if let first = first {
                    podiumCard(entry: first, height: 180, medal: "🥇")
                } else {
                    emptyPodium(rank: 1, height: 180)
                }

                // 3rd Place
                if let third = third {
                    podiumCard(entry: third, height: 120, medal: "🥉")
                } else {
                    emptyPodium(rank: 3, height: 120)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color.appBackgroundSecondary)
                .appShadow(level: .medium)
        )
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Podium Card

    private func podiumCard(entry: LeaderboardEntry, height: CGFloat, medal: String) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Medal
            Text(medal)
                .font(.system(size: 40))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: rankGradient(entry.rank),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .appShadow(level: .medium)

                Text(entry.avatar)
                    .font(.system(size: 40))
            }

            // Username
            Text(entry.username)
                .font(.system(size: entry.rank == 1 ? 16 : 14, weight: .bold))
                .foregroundColor(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Level
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.appBadgeGold)
                Text("Level \(entry.level)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            // XP Display
            VStack(spacing: 2) {
                Text("\(entry.xp.formatted())")
                    .font(.system(size: entry.rank == 1 ? 20 : 16, weight: .bold))
                    .foregroundColor(rankColor(entry.rank))
                Text("XP")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                    .textCase(.uppercase)
            }
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(rankColor(entry.rank).opacity(0.15))
            )

            // Streak & Badges
            HStack(spacing: AppSpacing.xs) {
                if entry.streakDays > 0 {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.system(size: 8))
                        Text("\(entry.streakDays)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                }

                if entry.badgeCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "rosette")
                            .font(.system(size: 8))
                            .foregroundColor(.appPrimary)
                        Text("\(entry.badgeCount)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [
                            rankColor(entry.rank).opacity(0.05),
                            rankColor(entry.rank).opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(rankColor(entry.rank).opacity(0.3), lineWidth: 2)
                )
        )
        .appShadow(level: entry.rank == 1 ? .heavy : .medium)
    }

    // MARK: - Empty Podium

    private func emptyPodium(rank: Int, height: CGFloat) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Text("—")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.appTextSecondary.opacity(0.3))

            Spacer()

            Text("#\(rank)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appTextSecondary.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.appTextSecondary.opacity(0.1), lineWidth: 2)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                )
        )
    }

    // MARK: - Helper Functions

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(hex: "#FFD700") // Gold
        case 2:
            return Color(hex: "#C0C0C0") // Silver
        case 3:
            return Color(hex: "#CD7F32") // Bronze
        default:
            return .appTextSecondary
        }
    }

    private func rankGradient(_ rank: Int) -> [Color] {
        switch rank {
        case 1:
            return [
                Color(hex: "#FFD700"),
                Color(hex: "#FFA500")
            ]
        case 2:
            return [
                Color(hex: "#E8E8E8"),
                Color(hex: "#C0C0C0")
            ]
        case 3:
            return [
                Color(hex: "#E39250"),
                Color(hex: "#CD7F32")
            ]
        default:
            return [.appTextSecondary, .appTextSecondary]
        }
    }
}

// MARK: - Preview

#Preview("Full Podium") {
    LeaderboardPodium(topThree: [
        LeaderboardEntry.sample(rank: 1),
        LeaderboardEntry.sample(rank: 2),
        LeaderboardEntry.sample(rank: 3)
    ])
    .padding()
    .background(Color.appBackground)
}

#Preview("Partial Podium") {
    LeaderboardPodium(topThree: [
        LeaderboardEntry.sample(rank: 1),
        LeaderboardEntry.sample(rank: 2)
    ])
    .padding()
    .background(Color.appBackground)
}

#Preview("Empty Podium") {
    LeaderboardPodium(topThree: [])
        .padding()
        .background(Color.appBackground)
}
