//
//  ExerciseView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import Combine

struct ExerciseQuestionView: View {
    let exercise: Exercise
    @StateObject private var viewModel = ExerciseSessionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: KidsSpacing.xl) {
                // Progress and timer header
                headerSection
                
                // Exercise content
                exerciseContentSection
                
                // Multiple choice answers
                answersSection
                
                Spacer()
                
                // Submit button
                submitSection
                
                // Result section
                if showingResult {
                    resultSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(KidsSpacing.lg)
            .background(
                LinearGradient(
                    colors: [
                        ThemeManager.shared.currentTheme.primaryColor.opacity(0.1),
                        Color.kidsBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Thoát") {
                        dismiss()
                    }
                    .foregroundColor(.kidsSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Show hint
                        showHint()
                    } label: {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: KidsSpacing.md) {
            // Progress bar
            HStack {
                Text("Câu \(viewModel.currentIndex + 1)/\(viewModel.totalExercises)")
                    .font(.kidsCaption)
                    .foregroundColor(.kidsSecondaryText)
                Spacer()
            }
            
            ProgressView(value: Double(viewModel.currentIndex + 1), total: Double(viewModel.totalExercises))
                .progressViewStyle(KidsProgressViewStyle(color: ThemeManager.shared.currentTheme.primaryColor))
        }
    }
    
    // MARK: - Exercise Content
    private var exerciseContentSection: some View {
        VStack(spacing: KidsSpacing.lg) {
            // Skill badge
            HStack {
                Spacer()
                HStack(spacing: KidsSpacing.xs) {
                    Text(exercise.skill.emoji)
                    Text(exercise.skill.title)
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                }
                .padding(.horizontal, KidsSpacing.md)
                .padding(.vertical, KidsSpacing.xs)
                .background(
                    Capsule()
                        .fill(ThemeManager.shared.currentTheme.primaryColor.opacity(0.2))
                )
                Spacer()
            }
            
            // Question text
            Text(exercise.question)
                .font(.kidsTitle)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.xlarge)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
    
    // MARK: - Answers Section
    private var answersSection: some View {
        VStack(spacing: KidsSpacing.md) {
            ForEach(exercise.options.indices, id: \.self) { index in
                let option = exercise.options[index]
                AnswerButton(
                    text: option,
                    isSelected: selectedAnswer == index,
                    isCorrect: showingResult ? index == exercise.correctIndex : nil,
                    color: ThemeManager.shared.currentTheme.primaryColor
                ) {
                    selectAnswer(index)
                }
            }
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        KidsButton(
            title: showingResult ? "Tiếp tục" : "Trả lời",
            emoji: showingResult ? "➡️" : "✨",
            color: showingResult ? .kidsSuccess : ThemeManager.shared.currentTheme.primaryColor
        ) {
            if showingResult {
                nextExercise()
            } else {
                submitAnswer()
            }
        }
        .disabled(selectedAnswer == nil && !showingResult)
        .opacity(selectedAnswer == nil && !showingResult ? 0.5 : 1.0)
    }
    
    // MARK: - Result Section
    private var resultSection: some View {
        VStack(spacing: KidsSpacing.lg) {
            // Result indicator
            HStack(spacing: KidsSpacing.md) {
                Image(systemName: isCorrectAnswer() ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isCorrectAnswer() ? .kidsSuccess : .kidsError)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isCorrectAnswer() ? "Chính xác! 🎉" : "Chưa đúng 😊")
                        .font(.kidsHeadline)
                        .foregroundColor(isCorrectAnswer() ? .kidsSuccess : .kidsError)
                        .fontWeight(.bold)
                    
                    if !isCorrectAnswer() {
                        Text("Đáp án đúng: \(exercise.options[exercise.correctIndex])")
                            .font(.kidsBody)
                            .foregroundColor(.kidsSecondaryText)
                    }
                }
                Spacer()
            }
            .padding(KidsSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill((isCorrectAnswer() ? Color.kidsSuccess : Color.kidsError).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke((isCorrectAnswer() ? Color.kidsSuccess : Color.kidsError).opacity(0.3), lineWidth: 2)
                    )
            )
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
        
        withAnimation(.kidsGentle) {
            showingResult = true
        }
        
        if selectedAnswer == exercise.correctIndex {
            HapticManager.shared.playSuccess()
            SoundManager.shared.playSound(.correctAnswer)
            viewModel.recordCorrectAnswer()
        } else {
            HapticManager.shared.playError()
            SoundManager.shared.playSound(.wrongAnswer)
            viewModel.recordIncorrectAnswer()
        }
    }
    
    private func nextExercise() {
        viewModel.moveToNextExercise()
        // Navigation logic would go here
        dismiss()
    }
    
    private func isCorrectAnswer() -> Bool {
        guard let selectedAnswer = selectedAnswer else { return false }
        return selectedAnswer == exercise.correctIndex
    }
    
    private func showHint() {
        // Show hint implementation
        print("Showing hint for exercise")
    }
}

// MARK: - Answer Button Component
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let color: Color
    let action: () -> Void
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .kidsSuccess.opacity(0.2) : .kidsError.opacity(0.2)
        }
        return isSelected ? color.opacity(0.2) : Color.white
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .kidsSuccess : .kidsError
        }
        return isSelected ? color : Color.gray.opacity(0.3)
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.kidsBody)
                    .foregroundColor(.kidsPrimaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.kidsHeadline)
                        .foregroundColor(isCorrect ? .kidsSuccess : .kidsError)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.kidsHeadline)
                        .foregroundColor(color)
                }
            }
            .padding(KidsSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(borderColor, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
        .kidsAccessibility(
            label: text,
            hint: isSelected ? "Đã chọn" : "Nhấn để chọn đáp án này",
            traits: .isButton
        )
    }
}

// MARK: - Exercise Session ViewModel
@MainActor
class ExerciseSessionViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var totalAnswers: Int = 0
    let totalExercises: Int = 10
    
    func recordCorrectAnswer() {
        correctAnswers += 1
        totalAnswers += 1
    }
    
    func recordIncorrectAnswer() {
        totalAnswers += 1
    }
    
    func moveToNextExercise() {
        currentIndex += 1
    }
    
    var accuracy: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }
}

#Preview {
    ExerciseQuestionView(
        exercise: Exercise(
            id: "1",
            level: .starters,
            skill: .vocabulary,
            question: "What color is the sun?",
            options: ["Blue", "Yellow", "Green", "Red"],
            correctIndex: 1
        )
    )
}

