//
//  OnboardingView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            OnboardingBackgroundView()

            TabView(selection: $onboardingManager.currentStep) {
                ForEach(OnboardingStep.allCases) { step in
                    OnboardingStepView(step: step, manager: onboardingManager)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.appGentle, value: onboardingManager.currentStep)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Onboarding Step View
struct OnboardingStepView: View {
    let step: OnboardingStep
    @ObservedObject var manager: OnboardingManager

    var body: some View {
        VStack(spacing: AppSpacing.xl3) {
            Spacer()
            stepContent
            Spacer()
            navigationButtons
        }
        .padding(AppSpacing.xl)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            WelcomeStepView()
        case .levelSelection:
            LevelSelectionStepView(manager: manager)
        case .parentSetup:
            ParentSetupStepView(manager: manager)
        case .permissions:
            PermissionsStepView(manager: manager)
        case .ready:
            ReadyStepView()
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: AppSpacing.lg) {
            if step != .welcome {
                AppButton(title: "Back", icon: "chevron.left", style: .secondary) {
                    manager.previousStep()
                }
                .frame(width: 80)
            }

            Spacer()

            OnboardingProgressIndicator(currentStep: step.rawValue, totalSteps: OnboardingStep.allCases.count)

            Spacer()

            AppButton(
                title: step == .ready ? "Start" : "Continue",
                icon: step == .ready ? "play.fill" : "arrow.right",
                style: .primary
            ) {
                if step == .ready {
                    manager.completeOnboarding()
                } else {
                    manager.nextStep()
                }
            }
            .disabled(!manager.canProceed(from: step))
            .opacity(manager.canProceed(from: step) ? 1.0 : 0.5)
            .frame(width: 110)
        }
    }
}

// MARK: - Onboarding Components
struct OnboardingBackgroundView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.appPrimary.opacity(0.08), Color.appSecondary.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.appPrimary.opacity(0.05))
                    .frame(width: CGFloat.random(in: 50...120))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.appPrimary : Color.appFillLight)
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.3 : 1.0)
                    .animation(.appGentle, value: currentStep)
            }
        }
    }
}

// MARK: - Onboarding Enum
enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case levelSelection
    case parentSetup
    case permissions
    case ready

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .welcome: return "Welcome to YLE X!"
        case .levelSelection: return "Choose Your Level"
        case .parentSetup: return "Parent Information"
        case .permissions: return "App Permissions"
        case .ready: return "Ready to Start!"
        }
    }

    var description: String {
        switch self {
        case .welcome: return "Learn English the fun way!"
        case .levelSelection: return "Select the level that matches your age"
        case .parentSetup: return "Set up information to track learning progress"
        case .permissions: return "Allow access to microphone and notifications"
        case .ready: return "Everything is set up! Let's start learning!"
        }
    }

    var emoji: String {
        switch self {
        case .welcome: return "🎉"
        case .levelSelection: return "🎯"
        case .parentSetup: return "👨‍👩‍👧‍👦"
        case .permissions: return "🔐"
        case .ready: return "🚀"
        }
    }

    var primaryColor: Color {
        switch self {
        case .welcome: return .appPrimary
        case .levelSelection: return .appLevelStarters
        case .parentSetup: return .appLevelMovers
        case .permissions: return .appLevelFlyers
        case .ready: return .appSuccess
        }
    }
}

#Preview {
    OnboardingView()
}
