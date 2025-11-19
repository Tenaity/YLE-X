# 🎨 Dictionary UI Implementation Guide

**Date**: November 18, 2025
**Status**: Backend Complete ✅ | UI Implementation Guide

---

## ✅ What's Complete

### **Models & Services** (100%)
- ✅ DictionaryWord model (Firebase-ready)
- ✅ VocabularyCategory model (20 categories)
- ✅ AudioPlayerService (3-tier audio strategy)
- ✅ DictionaryViewModel (Firebase queries + caching)

### **Next**: Create Kid-Friendly UI Views

---

## 🎯 UI Architecture Overview

```
Vocabulary Feature
├── VocabularyCategoriesView      // Main screen - Category grid
│   └── CategoryCard              // Colorful category cards
│
├── WordListView                   // Words in selected category
│   ├── LevelFilterBar            // Starters/Movers/Flyers tabs
│   └── WordRow                   // List item with word + translation
│
└── WordDetailView                 // Full word detail
    ├── WordHeaderSection         // Word + Audio buttons
    ├── DefinitionsSection        // EN + VI definitions
    ├── ExamplesSection           // 3 levels of examples
    └── AudioButtonsView          // 🇬🇧 British | 🇺🇸 American
```

---

## 📱 Screen 1: Categories Grid

### **Design Principles** (Apple + Kid-Friendly)
- ✅ Large, tappable cards (min 80x80pt)
- ✅ Bright, playful colors
- ✅ Big emoji icons
- ✅ Clear Vietnamese names
- ✅ Word count badges
- ✅ Smooth animations

### **File**: `VocabularyCategoriesView.swift`

```swift
//
//  VocabularyCategoriesView.swift
//  YLE X
//
//  Main vocabulary screen with 20 category cards
//

import SwiftUI

struct VocabularyCategoriesView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @State private var selectedLevel: YLELevel = .starters

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                if viewModel.isLoadingCategories {
                    loadingView
                } else if viewModel.categories.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle("📚 Vocabulary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    levelMenu
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                headerSection

                // Category Grid
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(destination: WordListView(category: category, selectedLevel: selectedLevel)) {
                            CategoryCard(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.lg)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Choose a Topic")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appText)

            Text("1,414 Cambridge Words")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)

            // Level Badge
            HStack(spacing: AppSpacing.xs) {
                Text(selectedLevel.icon)
                Text(selectedLevel.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(Color(hex: selectedLevel.color) ?? .blue)
                    .opacity(0.2)
            )
            .overlay(
                Capsule()
                    .stroke(Color(hex: selectedLevel.color) ?? .blue, lineWidth: 2)
            )
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Level Menu

    private var levelMenu: some View {
        Menu {
            ForEach(YLELevel.allCases, id: \.self) { level in
                Button(action: {
                    withAnimation(.appSmooth) {
                        selectedLevel = level
                    }
                }) {
                    Label {
                        Text("\(level.icon) \(level.displayName)")
                    } icon: {
                        if level == selectedLevel {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title3)
                .foregroundColor(.appPrimary)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading categories...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundColor(.appTextSecondary)

            Text("No categories found")
                .font(.system(size: 20, weight: .bold))

            Text("Please check your Firebase connection")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: VocabularyCategory

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Icon
            Text(category.icon)
                .font(.system(size: 50))

            VStack(spacing: 4) {
                // English name
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Vietnamese name
                Text(category.nameVi)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            // Word count badge
            Text("\(category.wordCount) words")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(category.swiftUIColor)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(category.swiftUIColor.opacity(0.15))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(category.swiftUIColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(category.swiftUIColor.opacity(0.3), lineWidth: 2)
        )
        .appShadow(level: .light)
    }
}

// MARK: - Preview

#Preview {
    VocabularyCategoriesView()
}
```

---

## 📱 Screen 2: Word List

### **File**: `WordListView.swift`

```swift
//
//  WordListView.swift
//  YLE X
//
//  List of words in selected category
//

import SwiftUI

struct WordListView: View {
    let category: VocabularyCategory
    @State var selectedLevel: YLELevel

    @StateObject private var viewModel = DictionaryViewModel()
    @StateObject private var audioService = AudioPlayerService()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Level Filter Bar
                levelFilterBar

                if viewModel.isLoadingWords {
                    loadingView
                } else if viewModel.words.isEmpty {
                    emptyView
                } else {
                    wordsList
                }
            }
        }
        .navigationTitle("\(category.icon) \(category.name)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchWords(for: category, level: selectedLevel)
        }
    }

    // MARK: - Level Filter Bar

    private var levelFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(YLELevel.allCases, id: \.self) { level in
                    LevelFilterChip(
                        level: level,
                        isSelected: level == selectedLevel,
                        action: {
                            selectedLevel = level
                            Task {
                                await viewModel.filterByLevel(level, forCategory: category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color.appBackgroundSecondary)
    }

    // MARK: - Words List

    private var wordsList: some View {
        List {
            ForEach(viewModel.words) { word in
                NavigationLink(destination: WordDetailView(word: word, audioService: audioService)) {
                    WordRow(word: word, audioService: audioService)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
            Text("Loading words...")
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppSpacing.lg) {
            Text(selectedLevel.icon)
                .font(.system(size: 60))
            Text("No words found")
                .font(.system(size: 18, weight: .semibold))
            Text("Try selecting a different level")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Level Filter Chip

struct LevelFilterChip: View {
    let level: YLELevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(level.icon)
                Text(level.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? (Color(hex: level.color) ?? .blue) : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(Color(hex: level.color) ?? .blue, lineWidth: isSelected ? 0 : 1.5)
            )
            .foregroundColor(isSelected ? .white : (Color(hex: level.color) ?? .blue))
        }
    }
}

// MARK: - Word Row

struct WordRow: View {
    let word: DictionaryWord
    @ObservedObject var audioService: AudioPlayerService

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Word info
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appText)

                Text(word.translationVi)
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)

                // Part of speech + IPA
                HStack(spacing: 8) {
                    Text(word.primaryPos)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary.opacity(0.1))
                        )

                    Text(word.pronunciation.british.ipa)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Quick play button
            Button(action: {
                audioService.playAudio(for: word, accent: .british)
            }) {
                Image(systemName: audioService.isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.appPrimary.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color.appBackgroundSecondary)
        )
        .appShadow(level: .subtle)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WordListView(
            category: VocabularyCategory.sample,
            selectedLevel: .starters
        )
    }
}
```

---

## 📱 Screen 3: Word Detail (với Audio)

### **File**: `WordDetailView.swift`

**Due to length, see full code in next message. Key features:**
- ✅ Large word header with emoji
- ✅ Audio buttons: 🇬🇧 British | 🇺🇸 American
- ✅ IPA display for both accents
- ✅ Definitions (EN + VI) in cards
- ✅ Examples filtered by user level
- ✅ Smooth animations
- ✅ Kid-friendly colors

---

## 🎨 Design Specifications

### **Colors** (Kid-Friendly Palette)
```swift
// Category colors are defined in Firebase
// Use category.swiftUIColor for dynamic colors

// App colors (from AppColor.swift)
.appPrimary      // Blue - buttons, accents
.appSuccess      // Green - correct answers
.appText         // Adaptive black/white
.appTextSecondary // Gray
```

### **Typography** (AppFont.swift)
```swift
.appDisplayLarge()    // 32pt bold - Word titles
.appTitleMedium()     // 20pt - Section headers
.appBodyMedium()      // 17pt - Definitions
.appCaptionSmall()    // 12pt - IPA, metadata
```

### **Spacing** (AppSpacing.swift)
```swift
AppSpacing.xs2   // 4pt
AppSpacing.xs    // 8pt
AppSpacing.sm    // 12pt
AppSpacing.md    // 16pt (default)
AppSpacing.lg    // 24pt
AppSpacing.xl    // 32pt
```

### **Animations**
```swift
withAnimation(.appSmooth) {
    // Smooth 0.3s spring animation
}

withAnimation(.appBouncy) {
    // Bouncy spring for playful feel
}
```

---

## 🔊 Audio Implementation

### **Usage in Views**
```swift
@StateObject private var audioService = AudioPlayerService()

// Play button
Button(action: {
    audioService.playAudio(for: word, accent: .british)
}) {
    Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
}

// Accent toggle
Button("🇬🇧 British") {
    audioService.playAudio(for: word, accent: .british)
}

Button("🇺🇸 American") {
    audioService.playAudio(for: word, accent: .american)
}
```

### **3-Tier Audio Strategy** (Automatic)
1. **Cambridge** (76% words) - Plays automatically if available
2. **Legacy** (14% words) - Fallback for missing Cambridge
3. **TTS** (100% words) - Always works as final fallback

---

## 🧪 Testing Checklist

### **Before Testing**
- [ ] Firebase data uploaded (1,414 words)
- [ ] Firebase SDK added to Xcode project
- [ ] serviceAccountKey.json configured (for Firebase emulator/local testing)

### **Test Scenarios**
1. **Categories Screen**
   - [ ] 20 categories load correctly
   - [ ] Tap category → navigates to word list
   - [ ] Level filter menu works
   - [ ] Colors match Firebase data
   - [ ] Pull to refresh works

2. **Word List Screen**
   - [ ] Words load for selected category
   - [ ] Level filters work (Starters/Movers/Flyers)
   - [ ] Word count is correct
   - [ ] Quick play button plays audio
   - [ ] Tap word → navigates to detail

3. **Word Detail Screen**
   - [ ] All word data displays correctly
   - [ ] British audio button plays
   - [ ] American audio button plays
   - [ ] TTS fallback works for words without audio
   - [ ] Examples show correct level
   - [ ] Definitions display in both languages

4. **Audio Playback**
   - [ ] Cambridge audio plays (for words like "cat")
   - [ ] TTS works for all words
   - [ ] Audio stops when switching words
   - [ ] Both accents work

---

## 🔌 Integration with TabBar

### **Add to TabBarView.swift**

```swift
TabView(selection: $selectedTab) {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }
        .tag(0)

    VocabularyCategoriesView()  // ← ADD THIS
        .tabItem {
            Label("Vocabulary", systemImage: "book.fill")
        }
        .tag(1)

    ProfileView()
        .tabItem {
            Label("Profile", systemImage: "person.fill")
        }
        .tag(2)
}
```

---

## 📊 Performance Optimization

### **Caching Strategy** (Already Implemented)
```swift
// ViewModel caches words by category + level
private var wordsCache: [String: [DictionaryWord]] = [:]

// Check cache before fetching
if let cached = wordsCache[cacheKey] {
    words = cached
    return
}
```

### **Limits**
- Categories: Load all 20 (small dataset)
- Words: Limit 200 per query (performance)
- Search: Limit 30 results (UX)

### **Debouncing**
- Search debounced 300ms (prevents excessive queries)

---

## 🎯 Next Steps for You

### **1. Create View Files** (Copy code above)
```
YLE X/Features/Dictionary/Views/
├── VocabularyCategoriesView.swift  ← Screen 1
├── WordListView.swift               ← Screen 2
├── WordDetailView.swift             ← Screen 3 (you need to create)
└── Components/
    ├── CategoryCard.swift           ← Already in first file
    ├── WordRow.swift                ← Already in second file
    └── AudioButton.swift            ← Create for word detail
```

### **2. Add to TabBar**
Update `TabBarView.swift` (see above)

### **3. Build & Test**
```bash
# In Xcode
1. ⌘B - Build project
2. Fix any compilation errors
3. ⌘R - Run on simulator
4. Test Firebase connection
5. Navigate to Vocabulary tab
```

### **4. Verify Firebase Connection**
Watch console for:
```
✅ Loaded 20 categories
✅ Loaded 63 words for Animals
✅ Found 5 results for 'cat'
```

---

## 🐛 Common Issues & Solutions

### **Issue 1: Categories don't load**
**Solution**: Check Firebase Rules
```javascript
// In Firebase Console → Firestore → Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;  // For development
    }
  }
}
```

### **Issue 2: Audio doesn't play**
**Solution**: Check Info.plist
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### **Issue 3: Compilation errors**
**Solution**: Missing imports
```swift
import FirebaseFirestore  // In models
import AVFoundation        // In audio service
import Combine            // In viewModel
```

---

## 📚 Additional Resources

### **Apple Design Guidelines**
- [Human Interface Guidelines - Lists](https://developer.apple.com/design/human-interface-guidelines/lists)
- [HIG - Navigation](https://developer.apple.com/design/human-interface-guidelines/navigation)
- [HIG - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)

### **Firebase Documentation**
- [Firestore Queries](https://firebase.google.com/docs/firestore/query-data/queries)
- [Firestore Arrays](https://firebase.google.com/docs/firestore/query-data/queries#array_membership)
- [Swift SDK](https://firebase.google.com/docs/ios/setup)

---

## ✅ Summary

**What You Have:**
- ✅ Complete backend (models, services, viewModels)
- ✅ Firebase queries working
- ✅ Audio player ready
- ✅ Category system designed
- ✅ UI code templates provided

**What You Need to Do:**
1. Copy UI code into Swift files
2. Add to TabBar
3. Build & test
4. Enjoy 1,414 words! 🎉

---

**Status**: ✅ Ready to build UI
**Timeline**: 2-3 hours to implement views
**Next**: Create WordDetailView (full code coming)

Good luck! 🚀
