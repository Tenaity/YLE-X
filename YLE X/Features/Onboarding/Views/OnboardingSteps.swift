//
//  OnboardingSteps.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

// MARK: - Welcome Step
struct WelcomeStepView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("🌟")
                .font(.system(size: 120))
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)

            Text("Welcome to YLE X!")
                .appDisplayLarge()
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)

            Text("Learn English the fun way! 🎈")
                .appTitleLarge()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)

            VStack(spacing: AppSpacing.md) {
                FeatureHighlight(icon: "🎮", title: "Learn Through Games", description: "Fun like playing video games")
                FeatureHighlight(icon: "🏆", title: "Badge System", description: "Collect badges as you learn")
                FeatureHighlight(icon: "📈", title: "Track Progress", description: "Parents can view the results")
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Feature Highlight
struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(icon).font(.system(size: 32))
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title).appHeadlineSmall().foregroundColor(.appPrimary)
                Text(description).appBodySmall().foregroundColor(.appTextSecondary)
            }
            Spacer()
        }
        .appCardPadding()
        .background(Color.appBackgroundSecondary)
        .appCardRadius()
        .appShadow(level: .light)
    }
}

// MARK: - Level Selection Step
struct LevelSelectionStepView: View {
    @ObservedObject var manager: OnboardingManager

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("How old are you? 🎂")
                .appDisplayMedium()
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)

            Text("Select the level that matches your age")
                .appTitleMedium()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: AppSpacing.lg) {
                ForEach(YLELevel.allCases) { level in
                    OnboardingLevelCard(level: level, isSelected: manager.selectedLevel == level) {
                        manager.selectLevel(level)
                    }
                }
            }
        }
    }
}

// MARK: - Level Card
struct OnboardingLevelCard: View {
    let level: YLELevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.playMedium()
            action()
        }) {
            HStack(spacing: AppSpacing.lg) {
                Text(level.emoji).font(.system(size: 40))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(level.title).appTitleMedium().foregroundColor(.appText)
                    Text(level.ageRange).appBodyMedium().foregroundColor(level.primaryColor).fontWeight(.semibold)
                    Text(level.description).appCaptionSmall().foregroundColor(.appTextSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? level.primaryColor : .appTextTertiary)
            }
            .appCardPadding()
            .background(Color.appBackgroundSecondary)
            .overlay(RoundedRectangle(cornerRadius: AppRadius.lg).stroke(isSelected ? level.primaryColor : Color.clear, lineWidth: 2))
            .appCardRadius()
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.appGentle, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Parent Setup Step
struct ParentSetupStepView: View {
    @ObservedObject var manager: OnboardingManager

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("Parent Information 👨‍👩‍👧‍👦")
                .appDisplayMedium()
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)

            Text("Help us personalize the experience for your child")
                .appTitleMedium()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: AppSpacing.lg) {
                ParentInfoField(title: "Child's Name", placeholder: "Enter child's name", text: $manager.childName, emoji: "👶")
                ParentInfoField(title: "Parent's Name", placeholder: "Enter parent's name", text: $manager.parentName, emoji: "👨‍👩‍👧‍👦")

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack {
                        Text("🎯")
                        Text("Daily Goal").appHeadlineSmall().foregroundColor(.appPrimary)
                        Spacer()
                    }
                    HStack {
                        Text("\(Int(manager.dailyGoalMinutes)) mins").appBodyMedium().foregroundColor(.appTextSecondary)
                        Slider(value: $manager.dailyGoalMinutes, in: 5...60, step: 5).tint(.appLevelMovers)
                        Text("60 mins").appCaptionSmall().foregroundColor(.appTextTertiary)
                    }
                }
                .appCardPadding()
                .background(Color.appBackgroundSecondary)
                .appCardRadius()
                .appShadow(level: .light)
            }
        }
    }
}

// MARK: - Parent Info Field
struct ParentInfoField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let emoji: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(emoji)
                Text(title).appHeadlineSmall().foregroundColor(.appPrimary)
                Spacer()
            }
            TextField(placeholder, text: $text)
                .appBodyMedium()
                .padding(AppSpacing.md)
                .background(Color.appFillLight)
                .appInputRadius()
        }
        .appCardPadding()
        .background(Color.appBackgroundSecondary)
        .appCardRadius()
        .appShadow(level: .light)
    }
}

// MARK: - Permissions Step
struct PermissionsStepView: View {
    @ObservedObject var manager: OnboardingManager

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("App Permissions 🔧")
                .appDisplayMedium()
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)

            Text("For the best experience, we need:")
                .appTitleMedium()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: AppSpacing.lg) {
                PermissionCard(icon: "🎤", title: "Microphone", description: "Practice your pronunciation",
                               isGranted: manager.microphonePermission) { manager.requestMicrophonePermission() }
                PermissionCard(icon: "🔔", title: "Notifications", description: "Daily learning reminders",
                               isGranted: manager.notificationPermission) { manager.requestNotificationPermission() }
            }

            Text("You can change these settings later")
                .appCaptionSmall()
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Permission Card
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let requestAction: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            Text(icon).font(.system(size: 32))
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title).appHeadlineSmall().foregroundColor(.appPrimary)
                Text(description).appBodySmall().foregroundColor(.appTextSecondary)
            }
            Spacer()
            if isGranted {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundColor(.appSuccess)
            } else {
                Button("Allow") { requestAction() }
                    .appCaptionSmall()
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(Capsule().fill(Color.appPrimary))
            }
        }
        .appCardPadding()
        .background(Color.appBackgroundSecondary)
        .overlay(RoundedRectangle(cornerRadius: AppRadius.lg).stroke(isGranted ? Color.appSuccess : Color.clear, lineWidth: 1))
        .appCardRadius()
    }
}

// MARK: - Ready Step
struct ReadyStepView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("🚀")
                .font(.system(size: 120))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)

            Text("Ready to Start!")
                .appDisplayLarge()
                .foregroundColor(.appSuccess)
                .multilineTextAlignment(.center)

            Text("Let's begin your English learning journey!")
                .appTitleMedium()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: AppSpacing.md) {
                ReadySummaryItem(icon: "🎯", text: "Level selected")
                ReadySummaryItem(icon: "👨‍👩‍👧‍👦", text: "Information set up")
                ReadySummaryItem(icon: "🔧", text: "Permissions granted")
                ReadySummaryItem(icon: "🎉", text: "Ready to learn!")
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Ready Summary Item
struct ReadySummaryItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(icon).font(.system(size: 20))
            Text(text).appBodyMedium().foregroundColor(.appText)
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundColor(.appSuccess)
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

#Preview {
    VStack {
        WelcomeStepView()
    }
}
