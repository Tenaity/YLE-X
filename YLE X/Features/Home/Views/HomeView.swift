//
//  HomeView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var programStore: ProgramSelectionStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var animateCards = false
    @State private var animateHeader = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Animated Header
                    headerSection
                        .opacity(animateHeader ? 1 : 0)
                        .offset(y: animateHeader ? 0 : -20)
                    
                    // Daily Progress Card
                    dailyProgressCard
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                    
                    // Level Selection Section
                    levelSelectionSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 30)
                    
                    // Quick Actions
                    quickActionsSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 40)
                    
                    // Skills Practice
                    skillsPracticeSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 50)
                    
                    // Recent Achievements
                    achievementsSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 60)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xl)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color.appPrimary.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: AppSpacing.sm) {
                        
                        Text("🎓")
                            .font(.system(size: 32))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("YLE X")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appPrimary)
                            
                            Text("Learn English Fun!")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                        
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppSpacing.sm) {
                        // Streak badge
                        HStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 16))
                            Text("\(viewModel.currentStreak)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.appAccent)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.appAccent.opacity(0.15))
                        .cornerRadius(AppRadius.full)
                        
                        // Notification bell
                        Button(action: {}) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.appBouncy.delay(0.1)) {
                    animateHeader = true
                }
                withAnimation(.appBouncy.delay(0.3)) {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Hello, \(viewModel.userName)! 👋")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appText)
            
            Text("Ready to learn something new today?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Daily Progress Card
    private var dailyProgressCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Today's Goal")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    
                    Text("\(viewModel.todayMinutes) / \(viewModel.dailyGoal) mins")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appPrimary)
                }
                
                Spacer()
                
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color.appPrimary.opacity(0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.dailyProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.appBouncy, value: viewModel.dailyProgress)
                    
                    Text("\(Int(viewModel.dailyProgress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appPrimary)
                }
            }
            
            // XP Progress bar
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text("⭐️ \(viewModel.totalXP) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appAccent)
                    
                    Spacer()
                    
                    Text("\(viewModel.xpToNextLevel) to next level")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.full)
                            .fill(Color.appAccent.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: AppRadius.full)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.xpProgress, height: 8)
                            .animation(.appBouncy, value: viewModel.xpProgress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }
    
    // MARK: - Level Selection Section
    private var levelSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Choose Your Level")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(YLELevel.allCases, id: \.self) { level in
                        LevelCard(level: level, isSelected: programStore.selectedLevel == level)
                            .onTapGesture {
                                guard programStore.selectedLevel != level else { return }
                                withAnimation(.appBouncy) {
                                    HapticManager.shared.playLight()
                                    programStore.select(level: level)
                                }
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                NavigationLink(destination: LinearJourneyView()) {
                    QuickActionCard(
                        icon: "map.fill",
                        title: "Main Quest",
                        subtitle: "Hành Trình YLE",
                        color: .appPrimary,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: SandboxMapView()) {
                    QuickActionCard(
                        icon: "globe.asia.australia.fill",
                        title: "Side Quest",
                        subtitle: "Thế Giới Khám Phá",
                        color: .appSecondary,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())

                QuickActionCard(
                    icon: "chart.bar.fill",
                    title: "Daily Challenge",
                    subtitle: "Earn bonus XP",
                    color: .appAccent,
                    action: {}
                )
                
                QuickActionCard(
                    icon: "book.fill",
                    title: "Vocabulary",
                    subtitle: "Review new words",
                    color: .appSkillVocabulary,
                    action: {}
                )
                
                QuickActionCard(
                    icon: "mic.fill",
                    title: "Speaking",
                    subtitle: "Practice pronunciation",
                    color: .appSkillSpeaking,
                    action: {}
                )
            }
        }
    }
    
    // MARK: - Skills Practice
    private var skillsPracticeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Skills Practice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.appPrimary)
                }
            }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(Skill.allCases.prefix(4), id: \.self) { skill in
                    SkillRow(skill: skill, progress: viewModel.getSkillProgress(skill))
                }
            }
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.recentBadges, id: \.id) { badge in
                        AchievementBadge(badge: badge)
                    }
                }
            }
        }
        .padding(.bottom, AppSpacing.xl)
    }
}

// MARK: - Level Card Component
struct LevelCard: View {
    let level: YLELevel
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                level.primaryColor,
                                level.primaryColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .appShadow(level: isSelected ? .medium : .light)
                
                Text(level.emoji)
                    .font(.system(size: 40))
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.appBouncy, value: isSelected)
            
            VStack(spacing: 4) {
                Text(level.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)
                
                Text(level.ageRange)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(width: 140)
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(isSelected ? level.primaryColor.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(isSelected ? level.primaryColor : Color.clear, lineWidth: 2)
                )
        )
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.playLight()
            action()
        }) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.15))
                    .cornerRadius(AppRadius.md)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appText)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .appShadow(level: .light)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.appQuick) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.appQuick) {
                isPressed = false
            }
        }
    }
}

// MARK: - Skill Row
struct SkillRow: View {
    let skill: Skill
    let progress: Double
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(skill.emoji)
                .font(.system(size: 28))
                .frame(width: 50, height: 50)
                .background(skill.color.opacity(0.15))
                .cornerRadius(AppRadius.md)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(skill.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appText)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.full)
                            .fill(skill.color.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: AppRadius.full)
                            .fill(skill.color)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.appBouncy, value: progress)
                    }
                }
                .frame(height: 6)
            }
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(skill.color)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
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
                    .frame(width: 70, height: 70)
                    .appShadow(level: .medium)
                
                Text(badge.emoji)
                    .font(.system(size: 32))
            }
            
            Text(badge.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
    }
}

// MARK: - Press Events Modifier
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Supporting Models
struct BadgeItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
}

#Preview {
    HomeView()
        .environmentObject(ProgramSelectionStore())
}
