//
//  StatCard.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: KidsSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.kidsDisplayMedium)
                    .foregroundColor(.kidsPrimary)
                
                Text(title)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
                
                Text(subtitle)
                    .font(.kidsCaption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
