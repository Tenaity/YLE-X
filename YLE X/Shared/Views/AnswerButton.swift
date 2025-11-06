//
//  AnswerButton.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI

// MARK: - Modern Answer Button for Educational Apps
struct AnswerButton: View {
    // MARK: - Properties
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let color: Color
    let action: () -> Void
    
    // MARK: - State
    @State private var isPressed = false
    @State private var animateSuccess = false
    @State private var animateError = false
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return Color.appSuccess.pastelVariant
            } else {
                return Color.appError.pastelVariant
            }
        }
        return isSelected ? color.pastelVariant : Color.appCardBackground
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .appSuccess : .appError
        }
        return isSelected ? color : Color.appSecondaryText.opacity(0.2)
    }
    
    private var borderWidth: CGFloat {
        if isCorrect != nil || isSelected {
            return 2.0
        }
        return 1.0
    }
    
    private var textColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .appSuccess : .appError
        }
        return .appPrimaryText
    }
    
    private var iconName: String? {
        guard let isCorrect = isCorrect else {
            return isSelected ? "checkmark.circle.fill" : nil
        }
        return isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var iconColor: Color {
        guard let isCorrect = isCorrect else {
            return color
        }
        return isCorrect ? .appSuccess : .appError
    }
    
    var body: some View {
        Button(action: {
            guard isCorrect == nil else { return }
            
            // Haptic feedback
            HapticManager.shared.playLight()
            action()
        }) {
            HStack(spacing: AppSpacing.md) {
                // Answer text
                Text(text)
                    .font(.appKidFriendlyBody)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Status icon
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.appTitleSmall)
                        .foregroundColor(iconColor)
                        .scaleEffect(animateSuccess ? 1.2 : 1.0)
                        .rotationEffect(.degrees(animateError ? -10 : 0))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardPadding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.KidFriendly.button)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.KidFriendly.button)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .appEducationalShadow(type: .exercise)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            guard isCorrect == nil else { return }
            withAnimation(.appQuick) {
                isPressed = pressing
            }
        }, perform: {})
        .onChange(of: isCorrect) { newValue in
            guard let newValue = newValue else { return }
            
            if newValue {
                // Success animation
                withAnimation(.appSuccess) {
                    animateSuccess = true
                }
                
                // Reset animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.appGentle) {
                        animateSuccess = false
                    }
                }
            } else {
                // Error animation (gentle shake)
                withAnimation(.appError) {
                    animateError = true
                }
                
                // Reset animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.appGentle) {
                        animateError = false
                    }
                }
            }
        }
        .appAccessibility(
            label: text,
            hint: accessibilityHint,
            traits: .isButton
        )
    }
    
    private var accessibilityHint: String {
        if let isCorrect = isCorrect {
            return isCorrect ? "Đáp án đúng" : "Đáp án sai"
        }
        return isSelected ? "Đã chọn. Nhấn để bỏ chọn" : "Nhấn để chọn đáp án này"
    }
}

// MARK: - Enhanced Answer Button with animations
struct AnimatedAnswerButton: View {
    let text: String
    let isSelected: Bool  
    let isCorrect: Bool?
    let color: Color
    let action: () -> Void
    
    @State private var bounceAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        AnswerButton(
            text: text,
            isSelected: isSelected,
            isCorrect: isCorrect,
            color: color,
            action: action
        )
        .overlay(
            // Glow effect for correct answers
            RoundedRectangle(cornerRadius: AppRadius.KidFriendly.button)
                .stroke(
                    isCorrect == true ? Color.appSuccess.opacity(glowAnimation ? 0.8 : 0.3) : Color.clear,
                    lineWidth: 2
                )
                .animation(.appGentle.repeatForever(autoreverses: true), value: glowAnimation)
        )
        .scaleEffect(bounceAnimation ? 1.05 : 1.0)
        .onChange(of: isCorrect) { newValue in
            guard let newValue = newValue else { return }
            
            if newValue {
                // Start glow animation for correct answer
                glowAnimation = true
                
                // Bounce animation
                withAnimation(.appBouncy) {
                    bounceAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.appGentle) {
                        bounceAnimation = false
                    }
                }
            }
        }
    }
}

// MARK: - Kid-Friendly Answer Button
struct KidFriendlyAnswerButton: View {
    let text: String
    let emoji: String?
    let isSelected: Bool
    let isCorrect: Bool?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                // Emoji or icon
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 32))
                }
                
                // Answer text
                Text(text)
                    .font(.appKidFriendlyBody)
                    .foregroundColor(.appPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity)
            .appCardPadding()
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xlarge)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xlarge)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .appKidFriendlyShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Color.appSuccess.pastelVariant : Color.appError.pastelVariant
        }
        return isSelected ? color.pastelVariant : Color.appCardBackground
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .appSuccess : .appError
        }
        return isSelected ? color : .clear
    }
    
    private var borderWidth: CGFloat {
        if isCorrect != nil || isSelected {
            return 3.0
        }
        return 0
    }
}

// MARK: - Preview
struct AnswerButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.lg) {
            // Standard answer button
            AnswerButton(
                text: "This is a sample answer that might be a bit longer to test text wrapping",
                isSelected: false,
                isCorrect: nil,
                color: .appPrimary,
                action: {}
            )
            
            // Selected answer button
            AnswerButton(
                text: "Selected answer",
                isSelected: true,
                isCorrect: nil,
                color: .appPrimary,
                action: {}
            )
            
            // Correct answer button
            AnswerButton(
                text: "Correct answer",
                isSelected: true,
                isCorrect: true,
                color: .appPrimary,
                action: {}
            )
            
            // Incorrect answer button
            AnswerButton(
                text: "Incorrect answer",
                isSelected: true,
                isCorrect: false,
                color: .appPrimary,
                action: {}
            )
            
            // Kid-friendly answer button
            KidFriendlyAnswerButton(
                text: "Fun Answer",
                emoji: "🎉",
                isSelected: false,
                isCorrect: nil,
                color: .appSuccess,
                action: {}
            )
        }
        .padding()
        .background(Color.appBackground)
    }
}
