//
//  ParentBadgeView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct ParentBadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: KidsSpacing.xs) {
            ZStack {
                Circle()
                    .fill(badge.color.opacity(0.2)) // Sửa: Dùng badge.color
                    .frame(width: 50, height: 50)
                
                Text(badge.emoji)
                    .font(.system(size: 24))
            }
            
            Text(badge.name)
                .font(.kidsCaption)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
            
            Text(badge.earnedDate, style: .date)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
}
