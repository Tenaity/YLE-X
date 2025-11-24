//
//  ExerciseView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct ExerciseView: View {
    let lesson: Lesson
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ExerciseViewModel
    @State private var animateQuestion = false
    @State private var animateOptions = false
    @State private var showResult = false

    init(lesson: Lesson) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: ExerciseViewModel(lesson: lesson))
    }

    var body: some View {
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

            VStack(spacing: 0) {
                // Top Progress Bar
                progressHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.xl) {
                        // Question Card
                        questionCard
                            .opacity(animateQuestion ? 1 : 0)
                            .offset(y: animateQuestion ? 0 : -30)

                        // Options
                        optionsSection
                            .opacity(animateOptions ? 1 : 0)
                            .offset(y: animateOptions ? 0 : 30)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }

                // Bottom Action Button
                if viewModel.selectedAnswer != nil {
                    submitButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            LessonResultView(result: viewModel.generateResult())
        }
        .task {
            await viewModel.loadExercises()
            withAnimation(.appBouncy.delay(0.2)) {
                animateQuestion = true
            }
            withAnimation(.appBouncy.delay(0.4)) {
                animateOptions = true
            }
        }
    }

    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: AppSpacing.sm) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: AppRadius.full)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: AppRadius.full)
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
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                        .animation(.appSmooth, value: viewModel.progress)
                }
            }
            .frame(height: 8)

            // Question Counter
            HStack {
                Text("Question \(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appAccent)
                    Text("\(viewModel.currentScore)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appText)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Material.ultraThinMaterial)
    }

    // MARK: - Question Card
    private var questionCard: some View {
        VStack(spacing: AppSpacing.lg) {
            // Emoji or Image
            if let emoji = viewModel.currentExercise?.emoji {
                Text(emoji)
                    .font(.system(size: 80))
                    .scaleEffect(animateQuestion ? 1 : 0.5)
                    .animation(.appBouncy.delay(0.3), value: animateQuestion)
            }

            // Question Text
            Text(viewModel.currentExercise?.question ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - Options Section
    private var optionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(Array((viewModel.currentExercise?.options ?? []).enumerated()), id: \.offset) { index, option in
                OptionButton(
                    text: option,
                    isSelected: viewModel.selectedAnswer == option,
                    isCorrect: viewModel.showFeedback ? (option == viewModel.currentExercise?.correctAnswer) : nil,
                    isWrong: viewModel.showFeedback ? (viewModel.selectedAnswer == option && option != viewModel.currentExercise?.correctAnswer) : nil,
                    action: {
                        guard !viewModel.showFeedback else { return }
                        withAnimation(.appBouncy) {
                            HapticManager.shared.playLight()
                            viewModel.selectAnswer(option)
                        }
                    }
                )
                .opacity(animateOptions ? 1 : 0)
                .offset(x: animateOptions ? 0 : -50)
                .animation(.appBouncy.delay(Double(index) * 0.1), value: animateOptions)
            }
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            HapticManager.shared.playLight()

            if viewModel.showFeedback {
                // Move to next question
                if viewModel.hasNextExercise {
                    withAnimation(.appSmooth) {
                        viewModel.moveToNextExercise()
                        animateQuestion = false
                        animateOptions = false
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.appBouncy) {
                            animateQuestion = true
                            animateOptions = true
                        }
                    }
                } else {
                    // Show result
                    showResult = true
                }
            } else {
                // Submit answer
                withAnimation(.appBouncy) {
                    viewModel.submitAnswer()
                }

                // Haptic feedback based on correctness
                if viewModel.isLastAnswerCorrect {
                    HapticManager.shared.playSuccess()
                } else {
                    HapticManager.shared.playError()
                }
            }
        }) {
            HStack(spacing: AppSpacing.sm) {
                if viewModel.showFeedback {
                    if viewModel.hasNextExercise {
                        Text("Next Question")
                        Image(systemName: "arrow.right")
                    } else {
                        Text("See Results")
                        Image(systemName: "checkmark.circle.fill")
                    }
                } else {
                    Text("Submit Answer")
                    Image(systemName: "paperplane.fill")
                }
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
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
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool?
    let action: () -> Void

    private var backgroundColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return .appSuccess.opacity(0.2)
        } else if let isWrong = isWrong, isWrong {
            return .appError.opacity(0.2)
        } else if isSelected {
            return .appPrimary.opacity(0.1)
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }

    private var borderColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return .appSuccess
        } else if let isWrong = isWrong, isWrong {
            return .appError
        } else if isSelected {
            return .appPrimary
        } else {
            return .clear
        }
    }

    private var icon: String? {
        if let isCorrect = isCorrect, isCorrect {
            return "checkmark.circle.fill"
        } else if let isWrong = isWrong, isWrong {
            return "xmark.circle.fill"
        } else if isSelected {
            return "circle.fill"
        } else {
            return "circle"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(
                            isCorrect == true ? .appSuccess :
                            isWrong == true ? .appError :
                            isSelected ? .appPrimary : .appTextSecondary
                        )
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .stroke(borderColor, lineWidth: 2)
                    )
                    .appShadow(level: isSelected ? .medium : .subtle)
            )
        }
        .disabled(isCorrect != nil || isWrong != nil)
    }
}

#Preview {
    NavigationStack {
        ExerciseView(lesson: Lesson(
            id: "1",
            title: "Colors",
            description: "Learn basic colors",
            level: "starters",
            skill: "vocabulary",
            order: 1,
            xpReward: 50,
            gemsReward: 10,
            isLocked: false,
            thumbnailEmoji: "🎨",
            estimatedMinutes: 10,
            totalExercises: 5,
            pathType: .linear,
            pathCategory: nil,
            isBoss: false,
            requiredGemsToUnlock: 0
        ))
    }
}
