//
//  LessonListView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import FirebaseAuth

struct LessonListView: View {
    @StateObject private var lessonService = LessonService.shared
    @State private var selectedLevel: YLELevel = .starters
    @State private var animateLessons = false
    @State private var selectedLesson: Lesson?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Error Message (if any)
                    if let error = errorMessage {
                        VStack(spacing: AppSpacing.sm) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.appError)
                                Text(error)
                                    .foregroundColor(.appError)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(Color.appError.opacity(0.1))
                            )
                        }
                    }

                    // Level Selector
                    levelSelector

                    // Progress Stats
                    progressStatsCard
                        .opacity(animateLessons ? 1 : 0)
                        .offset(y: animateLessons ? 0 : 20)

                    // Lesson Map
                    if lessonService.lessons.isEmpty && errorMessage != nil {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.appTextSecondary)
                            Text("No Lessons Found")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appText)
                            Text("Make sure lessons are added to Firebase for \(selectedLevel.title)")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.xl)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    } else {
                        lessonsSection
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xl)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        selectedLevel.primaryColor.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedLesson) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .task {
                do {
                    print("[LessonListView] Fetching lessons for level: \(selectedLevel.rawValue.lowercased())")
                    try await lessonService.fetchLessons(for: selectedLevel)
                    print("[LessonListView] Lessons fetched: \(lessonService.lessons.count)")

                    // Ensure user is authenticated before fetching user progress
                    if Auth.auth().currentUser == nil {
                        print("[LessonListView] No user signed in. Signing in anonymously...")
                        do {
                            _ = try await Auth.auth().signInAnonymously()
                            print("[LessonListView] Anonymous sign-in successful")
                        } catch {
                            print("[LessonListView] Anonymous sign-in failed: \(error)")
                        }
                    }

                    do {
                        try await lessonService.fetchUserProgress()
                        print("[LessonListView] User progress fetched: \(lessonService.userProgress.count)")
                    } catch {
                        print("[LessonListView] fetchUserProgress error: \(error)")
                    }

                    lessonService.startListeningToProgress()
                    print("[LessonListView] Started listening to progress")

                    // Clear error if lessons loaded successfully
                    if !lessonService.lessons.isEmpty {
                        errorMessage = nil
                    }

                    withAnimation(.appBouncy.delay(0.2)) {
                        animateLessons = true
                    }
                } catch {
                    let errorMsg = "Failed to load lessons: \(error.localizedDescription)"
                    print("[LessonListView] Error loading lessons: \(errorMsg)")
                    errorMessage = errorMsg
                }
            }
        }
    }

    // MARK: - Level Selector
    private var levelSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                ForEach(YLELevel.allCases, id: \.self) { level in
                    LevelSelectorButton(
                        level: level,
                        isSelected: selectedLevel == level,
                        action: {
                            withAnimation(.appBouncy) {
                                HapticManager.shared.playMedium()
                                selectedLevel = level
                                animateLessons = false
                                errorMessage = nil
                                Task {
                                    do {
                                        try await lessonService.fetchLessons(for: level)
                                        if !lessonService.lessons.isEmpty {
                                            errorMessage = nil
                                        }
                                    } catch {
                                        errorMessage = "Failed to load lessons for \(level.title)"
                                    }
                                    withAnimation(.appBouncy.delay(0.1)) {
                                        animateLessons = true
                                    }
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Progress Stats Card
    private var progressStatsCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // Completed Lessons
            StatBubble(
                icon: "checkmark.circle.fill",
                value: "\(completedLessonsCount)",
                label: "Completed",
                color: .appSuccess
            )

            Divider()
                .frame(height: 40)

            // Total XP
            StatBubble(
                icon: "star.fill",
                value: "\(totalXPEarned)",
                label: "XP Earned",
                color: .appAccent
            )

            Divider()
                .frame(height: 40)

            // Average Stars
            StatBubble(
                icon: "star.circle.fill",
                value: String(format: "%.1f", averageStars),
                label: "Avg Stars",
                color: .appBadgeGold
            )
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - Lessons Section
    private var lessonsSection: some View {
        LazyVStack(spacing: AppSpacing.lg) {
            ForEach(Array(lessonService.lessons.enumerated()), id: \.element.id) { index, lesson in
                LessonCard(
                    lesson: lesson,
                    isLocked: shouldLockLesson(lesson),
                    progress: lessonService.getProgress(for: lesson.id ?? ""),
                    action: {
                        HapticManager.shared.playLight()
                        selectedLesson = lesson
                    }
                )
                .opacity(animateLessons ? 1 : 0)
                .offset(x: animateLessons ? 0 : -50)
                .animation(.appBouncy.delay(Double(index) * 0.1), value: animateLessons)

                // Connecting Path
                if index < lessonService.lessons.count - 1 {
                    ConnectingPath(isCompleted: lessonService.isLessonCompleted(lesson.id ?? ""))
                        .opacity(animateLessons ? 1 : 0)
                        .animation(.appBouncy.delay(Double(index) * 0.1 + 0.05), value: animateLessons)
                }
            }
        }
    }

    // MARK: - Helper Methods
    private var completedLessonsCount: Int {
        lessonService.userProgress.values.filter { $0.completed }.count
    }

    private var totalXPEarned: Int {
        lessonService.lessons
            .filter { lessonService.isLessonCompleted($0.id ?? "") }
            .reduce(0) { $0 + $1.xpReward }
    }

    private var averageStars: Double {
        let completedProgress = lessonService.userProgress.values.filter { $0.completed }
        guard !completedProgress.isEmpty else { return 0 }
        let totalStars = completedProgress.reduce(0) { $0 + $1.stars }
        return Double(totalStars) / Double(completedProgress.count)
    }

    private func shouldLockLesson(_ lesson: Lesson) -> Bool {
        // First lesson is always unlocked
        guard lesson.order > 1 else { return false }

        // Check if previous lesson is completed
        let previousLesson = lessonService.lessons.first { $0.order == lesson.order - 1 }
        guard let prevId = previousLesson?.id else { return lesson.isLocked }

        return !lessonService.isLessonCompleted(prevId) || lesson.isLocked
    }
}

// MARK: - Level Selector Button
struct LevelSelectorButton: View {
    let level: YLELevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Text(level.emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? .white : .appText)

                    Text(level.ageRange)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .appTextSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.full)
                    .fill(isSelected ? level.primaryColor : Color(UIColor.secondarySystemBackground))
                    .appShadow(level: isSelected ? .medium : .light)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

// MARK: - Stat Bubble
struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let lesson: Lesson
    let isLocked: Bool
    let progress: UserLessonProgress?
    let action: () -> Void

    private var stars: Int {
        progress?.stars ?? 0
    }

    private var isCompleted: Bool {
        progress?.completed ?? false
    }

    var body: some View {
        Button(action: isLocked ? {} : action) {
            HStack(spacing: AppSpacing.md) {
                // Emoji Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    (lesson.ylelevel?.primaryColor ?? .appPrimary),
                                    (lesson.ylelevel?.primaryColor ?? .appPrimary).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .appShadow(level: .medium)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        Text(lesson.thumbnailEmoji)
                            .font(.system(size: 32))
                    }
                }

                // Lesson Info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(lesson.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appText)

                    Text(lesson.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)

                    // Meta Info
                    HStack(spacing: AppSpacing.sm) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                        Label("\(lesson.totalExercises) ex", systemImage: "list.bullet")
                        Label("+\(lesson.xpReward) XP", systemImage: "star")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                }

                Spacer()

                // Status Indicator
                VStack(spacing: AppSpacing.xs) {
                    if isCompleted {
                        // Stars
                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < stars ? "star.fill" : "star")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(index < stars ? .appAccent : .appTextSecondary)
                            }
                        }
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(lesson.ylelevel?.primaryColor ?? .appPrimary)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .appShadow(level: isLocked ? .subtle : .light)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(
                        isCompleted ? Color.appSuccess : Color.clear,
                        lineWidth: isCompleted ? 2 : 0
                    )
            )
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
    }
}

// MARK: - Connecting Path
struct ConnectingPath: View {
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { _ in
                Circle()
                    .fill(isCompleted ? Color.appSuccess : Color.appTextSecondary.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .padding(.vertical, 2)
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    LessonListView()
}
