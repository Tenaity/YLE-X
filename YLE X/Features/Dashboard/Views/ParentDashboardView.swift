//
//  ParentDashboardView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
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
                VStack(spacing: AppSpacing.xl) { // <-- OK
                    childInfoHeader
                    quickStatsSection
                    learningProgressSection
                    skillBreakdownSection
                    recentActivitiesSection
                    achievementsSection
                    recommendationsSection
                }
                .padding(AppSpacing.lg) // <-- OK
            }
            .background(Color.appBackground.ignoresSafeArea()) // <-- OK
            .navigationTitle("Bảng điều khiển phụ huynh")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Đóng") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    optionsMenu
                }
            }
        }
        .onAppear {
            dashboardManager.loadData()
        }
        .sheet(isPresented: $showingDetailedReport) {
            DetailedReportView() // Tách file
        }
        .sheet(isPresented: $showingSettings) {
            ParentSettingsView() // Tách file
        }
    }
    
    // MARK: - View Components
    
    private var optionsMenu: some View {
        Menu {
            Button("Báo cáo chi tiết") { showingDetailedReport = true }
            Button("Cài đặt") { showingSettings = true }
            Button("Xuất báo cáo") { dashboardManager.exportReport() }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private var childInfoHeader: some View {
        VStack(spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            HStack {
                Circle()
                    .fill(LinearGradient(
                        // SỬA: Dùng màu sắc rực rỡ từ AppColors
                        colors: [.moversBlue, .startersGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(dashboardManager.childName.prefix(1)).uppercased())
                            .font(.appDisplayMedium) // SỬA: .appDisplayMedium
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dashboardManager.childName)
                        .font(.appTitle) // SỬA: .kidsTitle
                        .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
                    
                    Text("Level: \(dashboardManager.currentLevel.rawValue)")
                        .font(.appBody) // SỬA: .kidsBody
                        .foregroundColor(.appSecondaryText) // SỬA: .kidsSecondaryText
                    
                    Text("Tham gia: \(dashboardManager.joinDate, formatter: dashboardManager.dateFormatter)")
                        .font(.appCaption) // SỬA: .kidsCaption
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack {
                    Text("\(dashboardManager.currentStreak)")
                        .font(.appDisplayMedium) // SỬA: .kidsDisplayMedium
                        .foregroundColor(.orange)
                    Text("ngày liên tiếp")
                        .font(.appCaption) // SỬA: .kidsCaption
                        .foregroundColor(.gray)
                    Text("🔥")
                        .font(.appBody) // SỬA: .kidsBody
                }
            }
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .medium) // SỬA: .kidsShadow
        )
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) { // SỬA: KidsSpacing.md
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
    
    private var learningProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            HStack {
                Text("Tiến độ học tập 📈")
                    .font(.appTitle) // SỬA: .kidsTitle
                    .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
                
                Spacer()
                
                Picker("Thời gian", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            Chart(dashboardManager.learningData) { data in
                BarMark(
                    x: .value("Ngày", data.date, unit: .day),
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
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .light) // SỬA: .kidsShadow
        )
        .onChange(of: selectedTimeRange) {
            dashboardManager.updateDataForRange(selectedTimeRange)
        }
    }
    
    private var skillBreakdownSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            Text("Phát triển kỹ năng 🎯")
                .font(.appTitle) // SỬA: .kidsTitle
                .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) { // SỬA: KidsSpacing.md
                ForEach(Skill.allCases) { skill in
                    SkillProgressCard(
                        skill: skill,
                        progress: dashboardManager.skillProgress[skill] ?? 0,
                        weeklyImprovement: dashboardManager.weeklyImprovement[skill] ?? 0
                    )
                }
            }
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .light) // SỬA: .kidsShadow
        )
    }
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            HStack {
                Text("Hoạt động gần đây 📝")
                    .font(.appTitle) // SỬA: .kidsTitle
                    .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
                
                Spacer()
                
                Button("Xem tất cả") {
                    showingDetailedReport = true
                }
                .font(.appCaption) // SỬA: .kidsCaption
                .foregroundColor(.appSecondaryText) // SỬA: .kidsSecondary
            }
            
            LazyVStack(spacing: AppSpacing.md) { // SỬA: KidsSpacing.md
                ForEach(dashboardManager.recentActivities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .light) // SỬA: .kidsShadow
        )
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            HStack {
                Text("Thành tích nổi bật 🏆")
                    .font(.appTitle) // SỬA: .kidsTitle
                    .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
                
                Spacer()
                
                Text("\(dashboardManager.totalBadges) huy hiệu")
                    .font(.appCaption) // SỬA: .kidsCaption
                    .foregroundColor(.appSecondaryText) // SỬA: .kidsSecondaryText
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
                    ForEach(dashboardManager.recentBadges) { badge in
                        ParentBadgeView(badge: badge)
                    }
                }
                .padding(.horizontal, AppSpacing.lg) // SỬA: KidsSpacing.lg
            }
            .padding(.horizontal, -AppSpacing.lg) // SỬA: KidsSpacing.lg
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .light) // SỬA: .kidsShadow
        )
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) { // SỬA: KidsSpacing.lg
            Text("Gợi ý cho phụ huynh 💡")
                .font(.appTitle) // SỬA: .kidsTitle
                .foregroundColor(.appPrimaryText) // SỬA: .kidsPrimary
            
            LazyVStack(spacing: AppSpacing.md) { // SỬA: KidsSpacing.md
                ForEach(dashboardManager.recommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding(AppSpacing.xl) // SỬA: KidsSpacing.xl
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA: KidsRadius.xlarge
                .fill(Color.appCardBackground) // SỬA: Color.white
                .appShadow(level: .light) // SỬA: .kidsShadow
        )
    }
}
