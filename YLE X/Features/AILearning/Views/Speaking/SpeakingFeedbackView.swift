//
//  SpeakingFeedbackView.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: Pronunciation Feedback Display
//

import SwiftUI

struct SpeakingFeedbackView: View {
    let score: PronunciationScore
    let targetText: String
    let onTryAgain: () -> Void
    let onNext: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var animateScore = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Overall Score Display
                    overallScoreSection

                    // Metrics Breakdown
                    metricsSection

                    // Word-by-Word Analysis
                    wordAnalysisSection

                    // Feedback Tips
                    feedbackSection

                    // Action Buttons
                    actionButtons
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Your Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .onAppear {
                withAnimation(.appBouncy.delay(0.2)) {
                    animateScore = true
                }
            }
        }
    }

    // MARK: - Overall Score

    private var overallScoreSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text(score.grade.emoji)
                .font(.system(size: 80))
                .scaleEffect(animateScore ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateScore)

            Text(score.grade.rawValue)
                .font(.title.weight(.bold))
                .foregroundColor(score.grade.color)

            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.appTextSecondary.opacity(0.2), lineWidth: 12)
                    .frame(width: 160, height: 160)

                // Progress circle
                Circle()
                    .trim(from: 0, to: animateScore ? score.overallScore / 100 : 0)
                    .stroke(
                        LinearGradient(
                            colors: [score.grade.color, score.grade.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: animateScore)

                // Score text
                VStack(spacing: 4) {
                    Text("\(Int(score.overallScore))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.appText)

                    Text("/ 100")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.xl)
    }

    // MARK: - Metrics

    private var metricsSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Score Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            MetricRow(
                icon: "checkmark.circle.fill",
                title: "Accuracy",
                value: score.accuracy,
                color: .appSuccess
            )

            MetricRow(
                icon: "waveform",
                title: "Fluency",
                value: score.fluency,
                color: .appAccent
            )

            MetricRow(
                icon: "text.badge.checkmark",
                title: "Completeness",
                value: score.completeness,
                color: .appPrimary
            )
        }
        .padding(AppSpacing.md)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Word Analysis

    private var wordAnalysisSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Word Analysis")
                .font(.headline)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Expected:")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)

                Text(targetText)
                    .font(.body)
                    .foregroundColor(.appText)
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appBackgroundSecondary)
                    .cornerRadius(AppRadius.sm)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Your pronunciation:")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)

                FlowLayout(spacing: 8) {
                    ForEach(score.wordScores) { wordScore in
                        WordChip(wordScore: wordScore)
                    }
                }
            }

            // Detailed word scores
            if score.wordScores.contains(where: { $0.status != .correct }) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Issues Found:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.appTextSecondary)

                    ForEach(score.wordScores.filter { $0.status != .correct }) { wordScore in
                        WordIssueRow(wordScore: wordScore)
                    }
                }
                .padding(AppSpacing.md)
                .background(Color.appWarning.opacity(0.1))
                .cornerRadius(AppRadius.md)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Feedback

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                Text("Tips for Improvement")
                    .font(.headline)
            }
            .foregroundColor(.appAccent)

            ForEach(Array(score.feedback.enumerated()), id: \.offset) { _, tip in
                HStack(alignment: .top, spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appAccent.opacity(0.1))
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                HapticManager.shared.playLight()
                dismiss()
                onTryAgain()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(Color.appPrimary)
                .cornerRadius(AppRadius.md)
            }

            Button {
                HapticManager.shared.playSuccess()
                dismiss()
                onNext()
            } label: {
                HStack {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(AppRadius.md)
            }
        }
    }
}

// MARK: - Metric Row Component

struct MetricRow: View {
    let icon: String
    let title: String
    let value: Double
    let color: Color

    @State private var animateProgress = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.appText)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appTextSecondary.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(
                                width: animateProgress ? geometry.size.width * value / 100 : 0,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }

            Text("\(Int(value))%")
                .font(.headline.monospacedDigit())
                .foregroundColor(.appText)
                .frame(width: 50, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Word Chip Component

struct WordChip: View {
    let wordScore: WordScore

    var body: some View {
        HStack(spacing: 4) {
            if wordScore.status != .omitted {
                Text(wordScore.word)
                    .font(.body.weight(.medium))
            } else {
                Text(wordScore.expected)
                    .font(.body.weight(.medium))
                    .strikethrough()
            }

            Image(systemName: wordScore.status.icon)
                .font(.caption2)
        }
        .foregroundColor(wordScore.status == .correct ? .white : .appText)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(wordScore.status.color.opacity(wordScore.status == .correct ? 1 : 0.2))
        .cornerRadius(AppRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .stroke(wordScore.status.color, lineWidth: wordScore.status == .correct ? 0 : 1)
        )
    }
}

// MARK: - Word Issue Row

struct WordIssueRow: View {
    let wordScore: WordScore

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: wordScore.status.icon)
                .foregroundColor(wordScore.status.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                if wordScore.status != .omitted {
                    Text(wordScore.word)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.appText)
                }

                if let suggestion = wordScore.suggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            if wordScore.accuracy > 0 {
                Text("\(Int(wordScore.accuracy))%")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(AppSpacing.sm)
        .background(Color.appBackground)
        .cornerRadius(AppRadius.sm)
    }
}

// MARK: - Flow Layout (for word chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(0, height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                let size = item.view.sizeThatFits(.unspecified)
                item.view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }

            y += row.height + spacing
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()

        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentRow.width + size.width + spacing > maxWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }

            currentRow.items.append(RowItem(view: subview))
            currentRow.width += size.width + spacing
            currentRow.height = max(currentRow.height, size.height)
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    struct Row {
        var items: [RowItem] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    struct RowItem {
        let view: LayoutSubview
    }
}

// MARK: - Preview

#Preview {
    SpeakingFeedbackView(
        score: PronunciationScore(
            overallScore: 85,
            accuracy: 90,
            fluency: 75,
            completeness: 90,
            wordScores: [
                WordScore(word: "Hello", expected: "Hello", accuracy: 100, status: .correct, suggestion: nil),
                WordScore(word: "how", expected: "how", accuracy: 85, status: .mispronounced, suggestion: "Try: how"),
                WordScore(word: "are", expected: "are", accuracy: 100, status: .correct, suggestion: nil)
            ],
            feedback: [
                "Great pronunciation overall!",
                "Work on the 'how' sound"
            ]
        ),
        targetText: "Hello, how are you?",
        onTryAgain: {},
        onNext: {}
    )
}
