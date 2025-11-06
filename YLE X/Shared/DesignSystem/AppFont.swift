//
//  AppFont.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//  Typography system following Apple Design Guidelines
//

import SwiftUI

// MARK: - Font Scales (Apple Design System)
extension Font {
    // MARK: - Display Scale (Hero text, main headings)
    /// Large display heading
    static let appDisplayLarge = Font.system(size: 32, weight: .bold, design: .default)
    /// Medium display heading
    static let appDisplayMedium = Font.system(size: 28, weight: .bold, design: .default)
    /// Small display heading
    static let appDisplaySmall = Font.system(size: 26, weight: .semibold, design: .default)

    // MARK: - Title Scale (Section headers, screen titles)
    /// Large title
    static let appTitleLarge = Font.system(size: 22, weight: .bold, design: .default)
    /// Medium title (most common)
    static let appTitleMedium = Font.system(size: 20, weight: .semibold, design: .default)
    /// Small title
    static let appTitleSmall = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Headline Scale (Labels, call-to-action)
    /// Large headline
    static let appHeadlineLarge = Font.system(size: 17, weight: .semibold, design: .default)
    /// Medium headline (default)
    static let appHeadlineMedium = Font.system(size: 16, weight: .semibold, design: .default)
    /// Small headline
    static let appHeadlineSmall = Font.system(size: 15, weight: .semibold, design: .default)

    // MARK: - Body Scale (Main content, descriptions)
    /// Large body
    static let appBodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    /// Medium body (default)
    static let appBodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    /// Small body
    static let appBodySmall = Font.system(size: 15, weight: .regular, design: .default)

    // MARK: - Callout Scale (Secondary text, navigation)
    /// Large callout
    static let appCalloutLarge = Font.system(size: 16, weight: .regular, design: .default)
    /// Medium callout
    static let appCalloutMedium = Font.system(size: 15, weight: .regular, design: .default)
    /// Small callout
    static let appCalloutSmall = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Subheadline Scale (Secondary labels)
    /// Large subheadline
    static let appSubheadlineLarge = Font.system(size: 15, weight: .regular, design: .default)
    /// Medium subheadline
    static let appSubheadlineMedium = Font.system(size: 14, weight: .regular, design: .default)
    /// Small subheadline
    static let appSubheadlineSmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Caption Scale (Tertiary text, help text)
    /// Large caption
    static let appCaptionLarge = Font.system(size: 12, weight: .regular, design: .default)
    /// Medium caption (default)
    static let appCaptionMedium = Font.system(size: 11, weight: .regular, design: .default)
    /// Small caption
    static let appCaptionSmall = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Monospace Scale (Code, technical content)
    /// Large monospace
    static let appMonospaceLarge = Font.system(size: 16, weight: .regular, design: .monospaced)
    /// Medium monospace
    static let appMonospaceMedium = Font.system(size: 14, weight: .regular, design: .monospaced)
    /// Small monospace
    static let appMonospaceSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: - View Modifiers for Typography
extension View {
    /// Display Large style
    func appDisplayLarge() -> some View {
        self.font(.appDisplayLarge)
            .foregroundColor(.appText)
    }

    /// Display Medium style
    func appDisplayMedium() -> some View {
        self.font(.appDisplayMedium)
            .foregroundColor(.appText)
    }

    /// Display Small style
    func appDisplaySmall() -> some View {
        self.font(.appDisplaySmall)
            .foregroundColor(.appText)
    }

    /// Title Large style
    func appTitleLarge() -> some View {
        self.font(.appTitleLarge)
            .foregroundColor(.appText)
    }

    /// Title Medium style (most common)
    func appTitleMedium() -> some View {
        self.font(.appTitleMedium)
            .foregroundColor(.appText)
    }

    /// Title Small style
    func appTitleSmall() -> some View {
        self.font(.appTitleSmall)
            .foregroundColor(.appText)
    }

    /// Headline Large style
    func appHeadlineLarge() -> some View {
        self.font(.appHeadlineLarge)
            .foregroundColor(.appText)
    }

    /// Headline Medium style
    func appHeadlineMedium() -> some View {
        self.font(.appHeadlineMedium)
            .foregroundColor(.appText)
    }

    /// Headline Small style
    func appHeadlineSmall() -> some View {
        self.font(.appHeadlineSmall)
            .foregroundColor(.appText)
    }

    /// Body Large style
    func appBodyLarge() -> some View {
        self.font(.appBodyLarge)
            .foregroundColor(.appText)
    }

    /// Body Medium style (most common)
    func appBodyMedium() -> some View {
        self.font(.appBodyMedium)
            .foregroundColor(.appText)
    }

    /// Body Small style
    func appBodySmall() -> some View {
        self.font(.appBodySmall)
            .foregroundColor(.appText)
    }

    /// Caption Large style
    func appCaptionLarge() -> some View {
        self.font(.appCaptionLarge)
            .foregroundColor(.appTextSecondary)
    }

    /// Caption Medium style
    func appCaptionMedium() -> some View {
        self.font(.appCaptionMedium)
            .foregroundColor(.appTextSecondary)
    }

    /// Caption Small style
    func appCaptionSmall() -> some View {
        self.font(.appCaptionSmall)
            .foregroundColor(.appTextSecondary)
    }
}
