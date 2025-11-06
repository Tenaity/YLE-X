//
//  NotificationService.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import UserNotifications
import UIKit

// MARK: - Push Notification Service
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var notificationSettings: UNNotificationSettings?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                isAuthorized = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("❌ Notification authorization failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationSettings = settings
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    @MainActor
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Local Notifications
    func scheduleStudyReminder(at date: Date, title: String, body: String) {
        let content = createNotificationContent(
            title: title,
            body: body,
            sound: "gentle_chime.wav",
            category: .studyReminder
        )
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyReminder.rawValue,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule study reminder: \(error.localizedDescription)")
            } else {
                print("✅ Study reminder scheduled for \(date)")
            }
        }
    }
    
    func scheduleStreakMotivation(streak: Int) {
        let content = createNotificationContent(
            title: getStreakTitle(streak: streak),
            body: getStreakMessage(streak: streak),
            sound: "celebration.wav",
            category: .motivation
        )
        
        // Schedule for next day if streak is maintained
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "\(NotificationIdentifier.streakMotivation.rawValue)_\(streak)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule streak motivation: \(error.localizedDescription)")
            } else {
                print("✅ Streak motivation scheduled for streak: \(streak)")
            }
        }
    }
    
    func scheduleAchievementNotification(badge: Badge) {
        let content = createNotificationContent(
            title: "🎉 Huy hiệu mới!",
            body: "Chúc mừng! Bé vừa đạt được huy hiệu '\(badge.name)'",
            sound: "badge_earned.wav",
            category: .achievement
        )
        
        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "\(NotificationIdentifier.achievement.rawValue)_\(badge.id)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule achievement notification: \(error.localizedDescription)")
            } else {
                print("✅ Achievement notification scheduled for: \(badge.name)")
            }
        }
    }
    
    func scheduleParentUpdate(childName: String, progress: String) {
        let content = createNotificationContent(
            title: "📊 Cập nhật tiến độ",
            body: "\(childName) đã có tiến bộ tuyệt vời! \(progress)",
            sound: "parent_update.wav",
            category: .parentUpdate
        )
        
        // Schedule for evening (7 PM)
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.parentUpdate.rawValue,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule parent update: \(error.localizedDescription)")
            } else {
                print("✅ Parent update scheduled")
            }
        }
    }
    
    // MARK: - Weekly Challenge Notifications
    func scheduleWeeklyChallenge() {
        let challenges = [
            "Thử thách tuần này: Học 50 từ mới! 📚",
            "Mục tiêu tuần: Hoàn thành 20 bài tập! 🎯",
            "Thử thách: Duy trì streak 7 ngày! 🔥",
            "Tuần này hãy tập trung vào phát âm! 🗣️"
        ]
        
        let content = createNotificationContent(
            title: "🌟 Thử thách tuần mới!",
            body: challenges.randomElement() ?? challenges[0],
            sound: "challenge.wav",
            category: .weeklyChallenge
        )
        
        // Schedule for Monday morning
        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.weeklyChallenge.rawValue,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule weekly challenge: \(error.localizedDescription)")
            } else {
                print("✅ Weekly challenge scheduled")
            }
        }
    }
    
    // MARK: - Notification Content Creation
    private func createNotificationContent(
        title: String,
        body: String,
        sound: String,
        category: NotificationCategory
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
        content.categoryIdentifier = category.rawValue
        content.badge = 1
        
        // Add user info for analytics
        content.userInfo = [
            "category": category.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        return content
    }
    
    // MARK: - Helper Methods
    private func getStreakTitle(streak: Int) -> String {
        switch streak {
        case 1...3: return "🌱 Khởi đầu tốt!"
        case 4...7: return "🔥 Streak tuyệt vời!"
        case 8...14: return "⭐ Siêu kiên trì!"
        case 15...30: return "🏆 Nhà vô địch!"
        default: return "👑 Huyền thoại!"
        }
    }
    
    private func getStreakMessage(streak: Int) -> String {
        let messages = [
            "Bé đã học \(streak) ngày liên tiếp! Tiếp tục phát huy nhé! 💪",
            "Streak \(streak) ngày! Bé thật là giỏi! 🌟",
            "Tuyệt vời! \(streak) ngày không nghỉ! Bé là siêu sao! ⭐",
            "Wow! \(streak) ngày liên tục! Bé làm tốt lắm! 🎉"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Notification Management
    func cancelNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        print("✅ Cancelled notification: \(identifier)")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("✅ All notifications cancelled")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }
    
    // MARK: - Notification Categories Setup
    func setupNotificationCategories() {
        let studyAction = UNNotificationAction(
            identifier: "STUDY_NOW",
            title: "Học ngay! 📚",
            options: [.foreground]
        )
        
        let studyLaterAction = UNNotificationAction(
            identifier: "STUDY_LATER",
            title: "Để sau 😴",
            options: []
        )
        
        let studyReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.studyReminder.rawValue,
            actions: [studyAction, studyLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        let celebrateAction = UNNotificationAction(
            identifier: "CELEBRATE",
            title: "Xem ngay! 🎉",
            options: [.foreground]
        )
        
        let achievementCategory = UNNotificationCategory(
            identifier: NotificationCategory.achievement.rawValue,
            actions: [celebrateAction],
            intentIdentifiers: [],
            options: []
        )
        
        let viewProgressAction = UNNotificationAction(
            identifier: "VIEW_PROGRESS",
            title: "Xem tiến độ 📊",
            options: [.foreground]
        )
        
        let parentUpdateCategory = UNNotificationCategory(
            identifier: NotificationCategory.parentUpdate.rawValue,
            actions: [viewProgressAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            studyReminderCategory,
            achievementCategory,
            parentUpdateCategory
        ])
        
        print("✅ Notification categories set up")
    }
    
    // MARK: - Smart Scheduling
    func scheduleSmartReminders(for userProgress: UserProgress) {
        // Analyze user's learning patterns and schedule optimal reminders
        let learningHours = analyzeLearningPatterns(userProgress)
        
        for hour in learningHours {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let content = createNotificationContent(
                title: getSmartReminderTitle(hour: hour),
                body: getSmartReminderBody(hour: hour, level: userProgress.level),
                sound: "smart_reminder.wav",
                category: .studyReminder
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "smart_reminder_\(hour)",
                content: content,
                trigger: trigger
            )
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule smart reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Smart reminder scheduled for \(hour):00")
                }
            }
        }
    }
    
    private func analyzeLearningPatterns(_ progress: UserProgress) -> [Int] {
        // This would analyze when the user is most active and engaged
        // For now, return optimal learning hours based on research
        return [9, 16, 19] // Morning, afternoon, evening
    }
    
    private func getSmartReminderTitle(hour: Int) -> String {
        switch hour {
        case 6...11: return "🌅 Chào buổi sáng!"
        case 12...17: return "☀️ Buổi chiều vui vẻ!"
        case 18...22: return "🌙 Buổi tối thư giãn!"
        default: return "📚 Giờ học tập!"
        }
    }
    
    private func getSmartReminderBody(hour: Int, level: YLELevel) -> String {
        let timeMessages: [String]
        
        switch hour {
        case 6...11:
            timeMessages = [
                "Bắt đầu ngày mới với tiếng Anh nhé! 🌟",
                "Buổi sáng là thời gian tuyệt vời để học! ☀️",
                "Hãy dành 10 phút học tiếng Anh nào! 📚"
            ]
        case 12...17:
            timeMessages = [
                "Giải lao với bài học tiếng Anh thú vị! 🎮",
                "Buổi chiều vui vẻ cùng YLE X! 🎨",
                "Cùng học vài từ mới nhé bé! 📖"
            ]
        default:
            timeMessages = [
                "Kết thúc ngày với bài học nhẹ nhàng! 🌙",
                "Ôn tập kiến thức trước khi ngủ nhé! 💤",
                "Buổi tối thư giãn cùng tiếng Anh! 🛋️"
            ]
        }
        
        return timeMessages.randomElement() ?? timeMessages[0]
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        let notification = response.notification
        
        handleNotificationResponse(actionIdentifier: actionIdentifier, notification: notification)
        
        completionHandler()
    }
    
    private func handleNotificationResponse(actionIdentifier: String, notification: UNNotification) {
        switch actionIdentifier {
        case "STUDY_NOW":
            // Navigate to learning screen
            NotificationCenter.default.post(name: .navigateToLearning, object: nil)
            print("📚 User chose to study now")
            
        case "STUDY_LATER":
            // Schedule reminder for later
            let futureDate = Date().addingTimeInterval(2 * 60 * 60) // 2 hours later
            scheduleStudyReminder(
                at: futureDate,
                title: "🔔 Nhắc nhở học tập",
                body: "Đã đến giờ học rồi! Cùng bắt đầu nào! 📚"
            )
            print("⏰ Study reminder rescheduled")
            
        case "CELEBRATE":
            // Navigate to achievements screen
            NotificationCenter.default.post(name: .navigateToAchievements, object: nil)
            print("🎉 User chose to celebrate achievement")
            
        case "VIEW_PROGRESS":
            // Navigate to parent dashboard
            NotificationCenter.default.post(name: .navigateToParentDashboard, object: nil)
            print("📊 User chose to view progress")
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            NotificationCenter.default.post(name: .notificationTapped, object: notification)
            print("👆 Notification tapped")
            
        default:
            print("🤷‍♂️ Unknown notification action: \(actionIdentifier)")
        }
    }
}

// MARK: - Supporting Enums
enum NotificationIdentifier: String {
    case dailyReminder = "daily_reminder"
    case streakMotivation = "streak_motivation"
    case achievement = "achievement"
    case parentUpdate = "parent_update"
    case weeklyChallenge = "weekly_challenge"
}

enum NotificationCategory: String {
    case studyReminder = "STUDY_REMINDER"
    case motivation = "MOTIVATION"
    case achievement = "ACHIEVEMENT"
    case parentUpdate = "PARENT_UPDATE"
    case weeklyChallenge = "WEEKLY_CHALLENGE"
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToLearning = Notification.Name("navigateToLearning")
    static let navigateToAchievements = Notification.Name("navigateToAchievements")
    static let navigateToParentDashboard = Notification.Name("navigateToParentDashboard")
    static let notificationTapped = Notification.Name("notificationTapped")
}

// MARK: - Remote Notification Handling
extension NotificationService {
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        print("📱 Received remote notification: \(userInfo)")
        
        // Extract notification type and data
        if let type = userInfo["type"] as? String {
            switch type {
            case "level_update":
                handleLevelUpdateNotification(userInfo)
            case "friend_challenge":
                handleFriendChallengeNotification(userInfo)
            case "new_content":
                handleNewContentNotification(userInfo)
            default:
                print("🤷‍♂️ Unknown remote notification type: \(type)")
            }
        }
    }
    
    private func handleLevelUpdateNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle level update from server
        print("📈 Level update notification received")
    }
    
    private func handleFriendChallengeNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle friend challenge notification
        print("👫 Friend challenge notification received")
    }
    
    private func handleNewContentNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle new content notification
        print("🆕 New content notification received")
    }
}

// MARK: - Notification Analytics
extension NotificationService {
    func trackNotificationEngagement(_ notification: UNNotification, action: String) {
        let analytics: [String: Any] = [
            "notification_id": notification.request.identifier,
            "category": notification.request.content.categoryIdentifier,
            "action": action,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send to analytics service
        print("📊 Notification engagement tracked: \(analytics)")
    }
}