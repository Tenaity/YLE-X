//
//  VocabularyCategory.swift
//  YLE X
//
//  Created on 11/18/25.
//  20 Cambridge YLE vocabulary categories
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Vocabulary Category Model

struct VocabularyCategory: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// Firestore document ID (e.g., "animals", "food_and_drink")
    @DocumentID var id: String?

    /// Category ID (same as document ID)
    let categoryId: String

    /// English name
    let name: String

    /// Vietnamese name
    let nameVi: String

    /// Emoji icon
    let icon: String

    /// Hex color code
    let color: String

    /// Display order (1-20)
    let order: Int

    /// Number of words in this category
    let wordCount: Int

    /// English description
    let description: String

    /// Vietnamese description
    let descriptionVi: String

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId
        case name, nameVi
        case icon, color
        case order, wordCount
        case description, descriptionVi
    }

    // MARK: - Computed Properties

    /// SwiftUI Color from hex
    var swiftUIColor: Color {
        Color(hex: color) ?? .blue
    }

    /// Category type enum
    var categoryType: CategoryType {
        CategoryType(rawValue: categoryId) ?? .animals
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VocabularyCategory, rhs: VocabularyCategory) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Category Type Enum

enum CategoryType: String, CaseIterable {
    case animals = "animals"
    case bodyAndFace = "body_and_face"
    case clothes = "clothes"
    case colours = "colours"
    case familyAndFriends = "family_and_friends"
    case foodAndDrink = "food_and_drink"
    case health = "health"
    case home = "home"
    case materials = "materials"
    case names = "names"
    case numbers = "numbers"
    case placesAndDirections = "places_and_directions"
    case school = "school"
    case sportsAndLeisure = "sports_and_leisure"
    case time = "time"
    case toys = "toys"
    case transport = "transport"
    case weather = "weather"
    case work = "work"
    case worldAroundUs = "world_around_us"

    var displayName: String {
        switch self {
        case .animals: return "Animals"
        case .bodyAndFace: return "Body & Face"
        case .clothes: return "Clothes"
        case .colours: return "Colours"
        case .familyAndFriends: return "Family & Friends"
        case .foodAndDrink: return "Food & Drink"
        case .health: return "Health"
        case .home: return "Home"
        case .materials: return "Materials"
        case .names: return "Names"
        case .numbers: return "Numbers"
        case .placesAndDirections: return "Places"
        case .school: return "School"
        case .sportsAndLeisure: return "Sports"
        case .time: return "Time"
        case .toys: return "Toys"
        case .transport: return "Transport"
        case .weather: return "Weather"
        case .work: return "Work"
        case .worldAroundUs: return "World"
        }
    }

    var icon: String {
        switch self {
        case .animals: return "🐾"
        case .bodyAndFace: return "👤"
        case .clothes: return "👕"
        case .colours: return "🎨"
        case .familyAndFriends: return "👨‍👩‍👧‍👦"
        case .foodAndDrink: return "🍔"
        case .health: return "💊"
        case .home: return "🏠"
        case .materials: return "🧱"
        case .names: return "👤"
        case .numbers: return "🔢"
        case .placesAndDirections: return "🗺️"
        case .school: return "🎓"
        case .sportsAndLeisure: return "⚽"
        case .time: return "⏰"
        case .toys: return "🧸"
        case .transport: return "🚗"
        case .weather: return "☀️"
        case .work: return "💼"
        case .worldAroundUs: return "🌍"
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension VocabularyCategory {
    /// Sample category for previews
    static let sample = VocabularyCategory(
        id: "animals",
        categoryId: "animals",
        name: "Animals",
        nameVi: "Động Vật",
        icon: "🐾",
        color: "#4ECDC4",
        order: 1,
        wordCount: 63,
        description: "Words related to animals",
        descriptionVi: "Từ vựng về động vật"
    )

    /// Sample categories array
    static let samples: [VocabularyCategory] = [
        sample,
        VocabularyCategory(
            id: "school",
            categoryId: "school",
            name: "School",
            nameVi: "Trường Học",
            icon: "🎓",
            color: "#FDA7DF",
            order: 2,
            wordCount: 95,
            description: "Words related to school",
            descriptionVi: "Từ vựng về trường học"
        ),
        VocabularyCategory(
            id: "food_and_drink",
            categoryId: "food_and_drink",
            name: "Food & Drink",
            nameVi: "Đồ Ăn",
            icon: "🍔",
            color: "#FF6B6B",
            order: 3,
            wordCount: 87,
            description: "Words related to food and drink",
            descriptionVi: "Từ vựng về đồ ăn và thức uống"
        ),
        VocabularyCategory(
            id: "sports_and_leisure",
            categoryId: "sports_and_leisure",
            name: "Sports",
            nameVi: "Thể Thao",
            icon: "⚽",
            color: "#F79F1F",
            order: 4,
            wordCount: 134,
            description: "Words related to sports and leisure",
            descriptionVi: "Từ vựng về thể thao và giải trí"
        )
    ]
}
#endif

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b: Double

        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b)
    }
}
