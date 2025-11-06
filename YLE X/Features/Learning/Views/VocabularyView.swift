//
//  VocabularyView.swift
//  YLE X
//
//  Intended path: Features/Learning/Views/
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct VocabularyView: View {
    @StateObject var viewModel = LearningViewModel()

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Level picker
            Picker("Level", selection: $viewModel.level) {
                ForEach(YLELevel.allCases) { level in
                    Text(level.title).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .padding(AppSpacing.lg)

            // Content
            if viewModel.isLoading {
                ProgressView("Loading content...")
                    .appPadding(.large)
            } else if let error = viewModel.error {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.appError)
                    Text(error)
                        .appBodyMedium()
                        .foregroundColor(.appError)
                }
                .appPadding(.large)
            } else if viewModel.vocabulary.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Text("No content available")
                        .appHeadlineMedium()
                    Text("Come back later for more vocabulary")
                        .appBodySmall()
                        .foregroundColor(.appTextSecondary)
                }
                .appPadding(.large)
            } else {
                TabView {
                    ForEach(viewModel.vocabulary) { item in
                        VStack(spacing: AppSpacing.lg) {
                            // Image
                            if let imageName = item.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .appClippedCornerRadius(.large)
                            }

                            // Word
                            Text(item.word)
                                .appDisplaySmall()

                            // Meaning
                            Text(item.meaning)
                                .appBodyLarge()
                                .foregroundColor(.appTextSecondary)

                            // Example
                            if let example = item.example {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Example")
                                        .appCaptionMedium()
                                        .foregroundColor(.appTextSecondary)
                                    Text(example)
                                        .appBodyMedium()
                                        .italic()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(AppSpacing.md)
                                .background(Color.appBackgroundSecondary)
                                .appCardRadius()
                            }

                            Spacer()
                        }
                        .appCardPadding()
                    }
                }
                .tabViewStyle(.page)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Vocabulary")
        .onAppear { viewModel.load() }
    }
}
