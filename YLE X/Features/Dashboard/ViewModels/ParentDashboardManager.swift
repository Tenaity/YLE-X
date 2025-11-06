//
//  ParentDashboardManager.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import Combine
import SwiftUI 

// MARK: - Dashboard Manager
class ParentDashboardManager: ObservableObject {
    @Published var childName = "Bảo An"
    @Published var currentLevel: YLELevel = .movers
    @Published var joinDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
    @Published var currentStreak = 7
    @Published var totalStudyTime: Double = 150 // minutes this week
    @Published var completedExercises = 25
    @Published var averageAccuracy = 0.85
    @Published var totalBadges = 12
    @Published var skillProgress: [Skill: Double] = [:]
    @Published var weeklyImprovement: [Skill: Double] = [:]
    @Published var learningData: [LearningData] = []
    @Published var recentActivities: [LearningActivity] = []
    @Published var recentBadges: [Badge] = []
    @Published var recommendations: [ParentRecommendation] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    func loadData() {
        loadSkillProgress()
        loadLearningData()
        loadRecentActivities()
        loadRecentBadges()
        generateRecommendations()
    }
    
    private func loadSkillProgress() {
        var progress: [Skill: Double] = [:]
        var improvement: [Skill: Double] = [:]
        
        for skill in Skill.allCases {
            progress[skill] = Double.random(in: 0.4...0.9)
            improvement[skill] = Double.random(in: 0.05...0.25)
        }
        
        self.skillProgress = progress
        self.weeklyImprovement = improvement
    }
    
    private func loadLearningData() {
        let calendar = Calendar.current
        var data: [LearningData] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let minutes = Double.random(in: 5...35)
            data.append(LearningData(date: date, minutes: minutes))
        }
        
        self.learningData = data.reversed()
    }
    
    private func loadRecentActivities() {
        recentActivities = [
            LearningActivity(
                title: "Hoàn thành bài tập từ vựng",
                description: "Học 10 từ mới về động vật",
                skill: .vocabulary,
                date: Date().addingTimeInterval(-3600),
                pointsEarned: 50,
                accuracy: 0.90
            ),
            LearningActivity(
                title: "Luyện phát âm",
                description: "Phát âm 5 từ với độ chính xác cao",
                skill: .speaking,
                date: Date().addingTimeInterval(-7200),
                pointsEarned: 30,
                accuracy: 0.85
            ),
            LearningActivity(
                title: "Đọc truyện ngắn",
                description: "Đọc và trả lời câu hỏi về truyện",
                skill: .reading,
                date: Date().addingTimeInterval(-10800),
                pointsEarned: 40,
                accuracy: 0.80
            )
        ]
    }
    
    private func loadRecentBadges() {
        // SỬA LỖI: Cập nhật Badge model để khớp với dữ liệu này
        recentBadges = [
            Badge(id: "vocab_master", name: "Bậc thầy từ vựng", description: "Học 100 từ mới", emoji: "📚", colorName: "moversBlue", earnedDate: Date().addingTimeInterval(-86400)),
            Badge(id: "daily_streak", name: "Siêu kiên trì", description: "7 ngày liên tiếp", emoji: "🔥", colorName: "kidsSecondary", earnedDate: Date().addingTimeInterval(-2 * 86400)),
            Badge(id: "accuracy_king", name: "Vua chính xác", description: "90% chính xác", emoji: "🎯", colorName: "startersGreen", earnedDate: Date().addingTimeInterval(-3 * 86400))
        ]
    }
    
    private func generateRecommendations() {
        recommendations = [
            ParentRecommendation(
                type: .encouragement,
                title: "Bé học rất tốt!",
                description: "Bé đã duy trì streak 7 ngày liên tiếp. Hãy tiếp tục khuyến khích bé!"
            ),
            ParentRecommendation(
                type: .skillFocus,
                title: "Tập trung vào Writing",
                description: "Kỹ năng viết của bé còn cần cải thiện. Hãy dành thêm thời gian cho bài tập viết."
            ),
            ParentRecommendation(
                type: .timeManagement,
                title: "Thời gian học lý tưởng",
                description: "15-20 phút mỗi ngày là thời gian phù hợp cho trẻ ở độ tuổi này."
            ),
            ParentRecommendation(
                type: .parentTips,
                title: "Học cùng con",
                description: "Hãy thỉnh thoảng ngồi học cùng bé để tăng động lực cho con."
            )
        ]
    }
    
    func updateDataForRange(_ range: TimeRange) {
        // Update learning data based on selected time range
        // Implementation would fetch different data sets
        print("Updating data for range: \(range.title)")
        loadLearningData()
    }
    
    func exportReport() {
        // Implementation for exporting detailed PDF report
        print("📄 Exporting detailed report...")
    }
}
