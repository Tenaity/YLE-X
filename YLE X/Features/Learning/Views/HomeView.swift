//
//  HomeView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var progressManager = UserProgressManager()
    @State private var showingProfile = false
    @State private var currentGreeting = ""
    @State private var showingCelebration = false
    
    let greetings = [
        "Chào bé! 🌟",
        "Hôm nay học gì nhỉ? 📚",
        "Sẵn sàng cho cuộc phiêu lưu? 🚀",
        "Bé có muốn học tiếng Anh không? 🎉"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: KidsSpacing.xl) {
                    // Header with greeting
                    headerSection
                    
                    // Daily streak and motivation
                    streakSection
                    
                    // Level selection
                    levelSelectionSection
                    
                    // Skills practice
                    skillsSection
                    
                    // Recent achievements
                    if !progressManager.recentBadges.isEmpty {
                        achievementsSection
                    }
                    
                    // Quick practice section
                    quickPracticeSection
                }
                .padding(.horizontal, KidsSpacing.lg)
                .padding(.bottom, KidsSpacing.xxxl)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.kidsBackground,
                        Color.blue.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.kidsPrimary)
                            Text("Xin chào, \(progressManager.childName)!")
                                .font(.kidsHeadline)
                                .foregroundColor(.kidsPrimaryText)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Show parent dashboard
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.kidsSecondary)
                    }
                }
            }
        }
        .onAppear {
            currentGreeting = greetings.randomElement() ?? greetings[0]
            checkForDailyRewards()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(progressManager: progressManager)
        }
        .overlay(
            celebrationOverlay
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: KidsSpacing.lg) {
            Text(currentGreeting)
                .font(.kidsDisplayLarge)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
            
            // Weather-based motivation or time-based greeting
            Text(getTimeBasedMessage())
                .font(.kidsBody)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        HStack(spacing: KidsSpacing.lg) {
            // Current streak
            VStack(spacing: KidsSpacing.xs) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(progressManager.currentStreak)")
                        .font(.kidsDisplayMedium)
                        .foregroundColor(.kidsPrimary)
                        .fontWeight(.bold)
                }
                Text("Ngày liên tiếp")
                    .font(.kidsCaption)
                    .foregroundColor(.kidsSecondaryText)
            }
            .padding(KidsSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                    )
            )
            
            // Points earned
            VStack(spacing: KidsSpacing.xs) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(progressManager.totalPoints)")
                        .font(.kidsDisplayMedium)
                        .foregroundColor(.kidsPrimary)
                        .fontWeight(.bold)
                }
                Text("Điểm tích lũy")
                    .font(.kidsCaption)
                    .foregroundColor(.kidsSecondaryText)
            }
            .padding(KidsSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Level Selection
    private var levelSelectionSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Chọn Level 🎯")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: KidsSpacing.lg) {
                    ForEach(YLELevel.allCases) { level in
                        LevelCard(
                            level: level,
                            isUnlocked: progressManager.isLevelUnlocked(level),
                            progress: progressManager.getLevelProgress(level)
                        ) {
                            // Navigate to level
                            navigateToLevel(level)
                        }
                    }
                }
                .padding(.horizontal, KidsSpacing.lg)
            }
            .padding(.horizontal, -KidsSpacing.lg)
        }
    }
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Kỹ năng luyện tập 🎨")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                Spacer()
                Button("Xem tất cả") {
                    // Show all skills
                }
                .font(.kidsCaption)
                .foregroundColor(.kidsSecondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: KidsSpacing.lg) {
                ForEach(Skill.allCases.prefix(4)) { skill in
                    SkillCard(
                        skill: skill,
                        progress: progressManager.getSkillProgress(skill),
                        isLocked: !progressManager.isSkillUnlocked(skill)
                    ) {
                        navigateToSkillPractice(skill)
                    }
                }
            }
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.lg) {
            HStack {
                Text("Thành tích mới 🏆")
                    .font(.kidsTitle)
                    .foregroundColor(.kidsPrimary)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: KidsSpacing.lg) {
                    ForEach(progressManager.recentBadges) { badge in
                        AchievementBadge(badge: badge)
                    }
                }
                .padding(.horizontal, KidsSpacing.lg)
            }
            .padding(.horizontal, -KidsSpacing.lg)
        }
    }
    
    // MARK: - Quick Practice Section
    private var quickPracticeSection: some View {
        VStack(spacing: KidsSpacing.lg) {
            Text("Luyện tập nhanh ⚡")
                .font(.kidsTitle)
                .foregroundColor(.kidsPrimary)
            
            VStack(spacing: KidsSpacing.md) {
                KidsButton(
                    title: "5 phút từ vựng",
                    emoji: "📚",
                    color: .vocabularyPink
                ) {
                    startQuickPractice(.vocabulary)
                }
                
                KidsButton(
                    title: "Nghe nhanh",
                    emoji: "👂",
                    color: .listeningBlue
                ) {
                    startQuickPractice(.listening)
                }
                
                KidsButton(
                    title: "Thử thách hàng ngày",
                    emoji: "🎯",
                    color: .kidsPrimary
                ) {
                    startDailyChallenge()
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
    
    // MARK: - Celebration Overlay
    private var celebrationOverlay: some View {
        Group {
            if showingCelebration {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: KidsSpacing.xl) {
                        Text("🎉")
                            .font(.system(size: 64))
                        
                        Text("Chúc mừng!")
                            .font(.kidsDisplayLarge)
                            .foregroundColor(.white)
                        
                        Text("Bé đã hoàn thành mục tiêu hôm nay!")
                            .font(.kidsBody)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        KidsButton(
                            title: "Tiếp tục",
                            emoji: "🚀",
                            color: .kidsSuccess
                        ) {
                            withAnimation(.kidsGentle) {
                                showingCelebration = false
                            }
                        }
                    }
                    .padding(KidsSpacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                            .fill(.ultraThinMaterial)
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getTimeBasedMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Buổi sáng tốt lành! Hãy bắt đầu ngày mới với tiếng Anh 🌅"
        case 12..<17: return "Buổi chiều vui vẻ! Cùng học thêm một chút nhé 🌞"
        case 17..<21: return "Buổi tối thư giãn! Ôn tập kiến thức đã học 🌙"
        default: return "Giờ nghỉ ngơi! Ngủ ngon và hẹn gặp lại ngày mai 😴"
        }
    }
    
    private func checkForDailyRewards() {
        // Check if user completed daily goals
        if progressManager.hasCompletedDailyGoal() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.kidsPlayful) {
                    showingCelebration = true
                }
                HapticManager.shared.playSuccess()
                SoundManager.shared.playSound(.celebration)
            }
        }
    }
    
    private func navigateToLevel(_ level: YLELevel) {
        // Implementation for level navigation
        print("Navigating to level: \(level.title)")
    }
    
    private func navigateToSkillPractice(_ skill: Skill) {
        // Implementation for skill practice navigation
        print("Starting skill practice: \(skill.title)")
    }
    
    private func startQuickPractice(_ skill: Skill) {
        // Implementation for quick practice
        print("Starting quick practice: \(skill.title)")
    }
    
    private func startDailyChallenge() {
        // Implementation for daily challenge
        print("Starting daily challenge")
    }
}

// MARK: - User Progress Manager
class UserProgressManager: ObservableObject {
    @Published var totalPoints: Int = 1250
    @Published var currentStreak: Int = 7
    @Published var childName: String = "Bảo An"
    @Published var currentLevel: YLELevel = .movers
    @Published var recentBadges: [Badge] = []
    
    // Sample data for demonstration
    private let skillProgress: [Skill: Double] = [
        .listening: 0.75,
        .speaking: 0.60,
        .reading: 0.85,
        .writing: 0.45,
        .vocabulary: 0.90,
        .grammar: 0.55
    ]
    
    private let levelProgress: [YLELevel: Double] = [
        .starters: 1.0,
        .movers: 0.65,
        .flyers: 0.0
    ]
    
    init() {
        loadRecentBadges()
    }
    
    func isLevelUnlocked(_ level: YLELevel) -> Bool {
        switch level {
        case .starters: return true
        case .movers: return levelProgress[.starters] ?? 0 >= 0.8
        case .flyers: return levelProgress[.movers] ?? 0 >= 0.8
        }
    }
    
    func getLevelProgress(_ level: YLELevel) -> Double {
        return levelProgress[level] ?? 0.0
    }
    
    func isSkillUnlocked(_ skill: Skill) -> Bool {
        // All basic skills are unlocked, but could add logic here
        return true
    }
    
    func getSkillProgress(_ skill: Skill) -> Double {
        return skillProgress[skill] ?? 0.0
    }
    
    func hasCompletedDailyGoal() -> Bool {
        // Mock implementation - check if daily goals are completed
        return currentStreak > 5
    }
    
    private func loadRecentBadges() {
        recentBadges = [
            Badge(
                id: "first_week",
                name: "Tuần đầu",
                description: "Học liên tiếp 7 ngày",
                emoji: "🔥",
                color: "orange",
                earnedDate: Date(),
                rarity: .common
            ),
            Badge(
                id: "vocabulary_master",
                name: "Bậc thầy từ vựng",
                description: "Học 100 từ mới",
                emoji: "📚",
                color: "blue",
                earnedDate: Date().addingTimeInterval(-86400),
                rarity: .rare
            )
        ]
    }
}

#Preview {
    HomeView()
}