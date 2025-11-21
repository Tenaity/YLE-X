//
//  DictionaryViewModel.swift
//  YLE X
//
//  Created on 11/18/25.
//  Firebase-powered Dictionary with 1,414 Cambridge words
//

import Combine
import FirebaseFirestore
import Foundation

@MainActor
class DictionaryViewModel: ObservableObject {
    // MARK: - Published Properties

    // Categories
    @Published var categories: [VocabularyCategory] = []
    @Published var selectedCategory: VocabularyCategory?

    // Words
    @Published var words: [DictionaryWord] = []
    @Published var selectedWord: DictionaryWord?
    @Published var featuredWords: [DictionaryWord] = []

    // Search
    @Published var searchQuery = ""
    @Published var searchResults: [DictionaryWord] = []

    // Filters
    @Published var selectedLevel: YLELevel = .starters
    @Published var showAllLevels = false

    // Loading States
    @Published var isLoadingCategories = false
    @Published var isLoadingWords = false
    @Published var isSearching = false

    // Error
    @Published var error: DictionaryError?

    // MARK: - Private Properties

    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var wordsCache: [String: [DictionaryWord]] = [:]  // category -> words

    // MARK: - Error Types

    enum DictionaryError: LocalizedError {
        case fetchFailed(String)
        case notFound
        case networkError

        var errorDescription: String? {
            switch self {
            case .fetchFailed(let message):
                return "Failed to load: \(message)"
            case .notFound:
                return "No words found"
            case .networkError:
                return "Network error. Please check your connection."
            }
        }
    }

    // MARK: - Initialization

    init() {
        setupSearchDebounce()
    }

    // MARK: - Search Debounce

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    Task {
                        await self?.searchWords(query: query)
                    }
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch Categories

    func fetchCategories() async {
        guard categories.isEmpty else { return }  // Only fetch once

        isLoadingCategories = true
        error = nil

        do {
            let snapshot = try await db.collection("categories")
                .order(by: "order")
                .getDocuments()

            categories = snapshot.documents.compactMap { document in
                try? document.data(as: VocabularyCategory.self)
            }

            isLoadingCategories = false

            print("✅ Loaded \(categories.count) categories")

        } catch {
            print("❌ Failed to fetch categories: \(error)")
            self.error = .fetchFailed("categories")
            isLoadingCategories = false
        }
    }

    // MARK: - Fetch Words by Category

    func fetchWords(for category: VocabularyCategory, level: YLELevel? = nil) async {
        // Check cache first
        let cacheKey = "\(category.categoryId)_\(level?.rawValue ?? "all")"
        if let cached = wordsCache[cacheKey] {
            words = cached
            selectedCategory = category
            return
        }

        isLoadingWords = true
        error = nil
        selectedCategory = category

        do {
            var query: Query = db.collection("dictionaries")
                .whereField("categories", arrayContains: category.categoryId)

            // Filter by level if specified
            if let level = level {
                query = query.whereField("levels", arrayContains: level.rawValue)
            }

            let snapshot =
                try await query
                .order(by: "word")
                .limit(to: 200)  // Limit for performance
                .getDocuments()

            let fetchedWords = snapshot.documents.compactMap { document in
                try? document.data(as: DictionaryWord.self)
            }

            words = fetchedWords
            wordsCache[cacheKey] = fetchedWords
            isLoadingWords = false

            print("✅ Loaded \(fetchedWords.count) words for \(category.name)")

        } catch {
            print("❌ Failed to fetch words: \(error)")
            self.error = .fetchFailed("words")
            isLoadingWords = false
        }
    }

    // MARK: - Search Words

    func searchWords(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedQuery = trimmedQuery.lowercased()
        let capitalizedQuery = lowercasedQuery.prefix(1).uppercased() + lowercasedQuery.dropFirst()

        do {
            // 1. Search by lowercase (e.g., "cat")
            let lowerQueryRef = db.collection("dictionaries")
                .whereField("word", isGreaterThanOrEqualTo: lowercasedQuery)
                .whereField("word", isLessThan: lowercasedQuery + "\u{f8ff}")
                .limit(to: 30)

            // 2. Search by capitalized (e.g., "Cat")
            let capitalQueryRef = db.collection("dictionaries")
                .whereField("word", isGreaterThanOrEqualTo: capitalizedQuery)
                .whereField("word", isLessThan: capitalizedQuery + "\u{f8ff}")
                .limit(to: 30)

            // Run queries concurrently
            async let lowerSnapshot = lowerQueryRef.getDocuments()
            async let capitalSnapshot = capitalQueryRef.getDocuments()

            let (lowerDocs, capitalDocs) = try await (lowerSnapshot, capitalSnapshot)

            var results: [DictionaryWord] = []

            // Process lowercase results
            let lowerWords = lowerDocs.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }
            results.append(contentsOf: lowerWords)

            // Process capitalized results
            let capitalWords = capitalDocs.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }
            results.append(contentsOf: capitalWords)

            // 3. Search in Vietnamese translations (client-side filter)
            // Note: For a large dataset, this should be an Algolia/Elasticsearch query.
            // Here we limit to a reasonable number to check.
            let allWordsQuery = db.collection("dictionaries")
                .limit(to: 200)  // Limit to avoid fetching too much

            let allSnapshot = try await allWordsQuery.getDocuments()
            let allWords = allSnapshot.documents.compactMap {
                try? $0.data(as: DictionaryWord.self)
            }

            let vietnameseMatches = allWords.filter {
                $0.translationVi.lowercased().contains(lowercasedQuery)
            }
            results.append(contentsOf: vietnameseMatches)

            // Deduplicate and sort
            // Use a Set of IDs to deduplicate
            var uniqueResults: [DictionaryWord] = []
            var seenIds: Set<String> = []

            for word in results {
                if let id = word.id, !seenIds.contains(id) {
                    seenIds.insert(id)
                    uniqueResults.append(word)
                } else if word.id == nil {
                    // Fallback if ID is missing (shouldn't happen with FirestoreCodable)
                    uniqueResults.append(word)
                }
            }

            searchResults = uniqueResults.sorted { $0.word < $1.word }
            isSearching = false

            print("✅ Found \(searchResults.count) results for '\(query)'")

        } catch {
            print("❌ Search failed: \(error)")
            self.error = .networkError
            isSearching = false
            searchResults = []
        }
    }

    // MARK: - Get Word by ID

    func fetchWord(id: String) async -> DictionaryWord? {
        do {
            let document = try await db.collection("dictionaries").document(id).getDocument()
            return try? document.data(as: DictionaryWord.self)
        } catch {
            print("❌ Failed to fetch word \(id): \(error)")
            return nil
        }
    }

    // MARK: - Featured Words (Random Words for Home)

    func fetchFeaturedWords(count: Int = 5) async {
        do {
            // Get random words (simple approach: get first N words)
            let snapshot = try await db.collection("dictionaries")
                .order(by: "word")
                .limit(to: count)
                .getDocuments()

            featuredWords = snapshot.documents.compactMap { document in
                try? document.data(as: DictionaryWord.self)
            }

            print("✅ Loaded \(featuredWords.count) featured words")

        } catch {
            print("❌ Failed to fetch featured words: \(error)")
        }
    }

    // MARK: - Filter by Level

    func filterByLevel(_ level: YLELevel, forCategory category: VocabularyCategory) async {
        selectedLevel = level
        await fetchWords(for: category, level: level)
    }

    // MARK: - Clear Search

    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }

    // MARK: - Select Category

    func selectCategory(_ category: VocabularyCategory) {
        selectedCategory = category
        Task {
            await fetchWords(for: category, level: showAllLevels ? nil : selectedLevel)
        }
    }

    // MARK: - Toggle Show All Levels

    func toggleShowAllLevels() {
        showAllLevels.toggle()
        if let category = selectedCategory {
            Task {
                await fetchWords(for: category, level: showAllLevels ? nil : selectedLevel)
            }
        }
    }

    // MARK: - Refresh

    func refresh() async {
        wordsCache.removeAll()
        categories.removeAll()
        await fetchCategories()
    }
}

// MARK: - Preview Helpers

#if DEBUG
    extension DictionaryViewModel {
        static let preview: DictionaryViewModel = {
            let vm = DictionaryViewModel()
            vm.categories = VocabularyCategory.samples
            vm.words = DictionaryWord.samples
            vm.selectedCategory = VocabularyCategory.sample
            return vm
        }()
    }
#endif
