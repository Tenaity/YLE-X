//
//  DictionaryWord.swift
//  YLE X
//
//  Created on 11/18/25.
//  Updated for Firebase integration with 1,414 Cambridge words
//

import FirebaseFirestore
import Foundation

// MARK: - Dictionary Word Model

struct DictionaryWord: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// Firestore document ID (e.g., "cat", "hello")
    @DocumentID var id: String?

    /// Main word (British spelling)
    let word: String

    /// British spelling variant
    let british: String

    /// American spelling variant
    let american: String

    /// Has irregular plural form
    let irregularPlural: Bool?

    // MARK: - Grammar

    /// All applicable parts of speech (e.g., ["noun", "verb"])
    let partOfSpeech: [String]

    /// Primary part of speech
    let primaryPos: String

    // MARK: - YLE Levels

    /// Applicable YLE levels (e.g., ["starters", "movers"])
    let levels: [String]

    /// Primary level (first appearance)
    let primaryLevel: String

    /// YLE level enum for convenience
    var level: YLELevel {
        YLELevel(rawValue: primaryLevel) ?? .starters
    }

    // MARK: - Categories

    /// Topic categories (e.g., ["animals", "food_and_drink"])
    let categories: [String]

    // MARK: - Translations & Definitions

    /// Vietnamese translation (single word)
    let translationVi: String

    /// English definition
    let definitionEn: String

    /// Vietnamese definition
    let definitionVi: String

    // MARK: - Pronunciation

    /// Pronunciation data for both accents
    let pronunciation: Pronunciation

    // MARK: - Examples

    /// Example sentences for different levels
    let examples: [Example]

    // MARK: - Media

    /// Image URL (optional)
    let imageUrl: String?

    /// Emoji representation (optional)
    let emoji: String?

    // MARK: - Gamification

    /// Difficulty level (1=Starters, 2=Movers, 3=Flyers)
    let difficulty: Int

    /// Word frequency rating
    let frequency: String?

    /// XP reward for learning this word
    let xpValue: Int

    /// Gems reward
    let gemsValue: Int

    // MARK: - Metadata

    /// When word was added
    let addedDate: Date?

    /// Last update timestamp
    let lastUpdated: Date?

    /// Data completeness tracking
    let dataCompleteness: DataCompleteness?

    // MARK: - Initializer

    init(
        id: String? = nil,
        word: String,
        british: String,
        american: String,
        irregularPlural: Bool?,
        partOfSpeech: [String],
        primaryPos: String,
        levels: [String],
        primaryLevel: String,
        categories: [String],
        translationVi: String,
        definitionEn: String,
        definitionVi: String,
        pronunciation: Pronunciation,
        examples: [Example],
        imageUrl: String?,
        emoji: String?,
        difficulty: Int,
        frequency: String?,
        xpValue: Int,
        gemsValue: Int,
        addedDate: Date?,
        lastUpdated: Date?,
        dataCompleteness: DataCompleteness?
    ) {
        self.id = id
        self.word = word
        self.british = british
        self.american = american
        self.irregularPlural = irregularPlural
        self.partOfSpeech = partOfSpeech
        self.primaryPos = primaryPos
        self.levels = levels
        self.primaryLevel = primaryLevel
        self.categories = categories
        self.translationVi = translationVi
        self.definitionEn = definitionEn
        self.definitionVi = definitionVi
        self.pronunciation = pronunciation
        self.examples = examples
        self.imageUrl = imageUrl
        self.emoji = emoji
        self.difficulty = difficulty
        self.frequency = frequency
        self.xpValue = xpValue
        self.gemsValue = gemsValue
        self.addedDate = addedDate
        self.lastUpdated = lastUpdated
        self.dataCompleteness = dataCompleteness
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case word, british, american
        case irregularPlural = "irregular_plural"
        case partOfSpeech, primaryPos
        case levels, primaryLevel
        case categories
        case translationVi, definitionEn, definitionVi
        case pronunciation
        case examples
        case imageUrl, emoji
        case difficulty, frequency
        case xpValue, gemsValue
        case addedDate, lastUpdated
        case dataCompleteness
    }

    // MARK: - Custom Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        british = try container.decode(String.self, forKey: .british)
        american = try container.decode(String.self, forKey: .american)

        // Handle irregularPlural which might be String or Bool
        if let boolValue = try? container.decode(Bool.self, forKey: .irregularPlural) {
            irregularPlural = boolValue
        } else if let stringValue = try? container.decode(String.self, forKey: .irregularPlural) {
            irregularPlural = (stringValue.uppercased() == "TRUE")
        } else {
            irregularPlural = nil
        }

        partOfSpeech = try container.decode([String].self, forKey: .partOfSpeech)
        primaryPos = try container.decode(String.self, forKey: .primaryPos)
        levels = try container.decode([String].self, forKey: .levels)
        primaryLevel = try container.decode(String.self, forKey: .primaryLevel)
        categories = try container.decode([String].self, forKey: .categories)
        translationVi = try container.decode(String.self, forKey: .translationVi)
        definitionEn = try container.decode(String.self, forKey: .definitionEn)
        definitionVi = try container.decode(String.self, forKey: .definitionVi)
        pronunciation = try container.decode(Pronunciation.self, forKey: .pronunciation)
        examples = try container.decode([Example].self, forKey: .examples)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji)
        difficulty = try container.decode(Int.self, forKey: .difficulty)
        frequency = try container.decodeIfPresent(String.self, forKey: .frequency)
        xpValue = try container.decode(Int.self, forKey: .xpValue)
        gemsValue = try container.decode(Int.self, forKey: .gemsValue)

        // Safely decode dates (handle String vs Timestamp mismatch)
        addedDate = try? container.decodeIfPresent(Date.self, forKey: .addedDate)
        lastUpdated = try? container.decodeIfPresent(Date.self, forKey: .lastUpdated)

        dataCompleteness = try container.decodeIfPresent(
            DataCompleteness.self, forKey: .dataCompleteness)
    }

    // MARK: - Helper Methods

    /// Get example for specific level
    func example(for level: YLELevel) -> Example? {
        examples.first { $0.levelEnum == level }
    }

    /// Get all examples up to user's level
    func examples(upTo userLevel: YLELevel) -> [Example] {
        let levelOrder: [YLELevel] = [.starters, .movers, .flyers]
        guard let maxIndex = levelOrder.firstIndex(of: userLevel) else {
            return examples
        }

        return examples.filter { example in
            if let exampleIndex = levelOrder.firstIndex(of: example.levelEnum) {
                return exampleIndex <= maxIndex
            }
            return false
        }
    }

    /// Check if word belongs to category
    func isInCategory(_ category: String) -> Bool {
        categories.contains(category)
    }

    /// Check if word is for specific level
    func isForLevel(_ level: YLELevel) -> Bool {
        levels.contains(level.rawValue)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DictionaryWord, rhs: DictionaryWord) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Pronunciation

struct Pronunciation: Codable, Hashable {
    let british: PronunciationData
    let american: PronunciationData
}

struct PronunciationData: Codable, Hashable {
    /// IPA notation (e.g., "/kæt/")
    let ipa: String

    /// Audio URL (Cambridge or legacy)
    let audioUrl: String

    /// Audio source (e.g., "Cambridge", "Vocabulary.com")
    let audioSource: String

    /// Check if has valid audio
    var hasAudio: Bool {
        !audioUrl.isEmpty
    }
}

// MARK: - Example Sentence

struct Example: Codable, Hashable, Identifiable {
    var id: String { level }

    /// Level (e.g., "starters", "movers", "flyers")
    let level: String

    /// English sentence
    let sentenceEn: String

    /// Vietnamese translation
    let sentenceVi: String

    /// Level enum for convenience
    var levelEnum: YLELevel {
        YLELevel(rawValue: level) ?? .starters
    }
}

// MARK: - Data Completeness

struct DataCompleteness: Codable, Hashable {
    let hasTranslation: Bool
    let hasDefinitionEn: Bool
    let hasDefinitionVi: Bool
    let hasIPABritish: Bool
    let hasIPAAmerican: Bool
    let hasAudioBritish: Bool
    let hasAudioAmerican: Bool
    let hasExamplesEn: Bool
    let hasExamplesVi: Bool

    /// Overall completeness percentage
    var completenessPercentage: Double {
        let total = 9.0
        let complete = [
            hasTranslation, hasDefinitionEn, hasDefinitionVi,
            hasIPABritish, hasIPAAmerican,
            hasAudioBritish, hasAudioAmerican,
            hasExamplesEn, hasExamplesVi,
        ].filter { $0 }.count

        return Double(complete) / total
    }
}

// MARK: - Preview Helpers

#if DEBUG
    extension DictionaryWord {
        /// Sample word for previews
        static let sample = DictionaryWord(
            id: "cat",
            word: "cat",
            british: "cat",
            american: "cat",
            irregularPlural: false,
            partOfSpeech: ["noun"],
            primaryPos: "noun",
            levels: ["starters"],
            primaryLevel: "starters",
            categories: ["animals"],
            translationVi: "con mèo",
            definitionEn: "A small furry animal with four legs and a tail.",
            definitionVi: "Một con vật nhỏ có lông mềm với bốn chân và một cái đuôi.",
            pronunciation: Pronunciation(
                british: PronunciationData(
                    ipa: "/kæt/",
                    audioUrl:
                        "https://dictionary.cambridge.org/media/english/uk_pron/u/ukc/ukcat/ukcat_029.mp3",
                    audioSource: "Cambridge"
                ),
                american: PronunciationData(
                    ipa: "/kæt/",
                    audioUrl:
                        "https://dictionary.cambridge.org/media/english/us_pron/c/cat/cat__/cat.mp3",
                    audioSource: "Cambridge"
                )
            ),
            examples: [
                Example(
                    level: "starters",
                    sentenceEn: "I have a cat.",
                    sentenceVi: "Em có một con mèo."
                ),
                Example(
                    level: "movers",
                    sentenceEn: "My cat is sleeping on the sofa.",
                    sentenceVi: "Con mèo của em đang ngủ trên ghế sofa."
                ),
                Example(
                    level: "flyers",
                    sentenceEn: "Cats are independent animals that make great pets.",
                    sentenceVi: "Mèo là loài vật độc lập và là thú cưng tuyệt vời."
                ),
            ],
            imageUrl: nil,
            emoji: "🐱",
            difficulty: 1,
            frequency: "common",
            xpValue: 5,
            gemsValue: 1,
            addedDate: Date(),
            lastUpdated: Date(),
            dataCompleteness: DataCompleteness(
                hasTranslation: true,
                hasDefinitionEn: true,
                hasDefinitionVi: true,
                hasIPABritish: true,
                hasIPAAmerican: true,
                hasAudioBritish: true,
                hasAudioAmerican: true,
                hasExamplesEn: true,
                hasExamplesVi: true
            )
        )

        /// Sample words array
        static let samples: [DictionaryWord] = [
            sample,
            DictionaryWord(
                id: "dog",
                word: "dog",
                british: "dog",
                american: "dog",
                irregularPlural: false,
                partOfSpeech: ["noun"],
                primaryPos: "noun",
                levels: ["starters"],
                primaryLevel: "starters",
                categories: ["animals"],
                translationVi: "con chó",
                definitionEn: "A domesticated animal with four legs, often kept as a pet.",
                definitionVi:
                    "Một con vật được thuần hóa với bốn chân, thường được nuôi làm thú cưng.",
                pronunciation: Pronunciation(
                    british: PronunciationData(ipa: "/dɒɡ/", audioUrl: "", audioSource: ""),
                    american: PronunciationData(ipa: "/dɔːɡ/", audioUrl: "", audioSource: "")
                ),
                examples: [
                    Example(
                        level: "starters", sentenceEn: "I see a dog.",
                        sentenceVi: "Em nhìn thấy con chó.")
                ],
                imageUrl: nil,
                emoji: "🐶",
                difficulty: 1,
                frequency: "common",
                xpValue: 5,
                gemsValue: 1,
                addedDate: Date(),
                lastUpdated: Date(),
                dataCompleteness: nil
            ),
        ]
    }
#endif
