//
//  View+AppAccessibility.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

extension View {
    /// Một hàm tùy chỉnh để thêm các thuộc tính Accessibility (Hỗ trợ tiếp cận)
    /// - Parameters:
    ///   - label: Văn bản mà VoiceOver sẽ đọc
    ///   - hint: Văn bản hướng dẫn (ví dụ: "Nhấn để chọn")
    ///   - traits: Loại của đối tượng (ví dụ: .isButton)
    func appAccessibility(label: String, hint: String, traits: AccessibilityTraits) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(traits)
    }
}
