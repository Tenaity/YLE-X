//
//  DictionaryView.swift
//  YLE X
//
//  English-Vietnamese Dictionary
//  Created on 11/9/25.
//  Enhanced on 11/23/25 - Improved UI/UX for search, suggestions, and results
//

import SwiftUI

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @StateObject private var audioService = AudioPlayerService()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showSuggestions = false
    @State private var hasSearched = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Color.clear.frame(height: 80)

                    ZStack {
                        if searchText.isEmpty && !hasSearched {
                            emptyState
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else if viewModel.isSearching {
                            loadingState
                                .transition(.opacity)
                        } else if viewModel.searchResults.isEmpty && hasSearched {
                            noResultsState
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else if !viewModel.searchResults.isEmpty {
                            resultsList
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .animation(.appSmooth, value: searchText.isEmpty)
                    .animation(.appSmooth, value: viewModel.isSearching)
                    .animation(.appSmooth, value: viewModel.searchResults.isEmpty)
                }

                searchBar.zIndex(200)

                if !viewModel.suggestions.isEmpty && showSuggestions && isSearchFocused {
                    suggestionsOverlay
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .zIndex(100)
                }
            }
            .navigationTitle("Dictionary")
            .navigationBarTitleDisplayMode(.large)
            .onTapGesture {
                isSearchFocused = false
                showSuggestions = false
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: isSearchFocused ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    .foregroundColor(isSearchFocused ? .appPrimary : .appTextSecondary)
                    .font(.system(size: 20, weight: isSearchFocused ? .semibold : .regular))
                    .animation(.appBouncy, value: isSearchFocused)

                TextField("Search English or Vietnamese...", text: $searchText)
                    .focused($isSearchFocused)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.appText)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { oldValue, newValue in
                        if !newValue.isEmpty {
                            showSuggestions = true
                            hasSearched = false
                            Task {
                                await viewModel.fetchSuggestions(query: newValue)
                            }
                        } else {
                            showSuggestions = false
                            hasSearched = false
                            viewModel.suggestions = []
                            viewModel.searchResults = []
                        }
                    }
                    .onSubmit {
                        showSuggestions = false
                        isSearchFocused = false
                        hasSearched = true
                        HapticManager.shared.playLight()
                        Task {
                            viewModel.suggestions = []
                            await viewModel.searchWords(query: searchText)
                        }
                    }

                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.appQuick) {
                            searchText = ""
                            showSuggestions = false
                            hasSearched = false
                            viewModel.clearSearch()
                            HapticManager.shared.playLight()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                            .font(.system(size: 18))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .strokeBorder(
                                isSearchFocused ? Color.appPrimary.opacity(0.5) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .appShadow(level: isSearchFocused ? .medium : .subtle)
            .animation(.appBouncy, value: isSearchFocused)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Color.appBackground)
    }

    // MARK: - Suggestions Overlay (New Design)
    private var suggestionsOverlay: some View {
        VStack(spacing: 0) {
            // Top spacer to position below search bar
            Color.clear
                .frame(height: 100)

            // Suggestions Card
            VStack(spacing: 0) {
                // Compact suggestions list (max 5 items)
                ForEach(Array(viewModel.suggestions.prefix(5).enumerated()), id: \.element.id) { index, suggestion in
                    Button(action: {
                        withAnimation(.appSmooth) {
                            searchText = suggestion.word
                            showSuggestions = false
                            isSearchFocused = false
                            hasSearched = true
                            HapticManager.shared.playSelection()
                        }
                        Task {
                            viewModel.suggestions = []
                            await viewModel.searchExactWord(word: suggestion.word)
                        }
                    }) {
                        HStack(spacing: AppSpacing.md) {
                            // Letter circle
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

                                Text(suggestion.word.prefix(1).uppercased())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appPrimary)
                            }

                            // Word info
                            VStack(alignment: .leading, spacing: 3) {
                                Text(suggestion.word)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.appText)

                                Text(suggestion.translationVi)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            // Arrow icon
                            Image(systemName: "arrow.up.left.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.appPrimary.opacity(0.3))
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(index % 2 == 0 ? Color.appBackground : Color(UIColor.secondarySystemBackground).opacity(0.5))
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .appShadow(level: .medium)
            )
            .padding(.horizontal, AppSpacing.lg)

            Spacer()

            // Dimmed background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.appQuick) {
                        showSuggestions = false
                        isSearchFocused = false
                    }
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl2) {
                Spacer(minLength: 40)

                // Animated Book Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.15),
                                    Color.appPrimary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.appPrimary)
                }

                VStack(spacing: AppSpacing.md) {
                    Text("📚 Dictionary")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.appText)

                    Text("Search 1,400+ Cambridge words\nEnglish - Vietnamese")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Popular Searches
                VStack(spacing: AppSpacing.md) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.appAccent)

                        Text("Try these popular words")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                        ForEach(["hello", "thank you", "goodbye", "friend", "learn", "happy"], id: \.self) { word in
                            Button(action: {
                                withAnimation(.appBouncy) {
                                    searchText = word
                                    hasSearched = true
                                    HapticManager.shared.playLight()
                                }
                                Task {
                                    await viewModel.searchWords(query: word)
                                }
                            }) {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 12))
                                        .foregroundColor(.appPrimary)

                                    Text(word)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.appText)

                                    Spacer()
                                }
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                        .appShadow(level: .subtle)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.xl)
        }
    }

    // MARK: - No Results State
    private var noResultsState: some View {
        VStack(spacing: AppSpacing.xl2) {
            Spacer()

            // Animated Icon
            ZStack {
                Circle()
                    .fill(Color.appTextSecondary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "exclamationmark.magnifyingglass")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                Text("No results for '\(searchText)'")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)

                VStack(spacing: AppSpacing.sm) {
                    Text("Try these tips:")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        tipRow(icon: "checkmark.circle", text: "Check your spelling")
                        tipRow(icon: "checkmark.circle", text: "Try different keywords")
                        tipRow(icon: "checkmark.circle", text: "Search in English or Vietnamese")
                    }
                }
            }
            .padding(.horizontal, AppSpacing.xl)

            // Clear button
            Button(action: {
                withAnimation(.appBouncy) {
                    searchText = ""
                    hasSearched = false
                    viewModel.clearSearch()
                    HapticManager.shared.playLight()
                }
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Clear Search")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    Capsule()
                        .fill(Color.appPrimary)
                        .appShadow(level: .medium)
                )
            }

            Spacer()
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.appPrimary)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
    }

    // MARK: - Loading State (Skeleton)
    private var loadingState: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Skeleton loading cards
                ForEach(0..<3, id: \.self) { _ in
                    skeletonCard
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    // Word skeleton
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appTextSecondary.opacity(0.2))
                        .frame(width: 120, height: 24)
                        .shimmer()

                    // IPA skeleton
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appTextSecondary.opacity(0.15))
                        .frame(width: 80, height: 16)
                        .shimmer()

                    // POS skeleton
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appTextSecondary.opacity(0.15))
                        .frame(width: 60, height: 24)
                        .shimmer()
                }

                Spacer()

                // Audio button skeleton
                Circle()
                    .fill(Color.appTextSecondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .shimmer()
            }

            Divider()

            // Definition skeleton
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appTextSecondary.opacity(0.15))
                    .frame(height: 14)
                    .shimmer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appTextSecondary.opacity(0.1))
                    .frame(width: 200, height: 14)
                    .shimmer()
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Results header
                HStack {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.appSuccess)

                        Text("Found \(viewModel.searchResults.count) result\(viewModel.searchResults.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    Text("for '\(searchText)'")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color.appBackground)

                // Results cards
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                    NavigationLink(destination: WordDetailView(word: result, audioService: audioService)) {
                        DictionaryResultCard(result: result, audioService: audioService)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.appSmooth.delay(Double(index) * 0.05), value: viewModel.searchResults.count)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

// MARK: - Shimmer Effect Modifier
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 300)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}


// MARK: - Dictionary Result Card
struct DictionaryResultCard: View {
    let result: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Compact Header (Always visible)
            HStack(spacing: AppSpacing.md) {
                // Word initial circle
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
                        .frame(width: 50, height: 50)

                    Text(result.word.prefix(1).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appPrimary)
                }

                // Word info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.word)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)

                    HStack(spacing: AppSpacing.sm) {
                        Text(result.pronunciation.british.ipa)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        Text("•")
                            .foregroundColor(.appTextSecondary.opacity(0.5))

                        Text(result.primaryPos)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.appPrimary.opacity(0.12))
                            )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                }

                Spacer()

                // Audio button
                Button(action: {
                    audioService.playAudio(for: result, accent: .british)
                    HapticManager.shared.playLight()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appPrimary)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.lg)

            // Vietnamese Translation (Always visible)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appAccent)

                    Text("Vietnamese")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                        .textCase(.uppercase)
                }

                Text(result.translationVi)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)
                    .lineLimit(isExpanded ? nil : 2)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)

            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Divider()
                        .padding(.horizontal, AppSpacing.lg)

                    // Definition
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.appInfo)

                            Text("Definition")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                                .textCase(.uppercase)
                        }

                        Text(result.definitionEn)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appText)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    // Example
                    if let example = result.example(for: result.level) {
                        Divider()
                            .padding(.horizontal, AppSpacing.lg)

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "quote.bubble.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appSuccess)

                                Text("Example")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                    .textCase(.uppercase)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("\"\(example.sentenceEn)\"")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.appText)
                                    .italic()

                                Text("\"\(example.sentenceVi)\"")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                    .italic()
                            }
                            .padding(.leading, AppSpacing.md)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    // Level badges
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextSecondary)

                        Text("Levels:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        ForEach(result.levels, id: \.self) { levelStr in
                            if let level = YLELevel(rawValue: levelStr) {
                                Text(level.displayName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: level.color) ?? .blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill((Color(hex: level.color) ?? .blue).opacity(0.15))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.sm)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Expand/Collapse button
            Button(action: {
                withAnimation(.appBouncy) {
                    isExpanded.toggle()
                    HapticManager.shared.playLight()
                }
            }) {
                HStack {
                    Spacer()

                    HStack(spacing: 6) {
                        Text(isExpanded ? "Show Less" : "Show More")
                            .font(.system(size: 13, weight: .semibold))

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .foregroundColor(.appPrimary)

                    Spacer()
                }
                .padding(.vertical, AppSpacing.sm)
                .background(Color.appPrimary.opacity(0.05))
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(Color.appPrimary.opacity(0.15), lineWidth: 1)
        )
        .appShadow(level: isExpanded ? .medium : .light)
        .animation(.appBouncy, value: isExpanded)
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Preview
#Preview {
    DictionaryView()
}
