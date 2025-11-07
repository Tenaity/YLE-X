//
//  LessonResultView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct LessonResultView: View {
    let result: LessonResult
    @Environment(\.dismiss) var dismiss
    @State private var animateContent = false
    @State private var animateStars = false
    @State private var showConfetti = false
    @State private var saveCompleted = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    result.lesson.ylelevel?.primaryColor.opacity(0.2) ?? Color.appPrimary.opacity(0.2),
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Top Emoji & Message
                    resultHeader

                    // Stars
                    starsSection

                    // Stats Cards
                    statsSection

                    // XP Earned
                    xpCard

                    // Performance Message
                    performanceMessage

                    // Action Buttons
                    actionButtons
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xl)
            }
        }
        .task {
            // Animate entrance
            withAnimation(.appBouncy.delay(0.2)) {
                animateContent = true
            }

            withAnimation(.appBouncy.delay(0.5)) {
                animateStars = true
            }

            // Show confetti for good performance
            if result.stars >= 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showConfetti = true
                    HapticManager.shared.playSuccess()
                }
            }

            // Save result to Firebase
            await saveResult()
        }
    }

    // MARK: - Result Header
    private var resultHeader: some View {
        VStack(spacing: AppSpacing.md) {
            Text(result.lesson.thumbnailEmoji)
                .font(.system(size: 100))
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)

            Text(result.isNewRecord ? "New Record! 🎉" : "Lesson Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.appText)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)

            Text(result.lesson.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
        }
    }

    // MARK: - Stars Section
    private var starsSection: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(0..<3) { index in
                Image(systemName: index < result.stars ? "star.fill" : "star")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(
                        index < result.stars
                            ? LinearGradient(
                                colors: [.appAccent, .appBadgeGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                    )
                    .scaleEffect(animateStars ? 1 : 0)
                    .animation(.appBouncy.delay(Double(index) * 0.1), value: animateStars)
            }
        }
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Correct",
                    value: "\(result.correctAnswers)/\(result.totalQuestions)",
                    color: .appSuccess
                )

                StatCard(
                    icon: "percent",
                    title: "Score",
                    value: "\(Int(result.percentage * 100))%",
                    color: .appInfo
                )
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)

            HStack(spacing: AppSpacing.md) {
                StatCard(
                    icon: "star.fill",
                    title: "Points",
                    value: "\(result.score)",
                    color: .appAccent
                )

                StatCard(
                    icon: "flame.fill",
                    title: "XP Earned",
                    value: "+\(result.xpEarned)",
                    color: .appWarning
                )
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
        }
    }

    // MARK: - XP Card
    private var xpCard: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appAccent, .appBadgeGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .appShadow(level: .heavy)

                Image(systemName: "star.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Experience Points")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                Text("+\(result.xpEarned) XP")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appAccent, .appBadgeGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Spacer()

            if result.isNewRecord {
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appBadgeGold)

                    Text("New Record!")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.appBadgeGold)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
        .scaleEffect(animateContent ? 1 : 0.8)
        .opacity(animateContent ? 1 : 0)
    }

    // MARK: - Performance Message
    private var performanceMessage: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(result.performanceLevel.rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appText)

            Text(getEncouragementMessage())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            // Continue Button
            Button(action: {
                HapticManager.shared.playLight()
                dismiss()
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Text("Continue Learning")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(
                            LinearGradient(
                                colors: [
                                    result.lesson.ylelevel?.primaryColor ?? .appPrimary,
                                    result.lesson.ylelevel?.secondaryColor ?? .appSecondary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .appShadow(level: .heavy)
                )
            }

            // Retry Button (if not perfect score)
            if result.stars < 3 {
                Button(action: {
                    HapticManager.shared.playLight()
                    // TODO: Implement retry logic
                    dismiss()
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again for 3 Stars")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .appShadow(level: .light)
                    )
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }

    // MARK: - Helper Methods
    private func getEncouragementMessage() -> String {
        switch result.stars {
        case 3:
            return "Perfect! You're a star student! ⭐️"
        case 2:
            return "Great work! Keep practicing to get 3 stars!"
        case 1:
            return "Good effort! Try again to improve your score!"
        default:
            return "Don't give up! Practice makes perfect!"
        }
    }

    private func saveResult() async {
        guard !saveCompleted else { return }

        do {
            try await LessonService.shared.saveLessonResult(result)
            saveCompleted = true
        } catch {
            print("Error saving result: \(error)")
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiShape()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .rotationEffect(.degrees(piece.rotation))
                        .offset(x: piece.x, y: piece.y)
                        .animation(
                            .linear(duration: piece.duration)
                            .repeatForever(autoreverses: false),
                            value: piece.y
                        )
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
    }

    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.appPrimary, .appSecondary, .appAccent, .appSuccess, .appWarning, .appBadgeGold]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                size: CGFloat.random(in: 8...15),
                color: colors.randomElement() ?? .appPrimary,
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 2...4)
            )
            confettiPieces.append(piece)

            // Animate falling
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                withAnimation {
                    if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                        confettiPieces[index].y = size.height + 50
                        confettiPieces[index].rotation += 720
                    }
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var rotation: Double
    let duration: Double
}

struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        return path
    }
}

#Preview {
    LessonResultView(result: LessonResult(
        lesson: Lesson(
            id: "1",
            title: "Colors",
            description: "Learn basic colors",
            level: "starters",
            skill: "vocabulary",
            order: 1,
            xpReward: 50,
            isLocked: false,
            thumbnailEmoji: "🎨",
            estimatedMinutes: 10,
            totalExercises: 5
        ),
        score: 85,
        totalPoints: 100,
        correctAnswers: 4,
        totalQuestions: 5,
        xpEarned: 80,
        stars: 3,
        isNewRecord: true
    ))
}
