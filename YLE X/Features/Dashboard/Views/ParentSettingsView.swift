//
//  ParentSettingsView.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//


import SwiftUI

struct ParentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Cài đặt phụ huynh")
                    .font(.appTitle)
                Text("Tính năng đang phát triển...")
                    .font(.appBody)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}
