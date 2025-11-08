//
//  LeaderboardView.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 3: Leaderboard System
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var leaderboardService = LeaderboardService.shared
    @State private var selectedTab: LeaderboardType = .weekly
    @State private var animateContent = false
    @State private var showCurrentUserBanner = false

    var currentLeaderboard: [LeaderboardEntry] {
        switch selectedTab {
        case .weekly:
            return leaderboardService.weeklyLeaderboard
        case .allTime:
            return leaderboardService.allTimeLeaderboard
        case .friends:
            return leaderboardService.friendsLeaderboard
        }
    }

    var topThree: [LeaderboardEntry] {
        Array(currentLeaderboard.prefix(3))
    }

    var remainingEntries: [LeaderboardEntry] {
        guard currentLeaderboard.count > 3 else { return [] }
        return Array(currentLeaderboard.dropFirst(3))
    }

    var currentUserEntry: LeaderboardEntry? {
        currentLeaderboard.first { $0.isCurrentUser }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Tab Selector
                        tabSelector

                        // Top 3 Podium
                        if !topThree.isEmpty {
                            LeaderboardPodium(topThree: topThree)
                                .padding(.top, AppSpacing.md)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.appBouncy.delay(0.2), value: animateContent)
                        }

                        // Current User Banner (if not in top 3)
                        if let userEntry = currentUserEntry, userEntry.rank > 3 {
                            currentUserBanner(userEntry)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.appBouncy.delay(0.3), value: animateContent)
                        }

                        // Remaining Ranks (4-100)
                        if !remainingEntries.isEmpty {
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(Array(remainingEntries.enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardRow(entry: entry)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(.appBouncy.delay(0.4 + Double(index) * 0.02), value: animateContent)
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                        }

                        // Empty State
                        if currentLeaderboard.isEmpty && !leaderboardService.isLoading {
                            emptyState
                        }
                    }
                    .padding(.bottom, AppSpacing.xl3)
                }
                .refreshable {
                    await refreshLeaderboard()
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground.ignoresSafeArea())
            .task {
                await loadLeaderboard()
            }
            .overlay {
                if leaderboardService.isLoading {
                    loadingOverlay
                }
            }
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(LeaderboardType.allCases, id: \.self) { type in
                Button {
                    selectTab(type)
                } label: {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: type.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(type.rawValue)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        selectedTab == type ?
                        Color.appPrimary.opacity(0.15) :
                        Color.appBackgroundSecondary
                    )
                    .foregroundColor(
                        selectedTab == type ?
                        .appPrimary :
                        .appTextSecondary
                    )
                    .cornerRadius(AppRadius.md)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Current User Banner

    private func currentUserBanner(_ entry: LeaderboardEntry) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Your Rank")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .textCase(.uppercase)

            HStack(spacing: AppSpacing.md) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(Color.appBadgeGold.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Text("#\(entry.rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appBadgeGold)
                }

                // User info
                HStack(spacing: AppSpacing.sm) {
                    Text(entry.avatar)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appText)
                        Text("Level \(entry.level)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    // XP
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(entry.xp.formatted()) XP")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appAccent)
                        Text("🔥 \(entry.streakDays) days")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBadgeGold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(Color.appBadgeGold.opacity(0.3), lineWidth: 2)
                )
        )
        .padding(.horizontal, AppSpacing.md)
        .appShadow(level: .medium)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary.opacity(0.3))

            Text("No Rankings Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appText)

            Text(selectedTab == .friends ?
                 "Add friends to compete!" :
                 "Complete lessons to join the leaderboard"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.appTextSecondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.appPrimary)

                Text("Loading leaderboard...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color.appBackgroundSecondary)
                    .appShadow(level: .heavy)
            )
        }
    }

    // MARK: - Functions

    private func selectTab(_ type: LeaderboardType) {
        guard selectedTab != type else { return }

        HapticManager.shared.playLight()
        selectedTab = type
        animateContent = false

        Task {
            await loadLeaderboard()
        }
    }

    private func loadLeaderboard() async {
        do {
            switch selectedTab {
            case .weekly:
                try await leaderboardService.fetchWeeklyLeaderboard()
            case .allTime:
                try await leaderboardService.fetchAllTimeLeaderboard()
            case .friends:
                try await leaderboardService.fetchFriendsLeaderboard()
            }

            withAnimation(.appBouncy) {
                animateContent = true
            }
        } catch {
            print("Error loading leaderboard: \(error)")
        }
    }

    private func refreshLeaderboard() async {
        HapticManager.shared.playLight()
        await loadLeaderboard()
    }
}

// MARK: - Preview

#Preview {
    LeaderboardView()
}
