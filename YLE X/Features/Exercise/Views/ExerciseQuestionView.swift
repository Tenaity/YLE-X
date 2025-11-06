//
//  ExerciseQuestionView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct ExerciseQuestionView: View {
    let exercise: Exercise
    @StateObject private var viewModel = ExerciseSessionViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAnswer: Int?
    @State private var showingResult = false

    private var themeColor: Color {
        exercise.skill.color
    }

    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.lg) {
                headerSection
                exerciseContentSection
                answersSection

                Spacer()

                submitSection

                if showingResult {
                    resultSection
                        .transition(.appScale)
                }
            }
            .appScreenPadding()
            .background(
                LinearGradient(
                    colors: [themeColor.opacity(0.15), Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Exit")
                        }
                    }
                    .foregroundColor(.appText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showHint()
                    } label: {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.appWarning)
                    }
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalExercises)")
                    .appCaptionMedium()
                Spacer()
            }

            ProgressView(
                value: Double(viewModel.currentIndex + 1),
                total: Double(viewModel.totalExercises)
            )
            .tint(themeColor)
        }
    }

    // MARK: - Exercise Content Section
    private var exerciseContentSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Skill Badge
            HStack {
                Spacer()
                HStack(spacing: AppSpacing.xs) {
                    Text(exercise.skill.emoji)
                        .font(.system(size: 18))
                    Text(exercise.skill.rawValue)
                        .appHeadlineSmall()
                }
                .appPadding(.small)
                .background(themeColor.opacity(0.2))
                .cornerRadius(AppRadius.md)
                Spacer()
            }

            // Question Text
            Text(exercise.question)
                .appTitleMedium()
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
        }
        .appCardPadding()
        .background(Color.appBackgroundSecondary)
        .appCardRadius()
        .appShadow(level: .light)
    }

    // MARK: - Answers Section
    private var answersSection: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(exercise.options.indices, id: \.self) { index in
                AnswerButtonView(
                    text: exercise.options[index],
                    isSelected: selectedAnswer == index,
                    isCorrect: showingResult ? (index == exercise.correctIndex) : nil,
                    color: themeColor
                ) {
                    selectAnswer(index)
                }
            }
        }
    }

    // MARK: - Submit Section
    private var submitSection: some View {
        AppButton(
            title: showingResult ? "Next Question" : "Submit Answer",
            icon: showingResult ? "arrow.right" : "checkmark",
            size: .fullWidth, style: showingResult ? .primary : .primary,
            action: {
                if showingResult {
                    nextExercise()
                } else {
                    submitAnswer()
                }
            }
        )
        .disabled(selectedAnswer == nil && !showingResult)
        .opacity(selectedAnswer == nil && !showingResult ? 0.6 : 1.0)
    }

    // MARK: - Result Section
    private var resultSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: isCorrectAnswer() ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isCorrectAnswer() ? .appSuccess : .appError)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(isCorrectAnswer() ? "Correct! 🎉" : "Try Again 😊")
                        .appHeadlineMedium()
                        .foregroundColor(isCorrectAnswer() ? .appSuccess : .appError)

                    if !isCorrectAnswer() {
                        Text("Correct answer: \(exercise.options[exercise.correctIndex])")
                            .appBodySmall()
                            .foregroundColor(.appTextSecondary)
                    }
                }
                Spacer()
            }
            .appCardPadding()
            .background(
                (isCorrectAnswer() ? Color.appSuccess : Color.appError).opacity(0.1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(
                        (isCorrectAnswer() ? Color.appSuccess : Color.appError).opacity(0.3),
                        lineWidth: 1.5
                    )
            )
            .appCardRadius()
        }
    }

    // MARK: - Helper Methods
    private func selectAnswer(_ index: Int) {
        guard !showingResult else { return }
        selectedAnswer = index
        HapticManager.shared.playLight()
    }

    private func submitAnswer() {
        guard let selectedAnswer = selectedAnswer else { return }

        withAnimation(.appGentle) {
            showingResult = true
        }

        if selectedAnswer == exercise.correctIndex {
            HapticManager.shared.playSuccess()
            viewModel.recordCorrectAnswer()
        } else {
            HapticManager.shared.playError()
            viewModel.recordIncorrectAnswer()
        }
    }

    private func nextExercise() {
        viewModel.moveToNextExercise()
        dismiss()
    }

    private func isCorrectAnswer() -> Bool {
        guard let selectedAnswer = selectedAnswer else { return false }
        return selectedAnswer == exercise.correctIndex
    }

    private func showHint() {
        print("Showing hint for exercise: \(exercise.id)")
    }
}

// MARK: - Answer Button View
struct AnswerButtonView: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(
                            isCorrect == true ? Color.appSuccess :
                            isCorrect == false ? Color.appError :
                            isSelected ? color : Color.appFillLight
                        )

                    if let isCorrect = isCorrect {
                        Image(systemName: isCorrect ? "checkmark" : "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    } else if isSelected {
                        Circle()
                            .fill(color)
                    }
                }
                .frame(width: 28, height: 28)

                Text(text)
                    .appBodyLarge()
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .appCardPadding()
            .background(
                isCorrect == true ? Color.appSuccess.opacity(0.1) :
                isCorrect == false ? Color.appError.opacity(0.1) :
                isSelected ? color.opacity(0.1) : Color.appBackgroundSecondary
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(
                        isCorrect == true ? Color.appSuccess :
                        isCorrect == false ? Color.appError :
                        isSelected ? color : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .appCardRadius()
            .appShadow(level: isSelected ? .light : .subtle)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
        .opacity(isCorrect == nil ? 1.0 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    ExerciseQuestionView(
        exercise: Exercise(
            id: "1",
            level: .starters,
            skill: .vocabulary,
            question: "What color is the sun?",
            options: ["Blue", "Yellow", "Green", "Red"],
            correctIndex: 1,
            explanation: "The sun is a star and it's yellow.",
            audioName: "sun.mp3",
            imageName: nil
        )
    )
}
