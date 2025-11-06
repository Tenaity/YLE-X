//
//  SkillProgressCard.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct SkillProgressCard: View {
    let skill: Skill
    let progress: Double
    let weeklyImprovement: Double
    
    var body: some View {
        VStack(spacing: KidsSpacing.sm) {
            HStack {
                Image(systemName: skill.icon)
                    .foregroundColor(skill.color)
                Text(skill.emoji)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(skill.title)
                        .font(.kidsHeadline)
                        .foregroundColor(.kidsPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(KidsProgressViewStyle(color: skill.color))
                    .frame(height: 6)
                
                if weeklyImprovement > 0 {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.kidsSuccess)
                            .font(.caption)
                        
                        Text("+\(Int(weeklyImprovement * 100))% tuần này")
                            .font(.kidsCaption)
                            .foregroundColor(.kidsSuccess)
                    }
                }
            }
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(skill.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(skill.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
