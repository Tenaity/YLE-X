//
//  LeaderboardView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @State private var selectedPeriod: LeaderboardPeriod = .weekly
    @State private var animateList = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Top 3 Podium
                    podiumSection
                        .opacity(animateList ? 1 : 0)
                        .offset(y: animateList ? 0 : 30)

                    // Period Selector
                    periodSelector
                        .padding(.horizontal, AppSpacing.lg)

                    // User's Rank Card
                    userRankCard
                        .padding(.horizontal, AppSpacing.lg)

                    // Leaderboard List
                    leaderboardList
                        .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.vertical, AppSpacing.xl)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color.appAccent.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.appBouncy.delay(0.2)) {
                    animateList = true
                }
            }
        }
    }

    // MARK: - Podium Section
    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.sm) {
            // 2nd Place
            if viewModel.topUsers.indices.contains(1) {
                PodiumCard(user: viewModel.topUsers[1], rank: 2)
                    .offset(y: 30)
            }

            // 1st Place
            if viewModel.topUsers.indices.contains(0) {
                PodiumCard(user: viewModel.topUsers[0], rank: 1)
            }

            // 3rd Place
            if viewModel.topUsers.indices.contains(2) {
                PodiumCard(user: viewModel.topUsers[2], rank: 3)
                    .offset(y: 50)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.appBouncy) {
                        HapticManager.shared.impact(.light)
                        selectedPeriod = period
                    }
                }) {
                    Text(period.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : .appTextSecondary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.full)
                                .fill(selectedPeriod == period ? Color.appAccent : Color(UIColor.tertiarySystemBackground))
                        )
                }
            }
        }
        .padding(AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.full)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    // MARK: - User Rank Card
    private var userRankCard: some View {
        HStack(spacing: AppSpacing.md) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 50, height: 50)

                Text("#\(viewModel.currentUserRank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appPrimary)
            }

            // User Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text("👧")
                    .font(.system(size: 28))
            }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("You")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)

                Text("\(viewModel.currentUserXP) XP")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            // Trend Indicator
            HStack(spacing: 4) {
                Image(systemName: viewModel.userTrend > 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 12, weight: .bold))

                Text("\(abs(viewModel.userTrend))")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(viewModel.userTrend > 0 ? .appSuccess : .appError)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.full)
                    .fill((viewModel.userTrend > 0 ? Color.appSuccess : Color.appError).opacity(0.15))
            )
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 2)
                )
        )
    }

    // MARK: - Leaderboard List
    private var leaderboardList: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(Array(viewModel.otherUsers.enumerated()), id: \.element.id) { index, user in
                LeaderboardRow(user: user, rank: index + 4)
                    .opacity(animateList ? 1 : 0)
                    .offset(x: animateList ? 0 : -50)
                    .animation(.appBouncy.delay(Double(index) * 0.05), value: animateList)
            }
        }
    }
}

// MARK: - Podium Card
struct PodiumCard: View {
    let user: LeaderboardUser
    let rank: Int

    private var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }

    private var podiumColor: Color {
        switch rank {
        case 1: return .appBadgeGold
        case 2: return .appBadgeSilver
        case 3: return .appBadgeBronze
        default: return .appTextSecondary
        }
    }

    private var podiumHeight: CGFloat {
        switch rank {
        case 1: return 120
        case 2: return 90
        case 3: return 70
        default: return 60
        }
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Medal
            Text(medalEmoji)
                .font(.system(size: 28))

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [podiumColor, podiumColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: rank == 1 ? 70 : 60, height: rank == 1 ? 70 : 60)
                    .appShadow(.medium)

                Text(user.avatar)
                    .font(.system(size: rank == 1 ? 36 : 30))
            }

            // Name
            Text(user.name)
                .font(.system(size: rank == 1 ? 14 : 12, weight: .bold))
                .foregroundColor(.appText)
                .lineLimit(1)

            // XP
            Text("\(user.xp) XP")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextSecondary)

            // Podium Base
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .fill(
                    LinearGradient(
                        colors: [podiumColor.opacity(0.3), podiumColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: podiumHeight)
                .overlay(
                    Text("#\(rank)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(podiumColor)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let user: LeaderboardUser
    let rank: Int

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appTextSecondary)
                .frame(width: 40, alignment: .leading)

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 45, height: 45)

                Text(user.avatar)
                    .font(.system(size: 24))
            }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appText)

                Text("\(user.xp) XP")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            // Level Badge
            HStack(spacing: 4) {
                Text(user.level.emoji)
                    .font(.system(size: 14))

                Text("Lv.\(user.level.rawValue)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.full)
                    .fill(Color(UIColor.tertiarySystemBackground))
            )
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Leaderboard Period Enum
enum LeaderboardPeriod: CaseIterable {
    case daily
    case weekly
    case monthly

    var title: String {
        switch self {
        case .daily: return "Today"
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        }
    }
}

// MARK: - Leaderboard User Model
struct LeaderboardUser: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    let xp: Int
    let level: YLELevel
}

// MARK: - Leaderboard ViewModel
@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var topUsers: [LeaderboardUser] = []
    @Published var otherUsers: [LeaderboardUser] = []
    @Published var currentUserRank: Int = 12
    @Published var currentUserXP: Int = 1250
    @Published var userTrend: Int = 3

    init() {
        loadLeaderboardData()
    }

    private func loadLeaderboardData() {
        topUsers = [
            LeaderboardUser(name: "Sarah", avatar: "👧", xp: 2850, level: .starters),
            LeaderboardUser(name: "Mike", avatar: "👦", xp: 2650, level: .starters),
            LeaderboardUser(name: "Emma", avatar: "👩", xp: 2400, level: .movers)
        ]

        otherUsers = [
            LeaderboardUser(name: "James", avatar: "🧒", xp: 2150, level: .starters),
            LeaderboardUser(name: "Lily", avatar: "👧", xp: 1950, level: .movers),
            LeaderboardUser(name: "Tom", avatar: "👦", xp: 1800, level: .flyers),
            LeaderboardUser(name: "Anna", avatar: "👩", xp: 1650, level: .starters),
            LeaderboardUser(name: "Ben", avatar: "🧑", xp: 1500, level: .movers),
            LeaderboardUser(name: "Sophie", avatar: "👧", xp: 1350, level: .starters),
            LeaderboardUser(name: "Jack", avatar: "👦", xp: 1200, level: .flyers)
        ]
    }
}

#Preview {
    LeaderboardView()
}
