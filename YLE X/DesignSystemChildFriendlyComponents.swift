//
//  DesignSystemChildFriendlyComponents.swift
//  YLE X - Child-Friendly English Learning App
//  
//  Intended Path: Core/UI/Components/
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import AVFoundation

// MARK: - Haptic Manager (from previous implementation)
struct HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    
    func playSuccess() {
        notification.notificationOccurred(.success)
    }
    
    func playError() {
        notification.notificationOccurred(.error)
    }
    
    func playLight() {
        lightImpact.impactOccurred()
    }
    
    func playMedium() {
        mediumImpact.impactOccurred()
    }
}

// MARK: - Sound Manager (from previous implementation)
struct SoundManager {
    static let shared = SoundManager()
    
    enum SoundEffect: String, CaseIterable {
        case buttonTap = "button_tap"
        case correctAnswer = "correct_answer"
        case wrongAnswer = "wrong_answer"
        case levelComplete = "level_complete"
        case celebration = "celebration"
    }
    
    func playSound(_ sound: SoundEffect) {
        print("🔊 Playing sound: \(sound.rawValue)")
    }
}

// MARK: - Glass Effect Extension (iOS 18+ feature fallback)
extension View {
    func glassEffect(_ effect: Any, in shape: Any) -> some View {
        // Fallback for iOS versions that don't support glass effect
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Child-Friendly Button Styles
struct FunButtonStyle: ButtonStyle {
    let theme: ChildFriendlyColors.BrandTheme
    let size: ButtonSize
    
    enum ButtonSize {
        case small, medium, large, extraLarge
        
        var height: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 50
            case .large: return 60
            case .extraLarge: return 80
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .subheadline
            case .medium: return .headline
            case .large: return .title2
            case .extraLarge: return .title
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 25
            case .large: return 30
            case .extraLarge: return 40
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.fontSize.weight(.bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(ChildFriendlyGradients.buttonGradient(for: theme))
                    .shadow(color: theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .animation(.bouncy(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Interactive Answer Card
struct AnswerCardView: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let theme: ChildFriendlyColors.BrandTheme
    let action: () -> Void
    
    var cardColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? ChildFriendlyColors.correctAnswer : ChildFriendlyColors.incorrectAnswer
        } else if isSelected {
            return ChildFriendlyColors.selectedState
        } else {
            return theme.backgroundColor
        }
    }
    
    var textColor: Color {
        if isCorrect != nil || isSelected {
            return .white
        } else {
            return ChildFriendlyColors.primaryText
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardColor)
                    .shadow(color: cardColor.opacity(0.3), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cardColor.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.bouncy(duration: 0.3), value: isSelected)
        .animation(.bouncy(duration: 0.3), value: isCorrect)
    }
}

// MARK: - Progress Bar with Fun Animation
struct FunProgressBar: View {
    let progress: Double
    let theme: ChildFriendlyColors.BrandTheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .frame(height: 24)
                
                // Progress fill with gradient
                RoundedRectangle(cornerRadius: 12)
                    .fill(ChildFriendlyGradients.buttonGradient(for: theme))
                    .frame(width: geometry.size.width * progress, height: 24)
                    .animation(.bouncy(duration: 0.8), value: progress)
                
                // Sparkle effect for completed progress
                if progress > 0.8 {
                    HStack {
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                            .font(.caption.weight(.bold))
                            .padding(.trailing, 8)
                    }
                    .frame(height: 24)
                }
                
                // Progress text
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(progress > 0.2 ? .white : ChildFriendlyColors.primaryText)
                    Spacer()
                }
                .frame(height: 24)
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Character Avatar Component
struct CharacterAvatarView: View {
    let character: LearningCharacter
    let size: AvatarSize
    let isActive: Bool
    
    enum AvatarSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 50
            case .medium: return 80
            case .large: return 120
            }
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: character.theme.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.dimension, height: size.dimension)
                .shadow(color: character.theme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.bouncy(duration: 0.3), value: isActive)
            
            Text(character.emoji)
                .font(.system(size: size.dimension * 0.5))
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.bouncy(duration: 0.3), value: isActive)
        }
        .overlay(
            Circle()
                .stroke(.white, lineWidth: isActive ? 4 : 0)
                .animation(.bouncy(duration: 0.3), value: isActive)
        )
    }
}

// MARK: - Achievement Badge
struct AchievementBadgeView: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                        ? LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: isUnlocked ? Color.orange.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                
                Text(achievement.emoji)
                    .font(.system(size: 30))
                    .grayscale(isUnlocked ? 0 : 1)
            }
            
            Text(achievement.name)
                .font(.caption.weight(.medium))
                .foregroundColor(isUnlocked ? ChildFriendlyColors.primaryText : ChildFriendlyColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .scaleEffect(isUnlocked ? 1.0 : 0.8)
        .animation(.bouncy(duration: 0.5), value: isUnlocked)
    }
}

// MARK: - Liquid Glass Card Component
struct LiquidGlassCard<Content: View>: View {
    let theme: ChildFriendlyColors.BrandTheme
    let isInteractive: Bool
    let content: Content
    
    init(theme: ChildFriendlyColors.BrandTheme, isInteractive: Bool = false, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .glassEffect(.regular.tint(theme.primaryColor).interactive(isInteractive), in: .rect(cornerRadius: 20))
            .shadow(color: theme.primaryColor.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Fun Text Field
struct FunTextField: View {
    let placeholder: String
    @Binding var text: String
    let theme: ChildFriendlyColors.BrandTheme
    let isSecure: Bool
    
    init(_ placeholder: String, text: Binding<String>, theme: ChildFriendlyColors.BrandTheme, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.theme = theme
        self.isSecure = isSecure
    }
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.title3)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Supporting Data Models
struct LearningCharacter {
    let id: UUID = UUID()
    let name: String
    let emoji: String
    let theme: ChildFriendlyColors.BrandTheme
    let personality: String
    
    static let defaultCharacters = [
        LearningCharacter(name: "Ocean Ollie", emoji: "🐙", theme: .ocean, personality: "Friendly and encouraging"),
        LearningCharacter(name: "Forest Fern", emoji: "🦋", theme: .forest, personality: "Gentle and patient"),
        LearningCharacter(name: "Sunny Sam", emoji: "🌞", theme: .sunshine, personality: "Energetic and fun"),
        LearningCharacter(name: "Berry Belle", emoji: "🍓", theme: .berry, personality: "Sweet and supportive"),
        LearningCharacter(name: "Rainbow Ray", emoji: "🌈", theme: .rainbow, personality: "Creative and imaginative")
    ]
}

struct Achievement {
    let id: UUID = UUID()
    let name: String
    let emoji: String
    let description: String
    let requiredPoints: Int
    
    static let sampleAchievements = [
        Achievement(name: "First Steps", emoji: "👶", description: "Complete your first lesson", requiredPoints: 10),
        Achievement(name: "Word Master", emoji: "📚", description: "Learn 50 new words", requiredPoints: 100),
        Achievement(name: "Streak Star", emoji: "⭐", description: "Study for 7 days in a row", requiredPoints: 200),
        Achievement(name: "Grammar Guru", emoji: "🎓", description: "Master basic grammar", requiredPoints: 300),
        Achievement(name: "Pronunciation Pro", emoji: "🎤", description: "Perfect pronunciation practice", requiredPoints: 400)
    ]
}

