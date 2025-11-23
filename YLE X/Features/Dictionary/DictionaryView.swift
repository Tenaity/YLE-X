//
//  DictionaryView.swift
//  YLE X
//
//  English-Vietnamese Dictionary
//  Created on 11/9/25.
//

import SwiftUI

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @StateObject private var audioService = AudioPlayerService()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar

                if searchText.isEmpty {
                    // Empty State
                    emptyState
                } else if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                    // No Results
                    noResultsState
                } else if viewModel.isSearching {
                    // Loading
                    loadingState
                } else {
                    // Results List
                    resultsList
                }
            }
            .navigationTitle("Dictionary")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appTextSecondary)
                        .font(.system(size: 16))

                    TextField("Search English or Vietnamese...", text: $searchText)
                        .focused($isSearchFocused)
                        .font(.system(size: 16))
                        .submitLabel(.search)
                        .onChange(of: searchText) { newValue in
                            Task {
                                await viewModel.fetchSuggestions(query: newValue)
                            }
                        }
                        .onSubmit {
                            Task {
                                viewModel.suggestions = []  // Hide suggestions on submit
                                await viewModel.searchWords(query: searchText)
                            }
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.clearSearch()
                        }) {
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
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(Color.appBackground)
            .zIndex(1)  // Ensure search bar is above suggestions

            // Suggestions List Overlay
            if !viewModel.suggestions.isEmpty && isSearchFocused {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.suggestions) { suggestion in
                            Button(action: {
                                searchText = suggestion.word
                                isSearchFocused = false
                                Task {
                                    viewModel.suggestions = []
                                    await viewModel.searchWords(query: suggestion.word)
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.word)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.appText)

                                        Text(suggestion.translationVi)
                                            .font(.system(size: 14))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 12))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.sm)
                                .background(Color.appBackground)
                            }
                            Divider()
                                .padding(.leading, AppSpacing.lg)
                        }
                    }
                }
                .frame(maxHeight: 250)
                .background(Color.appBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                .transition(.opacity)
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundColor(.appPrimary.opacity(0.3))

            VStack(spacing: AppSpacing.sm) {
                Text("English-Vietnamese Dictionary")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appText)

                Text("Search for any English or Vietnamese word")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: AppSpacing.sm) {
                Text("Popular Searches:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                HStack(spacing: AppSpacing.sm) {
                    ForEach(["hello", "thank you", "goodbye"] as [String], id: \.self) { word in
                        Button(action: {
                            searchText = word
                            Task {
                                await viewModel.searchWords(query: word)
                            }
                        }) {
                            Text(word)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color.appPrimary.opacity(0.1))
                                )
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
    }

    // MARK: - No Results State
    private var noResultsState: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)

            VStack(spacing: AppSpacing.sm) {
                Text("No results found")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appText)

                Text("Try searching with different words")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()
        }
    }

    // MARK: - Loading State
    private var loadingState: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Searching...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)

            Spacer()
        }
    }

    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.searchResults) { result in
                    DictionaryResultCard(result: result, audioService: audioService)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

// MARK: - Dictionary Result Card
struct DictionaryResultCard: View {
    let result: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService
    @State private var selectedExampleLevel: YLELevel = .starters

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Word Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(result.word)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appText)

                    Text(result.pronunciation.british.ipa)
                        .font(.system(size: 16))
                        .foregroundColor(.appTextSecondary)

                    Text(result.primaryPos)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary.opacity(0.1))
                        )
                }

                Spacer()

                // Pronunciation Button
                Button(action: {
                    audioService.playAudio(for: result, accent: .british)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                        )
                }
            }

            Divider()

            // Definition
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Definition:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                Text(result.definitionEn)
                    .font(.system(size: 16))
                    .foregroundColor(.appText)
            }

            // Vietnamese Translation
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Vietnamese:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                Text(result.translationVi)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appPrimary)
            }

            // Example Tabs
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Example:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(YLELevel.allCases, id: \.self) { level in
                        Button(action: {
                            withAnimation {
                                selectedExampleLevel = level
                            }
                        }) {
                            Text(level.rawValue.capitalized)
                                .font(
                                    .system(
                                        size: 14,
                                        weight: selectedExampleLevel == level ? .semibold : .medium)
                                )
                                .foregroundColor(
                                    selectedExampleLevel == level ? .white : .appTextSecondary
                                )
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .fill(
                                            selectedExampleLevel == level
                                                ? Color.appPrimary : Color.clear)
                                )
                        }
                    }
                }
                .padding(4)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .overlay(
                            Capsule()
                                .stroke(Color.appTextSecondary.opacity(0.1), lineWidth: 1)
                        )
                )

                // Example Content
                if let example = result.example(for: selectedExampleLevel) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(example.sentenceEn)
                            .font(.system(size: 15))
                            .foregroundColor(.appText)

                        Text(example.sentenceVi)
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                            .italic()
                    }
                    .padding(.top, 4)
                    .transition(.opacity)
                } else {
                    Text("No example for \(selectedExampleLevel.rawValue.capitalized)")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                        .italic()
                        .padding(.top, 4)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
        .onAppear {
            // Set initial level to the word's primary level
            selectedExampleLevel = result.level
        }
    }
}

// MARK: - Preview
#Preview {
    DictionaryView()
}
