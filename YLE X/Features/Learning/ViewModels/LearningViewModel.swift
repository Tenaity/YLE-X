//
//  LearningViewModel.swift
//  YLE X
//
//  Intended path: Features/Learning/ViewModels/
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LearningViewModel: ObservableObject {
    @Published var level: YLELevel = .starters
    @Published var topic: String? = nil
    @Published var vocabulary: [VocabularyItem] = []
    @Published var isLoading = false
    @Published var error: String?

    private let contentService = ContentService.shared

    func load() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let items = try await contentService.loadVocabulary(for: level, topic: topic)
                vocabulary = items
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadExercises(for skill: Skill) async throws -> [Exercise] {
        return try await contentService.loadExercises(for: level, skill: skill)
    }
}
