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
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextSecondary)
                    .font(.system(size: 16))

                TextField("Search English or Vietnamese...", text: $searchText)
                    .focused($isSearchFocused)
                    .font(.system(size: 16))
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.search(query: searchText)
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
                    ForEach(["hello", "thank you", "goodbye"], id: \.self) { word in
                        Button(action: {
                            searchText = word
                            viewModel.search(query: word)
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
                    DictionaryResultCard(result: result)
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

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Word Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(result.word)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appText)

                    if let phonetic = result.phonetic {
                        Text("/\(phonetic)/")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextSecondary)
                    }

                    if let partOfSpeech = result.partOfSpeech {
                        Text(partOfSpeech)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.appPrimary.opacity(0.1))
                            )
                    }
                }

                Spacer()

                // Pronunciation Button
                Button(action: {
                    result.speak()
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

                Text(result.definition)
                    .font(.system(size: 16))
                    .foregroundColor(.appText)
            }

            // Vietnamese Translation
            if let vietnamese = result.vietnamese {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Vietnamese:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text(vietnamese)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
            }

            // Example
            if let example = result.example {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Example:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text(example)
                        .font(.system(size: 15))
                        .foregroundColor(.appTextSecondary)
                        .italic()
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }
}

// MARK: - Preview
#Preview {
    DictionaryView()
}
