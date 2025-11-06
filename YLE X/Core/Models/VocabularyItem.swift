//
//  VocabularyItem.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//


struct VocabularyItem: Identifiable, Codable {
    let id: String
    let word: String
    let meaning: String
    let example: String?
    let imageName: String?
    let audioName: String?
    let level: YLELevel
    let topic: String
}