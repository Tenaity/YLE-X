//
//  LessonDetailView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    Text(lesson.thumbnailEmoji)
                        .font(.system(size: 80))

                    Text(lesson.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appText)

                    Text(lesson.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)

                    Text("Coming Soon! 🚀")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appPrimary)
                        .padding(.top, AppSpacing.xl)
                }
                .padding(AppSpacing.xl)
            }
            .navigationTitle("Lesson Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
