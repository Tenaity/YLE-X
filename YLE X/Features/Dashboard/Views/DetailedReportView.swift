//
//  DetailedReportView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//


import SwiftUI

struct DetailedReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Báo cáo chi tiết")
                    .font(.appTitle)
                Text("Tính năng đang phát triển...")
                    .font(.appBody)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Báo cáo chi tiết")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}
