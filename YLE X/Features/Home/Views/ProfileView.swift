//
//  ProfileView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var animateContent = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Profile Header
                    profileHeader
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)

                    // Stats Cards
                    statsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                    // Achievements Section
                    achievementsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                    // Activity Chart
                    activitySection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)

                    // Settings
                    settingsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 50)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xl)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color.appInfo.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.appBouncy.delay(0.2)) {
                    animateContent = true
                }
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppSpacing.lg) {
            // Avatar with Level Ring
            ZStack {
                // Level Progress Ring
                Circle()
                    .stroke(Color.appPrimary.opacity(0.2), lineWidth: 6)
                    .frame(width: 130, height: 130)

                Circle()
                    .trim(from: 0, to: viewModel.levelProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                viewModel.currentLevel.primaryColor,
                                viewModel.currentLevel.primaryColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(-90))
                    .animation(.appBouncy, value: viewModel.levelProgress)

                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    viewModel.currentLevel.primaryColor,
                                    viewModel.currentLevel.primaryColor.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .appShadow(level: .heavy)

                    Text("👧")
                        .font(.system(size: 60))
                }

                // Level Badge
                VStack(spacing: 2) {
                    Text(viewModel.currentLevel.emoji)
                        .font(.system(size: 16))

                    Text("Lv.\(viewModel.userLevel)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(viewModel.currentLevel.primaryColor)
                        .appShadow(level: .medium)
                )
                .offset(y: 55)
            }

            // User Info
            VStack(spacing: AppSpacing.xs) {
                Text(viewModel.userName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appText)

                Text(viewModel.currentLevel.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.currentLevel.primaryColor)

                // XP Progress
                HStack(spacing: AppSpacing.xs) {
                    Text("⭐️ \(viewModel.totalXP) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appAccent)

                    Text("•")
                        .foregroundColor(.appTextSecondary)

                    Text("\(viewModel.xpToNextLevel) to next level")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
            StatCard(
                icon: "flame.fill",
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: "days",
                color: .appAccent
            )

            StatCard(
                icon: "clock.fill",
                title: "Total Time",
                value: "\(viewModel.totalMinutes)",
                subtitle: "minutes",
                color: .appPrimary
            )

            StatCard(
                icon: "checkmark.circle.fill",
                title: "Completed",
                value: "\(viewModel.completedLessons)",
                subtitle: "lessons",
                color: .appSuccess
            )

            StatCard(
                icon: "trophy.fill",
                title: "Achievements",
                value: "\(viewModel.totalBadges)",
                subtitle: "badges",
                color: .appBadgeGold
            )
        }
    }

    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)

                Spacer()

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.appPrimary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.recentBadges, id: \.id) { badge in
                        BadgeCard(badge: badge)
                    }
                }
            }
        }
    }

    // MARK: - Activity Section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Weekly Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                ForEach(viewModel.weeklyActivity, id: \.day) { activity in
                    VStack(spacing: AppSpacing.xs) {
                        // Activity Bar
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        activity.minutes > 0 ? Color.appPrimary : Color.appPrimary.opacity(0.2),
                                        activity.minutes > 0 ? Color.appSecondary : Color.appSecondary.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(activity.minutes) * 2)
                            .frame(maxWidth: .infinity)

                        // Day Label
                        Text(activity.day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .frame(height: 150)
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SettingsRow(icon: "gear", title: "Settings", color: .appTextSecondary) {}
            SettingsRow(icon: "bell.badge", title: "Notifications", color: .appPrimary) {}
            SettingsRow(icon: "questionmark.circle", title: "Help & Support", color: .appInfo) {}
            SettingsRow(icon: "arrow.right.square", title: "Sign Out", color: .appError) {}
        }
        .padding(.bottom, AppSpacing.xl3)
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: BadgeItem

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [badge.color, badge.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .appShadow(level: .medium)

                Text(badge.emoji)
                    .font(.system(size: 36))
            }

            Text(badge.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 90)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.playLight()
            action()
        }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .cornerRadius(AppRadius.md)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }
}

// MARK: - Weekly Activity Model
struct WeeklyActivity: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

// MARK: - Profile ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Emily"
    @Published var currentLevel: YLELevel = .starters
    @Published var userLevel: Int = 12
    @Published var totalXP: Int = 1250
    @Published var currentStreak: Int = 7
    @Published var totalMinutes: Int = 345
    @Published var completedLessons: Int = 24
    @Published var totalBadges: Int = 12
    @Published var recentBadges: [BadgeItem] = []
    @Published var weeklyActivity: [WeeklyActivity] = []

    var levelProgress: Double {
        let currentLevelXP = 1000
        let nextLevelXP = 2000
        return Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
    }

    var xpToNextLevel: Int {
        let nextLevelXP = 2000
        return nextLevelXP - totalXP
    }

    init() {
        setupRecentBadges()
        setupWeeklyActivity()
    }

    private func setupRecentBadges() {
        recentBadges = [
            BadgeItem(name: "First Step", emoji: "👣", color: .appLevelStarters),
            BadgeItem(name: "Word Master", emoji: "📚", color: .appSkillVocabulary),
            BadgeItem(name: "7 Day Streak", emoji: "🔥", color: .appAccent),
            BadgeItem(name: "Perfect Score", emoji: "💯", color: .appBadgeGold),
            BadgeItem(name: "Speed Learner", emoji: "⚡️", color: .appPrimary)
        ]
    }

    private func setupWeeklyActivity() {
        weeklyActivity = [
            WeeklyActivity(day: "Mon", minutes: 45),
            WeeklyActivity(day: "Tue", minutes: 30),
            WeeklyActivity(day: "Wed", minutes: 60),
            WeeklyActivity(day: "Thu", minutes: 25),
            WeeklyActivity(day: "Fri", minutes: 40),
            WeeklyActivity(day: "Sat", minutes: 35),
            WeeklyActivity(day: "Sun", minutes: 15)
        ]
    }
}

#Preview {
    ProfileView()
}
