//
//  AppFonts.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts (For headers and hero text)
    static let appDisplayLarge = Font.largeTitle.weight(.heavy)
    static let appDisplayMedium = Font.largeTitle.weight(.bold)
    static let appDisplaySmall = Font.title.weight(.bold)
    
    // MARK: - Title Fonts (For section headers)
    static let appTitleLarge = Font.title.weight(.bold)
    static let appTitleMedium = Font.title2.weight(.semibold)
    static let appTitleSmall = Font.title3.weight(.medium)
    
    // MARK: - Body Fonts (For content)
    static let appBodyLarge = Font.body.weight(.medium)
    static let appBodyMedium = Font.body
    static let appBodySmall = Font.callout
    
    // MARK: - Label Fonts (For UI labels)
    static let appLabelLarge = Font.headline.weight(.semibold)
    static let appLabelMedium = Font.subheadline.weight(.medium)
    static let appLabelSmall = Font.caption.weight(.medium)
    
    // MARK: - Specialized Fonts (For specific use cases)
    static let appButtonLabel = Font.headline.weight(.semibold)
    static let appNavigationTitle = Font.title2.weight(.bold)
    static let appCardTitle = Font.headline.weight(.semibold)
    static let appCardSubtitle = Font.subheadline
    static let appBadgeText = Font.caption.weight(.bold)
    
    // MARK: - Legacy Font Support (for backward compatibility)
    static let appTitle = Font.title2.bold()
    static let appHeadline = Font.headline
    static let appBody = Font.body
    static let appCaption = Font.caption
    
    // MARK: - Accessibility Support
    /// Returns font that supports Dynamic Type
    static func appDynamic(_ baseFont: Font, maximumSize: CGFloat = 28) -> Font {
        baseFont
    }
    
    // MARK: - Monospace Fonts (For code/exercises)
    static let appMonoLarge = Font.system(.title2, design: .monospaced).weight(.medium)
    static let appMonoMedium = Font.system(.body, design: .monospaced)
    static let appMonoSmall = Font.system(.caption, design: .monospaced)
}

// MARK: - Font Weight Helpers
extension Font.Weight {
    static let appExtraLight = Font.Weight.ultraLight
    static let appLight = Font.Weight.light
    static let appRegular = Font.Weight.regular
    static let appMedium = Font.Weight.medium
    static let appSemibold = Font.Weight.semibold
    static let appBold = Font.Weight.bold
    static let appHeavy = Font.Weight.heavy
    static let appBlack = Font.Weight.black
}

// MARK: - Text Style Extensions
extension View {
    // MARK: - Quick Font Applications
    func appDisplayStyle() -> some View {
        self.font(.appDisplayMedium)
            .foregroundColor(.appPrimaryText)
    }
    
    func appTitleStyle() -> some View {
        self.font(.appTitleMedium)
            .foregroundColor(.appPrimaryText)
    }
    
    func appBodyStyle() -> some View {
        self.font(.appBodyMedium)
            .foregroundColor(.appPrimaryText)
    }
    
    func appCaptionStyle() -> some View {
        self.font(.appLabelSmall)
            .foregroundColor(.appSecondaryText)
    }
}

// MARK: - Line Height & Character Spacing
extension View {
    func appLineHeight(_ height: CGFloat) -> some View {
        self.lineSpacing(height - (UIFont.preferredFont(forTextStyle: .body).lineHeight))
    }
    
    func appLetterSpacing(_ spacing: CGFloat) -> some View {
        self.kerning(spacing)
    }
}
