//
//  Gamification.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Badge Model
struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let emoji: String
    let rarity: BadgeRarity
    let color: String
    let requirement: BadgeRequirement
    let xpReward: Int
    var unlockedAt: Date?

    enum BadgeRarity: String, Codable {
        case common, rare, epic, legendary

        var displayName: String {
            switch self {
            case .common: return "Common"
            case .rare: return "Rare"
            case .epic: return "Epic"
            case .legendary: return "Legendary"
            }
        }

        var borderColor: Color {
            switch self {
            case .common: return Color(hexString: "#4CAF50") ?? Color.white
            case .rare: return Color(hexString: "#2196F3") ?? Color.white
            case .epic: return Color(hexString: "#9C27B0") ?? Color.white
            case .legendary: return Color(hexString: "#FFD700") ?? Color.white
            }
        }
    }

    // Sample badge for preview
    static func sampleBadge(level: String = "appBadgeStarters") -> Badge {
        Badge(
            id: UUID().uuidString,
            name: "Achievement",
            description: "Sample achievement badge",
            icon: "star",
            emoji: "⭐️",
            rarity: .common,
            color: "#FFD700",
            requirement: BadgeRequirement(type: "sample", value: nil),
            xpReward: 50,
            unlockedAt: Date()
        )
    }
}

struct BadgeRequirement: Codable {
    let type: String
    let value: AnyCodable?

    // Default initializer
    init(type: String, value: AnyCodable? = nil) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type, value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        value = try container.decodeIfPresent(AnyCodable.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

// MARK: - Mission Model
struct Mission: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let emoji: String
    let difficulty: MissionDifficulty
    let category: String
    let resetDaily: Bool
    let requirement: MissionRequirement
    let reward: MissionReward
    let active: Bool
    let createdAt: Date

    var rewardXP: Int {
        reward.xp
    }

    enum MissionDifficulty: String, Codable {
        case easy, medium, hard

        var color: Color {
            switch self {
            case .easy: return .appSuccess
            case .medium: return .appWarning
            case .hard: return .appError
            }
        }

        var displayName: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }
    }
}

struct MissionRequirement: Codable {
    let type: String
    let value: AnyCodable?
    let skill: String?
}

struct MissionReward: Codable {
    let xp: Int
    let coins: Int
}

// MARK: - User Level Model
struct UserLevel: Codable {
    let userId: String
    var currentLevel: Int
    var totalXP: Int
    var streakDays: Int
    var lastLoginDate: Date?
    var badgesUnlocked: [String]
    var missionProgress: [String: MissionProgress]
    var petId: String?

    var currentLevelXP: Int {
        let xpThresholds: [Int: Int] = [
            1: 0, 2: 100, 3: 250, 4: 450, 5: 700,
            6: 1000, 7: 1350, 8: 1750, 9: 2200, 10: 2700,
            11: 3250, 12: 3850, 13: 4500, 14: 5200, 15: 5950,
            20: 10000, 50: 50000, 100: 200000
        ]
        return xpThresholds[currentLevel] ?? 0
    }

    var nextLevelXP: Int {
        let xpThresholds: [Int: Int] = [
            1: 100, 2: 250, 3: 450, 4: 700, 5: 1000,
            6: 1350, 7: 1750, 8: 2200, 9: 2700, 10: 3250,
            11: 3850, 12: 4500, 13: 5200, 14: 5950, 15: 10000,
            20: 50000, 50: 200000
        ]
        return xpThresholds[currentLevel] ?? 200000
    }

    var xpProgress: Double {
        let current = totalXP - currentLevelXP
        let needed = nextLevelXP - currentLevelXP
        return needed > 0 ? Double(current) / Double(needed) : 1.0
    }

    var xpToNextLevel: Int {
        max(0, nextLevelXP - totalXP)
    }
}

struct MissionProgress: Codable {
    let missionId: String
    var completed: Int
    let total: Int
    var isCompleted: Bool
    var claimedAt: Date?
}

// MARK: - Virtual Pet Model
struct VirtualPet: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let type: PetType
    let name: String
    var level: Int
    var happiness: Int // 0-100
    var health: Int // 0-100
    var experience: Int
    let adoptedAt: Date
    var lastFedAt: Date?
    var lastPlayedAt: Date?

    enum PetType: String, Codable {
        case dragon, cat, fox, unicorn, phoenix

        var emoji: String {
            switch self {
            case .dragon: return "🐉"
            case .cat: return "🐱"
            case .fox: return "🦊"
            case .unicorn: return "🦄"
            case .phoenix: return "🔥"
            }
        }

        var displayName: String {
            switch self {
            case .dragon: return "Dragon"
            case .cat: return "Cat"
            case .fox: return "Fox"
            case .unicorn: return "Unicorn"
            case .phoenix: return "Phoenix"
            }
        }
    }

    var statusEmoji: String {
        if happiness > 70 && health > 70 {
            return "😊"
        } else if happiness < 30 || health < 30 {
            return "😢"
        } else {
            return "😐"
        }
    }
}

// MARK: - Helper Codable Wrapper
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    var intValue: Int? {
        value as? Int
    }

    var stringValue: String? {
        value as? String
    }

    var doubleValue: Double? {
        value as? Double
    }

    var boolValue: Bool? {
        value as? Bool
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            var dict: [String: Any] = [:]
            for (key, val) in dictVal {
                dict[key] = val.value
            }
            value = dict
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let int = value as? Int {
            try container.encode(int)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            var anyCodableDict: [String: AnyCodable] = [:]
            for (key, val) in dict {
                anyCodableDict[key] = AnyCodable(val)
            }
            try container.encode(anyCodableDict)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "Unable to encode value"
            ))
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
