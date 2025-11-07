//
//  LessonDetailView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(\.dismiss) var dismiss
    @StateObject private var lessonService = LessonService.shared
    @State private var animateContent = false
    @State private var startLesson = false

    private var progress: UserLessonProgress? {
        lessonService.getProgress(for: lesson.id ?? "")
    }

    private var isCompleted: Bool {
        progress?.completed ?? false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        lesson.ylelevel?.primaryColor.opacity(0.1) ?? Color.appPrimary.opacity(0.1),
                        Color.appBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.xl) {
                        // Hero Section
                        heroSection

                        // Lesson Info Cards
                        infoCardsSection

                        // What You'll Learn
                        whatYouLearnSection

                        // Previous Attempts (if any)
                        if let progress = progress {
                            previousAttemptsSection(progress: progress)
                        }

                        // Start Button
                        startButton
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }
            }
            .navigationTitle("Lesson Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $startLesson) {
                NavigationStack {
                    ExerciseView(lesson: lesson)
                }
            }
            .task {
                withAnimation(.appBouncy.delay(0.2)) {
                    animateContent = true
                }
            }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Emoji
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                lesson.ylelevel?.primaryColor ?? .appPrimary,
                                lesson.ylelevel?.primaryColor.opacity(0.7) ?? .appPrimary.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .appShadow(level: .heavy)

                Text(lesson.thumbnailEmoji)
                    .font(.system(size: 70))
            }
            .scaleEffect(animateContent ? 1 : 0.5)
            .opacity(animateContent ? 1 : 0)

            // Title
            VStack(spacing: AppSpacing.sm) {
                Text(lesson.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)

                Text(lesson.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)

            // Level Badge
            HStack(spacing: AppSpacing.sm) {
                Text(lesson.ylelevel?.emoji ?? "📚")
                    .font(.system(size: 16))

                Text(lesson.ylelevel?.title ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Text("•")
                    .foregroundColor(.white.opacity(0.6))

                Text(lesson.skillType?.rawValue.capitalized ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(lesson.ylelevel?.primaryColor ?? .appPrimary)
                    .appShadow(level: .medium)
            )
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
        }
    }

    // MARK: - Info Cards Section
    private var infoCardsSection: some View {
        HStack(spacing: AppSpacing.md) {
            InfoCard(
                icon: "clock.fill",
                title: "Duration",
                value: "\(lesson.estimatedMinutes) min",
                color: .appInfo
            )

            InfoCard(
                icon: "list.bullet",
                title: "Exercises",
                value: "\(lesson.totalExercises)",
                color: .appSecondary
            )

            InfoCard(
                icon: "star.fill",
                title: "XP Reward",
                value: "+\(lesson.xpReward)",
                color: .appAccent
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }

    // MARK: - What You'll Learn
    private var whatYouLearnSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("What You'll Learn")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                LearningPoint(text: "Complete \(lesson.totalExercises) interactive exercises")
                LearningPoint(text: "Practice \(lesson.skillType?.rawValue ?? "English") skills")
                LearningPoint(text: "Earn up to \(lesson.xpReward + 30) XP points")
                LearningPoint(text: "Get instant feedback on your answers")
                LearningPoint(text: "Track your progress with star ratings")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }

    // MARK: - Previous Attempts Section
    private func previousAttemptsSection(progress: UserLessonProgress) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your Best Result")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)

            HStack(spacing: AppSpacing.lg) {
                // Stars
                VStack(spacing: AppSpacing.xs) {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < progress.stars ? "star.fill" : "star")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(index < progress.stars ? .appAccent : .appTextSecondary)
                        }
                    }

                    Text("\(progress.stars) Stars")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }

                Divider()
                    .frame(height: 40)

                // Score
                VStack(spacing: AppSpacing.xs) {
                    Text("\(progress.score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Best Score")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }

                Divider()
                    .frame(height: 40)

                // Attempts
                VStack(spacing: AppSpacing.xs) {
                    Text("\(progress.attempts)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Attempts")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(Color.appSuccess, lineWidth: 2)
                )
                .appShadow(level: .light)
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            HapticManager.shared.playLight()
            startLesson = true
        }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: isCompleted ? "arrow.clockwise.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24, weight: .bold))

                Text(isCompleted ? "Practice Again" : "Start Lesson")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [
                                lesson.ylelevel?.primaryColor ?? .appPrimary,
                                lesson.ylelevel?.secondaryColor ?? .appSecondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .appShadow(level: .heavy)
            )
        }
        .scaleEffect(animateContent ? 1 : 0.9)
        .opacity(animateContent ? 1 : 0)
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appText)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }
}

// MARK: - Learning Point
struct LearningPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appSuccess)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appText)
        }
    }
}
