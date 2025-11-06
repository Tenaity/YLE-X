//
//  ActivityRow.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct ActivityRow: View {
    let activity: LearningActivity
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(activity.skill.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: activity.skill.icon)
                        .foregroundColor(activity.skill.color)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.appBody)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(activity.date, style: .time)
                    .font(.appCaption)
                    .foregroundColor(.gray)
                
                if activity.pointsEarned > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(activity.pointsEarned)")
                            .font(.appCaption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}
