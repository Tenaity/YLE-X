//
//  MissionsView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct MissionsView: View {
    @StateObject private var gamificationService = GamificationService.shared
    @State private var selectedTab: MissionTab = .daily
    @State private var animateMissions = false

    enum MissionTab: Hashable {
        case daily
        case weekly
        case skill
    }

    var selectedMissions: [Mission] {
        switch selectedTab {
        case .daily:
            return gamificationService.dailyMissions
        case .weekly:
            return gamificationService.weeklyMissions
        case .skill:
            return (gamificationService.dailyMissions + gamificationService.weeklyMissions)
                .filter { $0.category == "skill" }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appPrimary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Mission Stats
                        missionStatsCard
                            .opacity(animateMissions ? 1 : 0)
                            .offset(y: animateMissions ? 0 : 20)

                        // Tab Selector
                        tabSelector

                        // Missions List
                        missionsSection
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }
            }
            .navigationTitle("Missions")
            .navigationBarTitleDisplayMode(.large)
            .task {
                do {
                    try await gamificationService.fetchMissions()
                    withAnimation(.appBouncy.delay(0.2)) {
                        animateMissions = true
                    }
                } catch {
                    print("Error loading missions: \(error)")
                }
            }
        }
    }

    // MARK: - Mission Stats Card
    private var missionStatsCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // Completed Today
            StatBubbleM(
                icon: "checkmark.circle.fill",
                value: "\(completedTodayCount)",
                label: "Completed",
                color: .appSuccess
            )

            Divider()
                .frame(height: 40)

            // Total Rewards
            StatBubbleM(
                icon: "gift.fill",
                value: "\(totalRewardXP)",
                label: "XP Available",
                color: .appAccent
            )

            Divider()
                .frame(height: 40)

            // Streak
            StatBubbleM(
                icon: "flame.fill",
                value: "\(streakDays)",
                label: "Day Streak",
                color: .appWarning
            )
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach([MissionTab.daily, .weekly, .skill], id: \.self) { tab in
                Button(action: {
                    withAnimation(.appBouncy) {
                        HapticManager.shared.playLight()
                        selectedTab = tab
                    }
                }) {
                    Text(tabTitle(tab))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isTabSelected(tab) ? .white : .appText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(isTabSelected(tab) ? Color.appPrimary : Color(UIColor.secondarySystemBackground))
                                .appShadow(level: isTabSelected(tab) ? .medium : .light)
                        )
                }
            }
        }
    }

    // MARK: - Missions Section
    private var missionsSection: some View {
        LazyVStack(spacing: AppSpacing.md) {
            if selectedMissions.isEmpty {
                emptyState
            } else {
                ForEach(Array(selectedMissions.enumerated()), id: \.element.id) { index, mission in
                    MissionCard(
                        mission: mission,
                        progress: getMissionProgress(mission.id),
                        onClaim: {
                            Task {
                                await claimMissionReward(mission)
                            }
                        }
                    )
                    .opacity(animateMissions ? 1 : 0)
                    .offset(x: animateMissions ? 0 : -50)
                    .animation(.appBouncy.delay(Double(index) * 0.08), value: animateMissions)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.appSuccess)

            Text("All Missions Complete!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appText)

            Text("Come back tomorrow for new missions")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    // MARK: - Helper Methods
    private var completedTodayCount: Int {
        selectedMissions.filter { mission in
            let progress = gamificationService.userLevel?.missionProgress[mission.id] ?? MissionProgress(missionId: mission.id, completed: 0, total: mission.requirement.value?.intValue ?? 1, isCompleted: false)
            return progress.isCompleted
        }.count
    }

    private var totalRewardXP: Int {
        selectedMissions
            .filter { mission in
                let progress = gamificationService.userLevel?.missionProgress[mission.id] ?? MissionProgress(missionId: mission.id, completed: 0, total: mission.requirement.value?.intValue ?? 1, isCompleted: false)
                return progress.isCompleted
            }
            .reduce(0) { $0 + $1.rewardXP }
    }

    private var streakDays: Int {
        gamificationService.userLevel?.streakDays ?? 0
    }

    private func isTabSelected(_ tab: MissionTab) -> Bool {
        selectedTab == tab
    }

    private func tabTitle(_ tab: MissionTab) -> String {
        switch tab {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .skill: return "Skill"
        }
    }

    private func getMissionProgress(_ missionId: String) -> MissionProgress {
        // Find mission to get requirement
        if let mission = selectedMissions.first(where: { $0.id == missionId }) {
            return gamificationService.userLevel?.missionProgress[missionId] ?? MissionProgress(
                missionId: missionId,
                completed: 0,
                total: mission.requirement.value?.intValue ?? 1,
                isCompleted: false
            )
        }
        return MissionProgress(
            missionId: missionId,
            completed: 0,
            total: 1,
            isCompleted: false
        )
    }

    private func claimMissionReward(_ mission: Mission) async {
        do {
            // Update mission progress to completion
            try await gamificationService.updateMissionProgress(
                missionId: mission.id,
                amount: 1
            )
            HapticManager.shared.playSuccess()
        } catch {
            print("Error claiming reward: \(error)")
            HapticManager.shared.playError()
        }
    }
}

// MARK: - Mission Card
struct MissionCard: View {
    let mission: Mission
    let progress: MissionProgress
    let onClaim: () -> Void

    private var progressPercentage: Double {
        guard progress.total > 0 else { return 0 }
        return Double(progress.completed) / Double(progress.total)
    }

    private var isCompleted: Bool {
        progress.isCompleted
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                // Mission Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    mission.difficulty.color,
                                    mission.difficulty.color.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .appShadow(level: .medium)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text(mission.emoji)
                            .font(.system(size: 32))
                    }
                }

                // Mission Info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.sm) {
                        Text(mission.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appText)

                        DifficultyBadge(difficulty: mission.difficulty)
                    }

                    Text(mission.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)

                    // Progress Display
                    HStack(spacing: AppSpacing.sm) {
                        Text("\(progress.completed)/\(progress.total)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.appAccent)

                        Spacer()

                        Text("+\(mission.rewardXP) XP")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.appAccent)
                    }
                }

                Spacer()

                // Status Icon
                VStack(spacing: AppSpacing.xs) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appSuccess)
                    } else if progressPercentage >= 1.0 {
                        Button(action: onClaim) {
                            Image(systemName: "gift.circle.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appAccent)
                        }
                    } else {
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .padding(AppSpacing.md)

            // Progress Bar
            if !isCompleted {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color.appTextSecondary.opacity(0.2))

                        // Progress
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [mission.difficulty.color, mission.difficulty.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * min(progressPercentage, 1.0))
                    }
                    .frame(height: 6)
                }
                .frame(height: 6)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: isCompleted ? .light : .medium)
        )
        .opacity(isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Mission.MissionDifficulty

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10, weight: .bold))

            Text(difficulty.displayName)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(difficulty.color)
        )
    }
}

// MARK: - Stat Bubble (Reused)
struct StatBubbleM: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MissionsView()
}
