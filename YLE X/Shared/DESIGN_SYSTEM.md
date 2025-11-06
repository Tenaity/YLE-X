# YLE X Design System

## Overview
A comprehensive, Apple Design Guidelines-compliant design system for the YLE X iOS application.

## Architecture

### DesignSystem/
Core design tokens and components following Apple's Human Interface Guidelines.

#### **AppFont.swift**
Typography scale with semantic naming:
- **Display**: Large, bold headings (32pt, 28pt, 26pt)
- **Title**: Section headers (22pt, 20pt, 18pt)
- **Headline**: Labels, call-to-action (17pt, 16pt, 15pt)
- **Body**: Main content (17pt, 16pt, 15pt)
- **Callout**: Secondary text (16pt, 15pt, 14pt)
- **Subheadline**: Secondary labels (15pt, 14pt, 13pt)
- **Caption**: Tertiary text (12pt, 11pt, 10pt)
- **Monospace**: Code/technical content

**Usage:**
```swift
Text("Hello").appDisplayMedium()
Text("Body text").appBodyMedium()
Text("Caption").appCaptionMedium()
```

#### **AppColor.swift**
Semantic color system with adaptive light/dark mode support:
- **Text Colors**: `appText`, `appTextSecondary`, `appTextTertiary`
- **Background Colors**: `appBackground`, `appBackgroundSecondary`, `appBackgroundGrouped`
- **Brand Colors**: `appPrimary`, `appSecondary`, `appAccent`
- **Status Colors**: `appSuccess`, `appError`, `appWarning`, `appInfo`
- **YLE Levels**: `appLevelStarters`, `appLevelMovers`, `appLevelFlyers`
- **Skills**: `appSkillListening`, `appSkillSpeaking`, `appSkillReading`, `appSkillWriting`, `appSkillVocabulary`, `appSkillGrammar`
- **Badge Colors**: `appBadgeStarters`, `appBadgeMovers`, `appBadgeFlyers`, `appBadgeGold`, `appBadgeSilver`, `appBadgeBronze`

**Usage:**
```swift
Text("Success").foregroundColor(.appSuccess)
VStack().background(Color.appBackground)
Text("Badge").foregroundColor(.appBadgeGold)
```

#### **AppSpacing.swift**
8pt grid-based spacing system:
- **Base Scale**: xs2 (4pt), xs (8pt), sm (12pt), md (16pt), lg (24pt), xl (32pt), xl2 (48pt), xl3 (64pt)
- **Component Spacing**: Button, Card, List, Screen, Navigation
- **Accessibility**: Minimum touch targets (44pt)

**Usage:**
```swift
VStack(spacing: AppSpacing.md)
Button().padding(AppSpacing.lg)
Text().appPaddingHorizontal(.large)
```

#### **AppRadius.swift**
Corner radius scale for consistent shapes:
- **Base Scale**: none, xs (4pt), sm (8pt), md (12pt), lg (16pt), xl (20pt), full
- **Component Radius**: Button, Card, Input, Modal

**Usage:**
```swift
RoundedRectangle(cornerRadius: AppRadius.md)
Text().appCornerRadius(.medium)
```

#### **AppButton.swift**
Comprehensive button component with variants:
- **Styles**: `.primary`, `.secondary`, `.tertiary`, `.destructive`, `.plain`
- **Sizes**: `.small`, `.medium`, `.large`, `.fullWidth`
- **Variants**: `AppPrimaryButton`, `AppSecondaryButton`, `AppTertiaryButton`, `AppDestructiveButton`, `AppIconButton`

**Usage:**
```swift
AppButton(title: "Submit", style: .primary, size: .fullWidth, action: {})
AppPrimaryButton(title: "Start", action: {})
AppIconButton(icon: "heart.fill", style: .secondary, action: {})
```

#### **AppBadgeStyle.swift**
Badge component for displaying achievements and badges:
- **Sizes**: `.small` (80x80), `.medium` (100x100), `.large` (120x120)
- **View**: `AppBadgeView` - Single badge display
- **Grid**: `AppBadgeGridView` - Grid layout of badges
- **Colors**: Linked to AppColor badge colors

**Usage:**
```swift
AppBadgeView(badge: myBadge, size: .medium)
AppBadgeGridView(badges: myBadges)

// In Badge model
let badge = Badge(
    id: "badge-1",
    name: "First Step",
    description: "Complete your first exercise",
    emoji: "🌱",
    colorName: "appBadgeStarters",  // Uses AppColor
    earnedDate: Date()
)
```

#### **AppShadow.swift**
Shadow depth system for elevation:
- **Levels**: `.none`, `.subtle`, `.light`, `.medium`, `.heavy`
- Opacity and offset automatically managed

**Usage:**
```swift
Card().appShadow(level: .light)
```

#### **AppAnimation.swift**
Standard animation presets:
- **Animations**: `appQuick`, `appSmooth`, `appGentle`, `appBouncy`
- **Transitions**: `appSlide`, `appScale`, `appModal`

**Usage:**
```swift
withAnimation(.appSmooth) {
    isVisible.toggle()
}
Button().transition(.appScale)
```

### Extensions/
Utility extensions and helpers.

#### **View+App.swift**
Common view modifiers:
- Accessibility helpers: `appAccessibilityLabel()`, `appAsButton()`, `appAsHeader()`
- Layout helpers: `fullWidth()`, `fullHeight()`, `square()`, `circle()`
- Conditional modifiers: `if()`, `ifElse()`

#### **Constants.swift**
App-wide constants:
- General: App name, version, build
- Exercise settings
- Timing values
- UserDefaults keys

### Managers/
Reusable managers and services.

#### **HapticManager.swift**
Haptic feedback management:
- Impact feedback: `playLight()`, `playMedium()`, `playHeavy()`
- Notification: `playSuccess()`, `playWarning()`, `playError()`
- Selection: `playSelection()`

## Color Palette

### Semantic Colors (Adaptive)
- Primary text: `.appText`
- Secondary text: `.appTextSecondary`
- Background: `.appBackground`
- Card background: `.appBackgroundSecondary`

### Brand Colors
- Primary (Blue): `#0077FF` - Main actions, focus
- Secondary (Purple): `#8040FF` - Supporting elements
- Accent (Orange): `#FF9900` - Highlights

### YLE Levels
- 🌱 Starters (Green): `#33D633`
- 🚀 Movers (Blue): `#0077FF`
- ✈️ Flyers (Purple): `#B330E3`

### Skills
- 👂 Listening (Sky Blue): `#0AAE!`
- 🗣️ Speaking (Orange): `#FF8400`
- 📖 Reading (Green): `#1AB540`
- ✏️ Writing (Purple): `#9A36CC`
- 📚 Vocabulary (Pink): `#FF3580`
- 📝 Grammar (Cyan): `#00CFCF`

## Design Principles

1. **Clarity**: Clear visual hierarchy and semantic naming
2. **Consistency**: Single source of truth for all design tokens
3. **Accessibility**: WCAG compliance, minimum touch targets (44pt)
4. **Simplicity**: Minimal, focused components with clear purposes
5. **Performance**: Efficient view hierarchy, no unnecessary re-renders

## Usage Examples

### Complete Screen Layout
```swift
VStack(spacing: AppSpacing.lg) {
    Text("Welcome")
        .appDisplayMedium()

    Text("Description text")
        .appBodyMedium()

    AppButton(
        title: "Get Started",
        style: .primary,
        size: .fullWidth,
        action: { }
    )
}
.appScreenPadding()
.background(Color.appBackground)
```

### Card Component
```swift
VStack(spacing: AppSpacing.md) {
    Text("Card Title").appTitleMedium()
    Text("Card content").appBodySmall()
}
.appCardPadding()
.background(Color.appBackgroundSecondary)
.appCardRadius()
.appShadow(level: .light)
```

### Button Usage
```swift
HStack(spacing: AppSpacing.md) {
    AppSecondaryButton(title: "Cancel", action: {})
    AppPrimaryButton(title: "Confirm", action: {})
}
.fullWidth()
```

## Customization

All values are centralized in the respective files. To change:
1. Global font sizes → Edit `AppFont.swift`
2. Color palette → Edit `AppColor.swift`
3. Spacing → Edit `AppSpacing.swift`
4. Corner radius → Edit `AppRadius.swift`
5. Button styles → Edit `AppButton.swift`

## Best Practices

1. ✅ Use semantic color names (`appText` not `blackText`)
2. ✅ Use spacing constants (`AppSpacing.md` not `16`)
3. ✅ Use view modifiers for consistency (`appPadding()` not `padding()`)
4. ✅ Use `@ViewBuilder` for conditional layouts
5. ✅ Test with Dynamic Type enabled
6. ✅ Support dark mode automatically

## Accessibility

- All text uses semantic colors for contrast
- Touch targets minimum 44x44pt
- Font sizes respect Dynamic Type
- Color is never the only indicator
- Haptic feedback for important interactions

---

**Created:** November 2025
**Version:** 1.0
**Framework:** SwiftUI, iOS 15+
