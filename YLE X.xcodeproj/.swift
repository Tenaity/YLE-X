//
//  KidsUIComponents.swift
//  YLE X
//
//  Intended path: Core/Utils/
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

// MARK: - Colorful Button Component
struct KidsButton: View {
    let title: String
    let emoji: String?
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.playLight()
            SoundManager.shared.playSound(.buttonTap)
            action()
        }) {
            HStack(spacing: KidsSpacing.sm) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.kidsHeadline)
                }
                Text(title)
                    .font(.kidsHeadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, KidsSpacing.lg)
            .padding(.vertical, KidsSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .kidsShadow(level: .medium)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.kidsGentle) {
                isPressed = pressing
            }
        }, perform: {})
        .kidsAccessibility(label: title, traits: [.isButton])
    }
}

// MARK: - Skill Card Component
struct SkillCard: View {
    let skill: Skill
    let progress: Double
    let isLocked: Bool
    let action: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            HapticManager.shared.playMedium()
            action()
        }) {
            VStack(spacing: KidsSpacing.md) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(skill.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: skill.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(skill.color)
                }
                
                // Skill name with emoji
                HStack(spacing: 4) {
                    Text(skill.emoji)
                        .font(.kidsBody)
                    Text(skill.vietnameseTitle)
                        .font(.kidsHeadline)
                        .foregroundColor(.kidsPrimaryText)
                }
                
                // Progress bar
                if !isLocked {
                    ProgressView(value: progress)
                        .progressViewStyle(KidsProgressViewStyle(color: skill.color))
                        .frame(height: 6)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.kidsBody)
                        .foregroundColor(.kidsSecondaryText)
                    
                    Text("Sắp mở khóa")
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                }
            }
            .padding(KidsSpacing.lg)
            .frame(width: 160, height: 180)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(Color.kidsCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(skill.color.opacity(0.3), lineWidth: 2)
                    )
            )
            .kidsShadow(level: isLocked ? .light : .medium)
            .opacity(isLocked ? 0.6 : 1.0)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.kidsPlayful, value: isAnimating)
        }
        .disabled(isLocked)
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if !isLocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                    withAnimation(.kidsPlayful) {
                        isAnimating.toggle()
                    }
                }
            }
        }
        .kidsAccessibility(
            label: "\(skill.vietnameseTitle), \(isLocked ? "Bị khóa" : "\(Int(progress * 100)) phần trăm hoàn thành")",
            traits: [.isButton]
        )
    }
}

// MARK: - Progress View Style
struct KidsProgressViewStyle: ProgressViewStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: KidsRadius.small)
                .fill(Color.gray.opacity(0.3))
            
            RoundedRectangle(cornerRadius: KidsRadius.small)
                .fill(color)
                .frame(width: (configuration.fractionCompleted ?? 0) * 300) // Fixed width for now
        }
        .frame(height: 8)
    }
}

// MARK: - Loading Animation
struct KidsLoadingView: View {
    @State private var isAnimating = false
    let colors: [Color] = [.startersGreen, .moversBlue, .flyersPurple, .kidsSecondary]
    
    var body: some View {
        VStack(spacing: KidsSpacing.lg) {
            HStack(spacing: KidsSpacing.sm) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }
            }
            
            Text("Đang tải...")
                .font(.kidsBody)
                .foregroundColor(.kidsSecondaryText)
        }
        .onAppear {
            isAnimating = true
        }
        .kidsAccessibility(label: "Đang tải nội dung")
    }
}