//
//  KidsProgressViewStyle.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct KidsProgressViewStyle: ProgressViewStyle {
    var color: Color
    var height: CGFloat = 6
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(color.opacity(0.2))
                .frame(height: height)
            
            RoundedRectangle(cornerRadius: height / 2)
                .fill(color)
                .frame(width: (configuration.fractionCompleted ?? 0) * (UIScreen.main.bounds.width * 0.3), height: height) // Cần logic width tốt hơn
                .animation(.spring(), value: configuration.fractionCompleted)
        }
    }
}
