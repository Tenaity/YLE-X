//
//  OnboardingManager.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import AVFoundation
import UserNotifications
import Combine
import SwiftUI

class OnboardingManager: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedLevel: YLELevel?
    @Published var childName: String = ""
    @Published var parentName: String = ""
    @Published var dailyGoalMinutes: Double = 15
    @Published var microphonePermission = false
    @Published var notificationPermission = false

    func nextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }

        withAnimation(.appGentle) {
            currentStep = nextStep
        }

        HapticManager.shared.playLight()
    }

    func previousStep() {
        guard let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }

        withAnimation(.appGentle) {
            currentStep = previousStep
        }

        HapticManager.shared.playLight()
    }

    func selectLevel(_ level: YLELevel) {
        selectedLevel = level
    }

    func canProceed(from step: OnboardingStep) -> Bool {
        switch step {
        case .welcome:
            return true
        case .levelSelection:
            return selectedLevel != nil
        case .parentSetup:
            return !childName.isEmpty && !parentName.isEmpty
        case .permissions:
            return true // Optional permissions
        case .ready:
            return true
        }
    }

    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (granted: Bool) in
            DispatchQueue.main.async {
                self?.microphonePermission = granted
                if granted {
                    HapticManager.shared.playSuccess()
                }
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted: Bool, _) in
            DispatchQueue.main.async {
                self?.notificationPermission = granted
                if granted {
                    HapticManager.shared.playSuccess()
                }
            }
        }
    }

    func completeOnboarding() {
        // Save onboarding data using semantic keys
        UserDefaults.standard.set(true, forKey: "app.onboarding.completed")
        UserDefaults.standard.set(selectedLevel?.rawValue, forKey: "app.onboarding.selectedLevel")
        UserDefaults.standard.set(childName, forKey: "app.onboarding.childName")
        UserDefaults.standard.set(parentName, forKey: "app.onboarding.parentName")
        UserDefaults.standard.set(dailyGoalMinutes, forKey: "app.onboarding.dailyGoalMinutes")

        HapticManager.shared.playSuccess()
        print("✅ Onboarding completed successfully")
    }
}
