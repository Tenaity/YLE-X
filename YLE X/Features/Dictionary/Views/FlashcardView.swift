//
//  FlashcardView.swift
//  YLE X
//
//  Created on 11/18/25.
//  Interactive flashcard UI with swipe gestures and flip animation
//

import SwiftUI

struct FlashcardView: View {
    let word: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService

    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0

    @Namespace private var flipAnimation

    var body: some View {
        ZStack {
            if !isFlipped {
                frontCard
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                backCard
                    .rotation3DEffect(
                        .degrees(180 + rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 450)
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width) / 20))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    handleSwipe(translation: value.translation)
                }
        )
        .onTapGesture {
            flipCard()
        }
        .animation(.appBouncy, value: isFlipped)
        .animation(.appBouncy, value: dragOffset)
    }

    // MARK: - Front Card (English)

    private var frontCard: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            HStack {
                Text("Tap to reveal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                // Level badge
                HStack(spacing: 4) {
                    Text(word.level.icon)
                        .font(.system(size: 14))
                    Text(word.level.displayName)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(hex: word.level.color) ?? .blue)
                )
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)

            Spacer()

            // Word
            VStack(spacing: AppSpacing.md) {
                // Main word
                Text(word.word)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)

                // IPA
                Text(word.pronunciation.british.ipa)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                // POS badge
                Text(word.primaryPos.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary.opacity(0.15))
                    )
            }

            Spacer()

            // Audio button
            Button(action: {
                audioService.playAudio(for: word, accent: .british)
                HapticManager.shared.playLight()
            }) {
                HStack(spacing: 8) {
                    Image(
                        systemName: audioService.isPlaying
                            ? "speaker.wave.3.fill" : "speaker.wave.2"
                    )
                    .font(.system(size: 18, weight: .semibold))
                    Text("Listen")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    Capsule()
                        .fill(Color.appPrimary)
                )
            }
            .padding(.bottom, AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color.appBackgroundSecondary)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(Color.appPrimary.opacity(0.2), lineWidth: 2)
        )
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Back Card (Vietnamese)

    private var backCard: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            HStack {
                Text("Swipe to answer")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                Button(action: {
                    flipCard()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18))
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)

            Spacer()

            // Vietnamese translation
            VStack(spacing: AppSpacing.lg) {
                // Translation
                Text(word.translationVi)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)

                Divider()
                    .padding(.horizontal, AppSpacing.xl2)

                // Definition
                VStack(spacing: AppSpacing.sm) {
                    Text("Definition")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text(word.definitionVi)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.appText)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, AppSpacing.lg)
                }

                // Example (if available)
                if let firstExample = word.examples.first {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Example")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appTextSecondary)

                        Text(firstExample.sentenceVi)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }

            Spacer()

            // Swipe indicators
            HStack(spacing: AppSpacing.xl2) {
                VStack(spacing: 4) {
                    Image(systemName: "hand.thumbsdown.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appError)
                    Text("Don't know")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appSuccess)
                    Text("I know it")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.xl2)
            .padding(.bottom, AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSecondary.opacity(0.1),
                            Color.appBackgroundSecondary,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(Color.appSecondary.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Actions

    private func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            rotation += 180
            isFlipped.toggle()
        }
        HapticManager.shared.playLight()
    }

    private func handleSwipe(translation: CGSize) {
        // Swipe threshold
        let threshold: CGFloat = 100

        if abs(translation.width) > threshold {
            if translation.width > 0 {
                // Swipe right (Correct)
                withAnimation(.spring()) {
                    dragOffset = CGSize(width: 500, height: translation.height)
                }
            } else {
                // Swipe left (Incorrect)
                withAnimation(.spring()) {
                    dragOffset = CGSize(width: -500, height: translation.height)
                }
            }
        } else {
            // Return to center
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    func resetCard() {
        withAnimation(.spring()) {
            dragOffset = .zero
            isFlipped = false
            rotation = 0
        }
    }
}

// MARK: - Flashcard Deck View

struct FlashcardDeckView: View {
    let category: VocabularyCategory
    let level: YLELevel

    @StateObject private var viewModel = FlashcardViewModel()
    @StateObject private var audioService = AudioPlayerService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let results = viewModel.sessionResults {
                resultsView(results)
            } else if let session = viewModel.currentSession {
                sessionView(session)
            } else {
                emptyView
            }
        }
        .navigationTitle("\(category.icon) Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUserProgress()
            await viewModel.startSession(
                category: category,
                level: level,
                sessionType: .practice,
                maxCards: 20
            )
        }
    }

    // MARK: - Session View

    @ViewBuilder
    private func sessionView(_ session: FlashcardSession) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar(session)

            // Card
            if let currentCard = session.currentCard {
                FlashcardView(word: currentCard, audioService: audioService)
                    .id(currentCard.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
            }

            // Action buttons
            actionButtons

            Spacer()
        }
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Progress Bar

    private func progressBar(_ session: FlashcardSession) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Stats
            HStack(spacing: AppSpacing.xl) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appSuccess)
                    Text("\(session.correctAnswers)")
                        .font(.system(size: 16, weight: .bold))
                }

                HStack(spacing: 4) {
                    Text("\(session.currentIndex)")
                        .font(.system(size: 18, weight: .bold))
                    Text("/ \(session.cards.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appError)
                    Text("\(session.incorrectAnswers)")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.appText)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color.appBackgroundSecondary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * session.progress, height: 8)
                        .animation(.spring(), value: session.progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: AppSpacing.xl) {
            // Don't Know button
            Button(action: {
                Task {
                    await viewModel.markIncorrect()
                }
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.appError.opacity(0.15))
                            .frame(width: 70, height: 70)

                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.appError)
                    }

                    Text("Don't Know")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appText)
                }
            }

            Spacer()

            // Skip button
            Button(action: {
                viewModel.skipCard()
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.appTextSecondary.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "forward.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appTextSecondary)
                    }

                    Text("Skip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // I Know It button
            Button(action: {
                Task {
                    await viewModel.markCorrect()
                }
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.appSuccess.opacity(0.15))
                            .frame(width: 70, height: 70)

                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.appSuccess)
                    }

                    Text("I Know It")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appText)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xl2)
        .padding(.top, AppSpacing.xl)
    }

    // MARK: - Results View

    @ViewBuilder
    private func resultsView(_ results: SessionResults) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl2) {
                // Performance emoji
                Text(results.performanceEmoji)
                    .font(.system(size: 80))

                // Rating
                Text(results.performanceRating)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.appText)

                // Stats grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: AppSpacing.md
                ) {
                    statCard(
                        icon: "checkmark.circle.fill",
                        value: "\(results.session.correctAnswers)",
                        label: "Correct",
                        color: .appSuccess
                    )

                    statCard(
                        icon: "xmark.circle.fill",
                        value: "\(results.session.incorrectAnswers)",
                        label: "Incorrect",
                        color: .appError
                    )

                    statCard(
                        icon: "percent",
                        value: String(format: "%.0f%%", results.session.accuracy),
                        label: "Accuracy",
                        color: .appPrimary
                    )

                    statCard(
                        icon: "clock.fill",
                        value: results.formattedDuration,
                        label: "Time",
                        color: .appInfo
                    )
                }
                .padding(.horizontal, AppSpacing.lg)

                // Rewards
                VStack(spacing: AppSpacing.md) {
                    Text("Rewards Earned")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)

                    HStack(spacing: AppSpacing.xl) {
                        rewardBadge(icon: "⭐", value: "+\(results.xpEarned) XP")
                        rewardBadge(icon: "💎", value: "+\(results.gemsEarned) Gems")
                    }
                }

                // Action buttons
                VStack(spacing: AppSpacing.md) {
                    Button(action: {
                        viewModel.resetSession()
                        Task {
                            await viewModel.startSession(
                                category: category,
                                level: level,
                                sessionType: .practice,
                                maxCards: 20
                            )
                        }
                    }) {
                        Text("Practice Again")
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

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appText)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(color.opacity(0.1))
        )
    }

    private func rewardBadge(icon: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appText)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
                .appShadow(level: .light)
        )
    }

    // MARK: - Loading & Empty Views

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appPrimary)

            Text("Preparing flashcards...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("📚")
                .font(.system(size: 80))

            Text("No cards available")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appText)

            Text("Try selecting a different level")
                .font(.system(size: 16))
                .foregroundColor(.appTextSecondary)

            Button(action: { dismiss() }) {
                Text("Go Back")
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

// MARK: - Preview

#Preview {
    NavigationStack {
        FlashcardDeckView(
            category: VocabularyCategory.sample,
            level: .starters
        )
    }
}
