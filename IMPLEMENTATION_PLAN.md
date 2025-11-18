# 🚀 YLE X - Vocabulary Implementation Plan

**Date**: November 18, 2025
**Status**: Ready to Execute
**Timeline**: 3 weeks to TestFlight

---

## 📋 Executive Summary

**Goal**: Integrate 1,414 Cambridge YLE vocabulary words into YLE X app

**Current Status**:
- ✅ Data 100% complete (Cam_Voca_2018.csv)
- ✅ Firebase structure designed
- ✅ Migration script ready
- ✅ UI wireframes designed
- ⏳ Ready to implement

**Timeline**: 3 weeks
**Cost**: $0 (data already complete)
**Approach**: Hybrid (Category Islands + Linear Path)

---

## 🎯 Implementation Strategy

### **Chosen Approach: HYBRID** 🎯

We will implement BOTH learning paths to maximize engagement:

#### **1. Sandbox Path: Category Islands** (Priority 1)
- 20 topic-based islands
- Free exploration
- Perfect for casual learning
- Easy to implement first

#### **2. Main Quest: Linear Path** (Priority 2)
- 60 structured rounds
- Story-driven progression
- Boss battles
- Add after Sandbox works

---

## 📅 3-Week Timeline

### **WEEK 1: Firebase & Backend** ⚙️

#### **Day 1 (Today): Preparation**
- [x] Analyze data (DONE)
- [x] Design Firebase structure (DONE)
- [x] Update migration script (DONE)
- [ ] Set up Firebase project
- [ ] Download serviceAccountKey.json

**Actions**:
```bash
# 1. Go to Firebase Console
https://console.firebase.google.com

# 2. Select YLE X project (or create new)

# 3. Go to Project Settings → Service Accounts

# 4. Generate new private key

# 5. Download serviceAccountKey.json

# 6. Move to project root:
mv ~/Downloads/serviceAccountKey.json /home/user/YLE-X/
```

---

#### **Day 2: Migration Testing**
- [ ] Test migration script with DRY_RUN
- [ ] Verify data parsing
- [ ] Check category mapping
- [ ] Review sample output

**Actions**:
```bash
cd /home/user/YLE-X

# Test migration (dry run)
python3 migrate_perfect_to_firebase.py

# Expected output:
# - 20 categories parsed
# - 1,414 words parsed
# - 100% completeness stats
# - No errors
```

---

#### **Day 3: Categories Upload**
- [ ] Upload 20 categories to Firebase
- [ ] Verify in Firebase Console
- [ ] Test category queries

**Actions**:
```bash
# 1. Edit migrate_perfect_to_firebase.py
# Set DRY_RUN = False (temporarily, just for categories)

# 2. Comment out vocabulary upload section
# Uncomment categories only

# 3. Run script
python3 migrate_perfect_to_firebase.py

# 4. Verify in Firebase Console:
# - categories collection should have 20 documents
# - Each with: name, nameVi, icon, color, wordCount
```

---

#### **Day 4-5: Vocabulary Upload**
- [ ] Upload all 1,414 words
- [ ] Monitor upload progress
- [ ] Verify completeness
- [ ] Spot-check quality

**Actions**:
```bash
# 1. Edit migrate_perfect_to_firebase.py
# Set DRY_RUN = False

# 2. Run full migration
python3 migrate_perfect_to_firebase.py

# Expected time: 5-10 minutes
# Expected output: 1,414 words uploaded

# 3. Check Firestore Console:
# - dictionaries collection: 1,414 documents
# - Random sample 10 words: verify all fields present
```

---

#### **Day 6: Indexing & Queries**
- [ ] Create Firestore indexes
- [ ] Test queries from console
- [ ] Optimize query performance
- [ ] Document query patterns

**Firestore Indexes to Create**:
```
Collection: dictionaries

Index 1: Category + Level Query
  - categories (array)
  - levels (array)
  - word (ascending)

Index 2: Level Query
  - primaryLevel (ascending)
  - word (ascending)

Index 3: Search Query
  - word (ascending)
  - translationVi (ascending)
```

**Test Queries**:
```javascript
// 1. Get all words in "animals" category for "starters"
db.collection('dictionaries')
  .where('categories', 'array-contains', 'animals')
  .where('levels', 'array-contains', 'starters')
  .get()

// 2. Get all starters level words
db.collection('dictionaries')
  .where('primaryLevel', '==', 'starters')
  .orderBy('word')
  .limit(20)
  .get()

// 3. Search by word
db.collection('dictionaries')
  .where('word', '>=', 'cat')
  .where('word', '<=', 'cat\uf8ff')
  .get()
```

---

#### **Day 7: Week 1 Review**
- [ ] Verify all data in Firebase
- [ ] Test all query patterns
- [ ] Document any issues
- [ ] Plan Week 2 implementation

**Deliverables**:
- ✅ 1,414 words in Firebase
- ✅ 20 categories in Firebase
- ✅ All indexes created
- ✅ Queries tested and working

---

### **WEEK 2: Swift Models & Core UI** 📱

#### **Day 8: Swift Models**
- [ ] Create DictionaryWord model
- [ ] Create VocabularyCategory model
- [ ] Add Codable conformance
- [ ] Test JSON parsing

**Files to Create**:
```
YLE X/
  Models/
    Vocabulary/
      DictionaryWord.swift         ← NEW
      VocabularyCategory.swift     ← NEW
      VocabularyEnums.swift        ← NEW
```

**Implementation**:
```swift
// See VOCABULARY_DATA_ANALYSIS.md for full code
// Models include:
// - DictionaryWord
// - VocabularyCategory
// - Pronunciation struct
// - Example struct
```

---

#### **Day 9: ViewModels**
- [ ] Create DictionaryViewModel
- [ ] Create AudioPlayerViewModel
- [ ] Implement Firebase queries
- [ ] Add error handling

**Files to Create**:
```
YLE X/
  ViewModels/
    Vocabulary/
      DictionaryViewModel.swift      ← NEW
      AudioPlayerViewModel.swift     ← NEW
```

**Key Functions**:
- `fetchCategories()` - Get all 20 categories
- `fetchWords(category:level:)` - Get words by filter
- `searchWords(query:level:)` - Search functionality
- `playAudio(word:accent:)` - Audio playback

---

#### **Day 10-11: Category Grid UI**
- [ ] Create VocabularyCategoriesView
- [ ] Design CategoryCard component
- [ ] Add navigation
- [ ] Implement loading states

**UI Structure**:
```
VocabularyCategoriesView
  ├── NavigationView
  ├── ScrollView
  └── LazyVGrid (2 columns)
      └── CategoryCard (×20)
          ├── Icon emoji
          ├── English name
          ├── Vietnamese name
          └── Word count
```

**Visual Design**:
- Grid: 2 columns
- Spacing: AppSpacing.md (16pt)
- Cards: Colored backgrounds (category.color)
- Icons: 50pt emoji
- Shadow: .light

---

#### **Day 12-13: Word List UI**
- [ ] Create WordListView
- [ ] Design WordRow component
- [ ] Add level filtering
- [ ] Implement search bar

**UI Structure**:
```
WordListView
  ├── NavigationBar (category icon + name)
  ├── Level Filter Picker
  ├── Search Bar
  └── List
      └── WordRow (×N)
          ├── Word (English)
          ├── Translation (Vietnamese)
          └── Level Badge
```

**Features**:
- Filter by level (Starters/Movers/Flyers)
- Search by English or Vietnamese
- Sorted alphabetically
- Pull to refresh

---

#### **Day 14: Week 2 Review**
- [ ] Test category browsing
- [ ] Test word filtering
- [ ] Test navigation flow
- [ ] Fix any bugs

**Deliverables**:
- ✅ Category grid working
- ✅ Word list working
- ✅ Navigation functional
- ✅ Firebase queries working

---

### **WEEK 3: Word Detail & Advanced Features** 🎨

#### **Day 15-16: Word Detail UI**
- [ ] Create WordDetailView
- [ ] Design audio player controls
- [ ] Add definitions section
- [ ] Implement examples section

**UI Structure**:
```
WordDetailView
  ├── ScrollView
  └── VStack
      ├── WordHeaderSection
      │   ├── Word (large)
      │   ├── Translation
      │   └── Audio buttons (🇬🇧 / 🇺🇸)
      ├── DefinitionsSection
      │   ├── English definition
      │   └── Vietnamese definition
      ├── ExamplesSection
      │   └── Example cards (×3 levels)
      │       ├── Level badge
      │       ├── English sentence
      │       └── Vietnamese sentence
      └── GrammarSection
          ├── Part of speech
          └── Categories
```

**Audio Implementation**:
- Priority 1: Cambridge audio URL
- Priority 2: Legacy audio URL
- Priority 3: TTS fallback (AVSpeechSynthesizer)
- Both accents: British (🇬🇧) & American (🇺🇸)

---

#### **Day 17: Audio Player**
- [ ] Implement AudioPlayerViewModel
- [ ] Add AVAudioPlayer support
- [ ] Add TTS fallback
- [ ] Handle loading states

**Audio Strategy**:
```swift
func playAudio(word: DictionaryWord, accent: String) {
    let pronunciation = accent == "british"
        ? word.pronunciation.british
        : word.pronunciation.american

    if !pronunciation.audioUrl.isEmpty {
        // Priority 1: Play from URL
        playFromURL(pronunciation.audioUrl)
    } else {
        // Priority 2: TTS fallback
        playTTS(text: word.word, accent: accent)
    }
}
```

**Coverage**:
- Cambridge audio: 76% (1,074 words)
- Legacy audio: ~14% (340 words)
- TTS fallback: 100% (all words)
- **Effective: 100% audio coverage**

---

#### **Day 18: Search Functionality**
- [ ] Create VocabularySearchView
- [ ] Implement search bar
- [ ] Add level filters
- [ ] Optimize search performance

**Search Features**:
- Search by English word
- Search by Vietnamese translation
- Filter by level (All/Starters/Movers/Flyers)
- Real-time results
- Search history (optional)

---

#### **Day 19-20: Flashcard Mode**
- [ ] Create FlashcardView
- [ ] Implement swipe gestures
- [ ] Add flip animation
- [ ] Track progress

**Flashcard Features**:
- Tap to flip (English ↔ Vietnamese)
- Swipe right = "I know"
- Swipe left = "Don't know"
- Progress tracking
- Category-based decks
- Daily review system

**UI Design**:
```
FlashcardView
  ├── Progress bar (X/Y cards)
  ├── Card (flip animation)
  │   ├── Front: English word
  │   └── Back: Vietnamese + Definition
  ├── Swipe gestures
  └── Action buttons
      ├── ✅ Know it
      ├── ❌ Don't know
      └── 🔊 Listen
```

---

#### **Day 21: Testing & Polish**
- [ ] End-to-end testing
- [ ] Fix bugs
- [ ] Polish UI/UX
- [ ] Optimize performance
- [ ] Prepare for TestFlight

**Testing Checklist**:
- [ ] Category browsing works
- [ ] Word filtering works
- [ ] Audio playback works (all 3 sources)
- [ ] Search returns correct results
- [ ] Flashcards swipe correctly
- [ ] No crashes on 1,414 words
- [ ] Loading states clear
- [ ] Error messages helpful
- [ ] Dark mode supported
- [ ] Accessibility labels present

---

## 🎨 UI Design Guidelines

### **Color Scheme**
Use category colors from Firebase:
```swift
// Category colors (from CATEGORIES_DATA)
Animals:       #4ECDC4 (Teal)
School:        #FDA7DF (Pink)
Food & Drink:  #FF6B6B (Red)
Sports:        #F79F1F (Orange)
...
```

### **Typography**
Use Design System (AppFont):
```swift
Word title:     .appDisplayLarge() (32pt)
Translation:    .appTitleMedium() (20pt)
Definition:     .appBodyMedium() (17pt)
Examples:       .appBodySmall() (15pt)
IPA:            .appCaptionSmall() (12pt, monospace)
```

### **Spacing**
Use Design System (AppSpacing):
```swift
Card padding:   AppSpacing.lg (24pt)
Section gaps:   AppSpacing.xl (32pt)
List items:     AppSpacing.md (16pt)
Inline text:    AppSpacing.sm (12pt)
```

### **Components**
Reuse existing Design System:
```swift
Buttons:   AppPrimaryButton, AppSecondaryButton
Cards:     .appCardRadius(), .appShadow(level: .light)
Badges:    LevelBadge (for Starters/Movers/Flyers)
Loading:   ProgressView() with .appSmooth animation
```

---

## 📊 Integration with Existing App

### **Add to Tab Bar**
```swift
// YLE_X_App.swift or MainTabView.swift
TabView {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }

    VocabularyCategoriesView()  // ← NEW
        .tabItem {
            Label("Vocabulary", systemImage: "book.fill")
        }

    ProfileView()
        .tabItem {
            Label("Profile", systemImage: "person.fill")
        }
}
```

### **Add to Sandbox Path**
In existing SandboxView, add Vocabulary island:
```swift
// Features/SandboxPath/Views/SandboxView.swift
IslandCard(
    title: "Vocabulary Dictionary",
    titleVi: "Từ Điển",
    icon: "📚",
    color: "#6C63FF",
    description: "Learn 1,414 Cambridge words",
    destination: VocabularyCategoriesView()
)
```

### **Gamification Integration**
Award XP and gems for vocabulary learning:
```swift
// After completing a flashcard deck
userViewModel.addXP(word.xpValue * wordsLearned)
userViewModel.addGems(word.gemsValue * perfectScores)

// After studying 10 words
achievementViewModel.unlock("first_10_words")

// After mastering a category
achievementViewModel.unlock("animals_master")
```

---

## 🎯 Success Criteria

### **Week 1 (Backend)**
- ✅ All 1,414 words in Firebase
- ✅ All 20 categories in Firebase
- ✅ Queries working correctly
- ✅ No data loss or corruption

### **Week 2 (Core UI)**
- ✅ Category grid displays all 20 categories
- ✅ Word list shows filtered words
- ✅ Navigation flows smoothly
- ✅ Firebase queries < 1 second

### **Week 3 (Advanced)**
- ✅ Word detail shows all data
- ✅ Audio plays correctly (100% coverage)
- ✅ Search finds relevant words
- ✅ Flashcards work smoothly
- ✅ No crashes, no bugs

### **Performance Targets**
- Category load: < 500ms
- Word list load: < 1s
- Search results: < 100ms
- Audio playback: < 500ms
- Smooth scrolling: 60 FPS

---

## 🐛 Potential Issues & Solutions

### **Issue 1: Large Dataset Performance**
**Problem**: 1,414 words might slow down UI

**Solutions**:
- ✅ Use LazyVStack/LazyVGrid (loads on scroll)
- ✅ Implement pagination (20 words at a time)
- ✅ Cache category counts
- ✅ Use Firestore indexes

### **Issue 2: Audio Loading Time**
**Problem**: Cambridge audio from external URLs

**Solutions**:
- ✅ Priority system (Cambridge → Legacy → TTS)
- ✅ TTS fallback (instant, on-device)
- ✅ Cache played audio (URLCache)
- ✅ Preload audio on card appear

### **Issue 3: Search Performance**
**Problem**: Searching 1,414 words might be slow

**Solutions**:
- ✅ Firestore client-side search (fast)
- ✅ Debounce search input (300ms)
- ✅ Limit results (50 max)
- ✅ Consider Algolia later (if needed)

### **Issue 4: Offline Support**
**Problem**: Need internet for Firebase

**Solutions**:
- ✅ Enable Firestore offline persistence
- ✅ TTS works offline
- ✅ Show cached data first
- ✅ Sync when online

```swift
// Enable offline persistence
let settings = FirestoreSettings()
settings.isPersistenceEnabled = true
db.settings = settings
```

---

## 📈 Post-Launch Enhancements

### **Phase 2A: Spaced Repetition**
- Track which words user knows
- Show difficult words more often
- Daily review reminders

### **Phase 2B: Quizzes**
- Multiple choice (definition → word)
- Listening quiz (audio → word)
- Translation quiz (EN ↔ VI)
- Spelling quiz

### **Phase 2C: Images**
- Add illustrations for nouns
- Use AI image generation (DALL-E)
- User-uploaded images (moderated)

### **Phase 2D: Social Features**
- Share learned words
- Challenge friends (flashcard duel)
- Vocabulary leaderboard

### **Phase 2E: Analytics**
Track:
- Most studied categories
- Audio playback rate (British vs American)
- Search queries (improve content)
- Difficult words (common mistakes)

---

## 💡 Key Decisions to Make

### **Decision 1: Word Detail Navigation**
**Option A**: Full-screen detail (current plan)
**Option B**: Bottom sheet (modal)

**Recommendation**: Full-screen (better for examples)

### **Decision 2: Audio Auto-play**
**Option A**: Auto-play on word detail open
**Option B**: Manual play only

**Recommendation**: Manual (user control)

### **Decision 3: Example Filtering**
**Option A**: Show all 3 levels always
**Option B**: Show only user's level and below

**Recommendation**: Option B (progressive disclosure)

### **Decision 4: Flashcard Deck Size**
**Option A**: Entire category (could be 130+ cards)
**Option B**: 20 cards per session

**Recommendation**: Option B (manageable chunks)

---

## 📝 Documentation to Create

### **For Developers**:
- [ ] Firebase schema documentation
- [ ] API query examples
- [ ] Model structure guide
- [ ] UI component library

### **For Users**:
- [ ] How to use vocabulary feature
- [ ] How flashcards work
- [ ] How to choose between British/American
- [ ] FAQ

### **For Stakeholders**:
- [ ] Feature overview
- [ ] Usage analytics plan
- [ ] Future roadmap
- [ ] Success metrics

---

## 🚀 Launch Checklist

### **Before TestFlight**:
- [ ] All 1,414 words verified
- [ ] All features working
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Dark mode supported
- [ ] Accessibility labels
- [ ] Privacy policy updated
- [ ] App Store screenshots prepared

### **TestFlight Submission**:
- [ ] Build uploaded to App Store Connect
- [ ] Beta testing notes written
- [ ] Invite 20-30 beta testers
- [ ] Set up feedback channel
- [ ] Monitor crash reports

### **Public Launch**:
- [ ] All beta issues fixed
- [ ] Marketing materials ready
- [ ] App Store listing optimized
- [ ] Support email set up
- [ ] Analytics dashboard ready

---

## 🎉 Expected Impact

### **For Students**:
- ✅ Access to 1,414 Cambridge words
- ✅ Learn with age-appropriate examples
- ✅ Practice pronunciation (both accents)
- ✅ Fun, engaging flashcards
- ✅ Track learning progress

### **For App**:
- ✅ Massive content addition
- ✅ New learning mode (vocabulary)
- ✅ Increased daily engagement
- ✅ Premium feature potential
- ✅ Differentiation from competitors

### **For Business**:
- ✅ No additional costs ($0)
- ✅ Production-ready in 3 weeks
- ✅ Scalable architecture
- ✅ Future monetization opportunities

---

## 📞 Summary

**What We're Building**:
- 20-category vocabulary browser
- Word detail with audio (both accents)
- Smart search (EN/VI)
- Flashcard learning mode
- Integration with existing gamification

**Timeline**: 3 weeks
**Cost**: $0
**Data Quality**: 100% complete
**Ready to Start**: YES ✅

**Next Step**: Set up Firebase project and begin Week 1 implementation! 🚀

---

**Status**: ✅ **READY TO IMPLEMENT**
**Created**: November 18, 2025
**Last Updated**: November 18, 2025
