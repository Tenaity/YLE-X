//
//  HapticManager.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let successNotification = UINotificationFeedbackGenerator()
    
    private init() {}
    
    func playLight() {
        lightImpact.impactOccurred()
    }
    
    func playSuccess() {
        successNotification.notificationOccurred(.success)
    }
    
    func playError() {
        successNotification.notificationOccurred(.error)
    }
}
