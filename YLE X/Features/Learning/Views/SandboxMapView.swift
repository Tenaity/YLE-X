//
//  SandboxMapView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//

import SwiftUI

struct SandboxMapView: View {
    @StateObject private var progressService = ProgressService.shared
    @StateObject private var lessonService = LessonService.shared
    @EnvironmentObject private var programStore: ProgramSelectionStore

    @State private var selectedIsland: IslandCategory?
    @State private var showIslandDetail = false
    @State private var islandCategories: [IslandCategory] = []

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.6),
                    Color(red: 0.2, green: 0.5, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Map header with discovery stats
                mapHeaderWithStats

                // Island grid map
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Islands in grid
                        islandGrid

                        // Locked islands teaser
                        lockedIslandsTeaser

                        Spacer()
                            .frame(height: AppSpacing.lg)
                    }
                    .padding(AppSpacing.md)
                }
            }
        }
        .navigationTitle("Thế Giới Khám Phá")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedIsland) { island in
            IslandDetailView(island: island)
                .presentationDetents([.large])
        }
        .onAppear {
            setupIslandCategories()
            Task {
                try await progressService.fetchLearningPathState()
            }
        }
    }

    // MARK: - Map Header with Stats
    private var mapHeaderWithStats: some View {
        VStack(spacing: AppSpacing.md) {
            // Discovery progress
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("Đảo Đã Khám Phá")
                        .font(.headline.weight(.semibold))

                    Spacer()

                    let discovered = progressService.sandboxProgress?.unlockedIslands.count ?? 0
                    Text("\(discovered)/12")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.appAccent)
                }

                // Progress bar
                GeometryReader { geometry in
                    let discovered = Double(progressService.sandboxProgress?.unlockedIslands.count ?? 0)
                    let progress = discovered / 12.0

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.appAccent, .appSuccess]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress)

                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.sm)
                    }
                }
                .frame(height: 24)
            }
            .padding(AppSpacing.md)
            .background(Color.white.opacity(0.1))
            .cornerRadius(AppRadius.md)

            // Gems available info
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Gems Sẵn Dùng")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))

                    HStack(spacing: 4) {
                        Image(systemName: "gem.fill")
                            .font(.headline)
                        Text("\(progressService.learningPathState?.gemsAvailable ?? 0)")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(.appWarning)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Hoạt Động Hoàn Thành")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(progressService.sandboxProgress?.totalActivitiesCompleted ?? 0)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.appSuccess)
                }
            }
            .padding(AppSpacing.md)
            .background(Color.white.opacity(0.1))
            .cornerRadius(AppRadius.md)
        }
        .padding(AppSpacing.md)
        .background(Color.black.opacity(0.1))
    }

    // MARK: - Island Grid
    @ViewBuilder
    private var islandGrid: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(islandCategories, id: \.id) { island in
                IslandCardView(
                    island: island,
                    isUnlocked: progressService.sandboxProgress?.unlockedIslands.contains(island.id) ?? false,
                    gemsAvailable: progressService.learningPathState?.gemsAvailable ?? 0,
                    onTap: {
                        selectedIsland = island
                        showIslandDetail = true
                    },
                    onUnlock: {
                        Task {
                            try await progressService.unlockIsland(
                                islandId: island.id,
                                gemsCost: island.unlockCost
                            )
                        }
                    }
                )
            }
        }
    }

    // MARK: - Locked Islands Teaser
    @ViewBuilder
    private var lockedIslandsTeaser: some View {
        if let unlockedCount = progressService.sandboxProgress?.unlockedIslands.count,
           unlockedCount < islandCategories.count {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.headline)

                    Text("Những Đảo Sắp Mở")
                        .font(.headline.weight(.semibold))

                    Spacer()
                }
                .foregroundColor(.appWarning)

                HStack(spacing: AppSpacing.sm) {
                    ForEach(islandCategories.dropFirst(unlockedCount).prefix(3), id: \.id) { island in
                        VStack(spacing: AppSpacing.xs) {
                            Text(island.emoji)
                                .font(.system(size: 20))

                            Text(island.name)
                                .font(.caption2)
                                .lineLimit(1)

                            HStack(spacing: 2) {
                                Image(systemName: "gem.fill")
                                    .font(.caption2)
                                Text("\(island.unlockCost)")
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundColor(.appWarning)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.sm)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppRadius.md)
                    }

                    Spacer()
                }
            }
            .padding(AppSpacing.md)
            .background(Color.appWarning.opacity(0.1))
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Setup Island Categories
    private func setupIslandCategories() {
        islandCategories = [
            IslandCategory(
                id: "vocab_animals",
                name: "Động Vật",
                emoji: "🦁",
                description: "Học từ vựng về các con vật",
                unlockCost: 0,
                topics: [
                    TopicItem(id: "animals_easy_1", name: "Động Vật - Dễ 1", difficulty: "easy"),
                    TopicItem(id: "animals_easy_2", name: "Động Vật - Dễ 2", difficulty: "easy"),
                    TopicItem(id: "animals_medium_1", name: "Động Vật - Vừa 1", difficulty: "medium"),
                ]
            ),
            IslandCategory(
                id: "vocab_school",
                name: "Trường Học",
                emoji: "🏫",
                description: "Học từ vựng về trường học",
                unlockCost: 50,
                topics: [
                    TopicItem(id: "school_easy_1", name: "Trường Học - Dễ 1", difficulty: "easy"),
                    TopicItem(id: "school_easy_2", name: "Trường Học - Dễ 2", difficulty: "easy"),
                ]
            ),
            IslandCategory(
                id: "vocab_professions",
                name: "Nghề Nghiệp",
                emoji: "💼",
                description: "Học tên các nghề nghiệp",
                unlockCost: 75,
                topics: []
            ),
            IslandCategory(
                id: "vocab_food",
                name: "Thức Ăn",
                emoji: "🍎",
                description: "Học từ vựng về thức ăn",
                unlockCost: 50,
                topics: []
            ),
            IslandCategory(
                id: "ipa_workshop",
                name: "IPA Mastery",
                emoji: "🎤",
                description: "Luyện tập 44 âm tiếng Anh",
                unlockCost: 100,
                topics: [
                    TopicItem(id: "ipa_chart", name: "IPA Chart - 44 Phonemes", difficulty: "easy"),
                    TopicItem(id: "ipa_vowels", name: "Practice Vowel Sounds", difficulty: "medium"),
                    TopicItem(id: "ipa_consonants", name: "Practice Consonants", difficulty: "medium"),
                ]
            ),
            IslandCategory(
                id: "pronunciation_lab",
                name: "Phòng Thí Nghiệm Phát Âm",
                emoji: "🗣️",
                description: "Cải thiện kỹ năng phát âm",
                unlockCost: 75,
                topics: []
            ),
            IslandCategory(
                id: "games_island",
                name: "Đảo Trò Chơi",
                emoji: "🎮",
                description: "Chơi game để học tiếng Anh",
                unlockCost: 0,
                topics: []
            ),
        ]
    }
}

// MARK: - Island Card View
struct IslandCardView: View {
    let island: IslandCategory
    let isUnlocked: Bool
    let gemsAvailable: Int
    let onTap: () -> Void
    let onUnlock: () -> Void

    @State private var showUnlockSheet = false

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                // Island emoji
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked ?
                            LinearGradient(
                                gradient: Gradient(colors: [.appPrimary.opacity(0.3), .appSecondary.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [.appTextSecondary.opacity(0.1), .appTextSecondary.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                    } else {
                        Text(island.emoji)
                            .font(.system(size: 32))
                    }
                }
                .frame(width: 56, height: 56)

                // Island info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(island.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(isUnlocked ? .appText : .appTextSecondary)

                    Text(island.description)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)

                    if isUnlocked {
                        Text("✓ Đã mở")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.appSuccess)
                    }
                }

                Spacer()

                // Unlock cost or status
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    if !isUnlocked {
                        HStack(spacing: 4) {
                            Image(systemName: "gem.fill")
                                .font(.caption)
                            Text("\(island.unlockCost)")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.appWarning)
                    } else if !island.topics.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "book.fill")
                                .font(.caption)
                            Text("\(island.topics.count)")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.appAccent)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(AppSpacing.md)
            .background(isUnlocked ? Color.appBackground : Color.appBackground.opacity(0.5))
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(
                        isUnlocked ? Color.appPrimary.opacity(0.3) : Color.appTextSecondary.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .opacity(isUnlocked ? 1 : 0.7)

            // Action buttons
            if isUnlocked {
                AppButton(
                    title: "Khám Phá",
                    style: .secondary,
                    action: onTap
                )
            } else {
                HStack(spacing: AppSpacing.sm) {
                    AppButton(
                        title: "Mở Khóa (💎 \(island.unlockCost))",
                        style: gemsAvailable >= island.unlockCost ? .primary : .secondary,
                        action: {
                            showUnlockSheet = true
                        }
                    )
                    .disabled(gemsAvailable < island.unlockCost)
                }
            }
        }
        .alert("Xác Nhận Mở Khóa", isPresented: $showUnlockSheet) {
            Button("Mở Khóa", action: onUnlock)
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Sử dụng \(island.unlockCost) Gems để mở khóa '\(island.name)'?")
        }
    }
}

// MARK: - Island Detail View
struct IslandDetailView: View {
    let island: IslandCategory
    @Environment(\.dismiss) var dismiss
    @StateObject private var progressService = ProgressService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Island header
                    VStack(spacing: AppSpacing.sm) {
                        Text(island.emoji)
                            .font(.system(size: 64))

                        Text(island.name)
                            .font(.title.weight(.bold))

                        Text(island.description)
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color.appSecondary.opacity(0.05))
                    .cornerRadius(AppRadius.md)

                    // Topics list
                    if !island.topics.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Các Chủ Đề")
                                .font(.headline.weight(.semibold))

                            VStack(spacing: AppSpacing.sm) {
                                ForEach(island.topics, id: \.id) { topic in
                                    TopicRowView(topic: topic)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 32))
                                .foregroundColor(.appTextSecondary)

                            VStack(spacing: AppSpacing.xs) {
                                Text("Sắp Ra Mắt")
                                    .font(.headline.weight(.semibold))

                                Text("Các nội dung cho đảo này đang được phát triển.")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.lg)
                    }

                    Spacer()
                }
                .padding(AppSpacing.md)
            }
            .navigationTitle(island.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Topic Row View
struct TopicRowView: View {
    let topic: TopicItem
    @StateObject private var lessonService = LessonService.shared
    @State private var showActivityDetail = false
    @State private var selectedActivity: AIActivity?
    @State private var showIPALearning = false

    var body: some View {
        Button(action: {
            // Check if this is IPA Learning topic
            if topic.name.contains("IPA") || topic.name.contains("Phoneme") {
                showIPALearning = true
            } else {
                // Fetch AI activity for this topic
                Task {
                    await loadActivityForTopic()
                }
            }
        }) {
            HStack(spacing: AppSpacing.md) {
                // Difficulty icon
                ZStack {
                    Circle()
                        .fill(Color.appSecondary.opacity(0.1))

                    switch topic.difficulty {
                    case "easy":
                        Text("1⭐")
                            .font(.caption2.weight(.bold))
                    case "medium":
                        Text("2⭐")
                            .font(.caption2.weight(.bold))
                    case "hard":
                        Text("3⭐")
                            .font(.caption2.weight(.bold))
                    default:
                        Text("?")
                            .font(.caption2.weight(.bold))
                    }
                }
                .frame(width: 40, height: 40)

                // Topic name
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.name)
                        .font(.subheadline.weight(.semibold))

                    Text(difficulty: topic.difficulty)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(AppSpacing.md)
            .background(Color.appBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(Color.appTextSecondary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showActivityDetail) {
            if let activity = selectedActivity {
                NavigationStack {
                    AIActivityDetailView(activity: activity)
                }
            }
        }
        .sheet(isPresented: $showIPALearning) {
            NavigationStack {
                IPALearningView()
            }
        }
    }

    private func loadActivityForTopic() async {
        do {
            // Try to fetch AI activities matching this topic
            try await lessonService.fetchAIActivities(for: .starters)

            // Find activity by topic name
            if let activity = lessonService.aiActivities.first(where: { activity in
                activity.title.localizedCaseInsensitiveContains(topic.name) ||
                topic.name.localizedCaseInsensitiveContains(activity.targetText)
            }) {
                selectedActivity = activity
                showActivityDetail = true
            } else {
                // Create a sample activity for this topic
                selectedActivity = createSampleActivity(for: topic)
                showActivityDetail = true
            }
        } catch {
            print("Error loading activity: \(error)")
            // Create sample activity as fallback
            selectedActivity = createSampleActivity(for: topic)
            showActivityDetail = true
        }
    }

    private func createSampleActivity(for topic: TopicItem) -> AIActivity {
        // Create a sample activity based on topic
        let difficulty = topic.difficulty.lowercased() == "easy" ? 1 : topic.difficulty.lowercased() == "medium" ? 2 : 3

        return AIActivity(
            type: .pronunciation,
            level: "starters",
            pathCategory: "Sandbox Topic",
            title: topic.name,
            description: "Practice pronunciation for \(topic.name)",
            targetText: topic.name.components(separatedBy: " ").first ?? topic.name,
            ipaGuide: "",
            difficulty: difficulty,
            xpReward: difficulty * 10,
            gemsReward: difficulty * 2,
            estimatedMinutes: 5,
            order: 1,
            thumbnailEmoji: "🎤"
        )
    }
}

// MARK: - Models
struct IslandCategory: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let unlockCost: Int
    let topics: [TopicItem]
}

struct TopicItem: Identifiable {
    let id: String
    let name: String
    let difficulty: String
}

// MARK: - Text Extension for Difficulty
extension Text {
    init(difficulty: String) {
        switch difficulty.lowercased() {
        case "easy":
            self.init("Dễ")
        case "medium":
            self.init("Vừa")
        case "hard":
            self.init("Khó")
        default:
            self.init(difficulty)
        }
    }
}

#Preview {
    NavigationStack {
        SandboxMapView()
            .environmentObject(ProgramSelectionStore())
    }
}
