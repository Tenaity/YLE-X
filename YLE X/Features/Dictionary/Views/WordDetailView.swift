//
//  WordDetailView.swift
//  YLE X
//
//  Created on 11/18/25.
//  Full word detail with audio, definitions, and examples
//

import SwiftUI

struct WordDetailView: View {
    let word: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService

    @State private var selectedAccent: AudioAccent = .british
    @State private var showAllExamples = false

    // Get examples up to user's level (default: show all for now)
    private var displayedExamples: [Example] {
        showAllExamples ? word.examples : Array(word.examples.prefix(2))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                headerSection

                // Audio Controls
                audioSection

                // Definitions
                definitionsSection

                // Examples
                examplesSection

                // Grammar Info
                grammarSection

                // Categories
                categoriesSection
            }
            .padding(AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Emoji (if available)
            if let emoji = word.emoji {
                Text(emoji)
                    .font(.system(size: 80))
            }

            // Word
            Text(word.word)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.appText)

            // Translation
            Text(word.translationVi)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.appPrimary)

            // Level badge
            HStack(spacing: 8) {
                Text(word.level.icon)
                Text(word.level.displayName)
                    .font(.system(size: 14, weight: .bold))
                Text("•")
                    .foregroundColor(.appTextSecondary)
                Text(word.primaryPos)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(Color(hex: word.level.color) ?? .blue)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(Color(hex: word.level.color)?.opacity(0.15) ?? .blue.opacity(0.15))
            )
        }
        .padding(.vertical, AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .light)
    }

    // MARK: - Audio Section

    private var audioSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Section title
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 16))
                Text("Pronunciation")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundColor(.appText)

            // Audio buttons
            HStack(spacing: AppSpacing.md) {
                // British
                AudioButton(
                    accent: .british,
                    ipa: word.pronunciation.british.ipa,
                    isSelected: selectedAccent == .british,
                    isPlaying: audioService.isPlaying && selectedAccent == .british,
                    hasAudio: word.pronunciation.british.hasAudio,
                    audioSource: word.pronunciation.british.audioSource,
                    action: {
                        selectedAccent = .british
                        audioService.playAudio(for: word, accent: .british)
                        HapticManager.shared.playMedium()
                    }
                )

                // American
                AudioButton(
                    accent: .american,
                    ipa: word.pronunciation.american.ipa,
                    isSelected: selectedAccent == .american,
                    isPlaying: audioService.isPlaying && selectedAccent == .american,
                    hasAudio: word.pronunciation.american.hasAudio,
                    audioSource: word.pronunciation.american.audioSource,
                    action: {
                        selectedAccent = .american
                        audioService.playAudio(for: word, accent: .american)
                        HapticManager.shared.playMedium()
                    }
                )
            }

            // Audio source indicator
            if audioService.isPlaying {
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.system(size: 12))

                    Text("Playing: \(audioService.audioSource.displayName)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.appPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.appPrimary.opacity(0.1))
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }

    // MARK: - Definitions Section

    private var definitionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Section title
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 16))
                Text("Definitions")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundColor(.appText)

            // English definition
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("🇬🇧")
                    Text("English")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }

                Text(word.definitionEn)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.appText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.appBackground)
            )

            // Vietnamese definition
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("🇻🇳")
                    Text("Tiếng Việt")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }

                Text(word.definitionVi)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.appText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.appPrimary.opacity(0.05))
            )
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }

    // MARK: - Examples Section

    private var examplesSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Section title
            HStack {
                Image(systemName: "text.quote")
                    .font(.system(size: 16))
                Text("Example Sentences")
                    .font(.system(size: 18, weight: .bold))
                Spacer()

                if word.examples.count > 2 {
                    Button(action: {
                        withAnimation(.appSmooth) {
                            showAllExamples.toggle()
                        }
                    }) {
                        Text(showAllExamples ? "Show Less" : "Show All")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .foregroundColor(.appText)

            // Examples
            ForEach(displayedExamples) { example in
                ExampleCard(example: example)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }

    // MARK: - Grammar Section

    private var grammarSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 16))
                Text("Grammar Info")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundColor(.appText)

            // Part of speech
            HStack {
                Text("Parts of Speech:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(word.partOfSpeech, id: \.self) { pos in
                        Text(pos)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.appPrimary.opacity(0.12))
                            )
                    }
                }
            }

            Divider()

            // Levels
            HStack {
                Text("YLE Levels:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(word.levels, id: \.self) { levelStr in
                        if let level = YLELevel(rawValue: levelStr) {
                            HStack(spacing: 4) {
                                Text(level.icon)
                                Text(level.displayName)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: level.color) ?? .blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical: 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: level.color)?.opacity(0.12) ?? .blue.opacity(0.12))
                            )
                        }
                    }
                }
            }

            if word.irregularPlural == true {
                Divider()

                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)

                    Text("Has irregular plural form")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)

                    Spacer()
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                Text("Categories")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundColor(.appText)

            FlowLayout(spacing: 8) {
                ForEach(word.categories, id: \.self) { categoryId in
                    if let categoryType = CategoryType(rawValue: categoryId) {
                        HStack(spacing: 6) {
                            Text(categoryType.icon)
                            Text(categoryType.displayName)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.appText)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.appBackgroundSecondary)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.appTextSecondary.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }
}

// MARK: - Audio Button

struct AudioButton: View {
    let accent: AudioAccent
    let ipa: String
    let isSelected: Bool
    let isPlaying: Bool
    let hasAudio: Bool
    let audioSource: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                // Flag + Name
                HStack(spacing: 8) {
                    Text(accent.flag)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(accent.displayName)
                            .font(.system(size: 15, weight: .bold))

                        // Audio source badge
                        if hasAudio {
                            Text(audioSource)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appSuccess)
                        } else {
                            Text("TTS")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }

                    Spacer()

                    // Speaker icon
                    Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .appPrimary)
                }

                Divider()

                // IPA
                Text(ipa)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? .white : .appText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(isSelected ? Color.appPrimary : Color.appBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .strokeBorder(
                        isSelected ? Color.clear : Color.appPrimary.opacity(0.3),
                        lineWidth: 2
                    )
            )
            .appShadow(level: isSelected ? .medium : .subtle)
            .scaleEffect(isPlaying ? 1.02 : 1.0)
            .animation(.appBouncy, value: isPlaying)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Example Card

struct ExampleCard: View {
    let example: Example

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Level badge
            HStack(spacing: 6) {
                Text(example.levelEnum.icon)
                Text(example.levelEnum.displayName)
                    .font(.system(size: 12, weight: .bold))
                Text(example.levelEnum.displayNameVi)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(Color(hex: example.levelEnum.color) ?? .blue)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(hex: example.levelEnum.color)?.opacity(0.12) ?? .blue.opacity(0.12))
            )

            // English sentence
            Text(example.sentenceEn)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appText)
                .fixedSize(horizontal: false, vertical: true)

            // Vietnamese translation
            Text(example.sentenceVi)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.appTextSecondary)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color.appBackground)
        )
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }

        totalHeight += lineHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }

            subview.place(
                at: CGPoint(x: lineX, y: lineY),
                proposal: ProposedViewSize(size)
            )

            lineHeight = max(lineHeight, size.height)
            lineX += size.width + spacing
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WordDetailView(
            word: DictionaryWord.sample,
            audioService: AudioPlayerService.preview
        )
    }
}
