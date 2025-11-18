//
//  DictionaryWord.swift
//  YLE X
//
//  Created on 11/9/25.
//

import Foundation
import AVFoundation

struct DictionaryWord: Identifiable, Codable {
    let id: UUID
    let word: String
    let phonetic: String?
    let partOfSpeech: String?
    let definition: String
    let vietnamese: String?
    let example: String?

    init(
        id: UUID = UUID(),
        word: String,
        phonetic: String? = nil,
        partOfSpeech: String? = nil,
        definition: String,
        vietnamese: String? = nil,
        example: String? = nil
    ) {
        self.id = id
        self.word = word
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.vietnamese = vietnamese
        self.example = example
    }

    // Text-to-Speech function
    func speak() {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slower for learning

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
