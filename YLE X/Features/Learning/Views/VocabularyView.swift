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
        VStack {
            Picker("Cấp độ", selection: $viewModel.level) {
                ForEach(YLELevel.allCases) { level in
                    Text(level.title).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.isLoading {
                ProgressView("Đang tải nội dung...")
            } else if let error = viewModel.error {
                Text(error).foregroundColor(.red)
            } else if viewModel.vocabulary.isEmpty {
                Text("Chưa có nội dung.")
            } else {
                TabView {
                    ForEach(viewModel.vocabulary) { item in
                        VStack(spacing: 16) {
                            if let imageName = item.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                            }
                            Text(item.word)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(item.meaning)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            if let example = item.example {
                                Text("Ví dụ: \(example)")
                                    .font(.body)
                                    .italic()
                            }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(.page)
            }
        }
        .navigationTitle("Từ vựng")
        .onAppear { viewModel.load() }
    }
}
