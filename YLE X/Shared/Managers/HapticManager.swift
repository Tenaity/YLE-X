//
//  HapticManager.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Haptic feedback manager
//

import UIKit

// MARK: - HapticManager
final class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    private init() {}

    // MARK: - Impact Feedback
    func playLight() {
        lightImpact.impactOccurred()
    }

    func playMedium() {
        mediumImpact.impactOccurred()
    }

    func playHeavy() {
        heavyImpact.impactOccurred()
    }

    // MARK: - Notification Feedback
    func playSuccess() {
        notification.notificationOccurred(.success)
    }

    func playWarning() {
        notification.notificationOccurred(.warning)
    }

    func playError() {
        notification.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback
    func playSelection() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
    }
}
