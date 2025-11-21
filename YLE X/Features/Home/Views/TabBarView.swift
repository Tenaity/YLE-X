//
//  TabBarView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//  Updated: 11/18/25 - Added Dictionary Integration
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    @Namespace private var animation

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content with subtle gradient background
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .learn:
                    LearningHubView() // NEW: Combined Dictionary + Lessons
                case .leaderboard:
                    LeaderboardView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                // Subtle gradient background based on selected tab
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        selectedTab.color.opacity(0.03)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            )

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation
                ) {
                    withAnimation(.appBouncy) {
                        HapticManager.shared.playLight()
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Material.ultraThinMaterial)
                .appShadow(level: .heavy)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(tab.color.opacity(0.2))
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                            .frame(width: 70, height: 40)
                    }

                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            isSelected
                                ? LinearGradient(
                                    colors: [tab.color, tab.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                                : LinearGradient(
                                    colors: [Color.appTextSecondary, Color.appTextSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? tab.color : .appTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Enum
enum Tab: CaseIterable {
    case home
    case learn
    case leaderboard
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .learn: return "Learn"
        case .leaderboard: return "Rank"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .learn: return "book"
        case .leaderboard: return "chart.bar"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .leaderboard: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .home: return .appPrimary
        case .learn: return .appSecondary
        case .leaderboard: return .appAccent
        case .profile: return .appInfo
        }
    }
}

// MARK: - Learning Hub View (NEW!)
/// Combined view with Dictionary and Lessons
struct LearningHubView: View {
    @State private var selectedMode: LearningMode = .dictionary

    enum LearningMode: String, CaseIterable {
        case dictionary = "Dictionary"
        case lessons = "Lessons"

        var icon: String {
            switch self {
            case .dictionary: return "book.fill"
            case .lessons: return "graduationcap.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode Selector
                modeSelector

                // Content
                TabView(selection: $selectedMode) {
                    VocabularyCategoriesView()
                        .tag(LearningMode.dictionary)

                    LessonListView()
                        .tag(LearningMode.lessons)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Learning")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var modeSelector: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(LearningMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.appSmooth) {
                        selectedMode = mode
                    }
                    HapticManager.shared.playSelection()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 16, weight: .semibold))

                        Text(mode.rawValue)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(selectedMode == mode ? .white : .appPrimary)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(selectedMode == mode ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appBackground)
    }
}

// MARK: - Learn View Wrapper (Keep for backwards compatibility)
struct LearnView: View {
    var body: some View {
        LearningHubView()
    }
}

#Preview {
    TabBarView()
        .environmentObject(ProgramSelectionStore())
}
