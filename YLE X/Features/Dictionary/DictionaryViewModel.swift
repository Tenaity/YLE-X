//
//  DictionaryViewModel.swift
//  YLE X
//
//  Created on 11/9/25.
//

import Foundation
import AVFoundation
import Combine

@MainActor
class DictionaryViewModel: ObservableObject {
    @Published var searchResults: [DictionaryWord] = []
    @Published var isSearching = false

    private let synthesizer = AVSpeechSynthesizer()

    // Simple dictionary data (can be expanded or connected to API later)
    private let dictionaryData: [String: DictionaryWord] = [
        "hello": DictionaryWord(
            word: "hello",
            phonetic: "həˈloʊ",
            partOfSpeech: "interjection",
            definition: "Used as a greeting or to begin a phone conversation",
            vietnamese: "Xin chào",
            example: "Hello! How are you today?"
        ),
        "thank you": DictionaryWord(
            word: "thank you",
            phonetic: "θæŋk juː",
            partOfSpeech: "phrase",
            definition: "A polite expression used when acknowledging a gift, service, or compliment",
            vietnamese: "Cảm ơn",
            example: "Thank you for your help!"
        ),
        "goodbye": DictionaryWord(
            word: "goodbye",
            phonetic: "ɡʊdˈbaɪ",
            partOfSpeech: "interjection",
            definition: "Used to express good wishes when parting or at the end of a conversation",
            vietnamese: "Tạm biệt",
            example: "Goodbye! See you tomorrow."
        ),
        "apple": DictionaryWord(
            word: "apple",
            phonetic: "ˈæp.əl",
            partOfSpeech: "noun",
            definition: "A round fruit with red, green, or yellow skin and firm white flesh",
            vietnamese: "Quả táo",
            example: "I eat an apple every day."
        ),
        "book": DictionaryWord(
            word: "book",
            phonetic: "bʊk",
            partOfSpeech: "noun",
            definition: "A written or printed work consisting of pages bound together",
            vietnamese: "Sách, cuốn sách",
            example: "I'm reading a good book."
        ),
        "cat": DictionaryWord(
            word: "cat",
            phonetic: "kæt",
            partOfSpeech: "noun",
            definition: "A small domesticated carnivorous mammal",
            vietnamese: "Con mèo",
            example: "My cat is sleeping."
        ),
        "dog": DictionaryWord(
            word: "dog",
            phonetic: "dɔːɡ",
            partOfSpeech: "noun",
            definition: "A domesticated carnivorous mammal",
            vietnamese: "Con chó",
            example: "The dog is playing in the garden."
        ),
        "water": DictionaryWord(
            word: "water",
            phonetic: "ˈwɔː.tər",
            partOfSpeech: "noun",
            definition: "A clear liquid that has no color, taste, or smell",
            vietnamese: "Nước",
            example: "I drink water every day."
        ),
        "house": DictionaryWord(
            word: "house",
            phonetic: "haʊs",
            partOfSpeech: "noun",
            definition: "A building for people to live in",
            vietnamese: "Nhà, căn nhà",
            example: "We live in a small house."
        ),
        "friend": DictionaryWord(
            word: "friend",
            phonetic: "frend",
            partOfSpeech: "noun",
            definition: "A person you know well and like",
            vietnamese: "Bạn bè, người bạn",
            example: "She is my best friend."
        ),
        "teacher": DictionaryWord(
            word: "teacher",
            phonetic: "ˈtiː.tʃər",
            partOfSpeech: "noun",
            definition: "A person who teaches, especially in a school",
            vietnamese: "Giáo viên",
            example: "My teacher is very kind."
        ),
        "student": DictionaryWord(
            word: "student",
            phonetic: "ˈstuː.dənt",
            partOfSpeech: "noun",
            definition: "A person who is learning at a school or university",
            vietnamese: "Học sinh, sinh viên",
            example: "I am a student."
        ),
        "school": DictionaryWord(
            word: "school",
            phonetic: "skuːl",
            partOfSpeech: "noun",
            definition: "A place where children go to be educated",
            vietnamese: "Trường học",
            example: "I go to school every day."
        ),
        "happy": DictionaryWord(
            word: "happy",
            phonetic: "ˈhæp.i",
            partOfSpeech: "adjective",
            definition: "Feeling, showing, or causing pleasure or satisfaction",
            vietnamese: "Vui vẻ, hạnh phúc",
            example: "I am very happy today!"
        ),
        "beautiful": DictionaryWord(
            word: "beautiful",
            phonetic: "ˈbjuː.tɪ.fəl",
            partOfSpeech: "adjective",
            definition: "Pleasing the senses or mind aesthetically",
            vietnamese: "Đẹp",
            example: "She has a beautiful smile."
        )
    ]

    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        // Simulate network delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let lowercasedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            // Search in dictionary
            let results = dictionaryData.values.filter { word in
                word.word.lowercased().contains(lowercasedQuery) ||
                word.vietnamese?.lowercased().contains(lowercasedQuery) == true ||
                word.definition.lowercased().contains(lowercasedQuery)
            }

            searchResults = Array(results).sorted { $0.word < $1.word }
            isSearching = false
        }
    }

    func clearSearch() {
        searchResults = []
        isSearching = false
    }
}
