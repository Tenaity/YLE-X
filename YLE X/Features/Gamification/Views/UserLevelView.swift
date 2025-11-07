//
//  UserLevelView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import FirebaseAuth

struct UserLevelView: View {
    @StateObject private var gamificationService = GamificationService.shared
    @State private var animateContent = false
    @State private var animateProgress = false
    @State private var showLevelUpAnimation = false

    private var userLevel: UserLevel? {
        gamificationService.userLevel
    }

    private var xpToNextLevel: Int {
        guard let userLevel = userLevel else { return 0 }
        let currentLevelXP = Self.xpRequiredForLevel(userLevel.currentLevel)
        let nextLevelXP = Self.xpRequiredForLevel(userLevel.currentLevel + 1)
        let xpInCurrentLevel = userLevel.totalXP - currentLevelXP
        return nextLevelXP - currentLevelXP - xpInCurrentLevel
    }

    private var currentLevelXP: Int {
        guard let userLevel = userLevel else { return 0 }
        let levelStartXP = Self.xpRequiredForLevel(userLevel.currentLevel)
        return userLevel.totalXP - levelStartXP
    }

    private var xpForCurrentLevel: Int {
        guard let userLevel = userLevel else { return 0 }
        let currentLevelXP = Self.xpRequiredForLevel(userLevel.currentLevel)
        let nextLevelXP = Self.xpRequiredForLevel(userLevel.currentLevel + 1)
        return nextLevelXP - currentLevelXP
    }

    private var progressPercentage: Double {
        guard xpForCurrentLevel > 0 else { return 0 }
        return Double(currentLevelXP) / Double(xpForCurrentLevel)
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

                // Level Up Animation Overlay
                if showLevelUpAnimation {
                    LevelUpAnimationView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.xl) {
                        // Current Level Display
                        levelDisplayCard
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)

                        // XP Progress Bar
                        xpProgressCard
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Level Progression Chart
                        levelProgressionChart
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Streak Information
                        streakCard
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Rewards & Milestones
                        rewardsSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }
            }
            .navigationTitle("My Level")
            .navigationBarTitleDisplayMode(.large)
            .task {
                do {
                    if let userId = Auth.auth().currentUser?.uid {
                        try await gamificationService.initializeUserLevel(userId: userId)
                        withAnimation(.appBouncy.delay(0.2)) {
                            animateContent = true
                        }
                        withAnimation(.appBouncy.delay(0.5)) {
                            animateProgress = true
                        }
                    }
                } catch {
                    print("Error loading level: \(error)")
                }
            }
        }
    }

    // MARK: - Level Display Card
    private var levelDisplayCard: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                // Background Circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.1),
                                Color.appPrimary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .appShadow(level: .heavy)

                // Animated Ring
                Circle()
                    .trim(from: 0, to: animateProgress ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.appAccent, .appBadgeGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: -90))

                // Level Number
                VStack(spacing: AppSpacing.sm) {
                    Text("Level")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text("\(userLevel?.currentLevel ?? 0)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.appPrimary, .appAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if userLevel?.currentLevel ?? 0 >= 100 {
                        Text("Master")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appBadgeGold)
                    }
                }
            }

            // Level Title
            Text(levelTitle(userLevel?.currentLevel ?? 0))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            Text(levelDescription(userLevel?.currentLevel ?? 0))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - XP Progress Card
    private var xpProgressCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Experience Progress")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text("\(currentLevelXP) / \(xpForCurrentLevel) XP")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("To Next Level")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text("+\(xpToNextLevel)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appAccent)
                }
            }

            // Progress Bar with Animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.appTextSecondary.opacity(0.2))

                    // Progress
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [.appAccent, .appBadgeGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (animateProgress ? progressPercentage : 0))
                        .animation(.easeInOut(duration: 1.0), value: animateProgress)
                }
            }
            .frame(height: 12)

            // Percentage
            HStack {
                Text("\(Int(progressPercentage * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appAccent)

                Spacer()

                Text("Level \(min((userLevel?.currentLevel ?? 0) + 1, 100))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Level Progression Chart
    private var levelProgressionChart: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Progression")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appText)

            HStack(spacing: AppSpacing.sm) {
                ForEach(0..<10, id: \.self) { index in
                    let levelNum = (index + 1) * 10
                    VStack(spacing: AppSpacing.xs) {
                        ZStack {
                            Circle()
                                .fill(
                                    levelNum <= (userLevel?.currentLevel ?? 0)
                                        ? Color.appSuccess
                                        : Color.appTextSecondary.opacity(0.2)
                                )
                                .frame(width: 40, height: 40)

                            if levelNum <= (userLevel?.currentLevel ?? 0) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(levelNum / 10)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }

                        Text("\(levelNum)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        HStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appWarning.opacity(0.2), .appWarning.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appWarning)

                    Text("\(userLevel?.streakDays ?? 0)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Day Streak")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)

                Text("Keep learning daily to build your streak!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                if userLevel?.streakDays ?? 0 >= 7 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Streak Milestone Unlocked!")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.appBadgeGold)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Rewards Section
    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Total Stats")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appText)

            HStack(spacing: AppSpacing.md) {
                // Total XP
                LevelStatCard(
                    icon: "star.fill",
                    title: "Total XP",
                    value: "\(userLevel?.totalXP ?? 0)",
                    color: .appAccent
                )

                // Badges Earned
                LevelStatCard(
                    icon: "shield.fill",
                    title: "Badges",
                    value: "\((userLevel?.badgesUnlocked.count ?? 0))/9",
                    color: .appSuccess
                )
            }
        }
    }

    // MARK: - Helper Methods
    private static func xpRequiredForLevel(_ level: Int) -> Int {
        // Exponential growth: each level requires more XP
        // Level 1: 100 XP, Level 2: 200 XP, etc.
        var totalXP = 0
        for i in 1..<level {
            totalXP += 100 + (i * 50)
        }
        return totalXP
    }

    private func levelTitle(_ level: Int) -> String {
        switch level {
        case 1...10: return "Beginner"
        case 11...25: return "Learner"
        case 26...50: return "Scholar"
        case 51...75: return "Expert"
        case 76...99: return "Master"
        case 100: return "Grand Master"
        default: return "Unknown"
        }
    }

    private func levelDescription(_ level: Int) -> String {
        switch level {
        case 1...10: return "Keep learning to unlock more content!"
        case 11...25: return "You're making great progress!"
        case 26...50: return "You're becoming a true scholar!"
        case 51...75: return "You're an expert learner now!"
        case 76...99: return "You're almost at the highest level!"
        case 100: return "Congratulations! You've reached the ultimate level!"
        default: return "Keep going!"
        }
    }
}

// MARK: - Level Up Animation View
struct LevelUpAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)

            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.appBadgeGold)
                        .scaleEffect(scale)

                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.appAccent, lineWidth: 3)
                            .frame(width: 120 + CGFloat(index * 60), height: 120 + CGFloat(index * 60))
                            .opacity(1 - Double(index) * 0.3)
                            .scaleEffect(scale)
                    }
                }

                Text("Level Up! 🎉")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(scale)

                Text("You've advanced to the next level!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .scaleEffect(scale)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 0
                }
            }
        }
    }
}

// MARK: - Level Stat Card
struct LevelStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appText)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }
}

#Preview {
    UserLevelView()
}
