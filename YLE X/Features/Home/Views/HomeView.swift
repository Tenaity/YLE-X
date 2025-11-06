//
//  HomeView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Text("🏠")
                    .font(.system(size: 80))
                
                Text("Chào mừng đến YLE X!")
                    .font(.appCaptionLarge)
                    .foregroundColor(.primary)
                
                Text("Trang chủ đang được phát triển")
                    .font(.appBodyLarge)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(AppSpacing.xl)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Trang chủ")
        }
    }
}

#Preview {
    HomeView()
}
