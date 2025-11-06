//
//  RecommendationCard.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct RecommendationCard: View {
    let recommendation: ParentRecommendation
    
    var body: some View {
        HStack(spacing: KidsSpacing.md) {
            Text(recommendation.type.emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.kidsHeadline)
                    .foregroundColor(.kidsPrimary)
                
                Text(recommendation.description)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(recommendation.type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(recommendation.type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
