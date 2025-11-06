//
//  ProgressViewStyle+App.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

// MARK: - Custom Progress View Style
struct AppProgressViewStyle: ProgressViewStyle {
    let color: Color
    var trackColor: Color = Color.appSecondaryText.opacity(0.2)
    var height: CGFloat = 6
    var cornerRadius: CGFloat = 3
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(trackColor)
                    .frame(height: height)
                
                // Progress fill
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: height
                    )
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Kid-Friendly Progress View Style
struct KidFriendlyProgressViewStyle: ProgressViewStyle {
    let color: Color
    var trackColor: Color = Color.appSecondaryText.opacity(0.1)
    var height: CGFloat = 10
    var cornerRadius: CGFloat = 5
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with fun design
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(trackColor)
                    .frame(height: height)
                    .overlay(
                        // Fun dotted pattern
                        HStack(spacing: 8) {
                            ForEach(0..<Int(geometry.size.width / 12), id: \.self) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 2, height: 2)
                            }
                        }
                    )
                
                // Progress fill with gradient
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: height
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: configuration.fractionCompleted)
                    .overlay(
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                                height: height
                            )
                    )
            }
        }
        .frame(height: height)
    }
}

// MARK: - Circular Progress View Style
struct CircularProgressViewStyle: ProgressViewStyle {
    let color: Color
    var trackColor: Color = Color.appSecondaryText.opacity(0.2)
    var lineWidth: CGFloat = 8
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: configuration.fractionCompleted)
        }
    }
}