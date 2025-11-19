//
//  WordListView.swift
//  YLE X
//
//  Created on 11/18/25.
//  Shows list of words in selected category with level filtering
//

import SwiftUI

struct WordListView: View {
    let category: VocabularyCategory
    @State var selectedLevel: YLELevel

    @StateObject private var viewModel = DictionaryViewModel()
    @StateObject private var audioService = AudioPlayerService()
    @Environment(\.dismiss) private var dismiss

    @State private var showAllLevels = false
    @State private var searchText = ""

    var filteredWords: [DictionaryWord] {
        if searchText.isEmpty {
            return viewModel.words
        } else {
            let query = searchText.lowercased()
            return viewModel.words.filter {
                $0.word.lowercased().contains(query) ||
                $0.translationVi.lowercased().contains(query)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Level Filter Bar
                if !showAllLevels {
                    levelFilterBar
                }

                // Content
                if viewModel.isLoadingWords {
                    loadingView
                } else if filteredWords.isEmpty {
                    emptyView
                } else {
                    wordsList
                }
            }
        }
        .navigationTitle("\(category.icon) \(category.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section {
                        NavigationLink {
                            FlashcardDeckView(category: category, level: selectedLevel)
                        } label: {
                            Label("Flashcards", systemImage: "rectangle.portrait.on.rectangle.portrait")
                        }

                        NavigationLink {
                            QuizView(category: category, level: selectedLevel)
                        } label: {
                            Label("Quiz", systemImage: "questionmark.circle")
                        }
                    }

                    Section {
                        showAllLevelsToggle
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .task {
            await viewModel.fetchWords(
                for: category,
                level: showAllLevels ? nil : selectedLevel
            )
        }
        .onChange(of: showAllLevels) { _, newValue in
            Task {
                await viewModel.fetchWords(
                    for: category,
                    level: newValue ? nil : selectedLevel
                )
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextSecondary)
                    .font(.system(size: 16))

                TextField("Search...", text: $searchText)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.appBackgroundSecondary)
            )
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Level Filter Bar

    private var levelFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(YLELevel.allCases, id: \.self) { level in
                    LevelFilterChip(
                        level: level,
                        isSelected: level == selectedLevel,
                        action: {
                            withAnimation(.appSmooth) {
                                selectedLevel = level
                            }
                            HapticManager.shared.playSelection()
                            Task {
                                await viewModel.filterByLevel(level, forCategory: category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color.appBackgroundSecondary)
    }

    // MARK: - Show All Levels Toggle

    private var showAllLevelsToggle: some View {
        Button(action: {
            withAnimation(.appSmooth) {
                showAllLevels.toggle()
            }
            HapticManager.shared.playLight()
        }) {
            HStack(spacing: 6) {
                Image(systemName: showAllLevels ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                Text("All Levels")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(showAllLevels ? .appPrimary : .appTextSecondary)
        }
    }

    // MARK: - Words List

    private var wordsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                // Word count header
                HStack {
                    Text("\(filteredWords.count) words")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Spacer()

                    if !showAllLevels {
                        HStack(spacing: 4) {
                            Text(selectedLevel.icon)
                            Text(selectedLevel.displayName)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(hex: selectedLevel.color) ?? .blue)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)

                // Words
                ForEach(filteredWords) { word in
                    NavigationLink {
                        WordDetailView(word: word, audioService: audioService)
                    } label: {
                        WordRow(word: word, audioService: audioService)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appPrimary)

            Text("Loading words...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppSpacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(category.swiftUIColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Text(selectedLevel.icon)
                    .font(.system(size: 50))
            }

            VStack(spacing: AppSpacing.sm) {
                if searchText.isEmpty {
                    Text("No words found")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Try selecting a different level")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No results for '\(searchText)'")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Try a different search")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

// MARK: - Level Filter Chip

struct LevelFilterChip: View {
    let level: YLELevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(level.icon)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 0) {
                    Text(level.displayName)
                        .font(.system(size: 13, weight: .bold))
                    Text(level.displayNameVi)
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? (Color(hex: level.color) ?? .blue) : Color.clear)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        Color(hex: level.color) ?? .blue,
                        lineWidth: isSelected ? 0 : 1.5
                    )
            )
            .foregroundColor(isSelected ? .white : (Color(hex: level.color) ?? .blue))
        }
    }
}

// MARK: - Word Row

struct WordRow: View {
    let word: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Left side - Word info
            VStack(alignment: .leading, spacing: 6) {
                // Word
                HStack(spacing: 8) {
                    Text(word.word)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.appText)

                    // Level badge (if multiple levels)
                    if word.levels.count > 1 {
                        Text(word.level.icon)
                            .font(.system(size: 12))
                    }
                }

                // Translation
                Text(word.translationVi)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                // Part of speech + IPA
                HStack(spacing: 8) {
                    // POS badge
                    Text(word.primaryPos)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary.opacity(0.12))
                        )

                    // IPA
                    Text(word.pronunciation.british.ipa)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Right side - Audio button
            Button(action: {
                audioService.playAudio(for: word, accent: .british)
                HapticManager.shared.playLight()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .strokeBorder(
                    Color.appPrimary.opacity(isPressed ? 0.3 : 0),
                    lineWidth: 2
                )
        )
        .appShadow(level: .subtle)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.appBouncy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WordListView(
            category: VocabularyCategory.sample,
            selectedLevel: .starters
        )
    }
}
