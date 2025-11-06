//
//  ExerciseQuestionView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI
import Combine

struct ExerciseQuestionView: View {
    let exercise: Exercise
    @StateObject private var viewModel = ExerciseSessionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    
    // SỬA: Lấy màu trực tiếp từ exercise, bỏ 'ThemeManager'
    private var themeColor: Color {
        exercise.skill.color
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.spacious) { // SỬA: Sử dụng spacing mới
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
                        .transition(.appModal) // SỬA: Sử dụng transition mới
                }
            }
            .appScreenPadding() // SỬA: Sử dụng screen padding mới
            .background(
                LinearGradient(
                    colors: [
                        themeColor.opacity(0.15), // SỬA: Sử dụng opacity thay vì pastel variant tạm thời
                        Color.appBackground
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
                    .foregroundColor(.appSecondaryText) // SỬA
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
        VStack(spacing: AppSpacing.md) { // SỬA
            // Progress bar
            HStack {
                Text("Câu \(viewModel.currentIndex + 1)/\(viewModel.totalExercises)")
                    .font(.appCaption) // SỬA
                    .foregroundColor(.appSecondaryText) // SỬA
                Spacer()
            }
            
            ProgressView(value: Double(viewModel.currentIndex + 1), total: Double(viewModel.totalExercises))
                .progressViewStyle(AppProgressViewStyle(color: themeColor)) // SỬA
        }
    }
    
    // MARK: - Exercise Content
    private var exerciseContentSection: some View {
        VStack(spacing: AppSpacing.lg) { // SỬA
            // Skill badge
            HStack {
                Spacer()
                HStack(spacing: AppSpacing.xs) { // SỬA
                    Text(exercise.skill.emoji)
                    Text(exercise.skill.title)
                        .font(.appCaption) // SỬA
                        .foregroundColor(.appSecondaryText) // SỬA
                }
                .padding(.horizontal, AppSpacing.md) // SỬA
                .padding(.vertical, AppSpacing.xs) // SỬA
                .background(
                    Capsule()
                        .fill(themeColor.opacity(0.2)) // SỬA
                )
                Spacer()
            }
            
            // Question text
            Text(exercise.question)
                .font(.appTitle) // SỬA
                .foregroundColor(.appPrimaryText) // SỬA
                .multilineTextAlignment(.center)
                // .lineLimit(nil) // Không cần thiết, đây là default cho Text
        }
        .padding(AppSpacing.lg) // SỬA
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xlarge) // SỬA
                .fill(Color.appCardBackground) // SỬA
                .appShadow(level: .light) // SỬA
        )
    }
    
    // MARK: - Answers Section
    private var answersSection: some View {
        VStack(spacing: AppSpacing.md) { // SỬA
            ForEach(exercise.options.indices, id: \.self) { index in
                let option = exercise.options[index]
                AnswerButton(
                    text: option,
                    isSelected: selectedAnswer == index,
                    isCorrect: showingResult ? index == exercise.correctIndex : nil,
                    color: themeColor // SỬA
                ) {
                    selectAnswer(index)
                }
            }
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        AppButton(
            title: showingResult ? "Tiếp tục" : "Trả lời",
            emoji: showingResult ? "➡️" : "✨",
            style: showingResult ? .success : .primary,
            size: .fullWidth
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
        VStack(spacing: AppSpacing.lg) { // SỬA
            // Result indicator
            HStack(spacing: AppSpacing.md) { // SỬA
                Image(systemName: isCorrectAnswer() ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isCorrectAnswer() ? .appSuccess : .appError) // SỬA
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isCorrectAnswer() ? "Chính xác! 🎉" : "Chưa đúng 😊")
                        .font(.appHeadline) // SỬA
                        .foregroundColor(isCorrectAnswer() ? .appSuccess : .appError) // SỬA
                        .fontWeight(.bold)
                    
                    if !isCorrectAnswer() {
                        Text("Đáp án đúng: \(exercise.options[exercise.correctIndex])")
                            .font(.appBody) // SỬA
                            .foregroundColor(.appSecondaryText) // SỬA
                    }
                }
                Spacer()
            }
            .padding(AppSpacing.lg) // SỬA
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large) // SỬA
                    .fill((isCorrectAnswer() ? Color.appSuccess : Color.appError).opacity(0.1)) // SỬA
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.large) // SỬA
                            .stroke((isCorrectAnswer() ? Color.appSuccess : Color.appError).opacity(0.3), lineWidth: 2) // SỬA
                    )
            )
        }
    }
    
    // MARK: - Helper Methods
    private func selectAnswer(_ index: Int) {
        guard !showingResult else { return }
        selectedAnswer = index
        HapticManager.shared.playLight() // SỬA (Giả lập)
    }
    
    private func submitAnswer() {
        guard let selectedAnswer = selectedAnswer else { return }
        
        withAnimation(.appGentle) { // SỬA
            showingResult = true
        }
        
        if selectedAnswer == exercise.correctIndex {
            HapticManager.shared.playSuccess() // SỬA
            SoundManager.shared.playSound(.correctAnswer) // SỬA
            viewModel.recordCorrectAnswer()
        } else {
            HapticManager.shared.playError() // SỬA
            SoundManager.shared.playSound(.wrongAnswer) // SỬA
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

// MARK: - Preview
struct ExerciseQuestionView_Previews: PreviewProvider {
    static var previews: some View {
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
                imageName: "sun_image"
            )
        )
    }
}
