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
        .toolbar(.hidden, for: .tabBar)
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

    // MARK: - Audio Section (Redesigned)

    private var audioSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header with gradient background
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.2),
                                    Color.appPrimary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Pronunciation")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Tap to hear")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                // Playing indicator (animated)
                if audioService.isPlaying {
                    HStack(spacing: 3) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appPrimary)
                                .frame(width: 3, height: 12)
                                .scaleEffect(y: audioService.isPlaying ? 1.5 : 0.5, anchor: .bottom)
                                .animation(
                                    .easeInOut(duration: 0.4)
                                    .repeatForever()
                                    .delay(Double(index) * 0.15),
                                    value: audioService.isPlaying
                                )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary.opacity(0.15))
                    )
                }
            }

            // Audio buttons with vertical stack for better mobile UX
            VStack(spacing: AppSpacing.md) {
                // British
                ModernAudioButton(
                    accent: .british,
                    ipa: word.pronunciation.british.ipa,
                    isSelected: selectedAccent == .british,
                    isPlaying: audioService.isPlaying && selectedAccent == .british,
                    hasAudio: word.pronunciation.british.hasAudio,
                    audioSource: word.pronunciation.british.audioSource,
                    action: {
                        withAnimation(.appBouncy) {
                            selectedAccent = .british
                        }
                        audioService.playAudio(for: word, accent: .british)
                        HapticManager.shared.playMedium()
                    }
                )

                // American
                ModernAudioButton(
                    accent: .american,
                    ipa: word.pronunciation.american.ipa,
                    isSelected: selectedAccent == .american,
                    isPlaying: audioService.isPlaying && selectedAccent == .american,
                    hasAudio: word.pronunciation.american.hasAudio,
                    audioSource: word.pronunciation.american.audioSource,
                    action: {
                        withAnimation(.appBouncy) {
                            selectedAccent = .american
                        }
                        audioService.playAudio(for: word, accent: .american)
                        HapticManager.shared.playMedium()
                    }
                )
            }

            // Currently playing info
            if audioService.isPlaying {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "music.note")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Audio source:")
                        .font(.system(size: 13, weight: .medium))

                    Text(audioService.audioSource.displayName)
                        .font(.system(size: 13, weight: .bold))

                    Spacer()

                    // Waveform animation
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Capsule()
                                .fill(Color.appSuccess)
                                .frame(width: 2, height: CGFloat.random(in: 6...14))
                                .animation(
                                    .easeInOut(duration: 0.3)
                                    .repeatForever()
                                    .delay(Double(index) * 0.1),
                                    value: audioService.isPlaying
                                )
                        }
                    }
                }
                .foregroundColor(.appSuccess)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.appSuccess.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .strokeBorder(Color.appSuccess.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color.appBackgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.1),
                                    Color.appPrimary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .appShadow(level: .medium)
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
                            .padding(.vertical, 4)
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

            DictionaryFlowLayout(spacing: 8) {
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

// MARK: - Modern Audio Button (Redesigned)

struct ModernAudioButton: View {
    let accent: AudioAccent
    let ipa: String
    let isSelected: Bool
    let isPlaying: Bool
    let hasAudio: Bool
    let audioSource: String
    let action: () -> Void

    @State private var isPressed = false
    @State private var rotationDegrees: Double = 0

    var body: some View {
        Button(action: {
            isPressed = true
            HapticManager.shared.playMedium()
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                // Flag circle - Top left corner
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [
                                    Color.appPrimary,
                                    Color.appPrimary.opacity(0.8)
                                ] : [
                                    Color.appPrimary.opacity(0.15),
                                    Color.appPrimary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.white.opacity(0.3) : Color.clear,
                                    lineWidth: 2
                                )
                        )

                    Text(accent.flag)
                        .font(.system(size: 18))
                }
                .scaleEffect(isPlaying && isSelected ? 1.05 : 1.0)

                // Content - 3 rows of info (spread evenly)
                VStack(alignment: .leading, spacing: 0) {
                    // Row 1: Accent name
                    Text(accent.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected ? .white : .appText)
                        .lineLimit(1)

                    Spacer()
                        .frame(height: 6)

                    // Row 2: Audio quality badge
                    HStack(spacing: 4) {
                        Image(systemName: hasAudio ? "checkmark.circle.fill" : "waveform")
                            .font(.system(size: 9, weight: .semibold))

                        Text(hasAudio ? audioSource : "TTS")
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .lineLimit(1)
                    }
                    .foregroundColor(hasAudio ? .appSuccess : .appTextSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(hasAudio ? Color.appSuccess.opacity(0.15) : Color.appTextSecondary.opacity(0.1))
                    )
                    .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                        .frame(height: 6)

                    // Row 3: IPA pronunciation
                    HStack(spacing: 4) {
                        Image(systemName: "textformat.abc")
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? .white.opacity(0.7) : .appTextSecondary)

                        Text(ipa)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(isSelected ? .white : .appText)
                            .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Play button - Right side
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.appPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: isPlaying && isSelected ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .appPrimary)
                        .rotationEffect(.degrees(rotationDegrees))
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color.appPrimary,
                                Color.appPrimary.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.appBackground,
                                Color.appBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .strokeBorder(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.3),
                                Color.appPrimary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .appShadow(level: isSelected ? .medium : .subtle)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPlaying)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .onChange(of: isPlaying) { oldValue, newValue in
            if newValue && isSelected {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotationDegrees = 360
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    rotationDegrees = 0
                }
            }
        }
    }
}

// MARK: - Audio Button (Legacy - Keep for compatibility)

struct AudioButton: View {
    let accent: AudioAccent
    let ipa: String
    let isSelected: Bool
    let isPlaying: Bool
    let hasAudio: Bool
    let audioSource: String
    let action: () -> Void

    var body: some View {
        ModernAudioButton(
            accent: accent,
            ipa: ipa,
            isSelected: isSelected,
            isPlaying: isPlaying,
            hasAudio: hasAudio,
            audioSource: audioSource,
            action: action
        )
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

struct DictionaryFlowLayout: Layout {
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
