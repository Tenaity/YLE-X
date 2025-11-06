//
//  ParentDashboardView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import Charts

// MARK: - Parent Dashboard
struct ParentDashboardView: View {
    @StateObject private var dashboardManager = ParentDashboardManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingDetailedReport = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: KidsSpacing.xl) {
                    // Header with child info
                    childInfoHeader
                    
                    // Quick stats cards
                    quickStatsSection
                    
                    // Learning progress chart
                    learningProgressSection
                    
                    // Skill breakdown
                    skillBreakdownSection
                    
                    // Recent activities
                    recentActivitiesSection
                    
                    // Achievements and badges
                    achievementsSection
                    
                    // Recommendations for parents
                    recommendationsSection
                }
                .padding(KidsSpacing.lg)
            }
            .background(Color.kidsBackground.ignoresSafeArea())
            .navigationTitle("Bảng điều khiển phụ huynh")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Báo cáo chi tiết") {
                            showingDetailedReport = true
                        }
                        
                        Button("Cài đặt") {
                            showingSettings = true
                        }
                        
                        Button("Xuất báo cáo") {
                            dashboardManager.exportReport()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            dashboardManager.loadData()
        }
        .sheet(isPresented: $showingDetailedReport) {
            DetailedReportView(manager: dashboardManager)
        }
        .sheet(isPresented: $showingSettings) {
            ParentSettingsView()
        }
    }
    
    // MARK: - Child Info Header
    private var childInfoHeader: some View {
        VStack(spacing: KidsSpacing.lg) {
            HStack {
                // Child avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [.kidsPrimary, .kidsSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(dashboardManager.childName.prefix(1)).uppercased())
                            .font(.kidsDisplayMedium)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dashboardManager.childName)
                        .font(.kidsTitle)
                        .foregroundColor(.kidsPrimary)
                    
                    Text("Level: \(dashboardManager.currentLevel.title)")
                        .font(.kidsBody)
                        .foregroundColor(.kidsSecondaryText)
                    
                    Text("Tham gia: \(dashboardManager.joinDate, formatter: dashboardManager.dateFormatter)")
                        .font(.kidsCaption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Current streak
                VStack {
                    Text("\(dashboardManager.currentStreak)")
                        .font(.kidsDisplayMedium)
                        .foregroundColor(.orange)
                    Text("ngày liên tiếp")
                        .font(.kidsCaption)
                        .foregroundColor(.gray)
                    Text("🔥")
                        .font(.kidsBody)
                }
            }
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .medium)
        )
    }
    
    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: KidsSpacing.md) {
            StatCard(
                title: "Thời gian học",
                value: "\(Int(dashboardManager.totalStudyTime)) phút",
                subtitle: "Tuần này",
                color: .moversBlue,
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Bài tập hoàn thành",
                value: "\(dashboardManager.completedExercises)",
                subtitle: "Tuần này",
                color: .startersGreen,
                icon: "checkmark.circle.fill"
            )
            
            StatCard(
                title: "Độ chính xác",
                value: "\(Int(dashboardManager.averageAccuracy * 100))%",
                subtitle: "Trung bình",
                color: .vocabularyPink,
                icon: "target"
            )
            
            StatCard(
                title: "Huy hiệu",
                value: "\(dashboardManager.totalBadges)",
                subtitle: "Đã đạt được",
                color: .flyersPurple,
                icon: "star.fill"
            )
        }
    }
    
    // MARK: - Learning Progress Chart
    private var learningProgressSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Tiến độ học tập 📈")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                
                Spacer()
                
                Picker("Thời gian", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Learning time chart
            Chart(dashboardManager.learningData) { data in
                BarMark(
                    x: .value("Ngày", data.date),
                    y: .value("Phút", data.minutes)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.moversBlue, .moversBlue.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
        .onChange(of: selectedTimeRange) { range in
            dashboardManager.updateDataForRange(range)
        }
    }
    
    // MARK: - Skill Breakdown
    private var skillBreakdownSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            Text("Phát triển kỹ năng 🎯")
                .font(.kidsTitle)
                .foregroundColor(.kidsPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: KidsSpacing.md) {
                ForEach(Skill.allCases) { skill in
                    SkillProgressCard(
                        skill: skill,
                        progress: dashboardManager.skillProgress[skill] ?? 0,
                        weeklyImprovement: dashboardManager.weeklyImprovement[skill] ?? 0
                    )
                }
            }
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
    
    // MARK: - Recent Activities
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Hoạt động gần đây 📝")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                
                Spacer()
                
                Button("Xem tất cả") {
                    showingDetailedReport = true
                }
                .font(.kidsCaption)
                .foregroundColor(.kidsSecondary)
            }
            
            LazyVStack(spacing: KidsSpacing.md) {
                ForEach(dashboardManager.recentActivities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
    
    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Thành tích nổi bật 🏆")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                
                Spacer()
                
                Text("\(dashboardManager.totalBadges) huy hiệu")
                    .font(.kidsCaption)
                    .foregroundColor(.kidsSecondaryText)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: KidsSpacing.lg) {
                    ForEach(dashboardManager.recentBadges) { badge in
                        ParentBadgeView(badge: badge)
                    }
                }
                .padding(.horizontal, KidsSpacing.lg)
            }
            .padding(.horizontal, -KidsSpacing.lg)
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
    
    // MARK: - Recommendations
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            Text("Gợi ý cho phụ huynh 💡")
                .font(.kidsTitle)
                .foregroundColor(.kidsPrimary)
            
            LazyVStack(spacing: KidsSpacing.md) {
                ForEach(dashboardManager.recommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding(KidsSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
}

// MARK: - Supporting Views

// Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: KidsSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.kidsDisplayMedium)
                    .foregroundColor(.kidsPrimary)
                
                Text(title)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
                
                Text(subtitle)
                    .font(.kidsCaption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Skill Progress Card
struct SkillProgressCard: View {
    let skill: Skill
    let progress: Double
    let weeklyImprovement: Double
    
    var body: some View {
        VStack(spacing: KidsSpacing.sm) {
            HStack {
                Image(systemName: skill.icon)
                    .foregroundColor(skill.color)
                Text(skill.emoji)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(skill.vietnameseTitle)
                        .font(.kidsHeadline)
                        .foregroundColor(.kidsPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(KidsProgressViewStyle(color: skill.color))
                    .frame(height: 6)
                
                if weeklyImprovement > 0 {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.kidsSuccess)
                            .font(.caption)
                        
                        Text("+\(Int(weeklyImprovement * 100))% tuần này")
                            .font(.kidsCaption)
                            .foregroundColor(.kidsSuccess)
                    }
                }
            }
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(skill.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(skill.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Activity Row
struct ActivityRow: View {
    let activity: LearningActivity
    
    var body: some View {
        HStack(spacing: KidsSpacing.md) {
            // Activity icon
            Circle()
                .fill(activity.skill.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: activity.skill.icon)
                        .foregroundColor(activity.skill.color)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.kidsBody)
                    .foregroundColor(.kidsPrimary)
                
                Text(activity.description)
                    .font(.kidsCaption)
                    .foregroundColor(.kidsSecondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(activity.date, style: .time)
                    .font(.kidsCaption)
                    .foregroundColor(.gray)
                
                if activity.pointsEarned > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(activity.pointsEarned)")
                            .font(.kidsCaption)
                            .foregroundColor(.kidsSecondaryText)
                    }
                }
            }
        }
        .padding(.vertical, KidsSpacing.sm)
    }
}

// Parent Badge View
struct ParentBadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: KidsSpacing.xs) {
            ZStack {
                Circle()
                    .fill(Color(badge.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(badge.emoji)
                    .font(.system(size: 24))
            }
            
            Text(badge.name)
                .font(.kidsCaption)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
            
            Text(badge.earnedDate, style: .date)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
}

// Recommendation Card
struct RecommendationCard: View {
    let recommendation: ParentRecommendation
    
    var body: some View {
        HStack(spacing: KidsSpacing.md) {
            Text(recommendation.type.emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.kidsHeadline)
                    .foregroundColor(.kidsPrimary)
                
                Text(recommendation.description)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(recommendation.type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(recommendation.type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Supporting Models and Enums

enum TimeRange: CaseIterable, Identifiable {
    case week, month, quarter
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .week: return "Tuần"
        case .month: return "Tháng"
        case .quarter: return "Quý"
        }
    }
}

struct LearningData: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Double
}

struct LearningActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let skill: Skill
    let date: Date
    let pointsEarned: Int
    let accuracy: Double
}

struct ParentRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
}

enum RecommendationType {
    case encouragement, skillFocus, timeManagement, parentTips
    
    var emoji: String {
        switch self {
        case .encouragement: return "🌟"
        case .skillFocus: return "🎯"
        case .timeManagement: return "⏰"
        case .parentTips: return "💡"
        }
    }
    
    var color: Color {
        switch self {
        case .encouragement: return .kidsSuccess
        case .skillFocus: return .kidsPrimary
        case .timeManagement: return .kidsSecondary
        case .parentTips: return .vocabularyPink
        }
    }
}

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
        skillProgress = [
            .listening: 0.75,
            .speaking: 0.60,
            .reading: 0.85,
            .writing: 0.45,
            .vocabulary: 0.90,
            .grammar: 0.55
        ]
        
        weeklyImprovement = [
            .listening: 0.15,
            .speaking: 0.20,
            .reading: 0.05,
            .writing: 0.25,
            .vocabulary: 0.10,
            .grammar: 0.18
        ]
    }
    
    private func loadLearningData() {
        let calendar = Calendar.current
        learningData = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let minutes = Double.random(in: 5...35)
            learningData.append(LearningData(date: date, minutes: minutes))
        }
        
        learningData = learningData.reversed()
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
        recentBadges = [
            Badge(id: "vocab_master", name: "Bậc thầy từ vựng", description: "Học 100 từ mới", emoji: "📚", color: "blue", earnedDate: Date().addingTimeInterval(-86400), rarity: .rare),
            Badge(id: "daily_streak", name: "Siêu kiên trì", description: "7 ngày liên tiếp", emoji: "🔥", color: "orange", earnedDate: Date().addingTimeInterval(-2 * 86400), rarity: .common),
            Badge(id: "accuracy_king", name: "Vua chính xác", description: "90% chính xác", emoji: "🎯", color: "green", earnedDate: Date().addingTimeInterval(-3 * 86400), rarity: .epic)
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
        loadLearningData()
    }
    
    func exportReport() {
        // Implementation for exporting detailed PDF report
        print("📄 Exporting detailed report...")
    }
}

// MARK: - Additional Views

struct DetailedReportView: View {
    let manager: ParentDashboardManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Báo cáo chi tiết")
                    .font(.kidsTitle)
                Text("Tính năng đang phát triển...")
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
            }
            .navigationTitle("Báo cáo chi tiết")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

struct ParentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Cài đặt phụ huynh")
                    .font(.kidsTitle)
                Text("Tính năng đang phát triển...")
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ParentDashboardView()
}