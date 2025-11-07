//
//  BadgeGalleryView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct BadgeGalleryView: View {
    @StateObject private var gamificationService = GamificationService.shared
    @State private var selectedBadge: Badge?
    @State private var animateBadges = false

    var unlockedBadges: [Badge] {
        gamificationService.unlockedBadges.values.sorted { $0.id < $1.id }
    }

    var lockedBadges: [Badge] {
        gamificationService.availableBadges.filter {
            !gamificationService.unlockedBadges.keys.contains($0.id)
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
                    VStack(spacing: AppSpacing.xl) {
                        // Stats Header
                        HStack(spacing: AppSpacing.lg) {
                            VStack(spacing: AppSpacing.xs) {
                                Text("\(unlockedBadges.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.appSuccess)
                                Text("Unlocked")
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

                            VStack(spacing: AppSpacing.xs) {
                                Text("\(lockedBadges.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.appTextSecondary)
                                Text("Locked")
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

                        // Unlocked Badges
                        if !unlockedBadges.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Unlocked Badges")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appText)
                                    .padding(.horizontal, AppSpacing.md)

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: AppSpacing.md
                                ) {
                                    ForEach(Array(unlockedBadges.enumerated()), id: \.element.id) { index, badge in
                                        BadgeCard(badge: badge, isUnlocked: true) {
                                            HapticManager.shared.playLight()
                                            selectedBadge = badge
                                        }
                                        .opacity(animateBadges ? 1 : 0)
                                        .scaleEffect(animateBadges ? 1 : 0.5)
                                        .animation(.appBouncy.delay(Double(index) * 0.05), value: animateBadges)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                            }
                        }

                        // Locked Badges
                        if !lockedBadges.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Locked Badges")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appText)
                                    .padding(.horizontal, AppSpacing.md)

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: AppSpacing.md
                                ) {
                                    ForEach(Array(lockedBadges.enumerated()), id: \.element.id) { index, badge in
                                        BadgeCard(badge: badge, isUnlocked: false) {
                                            HapticManager.shared.playLight()
                                            selectedBadge = badge
                                        }
                                        .opacity(animateBadges ? 1 : 0)
                                        .scaleEffect(animateBadges ? 1 : 0.5)
                                        .animation(.appBouncy.delay(Double(unlockedBadges.count + index) * 0.05), value: animateBadges)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                            }
                        }
                    }
                    .padding(.vertical, AppSpacing.xl)
                }
            }
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedBadge) { badge in
                BadgeDetailView(badge: badge)
            }
            .task {
                do {
                    try await gamificationService.fetchAllBadges()
                    withAnimation(.appBouncy) {
                        animateBadges = true
                    }
                } catch {
                    print("Error loading badges: \(error)")
                }
            }
        }
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: badge.color),
                                    Color(hex: badge.color).opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                        .appShadow(level: .medium)

                    if isUnlocked {
                        Text(badge.emoji)
                            .font(.system(size: 40))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("?")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }

                Text(isUnlocked ? badge.name : "?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if isUnlocked {
                    HStack(spacing: 2) {
                        ForEach(0..<badgeRarityStars(badge.rarity), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.appAccent)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(isUnlocked ? 1 : 0.5)
        }
    }

    private func badgeRarityStars(_ rarity: Badge.BadgeRarity) -> Int {
        switch rarity {
        case .common: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
}

// MARK: - Badge Detail View
struct BadgeDetailView: View {
    @Environment(\.dismiss) var dismiss
    let badge: Badge
    @State private var animateContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color(hex: badge.color).opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Large Badge Display
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: badge.color),
                                            Color(hex: badge.color).opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 180, height: 180)
                                .appShadow(level: .heavy)

                            Text(badge.emoji)
                                .font(.system(size: 100))
                        }
                        .scaleEffect(animateContent ? 1 : 0.5)
                        .opacity(animateContent ? 1 : 0)

                        // Badge Info
                        VStack(spacing: AppSpacing.md) {
                            Text(badge.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.appText)

                            Text(badge.description)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // Rarity Badge
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))
                            Text(badge.rarity.displayName)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            Capsule()
                                .fill(badge.rarity.borderColor)
                                .appShadow(level: .medium)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // Reward
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appAccent)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("XP Reward")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                Text("+\(badge.xpReward) XP")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.appAccent)
                            }

                            Spacer()
                        }
                        .padding(AppSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .appShadow(level: .light)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding(AppSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                withAnimation(.appBouncy.delay(0.2)) {
                    animateContent = true
                }
            }
        }
    }
}

#Preview {
    BadgeGalleryView()
}
