//
//  LinearJourneyView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//

import SwiftUI

struct LinearJourneyView: View {
    @StateObject private var progressService = ProgressService.shared
    @StateObject private var lessonService = LessonService.shared

    @State private var selectedPhase: YLELevel = .starters
    @State private var scrollPosition: YLELevel?
    @State private var showCongrats = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.appBackground,
                    Color.appBackground.opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with progress overview
                progressOverviewHeader

                // Phase selector with scroll
                ScrollViewReader { reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.md) {
                            ForEach(YLELevel.allCases, id: \.self) { level in
                                phaseTab(for: level)
                                    .id(level)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                    .onAppear {
                        withAnimation {
                            reader.scrollTo(selectedPhase, anchor: .center)
                        }
                    }
                    .onChange(of: selectedPhase) { _, newPhase in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            reader.scrollTo(newPhase, anchor: .center)
                        }
                    }
                }
                .frame(height: 120)
                .background(Color.appSecondary.opacity(0.05))
                .padding(.bottom, AppSpacing.md)

                // Phase content - rounds and boss
                phaseContent
            }
        }
        .navigationTitle("Hành Trình YLE")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                try await progressService.fetchLearningPathState()
                if let currentPhase = progressService.learningPathState?.linearProgress.currentPhase {
                    selectedPhase = currentPhase
                }
            }
        }
        .sheet(isPresented: $showCongrats) {
            phaseCompletionCongrats
        }
    }

    // MARK: - Progress Overview Header
    private var progressOverviewHeader: some View {
        VStack(spacing: AppSpacing.sm) {
            // Total progress
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text("Tiến Độ Tổng Thể")
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                        Text("\(progressService.learningPathState?.totalXP ?? 0) XP")
                            .font(.caption.weight(.semibold))
                    }
                }

                // Total progress bar
                GeometryReader { geometry in
                    let totalPhases = 3.0
                    let completedPhases = calculateCompletedPhases()
                    let progress = completedPhases / totalPhases

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color.appTextSecondary.opacity(0.1))

                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.appAccent, .appPrimary]),
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
            .background(Color.appSecondary.opacity(0.05))
            .cornerRadius(AppRadius.md)
            .padding(AppSpacing.md)
        }
    }

    // MARK: - Phase Tab
    private func phaseTab(for level: YLELevel) -> some View {
        VStack(spacing: AppSpacing.xs) {
            // Phase emoji and name
            VStack(spacing: 4) {
                Text(level.emoji)
                    .font(.system(size: 28))

                Text(level.rawValue)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }

            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.appTextSecondary.opacity(0.1), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: phaseProgress(for: level))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [level.primaryColor, level.primaryColor.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(roundsCompleted(for: level))")
                        .font(.caption2.weight(.bold))
                    Text("/ 20")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
                .font(.system(size: 10))
            }
            .frame(width: 60, height: 60)

            // Phase status
            if phaseProgress(for: level) == 1.0 {
                Text("✓ Hoàn Thành")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.appSuccess)
            } else if level == selectedPhase {
                Text("Đang Học")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.appPrimary)
            }
        }
        .frame(width: 90)
        .padding(AppSpacing.sm)
        .background(selectedPhase == level ? level.primaryColor.opacity(0.1) : Color.white)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    selectedPhase == level ? level.primaryColor : Color.clear,
                    lineWidth: 2
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedPhase = level
            }
        }
    }

    // MARK: - Phase Content (Rounds & Boss)
    @ViewBuilder
    private var phaseContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Phase header with stats
                phaseHeader

                // Rounds list
                roundsList

                // Boss battle
                bossBattle

                // Next phase hint
                if selectedPhase != .flyers && phaseProgress(for: selectedPhase) >= 1.0 {
                    nextPhaseHint
                }
            }
            .padding(AppSpacing.md)
        }
    }

    // MARK: - Phase Header
    private var phaseHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(selectedPhase.rawValue)
                        .font(.title2.weight(.bold))
                        .foregroundColor(selectedPhase.primaryColor)

                    Text("Tiến độ: \(roundsCompleted(for: selectedPhase))/20 vòng")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("+\(50 * roundsCompleted(for: selectedPhase)) XP")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.appAccent)

                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "gem.fill")
                            .font(.caption)
                        Text("+\(10 * roundsCompleted(for: selectedPhase)) 💎")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.appWarning)
                }
            }

            // Phase progress bar
            GeometryReader { geometry in
                let progress = phaseProgress(for: selectedPhase)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(selectedPhase.secondaryColor)

                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(selectedPhase.primaryColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
        .padding(AppSpacing.md)
        .background(selectedPhase.primaryColor.opacity(0.05))
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Rounds List
    private var roundsList: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(1...19, id: \.self) { roundNumber in
                let isCompleted = roundsCompleted(for: selectedPhase) >= roundNumber
                let isCurrent = roundsCompleted(for: selectedPhase) == (roundNumber - 1)

                RoundCard(
                    roundNumber: roundNumber,
                    phase: selectedPhase,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    xpReward: 50,
                    gemsReward: 10,
                    onTap: {
                        if isCompleted || isCurrent {
                            // Navigate to lesson
                        }
                    }
                )
            }
        }
    }

    // MARK: - Boss Battle
    private var bossBattle: some View {
        VStack(spacing: AppSpacing.sm) {
            // Boss unlock condition
            if roundsCompleted(for: selectedPhase) >= 20 {
                BossBattleCard(
                    phase: selectedPhase,
                    isUnlocked: true,
                    xpReward: 500,
                    gemsReward: 100,
                    roundsUntilUnlock: nil,
                    onTap: {
                        // Navigate to boss battle
                    }
                )
                .transition(.scale.combined(with: .opacity))
            } else {
                BossBattleCard(
                    phase: selectedPhase,
                    isUnlocked: false,
                    xpReward: 500,
                    gemsReward: 100,
                    roundsUntilUnlock: max(0, 20 - roundsCompleted(for: selectedPhase)),
                    onTap: {}
                )
            }
        }
    }

    // MARK: - Next Phase Hint
    private var nextPhaseHint: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("🎉 Chúc Mừng!")
                        .font(.headline.weight(.bold))

                    if let nextPhase = selectedPhase.nextPhase {
                        Text("Bạn đã sẵn sàng cho \(nextPhase.rawValue)!")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.appPrimary)
            }
            .padding(AppSpacing.md)
            .background(selectedPhase.primaryColor.opacity(0.1))
            .cornerRadius(AppRadius.md)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Phase Completion Congrats
    private var phaseCompletionCongrats: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.md) {
                Text("🏆")
                    .font(.system(size: 64))

                Text("Tuyệt Vời!")
                    .font(.title.weight(.bold))

                Text("Bạn đã hoàn thành giai đoạn \(selectedPhase.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: AppSpacing.md) {
                    VStack(spacing: AppSpacing.xs) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("500 XP")
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.appAccent)
                    }

                    Divider()

                    VStack(spacing: AppSpacing.xs) {
                        HStack {
                            Image(systemName: "gem.fill")
                            Text("100 💎")
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.appWarning)
                    }
                }
                .padding(AppSpacing.md)
                .background(Color.appSecondary.opacity(0.05))
                .cornerRadius(AppRadius.md)
            }
            .padding(AppSpacing.lg)
            .background(Color.appBackground)
            .cornerRadius(AppRadius.lg)

            Spacer()

            if let nextPhase = selectedPhase.nextPhase {
                AppButton(
                    title: "Bắt đầu \(nextPhase.rawValue) →",
                    style: .primary
                ) {
                    selectedPhase = nextPhase
                    showCongrats = false
                }
            } else {
                AppButton(
                    title: "Thành tích cuối cùng 🎓",
                    style: .primary
                ) {
                    showCongrats = false
                }
            }

            AppButton(
                title: "Đóng",
                style: .secondary
            ) {
                showCongrats = false
            }
        }
        .padding(AppSpacing.lg)
        .presentationDetents([.medium])
    }

    // MARK: - Helper Methods
    private func roundsCompleted(for level: YLELevel) -> Int {
        guard let progress = progressService.learningPathState?.linearProgress else { return 0 }
        if progress.currentPhase == level {
            return progress.roundsCompleted.count
        }
        // If phase not current, return full completion if it was passed
        if level.order < progress.currentPhase.order {
            return 20
        }
        return 0
    }

    private func phaseProgress(for level: YLELevel) -> Double {
        let completed = roundsCompleted(for: level)
        return Double(completed) / 20.0
    }

    private func calculateCompletedPhases() -> Double {
        guard let progress = progressService.learningPathState?.linearProgress else { return 0 }
        var completed = 0.0

        // Add completed phases
        if YLELevel.starters.order < progress.currentPhase.order {
            completed += 1.0
        } else if YLELevel.starters == progress.currentPhase {
            completed += phaseProgress(for: YLELevel.starters)
        }

        if YLELevel.movers.order < progress.currentPhase.order {
            completed += 1.0
        } else if YLELevel.movers == progress.currentPhase {
            completed += phaseProgress(for: YLELevel.movers)
        }

        if YLELevel.flyers.order < progress.currentPhase.order {
            completed += 1.0
        } else if YLELevel.flyers == progress.currentPhase {
            completed += phaseProgress(for: YLELevel.flyers)
        }

        return completed
    }
}

// MARK: - Round Card Component
struct RoundCard: View {
    let roundNumber: Int
    let phase: YLELevel
    let isCompleted: Bool
    let isCurrent: Bool
    let xpReward: Int
    let gemsReward: Int
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Round number indicator
            ZStack {
                Circle()
                    .fill(
                        isCompleted ? phase.primaryColor :
                        isCurrent ? phase.primaryColor.opacity(0.3) :
                        Color.appTextSecondary.opacity(0.1)
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(roundNumber)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(
                            isCurrent ? phase.primaryColor : .appText
                        )
                }
            }
            .frame(width: 44, height: 44)

            // Round info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Vòng \(roundNumber)")
                    .font(.subheadline.weight(.semibold))

                if isCurrent {
                    Text("Đang học")
                        .font(.caption)
                        .foregroundColor(phase.primaryColor)
                } else if isCompleted {
                    Text("Hoàn thành ✓")
                        .font(.caption)
                        .foregroundColor(.appSuccess)
                } else {
                    Text("Bị khóa")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Rewards
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("+\(xpReward)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.appAccent)

                HStack(spacing: 4) {
                    Image(systemName: "gem.fill")
                        .font(.caption)
                    Text("+\(gemsReward)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.appWarning)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .opacity(isCompleted || isCurrent ? 1 : 0.3)
        }
        .padding(AppSpacing.md)
        .background(
            isCompleted ? phase.primaryColor.opacity(0.05) :
            isCurrent ? phase.primaryColor.opacity(0.1) :
            Color.appBackground
        )
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    isCurrent ? phase.primaryColor : Color.clear,
                    lineWidth: 2
                )
        )
        .opacity((isCompleted || isCurrent) ? 1 : 0.6)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Boss Battle Card Component
struct BossBattleCard: View {
    let phase: YLELevel
    let isUnlocked: Bool
    let xpReward: Int
    let gemsReward: Int
    let roundsUntilUnlock: Int?
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                // Boss icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.appWarning.opacity(0.3),
                                    Color.appAccent.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("🏆")
                        .font(.system(size: 28))
                }
                .frame(width: 56, height: 56)

                // Boss info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Cuộc Thi Thử \(phase.rawValue)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(phase.primaryColor)

                    if isUnlocked {
                        Text("Sẵn sàng để chinh phục! 🎯")
                            .font(.caption)
                            .foregroundColor(.appSuccess)
                    } else if let rounds = roundsUntilUnlock {
                        Text("Hoàn thành \(rounds) vòng nữa")
                            .font(.caption)
                            .foregroundColor(.appWarning)
                    }
                }

                Spacer()

                // Rewards
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("+\(xpReward)")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.appAccent)

                    HStack(spacing: 4) {
                        Image(systemName: "gem.fill")
                            .font(.caption)
                        Text("+\(gemsReward)")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.appWarning)
                }
            }
            .padding(AppSpacing.md)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        phase.primaryColor.opacity(0.15),
                        phase.secondaryColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(phase.primaryColor, lineWidth: 2)
            )

            // Action button
            if isUnlocked {
                AppButton(
                    title: "Bắt Đầu Cuộc Thi 🎯",
                    style: .primary,
                    action: onTap
                )
            }
        }
    }
}

// MARK: - YLELevel Extension for UI
extension YLELevel {


    var nextPhase: YLELevel? {
        switch self {
        case .starters: return .movers
        case .movers: return .flyers
        case .flyers: return nil
        }
    }
}

#Preview {
    NavigationStack {
        LinearJourneyView()
    }
}
