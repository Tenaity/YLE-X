//
//  VocabularyCategoriesView.swift
//  YLE X
//
//  Created on 11/18/25.
//  Main vocabulary screen with 20 colorful category cards
//

import SwiftUI

struct VocabularyCategoriesView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @State private var selectedLevel: YLELevel = .starters
    @State private var showLevelInfo = false
    @State private var selectedCategoryForFlashcard: VocabularyCategory?
    @State private var selectedCategoryForQuiz: VocabularyCategory?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color.appBackground.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.isLoadingCategories {
                    loadingView
                } else if viewModel.categories.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle("📚 Vocabulary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    levelMenu
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .fullScreenCover(item: $selectedCategoryForFlashcard) { category in
                NavigationStack {
                    FlashcardDeckView(category: category, level: selectedLevel)
                }
            }
            .fullScreenCover(item: $selectedCategoryForQuiz) { category in
                NavigationStack {
                    QuizView(category: category, level: selectedLevel)
                }
            }
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                headerSection
                    .padding(.top, AppSpacing.md)

                // Category Grid
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(viewModel.categories) { category in
                        CategoryCardWithActions(
                            category: category,
                            selectedLevel: selectedLevel,
                            selectedCategoryForFlashcard: $selectedCategoryForFlashcard,
                            selectedCategoryForQuiz: $selectedCategoryForQuiz
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Title
            Text("Choose a Topic")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appText)

            // Subtitle
            HStack(spacing: 4) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                Text("1,414 Cambridge Words")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.appTextSecondary)

            // Level Badge
            Button(action: { showLevelInfo.toggle() }) {
                HStack(spacing: AppSpacing.sm) {
                    Text(selectedLevel.icon)
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedLevel.displayName)
                            .font(.system(size: 16, weight: .bold))
                        Text(selectedLevel.displayNameVi)
                            .font(.system(size: 12, weight: .medium))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .frame(maxWidth: 300)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(Color(hex: selectedLevel.color) ?? .blue)
                )
                .appShadow(level: .medium)
            }
            .sheet(isPresented: $showLevelInfo) {
                LevelSelectionSheet(selectedLevel: $selectedLevel)
                    .presentationDetents([.medium])
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Level Menu

    private var levelMenu: some View {
        Menu {
            ForEach(YLELevel.allCases, id: \.self) { level in
                Button(action: {
                    withAnimation(.appSmooth) {
                        selectedLevel = level
                    }
                    HapticManager.shared.playLight()
                }) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("\(level.icon) \(level.displayName)")
                            Text(level.ageRange)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        if level == selectedLevel {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.title3)
                .foregroundColor(.appPrimary)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.xl) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appPrimary)

            VStack(spacing: AppSpacing.sm) {
                Text("Loading Categories...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appText)

                Text("Please wait")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
            }
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppSpacing.xl2) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appPrimary)
            }

            VStack(spacing: AppSpacing.md) {
                Text("No Categories Found")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appText)

                Text("Please check your Firebase connection\nand make sure data is uploaded")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Retry button
            Button(action: {
                Task {
                    await viewModel.refresh()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    Capsule()
                        .fill(Color.appPrimary)
                )
                .appShadow(level: .light)
            }
        }
        .padding(AppSpacing.xl)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: VocabularyCategory
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Icon with circle background
            ZStack {
                Circle()
                    .fill(category.swiftUIColor.opacity(0.15))
                    .frame(width: 70, height: 70)

                Text(category.icon)
                    .font(.system(size: 40))
            }

            // Text content
            VStack(spacing: 4) {
                // English name
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Vietnamese name
                Text(category.nameVi)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(height: 50)

            // Word count badge
            HStack(spacing: 4) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 10))
                Text("\(category.wordCount)")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(category.swiftUIColor)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(category.swiftUIColor.opacity(0.15))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color.appBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(
                    category.swiftUIColor.opacity(isPressed ? 0.6 : 0.3),
                    lineWidth: isPressed ? 3 : 2
                )
        )
        .appShadow(level: isPressed ? .medium : .light)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.appBouncy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
            if pressing {
                HapticManager.shared.playLight()
            }
        }, perform: {})
    }
}

// MARK: - Level Selection Sheet

struct LevelSelectionSheet: View {
    @Binding var selectedLevel: YLELevel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(YLELevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedLevel = level
                        HapticManager.shared.playSelection()
                        dismiss()
                    }) {
                        HStack(spacing: AppSpacing.md) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: level.color)?.opacity(0.15) ?? .blue.opacity(0.15))
                                    .frame(width: 50, height: 50)

                                Text(level.icon)
                                    .font(.system(size: 28))
                            }

                            // Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.displayName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appText)

                                Text(level.displayNameVi)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appTextSecondary)

                                Text(level.ageRange)
                                    .font(.system(size: 12))
                                    .foregroundColor(.appTextSecondary)
                            }

                            Spacer()

                            if level == selectedLevel {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(hex: level.color) ?? .blue)
                            }
                        }
                        .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Category Card with Actions

struct CategoryCardWithActions: View {
    let category: VocabularyCategory
    let selectedLevel: YLELevel
    @Binding var selectedCategoryForFlashcard: VocabularyCategory?
    @Binding var selectedCategoryForQuiz: VocabularyCategory?

    @State private var showActionSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Main category card
            NavigationLink {
                WordListView(
                    category: category,
                    selectedLevel: selectedLevel
                )
            } label: {
                CategoryCard(category: category)
            }
            .buttonStyle(.plain)

            // Quick actions
            HStack(spacing: 0) {
                // Flashcards button
                Button {
                    selectedCategoryForFlashcard = category
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                            .font(.system(size: 12))
                        Text("Cards")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(category.swiftUIColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(category.swiftUIColor.opacity(0.1))
                }
                .buttonStyle(.plain)

                Divider()
                    .frame(height: 20)

                // Quiz button
                Button {
                    selectedCategoryForQuiz = category
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12))
                        Text("Quiz")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(category.swiftUIColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(category.swiftUIColor.opacity(0.1))
                }
                .buttonStyle(.plain)
            }
            .background(Color.appBackgroundSecondary)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(
                    category.swiftUIColor.opacity(0.3),
                    lineWidth: 2
                )
        )
        .appShadow(level: .light)
    }
}

// MARK: - Preview

#Preview {
    VocabularyCategoriesView()
}
