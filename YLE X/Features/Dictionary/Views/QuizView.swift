//
//  QuizView.swift
//  YLE X
//
//  Created on 11/18/25.
//  Interactive quiz UI with multiple question types
//

import SwiftUI

struct QuizView: View {
    let category: VocabularyCategory
    let level: YLELevel

    @StateObject private var viewModel = QuizViewModel()
    @StateObject private var audioService = AudioPlayerService()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: QuizSession.QuizMode = .mixed
    @State private var showModeSelection = true

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if showModeSelection {
                modeSelectionView
            } else if viewModel.isLoading {
                loadingView
            } else if let results = viewModel.quizResults {
                resultsView(results)
            } else if let session = viewModel.currentSession {
                quizView(session)
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            }
        }
        .navigationTitle("\(category.icon) Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Mode Selection

    private var modeSelectionView: some View {
        VStack(spacing: AppSpacing.xl2) {
            // Header
            VStack(spacing: AppSpacing.md) {
                Text("📝")
                    .font(.system(size: 80))

                Text("Choose Quiz Mode")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appText)

                Text("Select your preferred question type")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Mode cards
            VStack(spacing: AppSpacing.md) {
                ForEach(QuizSession.QuizMode.allCases, id: \.self) { mode in
                    Button(action: {
                        selectedMode = mode
                        startQuiz()
                    }) {
                        HStack(spacing: AppSpacing.lg) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.15))
                                    .frame(width: 60, height: 60)

                                Image(systemName: mode.icon)
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                            }

                            // Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.rawValue)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appText)

                                Text(mode.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(AppSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(Color.appBackgroundSecondary)
                                .appShadow(level: .light)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(AppSpacing.xl)
    }

    private func startQuiz() {
        showModeSelection = false
        Task {
            await viewModel.startQuiz(
                category: category,
                level: level,
                mode: selectedMode,
                questionCount: 10
            )
        }
        HapticManager.shared.playLight()
    }

    // MARK: - Quiz View

    @ViewBuilder
    private func quizView(_ session: QuizSession) -> some View {
        VStack(spacing: 0) {
            // Progress header
            progressHeader(session)

            // Question card
            if let question = session.currentQuestion {
                questionCard(question, session: session)
                    .id(question.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
            }

            Spacer()
        }
    }

    // MARK: - Progress Header

    private func progressHeader(_ session: QuizSession) -> some View {
        VStack(spacing: AppSpacing.md) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color.appBackgroundSecondary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSuccess, Color.appPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * session.progress, height: 8)
                        .animation(.spring(), value: session.progress)
                }
            }
            .frame(height: 8)

            // Stats
            HStack {
                Text("Question \(session.currentIndex + 1) / \(session.questions.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)

                Spacer()

                HStack(spacing: AppSpacing.md) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.appSuccess)
                        Text("\(session.score)")
                            .font(.system(size: 14, weight: .bold))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appError)
                        Text("\(session.answers.count - session.score)")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.appText)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appBackground)
    }

    // MARK: - Question Card

    @ViewBuilder
    private func questionCard(_ question: QuizQuestion, session: QuizSession) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Question type badge
                HStack {
                    Image(systemName: question.type.icon)
                        .font(.system(size: 14))
                    Text(question.type.displayName)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.appSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.appSecondary.opacity(0.15))
                )

                // Audio button for listening questions
                if question.type == .listening {
                    audioPlayButton(for: question.word)
                }

                // Question text
                Text(question.question)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)

                // Hint button
                if let hint = question.hint {
                    Button(action: {
                        viewModel.toggleHint()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.showHint ? "lightbulb.fill" : "lightbulb")
                                .font(.system(size: 14))
                            Text(viewModel.showHint ? hint : "Show Hint")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(viewModel.showHint ? .appWarning : .appTextSecondary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.appWarning.opacity(viewModel.showHint ? 0.2 : 0.1))
                        )
                    }
                }

                // Answer options
                VStack(spacing: AppSpacing.md) {
                    ForEach(question.options, id: \.self) { option in
                        answerButton(option, for: question)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                // Skip button
                Button(action: {
                    viewModel.skipQuestion()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14))
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(Color.appBackgroundSecondary)
                    )
                }
            }
            .padding(.vertical, AppSpacing.xl)
        }
    }

    // MARK: - Audio Play Button

    private func audioPlayButton(for word: DictionaryWord) -> some View {
        Button(action: {
            audioService.playAudio(for: word, accent: .british)
            HapticManager.shared.playLight()
        }) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(
                        systemName: audioService.isPlaying
                            ? "speaker.wave.3.fill" : "play.circle.fill"
                    )
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
                }

                Text("Tap to listen")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
        }
    }

    // MARK: - Answer Button

    private func answerButton(_ option: String, for question: QuizQuestion) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                viewModel.submitAnswer(option)
            }
        }) {
            HStack {
                Text(option)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "circle")
                    .font(.system(size: 20))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color.appBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .strokeBorder(Color.appPrimary.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Results View

    @ViewBuilder
    private func resultsView(_ results: QuizResults) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl2) {
                // Grade badge
                VStack(spacing: AppSpacing.lg) {
                    Text(results.grade.emoji)
                        .font(.system(size: 100))

                    Text(results.grade.title)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.appText)

                    Text(results.grade.message)
                        .font(.system(size: 18))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Score display
                VStack(spacing: AppSpacing.md) {
                    Text("\(results.session.score) / \(results.session.questions.count)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: results.grade.color) ?? .appPrimary)

                    Text(String(format: "%.0f%% Accuracy", results.session.accuracy))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }

                // Stats grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: AppSpacing.md
                ) {
                    statCard(
                        icon: "⭐",
                        value: "+\(results.xpEarned)",
                        label: "XP Earned"
                    )

                    statCard(
                        icon: "💎",
                        value: "+\(results.gemsEarned)",
                        label: "Gems Earned"
                    )

                    statCard(
                        icon: "⏱️",
                        value: results.formattedDuration,
                        label: "Time"
                    )

                    statCard(
                        icon: "🔥",
                        value: "\(results.streak)",
                        label: "Streak"
                    )
                }
                .padding(.horizontal, AppSpacing.lg)

                // Answer review
                answerReviewSection(results)

                // Action buttons
                VStack(spacing: AppSpacing.md) {
                    Button(action: {
                        viewModel.resetQuiz()
                        showModeSelection = true
                    }) {
                        Text("Take Another Quiz")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(Color.appPrimary)
                            )
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Categories")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(Color.appPrimary.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.xl2)
        }
    }

    // MARK: - Stat Card

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Text(icon)
                .font(.system(size: 36))

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appText)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
                .appShadow(level: .light)
        )
    }

    // MARK: - Answer Review Section

    @ViewBuilder
    private func answerReviewSection(_ results: QuizResults) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Review Answers")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.appText)
                .padding(.horizontal, AppSpacing.lg)

            VStack(spacing: AppSpacing.md) {
                ForEach(results.getAnswerReviews()) { review in
                    answerReviewCard(review)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private func answerReviewCard(_ review: QuizResults.AnswerReview) -> some View {
        HStack(spacing: AppSpacing.md) {
            // Status icon
            Image(systemName: review.statusIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(hex: review.statusColor) ?? .appTextSecondary)
                .frame(width: 40, height: 40)

            // Question and answer
            VStack(alignment: .leading, spacing: 6) {
                Text(review.question.word.word)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.appText)

                if let userAnswer = review.userAnswer {
                    if review.isCorrect {
                        Text("✓ \(userAnswer)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appSuccess)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("✗ \(userAnswer)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appError)
                            Text("✓ \(review.question.correctAnswer)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appSuccess)
                        }
                    }
                } else {
                    Text("Skipped")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appPrimary)

            Text("Preparing quiz...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.appWarning)

            Text("Oops!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appText)

            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Button(action: {
                showModeSelection = true
                viewModel.errorMessage = nil
            }) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary)
                    )
            }
        }
        .padding(AppSpacing.xl)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        QuizView(
            category: VocabularyCategory.sample,
            level: .starters
        )
    }
}
