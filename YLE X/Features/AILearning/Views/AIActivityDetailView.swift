//
//  AIActivityDetailView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//  Phase 5A: Connect AI Activities to Speaking Exercises
//

import SwiftUI

struct AIActivityDetailView: View {
    let activity: AIActivity
    @Environment(\.dismiss) var dismiss
    @StateObject private var progressService = ProgressService.shared

    @State private var showExercise = false
    @State private var exerciseCompleted = false
    @State private var earnedXP = 0
    @State private var showSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Activity Header
                activityHeader

                // Activity Details
                activityDetails

                // Start Button
                startButton

                // Previous Scores (if any)
                if let progress = progressService.sandboxProgress {
                    if let score = progress.activityScores[activity.id ?? ""] {
                        previousScoresSection(score: score)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExercise) {
            // Convert AIActivity to SpeakingExercise
            let exercise = convertToSpeakingExercise(activity)
            SpeakingExerciseView(exercise: exercise)
                .onDisappear {
                    // Handle completion
                    if !exerciseCompleted {
                        handleExerciseCompletion()
                    }
                }
        }
        .alert("Great Job!", isPresented: $showSuccessAlert) {
            Button("Continue") {
                dismiss()
            }
        } message: {
            Text("You earned \(earnedXP) XP and \(activity.gemsReward) gems! 🎉")
        }
    }

    // MARK: - Activity Header
    private var activityHeader: some View {
        VStack(spacing: AppSpacing.md) {
            // Activity emoji
            Text(activity.thumbnailEmoji)
                .font(.system(size: 64))

            // Activity type badge
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: activityTypeIcon(activity.type))
                    .font(.caption)
                Text(activityTypeLabel(activity.type))
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(Color.appPrimary.opacity(0.1))
            .foregroundColor(.appPrimary)
            .cornerRadius(AppRadius.sm)

            // Title
            Text(activity.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            // Description
            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.appSecondary.opacity(0.1),
                    Color.appAccent.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Activity Details
    private var activityDetails: some View {
        VStack(spacing: AppSpacing.md) {
            // Target Text
            detailRow(
                icon: "text.bubble",
                label: "Practice Word/Phrase",
                value: activity.targetText,
                valueFont: .headline.weight(.semibold)
            )

            // IPA Guide (if available)
            if let ipa = activity.ipaGuide, !ipa.isEmpty {
                detailRow(
                    icon: "textformat.abc",
                    label: "IPA Pronunciation",
                    value: ipa,
                    valueFont: .title3.weight(.medium),
                    valueColor: .appAccent
                )
            }

            Divider()

            // Rewards
            HStack(spacing: AppSpacing.lg) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appAccent)
                    Text("\(activity.xpReward) XP")
                        .font(.subheadline.weight(.semibold))
                }

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "gem.fill")
                        .foregroundColor(.appWarning)
                    Text("\(activity.gemsReward) Gems")
                        .font(.subheadline.weight(.semibold))
                }

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "clock")
                        .foregroundColor(.appTextSecondary)
                    Text("\(activity.estimatedMinutes) min")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)

            Divider()

            // Difficulty
            HStack {
                Text("Difficulty:")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { level in
                        Image(systemName: level <= activity.difficulty ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(level <= activity.difficulty ? .appWarning : .appTextSecondary.opacity(0.3))
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appSecondary.opacity(0.05))
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Start Button
    private var startButton: some View {
        AppButton(
            title: "Start Practice",
            icon: "mic.fill",
            style: .primary,
            action: {
                showExercise = true
            }
        )
    }

    // MARK: - Previous Scores Section
    private func previousScoresSection(score: Int) -> some View {
        let scoreDouble = Double(score)
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your Best Score")
                .font(.headline.weight(.semibold))

            HStack(spacing: AppSpacing.lg) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.appTextSecondary.opacity(0.2), lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: scoreDouble / 100)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.appSuccess, .appAccent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(score))")
                            .font(.title.weight(.bold))
                            .foregroundColor(.appSuccess)
                        Text("/ 100")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(scoreLabel(score: scoreDouble))
                        .font(.headline.weight(.semibold))
                        .foregroundColor(scoreColor(score: scoreDouble))

                    Text("Keep practicing to improve!")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appSuccess.opacity(0.05))
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Helper Views
    private func detailRow(icon: String, label: String, value: String, valueFont: Font = .subheadline, valueColor: Color = .appText) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.appPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Text(value)
                .font(valueFont)
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helper Methods
    private func convertToSpeakingExercise(_ activity: AIActivity) -> SpeakingExercise {
        // Determine exercise type based on activity type
        let exerciseType: ExerciseType = {
            switch activity.type {
            case .pronunciation:
                return .wordRepetition
            case .vocabularyWithIPA:
                return .wordRepetition
            case .ipaWorkshop:
                return .sentenceReading
            default:
                return .sentenceReading
            }
        }()

        // Map difficulty
        let exerciseDifficulty: ExerciseDifficulty = {
            switch activity.difficulty {
            case 1: return .beginner
            case 2: return .intermediate
            case 3, 4, 5: return .advanced
            default: return .beginner
            }
        }()

        // Generate tips based on activity type
        let tips: [String] = {
            switch activity.type {
            case .pronunciation:
                return [
                    "Listen to the IPA guide carefully",
                    "Speak clearly at a natural pace",
                    "Focus on the correct vowel sound"
                ]
            case .vocabularyWithIPA:
                return [
                    "Pay attention to word stress",
                    "Practice each syllable separately",
                    "Use the IPA guide for accuracy"
                ]
            case .ipaWorkshop:
                return [
                    "Focus on mouth position",
                    "Listen to the phoneme sound",
                    "Practice multiple times"
                ]
            default:
                return ["Speak clearly and at a natural pace"]
            }
        }()

        return SpeakingExercise(
            id: activity.id ?? UUID().uuidString,
            type: exerciseType,
            targetText: activity.targetText,
            ipaText: activity.ipaGuide ?? "",
            difficulty: exerciseDifficulty,
            tips: tips,
            maxAttempts: 3
        )
    }

    private func handleExerciseCompletion() {
        // This would be called when user completes the exercise
        // For now, we'll mark as completed and award XP
        exerciseCompleted = true
        earnedXP = activity.xpReward

        Task {
            do {
                // Update progress
                try await progressService.completeActivity(
                    activityId: activity.id ?? "",
                    score: 85, // Default score, would come from SpeakingExerciseView in real implementation
                    xpEarned: activity.xpReward
                )

                showSuccessAlert = true
            } catch {
                print("Error updating progress: \(error)")
            }
        }
    }

    private func activityTypeIcon(_ type: AIActivity.AIActivityType) -> String {
        switch type {
        case .pronunciation: return "mic.fill"
        case .vocabularyWithIPA: return "book.fill"
        case .listeningComp: return "ear.fill"
        case .conversationPractice: return "bubble.left.and.bubble.right.fill"
        case .ipaWorkshop: return "textformat.abc"
        }
    }

    private func activityTypeLabel(_ type: AIActivity.AIActivityType) -> String {
        switch type {
        case .pronunciation: return "Pronunciation"
        case .vocabularyWithIPA: return "Vocabulary"
        case .listeningComp: return "Listening"
        case .conversationPractice: return "Conversation"
        case .ipaWorkshop: return "IPA Workshop"
        }
    }

    private func scoreLabel(score: Double) -> String {
        switch score {
        case 90...100: return "Excellent! 🌟"
        case 75..<90: return "Great! 👍"
        case 60..<75: return "Good 💪"
        default: return "Keep Trying! 📚"
        }
    }

    private func scoreColor(score: Double) -> Color {
        switch score {
        case 90...100: return .appSuccess
        case 75..<90: return .appAccent
        case 60..<75: return .appWarning
        default: return .appTextSecondary
        }
    }
}

// MARK: - Preview
struct AIActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AIActivityDetailView(
                activity: AIActivity(
                    type: .pronunciation,
                    level: "starters",
                    pathCategory: "Pronunciation Workshop",
                    title: "Practice Vowel /æ/",
                    description: "Learn to pronounce the 'a' sound in words like 'cat'",
                    targetText: "cat",
                    ipaGuide: "/kæt/",
                    difficulty: 2,
                    xpReward: 30,
                    gemsReward: 6,
                    estimatedMinutes: 8,
                    order: 1,
                    thumbnailEmoji: "🎤"
                )
            )
        }
        .environmentObject(ProgramSelectionStore())
    }
}
