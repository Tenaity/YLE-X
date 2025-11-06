//
//  Badge.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI

struct Badge: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let colorName: String // Lưu tên màu từ Design System
    let earnedDate: Date
    
    var color: Color {
        switch colorName {
        case "moversBlue": return .moversBlue
        case "flyersPurple": return .flyersPurple
        case "startersGreen": return .startersGreen
        default: return .gray
        }
    }
}
