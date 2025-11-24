# 🗺️ YLE X - Feature Roadmap & Implementation Plan

**Last Updated**: November 23, 2025
**Current Status**: ✅ Phase 1 Complete (Data Ready), 🚧 Phase 2-6 In Planning

---

## 📊 Current State Analysis

### ✅ What's Completed (Phase 1)

#### 1. **Complete Vocabulary Dataset**
- **Status**: ✅ 100% Complete
- **Details**:
  - 1,414 Cambridge YLE words
  - 59 columns per word (base + AI-generated)
  - 100% data completeness (all status = "done")
  - Audio: 79.8% British, 86.4% American (Cambridge)
  - AI-generated: Vietnamese translations, definitions, IPA, examples

**Data Breakdown**:
```
YLE Levels:
- Starters (7-8yo): ~471 words
- Movers (8-11yo): ~471 words
- Flyers (9-12yo): ~472 words

Categories (20 topics):
- Animals, Food & Drink, School, Home, etc.

Parts of Speech (13 types):
- Noun, Verb, Adjective, Adverb, etc.

AI Fields (11 per word):
✅ translationVi (Vietnamese translation)
✅ definitionEn (English definition)
✅ definitionVi (Vietnamese definition)
✅ ipaGB (British IPA)
✅ ipaUS (American IPA)
✅ exampleStarters (English, age 7-8)
✅ exampleMovers (English, age 8-11)
✅ exampleFlyers (English, age 9-12)
✅ exampleStartersVi (Vietnamese, age 7-8)
✅ exampleMoversVi (Vietnamese, age 8-11)
✅ exampleFlyersVi (Vietnamese, age 9-12)
```

#### 2. **Core Swift Models**
- **Status**: ✅ Implemented
- **Files**:
  - `DictionaryWord.swift` - Main vocabulary model
  - `VocabularyCategory.swift` - 20 categories
  - `Lesson.swift` - Lesson structure (dual-path)
  - `Exercise.swift` - Exercise types
  - `UserProgress.swift` - Progress tracking
  - `Gamification.swift` - XP, levels, missions

#### 3. **Basic Features Implemented**
- **Status**: ✅ Partially Implemented
- **Completed**:
  - Dictionary browsing (categories grid)
  - Word detail view (basic)
  - Audio playback service (British/American)
  - Search functionality (basic)
  - Authentication (Phone/Google/Apple)
  - Firebase integration
  - Design system (colors, fonts, spacing)

- **Incomplete/Needs Enhancement**:
  - Flashcard view (exists but needs spaced repetition)
  - Quiz view (exists but needs more modes)
  - Learning paths (structure exists, content needed)
  - AI features (placeholder code)
  - Gamification (models exist, UI incomplete)

---

## 🎯 Feature Roadmap (Phases 2-6)

### **Phase 2: Firebase Data Migration & Dictionary Enhancement**
**Duration**: 1 week
**Priority**: 🔴 Critical (Blocker for all other features)

#### Objectives:
1. ✅ Upload 1,414 words to Firebase Firestore
2. ✅ Create 20 category documents
3. ✅ Verify data integrity
4. 🚧 Enhance dictionary UI/UX
5. 🚧 Implement advanced search

#### Tasks:

**2.1 Firebase Data Migration** (Day 1-2)
```bash
# Prerequisites
- Download serviceAccountKey.json from Firebase
- Install firebase-admin: pip install firebase-admin

# Execution
1. Dry run: python3 migrate_perfect_to_firebase.py
2. Review output (1,414 words, 20 categories)
3. Edit script: DRY_RUN = False
4. Live upload: python3 migrate_perfect_to_firebase.py
5. Verify in Firebase Console
```

**Expected Firestore Structure**:
```
dictionaries/ (1,414 documents)
  ├── a/
  ├── cat/
  ├── dog/
  └── ... (1,411 more)

categories/ (20 documents)
  ├── animals/
  ├── food_and_drink/
  └── ... (18 more)
```

**2.2 Dictionary UI Enhancement** (Day 3-5)

**Current State**: Basic category grid + word list
**Target State**: Rich, interactive dictionary experience

**Enhancements**:

A. **Category View Improvements**
```swift
// Features to add:
- Category cards with gradient backgrounds
- Word count per category
- Preview of 3 random words
- Filter by YLE level (Starters/Movers/Flyers)
- Sort by: Name, Word Count, Recently Added
```

B. **Word Detail View Enhancements**
```swift
// Current: Basic word card
// Add:
- Favorite/bookmark button
- Share word card (generate image)
- Word of the day badge
- Related words section
- Usage statistics (how many users learning this)
- Progress indicator (New/Learning/Mastered)
```

C. **Advanced Search** (Day 6-7)
```swift
// Current: Basic text search
// Add:
- Search filters:
  * YLE Level
  * Part of Speech
  * Category
  * Has Audio (British/American)
  * Difficulty

- Search suggestions (autocomplete)
- Recent searches
- Search history
- Voice search (speech-to-text)
- Search by IPA notation
```

**Implementation**:
```swift
// File: DictionaryViewModel.swift
func searchWithFilters(
    query: String,
    level: YLELevel? = nil,
    partOfSpeech: String? = nil,
    category: String? = nil,
    hasAudio: Bool? = nil
) async {
    var baseQuery = db.collection("dictionaries")

    if let level = level {
        baseQuery = baseQuery.whereField("levels", arrayContains: level.rawValue)
    }

    if let pos = partOfSpeech {
        baseQuery = baseQuery.whereField("partOfSpeech", arrayContains: pos)
    }

    // ... apply other filters

    let snapshot = try await baseQuery.getDocuments()
    searchResults = snapshot.documents.compactMap { try? $0.data(as: DictionaryWord.self) }
}
```

**Success Metrics**:
- ✅ 1,414 words in Firestore
- ✅ 20 categories in Firestore
- ✅ Search returns results <300ms
- ✅ Advanced filters work correctly
- ✅ Audio plays for 86%+ of words

---

### **Phase 3: Flashcard System with Spaced Repetition**
**Duration**: 1.5 weeks
**Priority**: 🟠 High (Core learning feature)

#### Objectives:
1. Implement SM-2 spaced repetition algorithm
2. Create engaging flashcard UI
3. Track user progress per word
4. Daily review reminders

#### Current State Analysis:
```swift
// FlashcardView.swift exists with:
✅ Flip animation
✅ Swipe gestures (right = know, left = don't know)
✅ Front/back card design

❌ Missing:
- Spaced repetition algorithm
- Progress tracking in Firestore
- Daily review scheduling
- Statistics dashboard
```

#### Implementation Plan:

**3.1 Spaced Repetition Algorithm** (Day 1-3)

**Algorithm**: SuperMemo 2 (SM-2)

```swift
// File: Core/Services/SpacedRepetitionService.swift

class SpacedRepetitionService {

    /// SM-2 Algorithm
    /// - Parameters:
    ///   - quality: User response (0-5)
    ///     0 = "complete blackout"
    ///     1 = "incorrect response; correct remembered"
    ///     2 = "incorrect response; correct seemed easy to recall"
    ///     3 = "correct response recalled with serious difficulty"
    ///     4 = "correct response after a hesitation"
    ///     5 = "perfect response"
    func calculateNextReview(
        currentEaseFactor: Double,
        currentInterval: Int,
        quality: Int
    ) -> (easeFactor: Double, interval: Int, nextReviewDate: Date) {

        var easeFactor = currentEaseFactor
        var interval = currentInterval

        // Update ease factor
        easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))

        if easeFactor < 1.3 {
            easeFactor = 1.3
        }

        // Calculate new interval
        if quality < 3 {
            // Failed: Reset to 1 day
            interval = 1
        } else {
            if interval == 0 {
                interval = 1
            } else if interval == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
        }

        // Calculate next review date
        let nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: interval,
            to: Date()
        ) ?? Date()

        return (easeFactor, interval, nextReviewDate)
    }
}
```

**3.2 Firestore Progress Tracking** (Day 4-5)

**New Collection**: `flashcardProgress`

```javascript
// Document ID: {userId}_{wordId}
// Example: flashcardProgress/user123_cat

{
  "userId": "user123",
  "wordId": "cat",

  // SM-2 Algorithm Data
  "easeFactor": 2.5,        // Initial: 2.5
  "interval": 7,            // Days until next review
  "nextReviewDate": Timestamp("2025-11-30"),

  // Statistics
  "reviewCount": 5,         // Total reviews
  "correctCount": 4,        // Correct answers
  "lastReviewed": Timestamp("2025-11-23"),
  "firstReviewed": Timestamp("2025-11-15"),

  // Progress Level
  "level": "learning",      // "new", "learning", "review", "mastered"

  // Last Response
  "lastQuality": 4,         // 0-5 (SM-2 quality)

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Swift Model**:
```swift
// File: Features/Dictionary/Models/FlashcardProgress.swift

struct FlashcardProgress: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let wordId: String

    // SM-2 Data
    var easeFactor: Double       // 1.3 - 2.5+
    var interval: Int            // Days
    var nextReviewDate: Date

    // Statistics
    var reviewCount: Int
    var correctCount: Int
    var lastReviewed: Date?
    var firstReviewed: Date

    // Progress
    var level: ProgressLevel
    var lastQuality: Int         // 0-5

    enum ProgressLevel: String, Codable {
        case new = "new"              // Never reviewed
        case learning = "learning"    // < 3 successful reviews
        case review = "review"        // 3-10 successful reviews
        case mastered = "mastered"    // 10+ successful reviews
    }

    var accuracyPercentage: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount) * 100
    }
}
```

**3.3 Enhanced Flashcard UI** (Day 6-8)

**New Features**:

A. **Improved Card Design**
```swift
// Front Card:
- Word in large font
- IPA notation (British/American toggle)
- Audio button (British 🇬🇧 / American 🇺🇸)
- Part of speech badge
- YLE level indicator

// Back Card:
- Vietnamese translation
- English definition
- Vietnamese definition
- Example sentence (appropriate for user's level)
- Vietnamese translation of example
```

B. **Response Buttons** (Replace simple swipe)
```swift
// After seeing back card, show 4 buttons:
VStack {
    Text("How well did you know this word?")

    HStack(spacing: 12) {
        // Again (quality: 1)
        Button {
            submitReview(quality: 1)
        } label: {
            VStack {
                Text("😕")
                Text("Again")
                Text("< 1 day")
            }
        }

        // Hard (quality: 3)
        Button {
            submitReview(quality: 3)
        } label: {
            VStack {
                Text("😐")
                Text("Hard")
                Text("~3 days")
            }
        }

        // Good (quality: 4)
        Button {
            submitReview(quality: 4)
        } label: {
            VStack {
                Text("😊")
                Text("Good")
                Text("~7 days")
            }
        }

        // Easy (quality: 5)
        Button {
            submitReview(quality: 5)
        } label: {
            VStack {
                Text("😄")
                Text("Easy")
                Text("~14 days")
            }
        }
    }
}
```

C. **Session Statistics**
```swift
// Top bar during session:
HStack {
    // Progress
    Text("\(currentCard)/\(totalCards)")

    // New cards
    HStack {
        Circle().fill(.blue)
        Text("\(newCount)")
    }

    // Review cards
    HStack {
        Circle().fill(.orange)
        Text("\(reviewCount)")
    }

    // Mastered cards
    HStack {
        Circle().fill(.green)
        Text("\(masteredCount)")
    }
}
```

**3.4 Daily Review System** (Day 9-10)

**Features**:
```swift
// Calculate daily review queue
func getDailyReviewQueue(userId: String) async -> [DictionaryWord] {
    let today = Calendar.current.startOfDay(for: Date())

    // Fetch all cards due for review
    let snapshot = try await db.collection("flashcardProgress")
        .whereField("userId", isEqualTo: userId)
        .whereField("nextReviewDate", isLessThanOrEqualTo: today)
        .order(by: "nextReviewDate")
        .getDocuments()

    let progressItems = snapshot.documents.compactMap {
        try? $0.data(as: FlashcardProgress.self)
    }

    // Fetch corresponding words
    let wordIds = progressItems.map { $0.wordId }
    let words = await fetchWords(ids: wordIds)

    return words
}

// Notification reminder
func scheduleReviewReminder(reviewCount: Int) {
    let content = UNMutableNotificationContent()
    content.title = "📚 Daily Review Time!"
    content.body = "You have \(reviewCount) words to review today"
    content.sound = .default

    // Schedule for 8 PM daily
    var dateComponents = DateComponents()
    dateComponents.hour = 20
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "daily-review",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

**3.5 Statistics Dashboard** (Day 11)

**New View**: `FlashcardStatsView.swift`

```swift
struct FlashcardStatsView: View {
    @StateObject private var viewModel = FlashcardStatsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Overview Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Words",
                        value: "\(viewModel.totalWords)",
                        icon: "📚",
                        color: .blue
                    )

                    StatCard(
                        title: "Mastered",
                        value: "\(viewModel.masteredCount)",
                        icon: "✅",
                        color: .green
                    )
                }

                HStack(spacing: 16) {
                    StatCard(
                        title: "Learning",
                        value: "\(viewModel.learningCount)",
                        icon: "🎯",
                        color: .orange
                    )

                    StatCard(
                        title: "Due Today",
                        value: "\(viewModel.dueToday)",
                        icon: "📅",
                        color: .red
                    )
                }

                // Accuracy Chart
                AccuracyChartView(data: viewModel.accuracyData)

                // Review Heatmap (last 30 days)
                ReviewHeatmapView(data: viewModel.reviewHistory)

                // Recent Activity
                RecentReviewsListView(reviews: viewModel.recentReviews)
            }
        }
    }
}
```

**Success Metrics**:
- ✅ SM-2 algorithm correctly calculates intervals
- ✅ User can review cards daily
- ✅ Progress saved to Firestore
- ✅ Notifications sent for due reviews
- ✅ Statistics dashboard shows accurate data

---

### **Phase 4: Advanced Quiz System**
**Duration**: 1.5 weeks
**Priority**: 🟠 High (Assessment & practice)

#### Objectives:
1. Multiple quiz modes (5 types)
2. Adaptive difficulty
3. Performance analytics
4. Leaderboard integration

#### Current State Analysis:
```swift
// QuizView.swift exists with:
✅ Mode selection UI
✅ Basic question display
✅ Results view

❌ Missing:
- Multiple question types
- Listening quiz (audio-based)
- Adaptive difficulty
- Detailed analytics
```

#### Quiz Types to Implement:

**4.1 Definition → Word** (Multiple Choice)
```
Question: "A small furry animal with four legs and a tail"
Options:
A) Dog
B) Cat ✅
C) Mouse
D) Rabbit
```

**4.2 Translation → Word** (Multiple Choice)
```
Question: "con mèo"
Options:
A) Dog
B) Cat ✅
C) Mouse
D) Hamster
```

**4.3 Listening Quiz** (Audio → Word)
```
[Play audio: British pronunciation of "cat"]
Question: "What word did you hear?"
Options:
A) Cut
B) Cat ✅
C) Cot
D) Cart
```

**4.4 Example Sentence Fill-in-Blank**
```
Question: "I have a ___."
Options:
A) dog
B) cat ✅
C) running
D) happy
```

**4.5 IPA → Word** (Advanced)
```
Question: "/kæt/"
Options:
A) Cut
B) Cat ✅
C) Cot
D) Kit
```

#### Implementation:

**4.1 Quiz Generation Service** (Day 1-3)

```swift
// File: Features/Dictionary/Services/QuizGenerationService.swift

class QuizGenerationService {

    enum QuizMode {
        case definitionToWord
        case translationToWord
        case listening
        case fillInBlank
        case ipaToWord
        case mixed
    }

    func generateQuiz(
        words: [DictionaryWord],
        mode: QuizMode,
        questionCount: Int = 10
    ) -> QuizSession {

        var questions: [QuizQuestion] = []

        for word in words.prefix(questionCount) {
            let question: QuizQuestion

            switch mode {
            case .definitionToWord:
                question = generateDefinitionQuestion(word: word, allWords: words)
            case .translationToWord:
                question = generateTranslationQuestion(word: word, allWords: words)
            case .listening:
                question = generateListeningQuestion(word: word, allWords: words)
            case .fillInBlank:
                question = generateFillInBlankQuestion(word: word, allWords: words)
            case .ipaToWord:
                question = generateIPAQuestion(word: word, allWords: words)
            case .mixed:
                question = generateRandomQuestion(word: word, allWords: words)
            }

            questions.append(question)
        }

        return QuizSession(
            questions: questions,
            mode: mode,
            startTime: Date()
        )
    }

    private func generateDefinitionQuestion(
        word: DictionaryWord,
        allWords: [DictionaryWord]
    ) -> QuizQuestion {

        // Get 3 wrong answers from same category
        let wrongAnswers = allWords
            .filter { $0.id != word.id }
            .filter { $0.categories.contains(where: word.categories.contains) }
            .shuffled()
            .prefix(3)
            .map { $0.word }

        var options = wrongAnswers + [word.word]
        options.shuffle()

        return QuizQuestion(
            id: UUID().uuidString,
            type: .definitionToWord,
            questionText: word.definitionEn,
            options: Array(options),
            correctAnswer: word.word,
            wordId: word.id ?? "",
            audioUrl: nil
        )
    }

    private func generateListeningQuestion(
        word: DictionaryWord,
        allWords: [DictionaryWord]
    ) -> QuizQuestion {

        // Get words with similar pronunciation
        let similarWords = allWords
            .filter { $0.id != word.id }
            .filter { isSimilarPronunciation($0.pronunciation.british.ipa, word.pronunciation.british.ipa) }
            .shuffled()
            .prefix(3)
            .map { $0.word }

        var options = similarWords + [word.word]
        options.shuffle()

        return QuizQuestion(
            id: UUID().uuidString,
            type: .listening,
            questionText: "Listen and select the correct word:",
            options: Array(options),
            correctAnswer: word.word,
            wordId: word.id ?? "",
            audioUrl: word.pronunciation.british.audioUrl  // British or American based on user preference
        )
    }

    private func isSimilarPronunciation(_ ipa1: String, _ ipa2: String) -> Bool {
        // Simple similarity check (can be enhanced)
        let vowels1 = ipa1.filter { "aeiouæɑɔəɪʊɛʌ".contains($0) }
        let vowels2 = ipa2.filter { "aeiouæɑɔəɪʊɛʌ".contains($0) }
        return vowels1 == vowels2 || ipa1.prefix(3) == ipa2.prefix(3)
    }
}
```

**4.2 Adaptive Difficulty** (Day 4-5)

```swift
// Adjust difficulty based on user performance

class AdaptiveDifficultyService {

    func adjustDifficulty(
        userProgress: [QuizResult],
        currentDifficulty: Double
    ) -> Double {

        guard !userProgress.isEmpty else { return currentDifficulty }

        // Calculate recent accuracy (last 10 quizzes)
        let recentResults = Array(userProgress.suffix(10))
        let accuracy = recentResults.map { $0.accuracy }.reduce(0, +) / Double(recentResults.count)

        var newDifficulty = currentDifficulty

        if accuracy > 0.9 {
            // Too easy, increase difficulty
            newDifficulty += 0.1
        } else if accuracy < 0.6 {
            // Too hard, decrease difficulty
            newDifficulty -= 0.1
        }

        // Clamp between 0.1 and 1.0
        return max(0.1, min(1.0, newDifficulty))
    }

    func selectWordsForQuiz(
        allWords: [DictionaryWord],
        userLevel: YLELevel,
        difficulty: Double
    ) -> [DictionaryWord] {

        var selectedWords: [DictionaryWord] = []

        // 60% from user's level
        let levelWords = allWords.filter { $0.level == userLevel }.shuffled()
        selectedWords.append(contentsOf: Array(levelWords.prefix(6)))

        if difficulty > 0.7 {
            // High difficulty: Add 40% from next level
            let nextLevel = userLevel.next()
            let hardWords = allWords.filter { $0.level == nextLevel }.shuffled()
            selectedWords.append(contentsOf: Array(hardWords.prefix(4)))
        } else if difficulty < 0.4 {
            // Low difficulty: Add 40% from previous level
            let prevLevel = userLevel.previous()
            let easyWords = allWords.filter { $0.level == prevLevel }.shuffled()
            selectedWords.append(contentsOf: Array(easyWords.prefix(4)))
        } else {
            // Medium difficulty: Mix current level
            selectedWords.append(contentsOf: Array(levelWords.dropFirst(6).prefix(4)))
        }

        return selectedWords.shuffled()
    }
}
```

**4.3 Performance Analytics** (Day 6-8)

**New View**: `QuizAnalyticsView.swift`

```swift
struct QuizAnalyticsView: View {
    @StateObject private var viewModel = QuizAnalyticsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Overall Stats
                StatsSummaryCard(
                    totalQuizzes: viewModel.totalQuizzes,
                    averageScore: viewModel.averageScore,
                    totalTime: viewModel.totalTimeSpent,
                    streak: viewModel.quizStreak
                )

                // Accuracy by Category
                CategoryAccuracyChart(data: viewModel.categoryAccuracy)

                // Accuracy Trend (last 30 days)
                LineChart(data: viewModel.accuracyTrend)
                    .frame(height: 200)

                // Weakest Categories (need improvement)
                WeakCategoriesListView(categories: viewModel.weakCategories)

                // Recent Quiz Results
                RecentQuizzesListView(quizzes: viewModel.recentQuizzes)
            }
        }
    }
}
```

**Firestore Collection**: `quizResults`

```javascript
// Document ID: auto-generated
{
  "userId": "user123",
  "quizId": "quiz_abc123",
  "category": "animals",
  "level": "starters",
  "mode": "mixed",

  // Results
  "totalQuestions": 10,
  "correctAnswers": 8,
  "accuracy": 0.8,
  "score": 80,

  // Time
  "startTime": Timestamp,
  "endTime": Timestamp,
  "totalSeconds": 180,
  "averageTimePerQuestion": 18,

  // Rewards
  "xpEarned": 40,
  "gemsEarned": 4,

  // Detailed Answers
  "answers": [
    {
      "questionId": "q1",
      "wordId": "cat",
      "userAnswer": "cat",
      "correctAnswer": "cat",
      "isCorrect": true,
      "timeSpent": 5
    },
    // ... 9 more
  ],

  // Metadata
  "createdAt": Timestamp
}
```

**Success Metrics**:
- ✅ 5 quiz types implemented
- ✅ Adaptive difficulty adjusts based on performance
- ✅ Analytics show accurate trends
- ✅ Listening quiz plays audio correctly
- ✅ Results saved to Firestore

---

### **Phase 5: Lesson System & Learning Paths**
**Duration**: 2 weeks
**Priority**: 🟡 Medium (Structured learning)

#### Objectives:
1. Create 50+ lessons across 3 levels
2. Implement dual learning paths (Linear + Sandbox)
3. Progress tracking
4. Unlock system with XP/Gems

#### Dual Path System:

**5.1 Linear Path** (Main Quest)

**Structure**:
```
Starters (YLE Level 1)
  ├── Unit 1: Greetings & Introductions (5 lessons)
  ├── Unit 2: Family & Friends (5 lessons)
  ├── Unit 3: Animals (5 lessons)
  ├── Unit 4: Food & Drink (5 lessons)
  ├── Unit 5: Home (5 lessons)
  └── Boss Battle: Starters Mock Test

Movers (YLE Level 2)
  ├── Unit 6: School (5 lessons)
  ├── Unit 7: Sports & Leisure (5 lessons)
  ├── Unit 8: Body & Health (5 lessons)
  ├── Unit 9: Clothes (5 lessons)
  ├── Unit 10: Transport (5 lessons)
  └── Boss Battle: Movers Mock Test

Flyers (YLE Level 3)
  ├── Unit 11: Weather (5 lessons)
  ├── Unit 12: Time (5 lessons)
  ├── Unit 13: Places & Directions (5 lessons)
  ├── Unit 14: Work (5 lessons)
  ├── Unit 15: World Around Us (5 lessons)
  └── Boss Battle: Flyers Mock Test
```

**Lesson Content Template**:
```javascript
{
  "id": "lesson_greetings_1",
  "title": "Lesson 1: Hello & Goodbye",
  "description": "Learn how to greet people and say goodbye",

  "level": "starters",
  "unit": 1,
  "order": 1,

  "vocabulary": ["hello", "hi", "goodbye", "bye", "thank_you", "please"],

  "exercises": [
    {
      "type": "introduction",
      "content": "Video: How to say hello"
    },
    {
      "type": "vocabulary",
      "words": ["hello", "hi"],
      "activity": "flashcard"
    },
    {
      "type": "listening",
      "audio": "conversation1.mp3",
      "questions": [...]
    },
    {
      "type": "speaking",
      "prompt": "Say 'Hello, my name is...'",
      "targetIPA": "/həˈləʊ/"
    },
    {
      "type": "quiz",
      "questionCount": 5,
      "mode": "mixed"
    }
  ],

  "xpReward": 50,
  "gemsReward": 5,
  "estimatedMinutes": 15,

  "unlockRequirements": {
    "previousLesson": null,
    "minXP": 0,
    "minLevel": 1
  }
}
```

**5.2 Sandbox Path** (Side Quest)

**Interactive Map with Islands**:

```
🏝️ Vocabulary Island
  ├── Animals Adventure (20 gems)
  ├── Food Festival (20 gems)
  ├── Home Explorer (20 gems)
  └── School Days (20 gems)

🎵 Pronunciation Workshop
  ├── IPA Basics (30 gems)
  ├── British vs American (30 gems)
  ├── Vowel Sounds (30 gems)
  └── Consonant Clusters (30 gems)

🎮 Grammar Games
  ├── Noun Hunt (25 gems)
  ├── Verb Race (25 gems)
  ├── Adjective Match (25 gems)
  └── Sentence Builder (25 gems)

🎯 Challenge Arena
  ├── Speed Quiz (50 gems)
  ├── Memory Master (50 gems)
  ├── Listening Marathon (50 gems)
  └── Speaking Challenge (50 gems)
```

**Unlock System**:
```swift
func canUnlockSandboxItem(_ item: SandboxItem, user: UserProgress) -> Bool {
    // Check gems
    if user.totalGems < item.requiredGems {
        return false
    }

    // Check level requirement
    if user.userLevel < item.minLevel {
        return false
    }

    // Check prerequisite items
    if let prereq = item.prerequisiteId {
        return user.unlockedSandboxItems.contains(prereq)
    }

    return true
}
```

**Implementation** (Day 1-10):

1. **Create Lesson Content** (Day 1-5)
   - Write 50 lesson scripts
   - Select vocabulary for each lesson
   - Design exercise sequences
   - Record/find audio materials

2. **Lesson UI** (Day 6-8)
   ```swift
   // LinearJourneyView.swift
   - Vertical scrolling path
   - Locked/unlocked indicators
   - Progress bars
   - Boss battle nodes

   // SandboxMapView.swift
   - Interactive island map
   - Gem cost labels
   - Lock/unlock animations
   - Island detail popups
   ```

3. **Progress Tracking** (Day 9-10)
   ```swift
   // Update user progress after lesson completion
   func completeLesssoon(_ lesson: Lesson, score: Double) async {
       // Award XP and gems
       let xp = Int(Double(lesson.xpReward) * score)
       let gems = score >= 0.8 ? lesson.gemsReward : 0

       // Update Firestore
       await db.collection("users").document(userId).updateData([
           "totalXP": FieldValue.increment(Int64(xp)),
           "totalGems": FieldValue.increment(Int64(gems)),
           "completedLessons": FieldValue.arrayUnion([lesson.id])
       ])

       // Check level up
       await checkLevelUp(newXP: currentXP + xp)
   }
   ```

**Success Metrics**:
- ✅ 50+ lessons created and uploaded to Firestore
- ✅ Linear path UI shows progression
- ✅ Sandbox map interactive and unlockable
- ✅ Progress saves correctly
- ✅ XP and gems awarded accurately

---

### **Phase 6: AI-Powered Features**
**Duration**: 2 weeks
**Priority**: 🟢 Medium-Low (Enhancement)

#### Objectives:
1. Speech recognition for pronunciation practice
2. AI pronunciation feedback
3. IPA interactive learning
4. Conversational AI tutor (future)

#### Features:

**6.1 Speech Recognition** (Day 1-4)

```swift
// File: Features/AILearning/Services/SpeechRecognitionService.swift

import Speech

class SpeechRecognitionService: ObservableObject {

    @Published var isRecording = false
    @Published var transcription = ""
    @Published var pronunciationScore: Double = 0.0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startRecording(targetWord: String) throws {
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { status in
            // Handle authorization
        }

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw RecognitionError.requestFailed
        }

        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcription = result.bestTranscription.formattedString

                // Compare with target word
                self.pronunciationScore = self.calculateSimilarity(
                    spoken: self.transcription.lowercased(),
                    target: targetWord.lowercased()
                )
            }
        }

        isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }

    private func calculateSimilarity(spoken: String, target: String) -> Double {
        // Levenshtein distance algorithm
        let spokenChars = Array(spoken)
        let targetChars = Array(target)

        var matrix = Array(repeating: Array(repeating: 0, count: targetChars.count + 1), count: spokenChars.count + 1)

        for i in 0...spokenChars.count {
            matrix[i][0] = i
        }

        for j in 0...targetChars.count {
            matrix[0][j] = j
        }

        for i in 1...spokenChars.count {
            for j in 1...targetChars.count {
                if spokenChars[i-1] == targetChars[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(
                        matrix[i-1][j] + 1,
                        matrix[i][j-1] + 1,
                        matrix[i-1][j-1] + 1
                    )
                }
            }
        }

        let distance = matrix[spokenChars.count][targetChars.count]
        let maxLength = max(spoken.count, target.count)

        return 1.0 - (Double(distance) / Double(maxLength))
    }
}
```

**UI Implementation**:
```swift
// SpeakingExerciseView.swift
struct SpeakingExerciseView: View {
    let word: DictionaryWord
    @StateObject private var speechService = SpeechRecognitionService()

    var body: some View {
        VStack(spacing: 32) {
            // Target Word
            VStack {
                Text(word.word)
                    .font(.system(size: 48, weight: .bold))

                Text(word.pronunciation.british.ipa)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            // Waveform Visualizer
            if speechService.isRecording {
                WaveformVisualizerView()
                    .frame(height: 100)
            }

            // Record Button
            Button {
                if speechService.isRecording {
                    speechService.stopRecording()
                } else {
                    try? speechService.startRecording(targetWord: word.word)
                }
            } label: {
                Circle()
                    .fill(speechService.isRecording ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(.white)
                    )
            }

            // Feedback
            if !speechService.transcription.isEmpty {
                VStack {
                    Text("You said: \(speechService.transcription)")

                    // Score
                    HStack {
                        Text("Accuracy:")
                        ProgressView(value: speechService.pronunciationScore)
                            .tint(scoreColor(speechService.pronunciationScore))
                        Text("\(Int(speechService.pronunciationScore * 100))%")
                    }

                    // Feedback message
                    Text(feedbackMessage(speechService.pronunciationScore))
                        .font(.headline)
                        .foregroundColor(scoreColor(speechService.pronunciationScore))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 { return .green }
        if score >= 0.7 { return .orange }
        return .red
    }

    func feedbackMessage(_ score: Double) -> String {
        if score >= 0.9 { return "Excellent! 🎉" }
        if score >= 0.7 { return "Good job! Keep practicing 👍" }
        return "Try again 💪"
    }
}
```

**6.2 IPA Learning Mode** (Day 5-7)

**Interactive IPA Chart**:
```swift
struct IPALearningView: View {
    let ipaSymbols = [
        IPACategory(name: "Vowels", symbols: [
            IPASymbol(symbol: "æ", example: "cat", audio: "cat_vowel.mp3"),
            IPASymbol(symbol: "ɑː", example: "father", audio: "father_vowel.mp3"),
            // ... more vowels
        ]),
        IPACategory(name: "Consonants", symbols: [
            IPASymbol(symbol: "θ", example: "think", audio: "think_th.mp3"),
            IPASymbol(symbol: "ð", example: "this", audio: "this_th.mp3"),
            // ... more consonants
        ])
    ]

    @State private var selectedSymbol: IPASymbol?

    var body: some View {
        ScrollView {
            ForEach(ipaSymbols) { category in
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(category.symbols) { symbol in
                            IPASymbolCard(symbol: symbol)
                                .onTapGesture {
                                    selectedSymbol = symbol
                                }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedSymbol) { symbol in
            IPASymbolDetailView(symbol: symbol)
        }
    }
}

struct IPASymbolCard: View {
    let symbol: IPASymbol

    var body: some View {
        VStack {
            Text(symbol.symbol)
                .font(.system(size: 36))
            Text(symbol.example)
                .font(.caption)
        }
        .frame(width: 80, height: 80)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
```

**Success Metrics**:
- ✅ Speech recognition works with 80%+ accuracy
- ✅ Pronunciation score calculated correctly
- ✅ IPA chart interactive and educational
- ✅ Audio examples play for each IPA symbol

---

## 📊 Priority Matrix & Timeline

### Overall Timeline: 8-10 weeks

```
Week 1-2:   Phase 2 - Firebase Migration & Dictionary Enhancement
Week 3-4:   Phase 3 - Flashcard System with Spaced Repetition
Week 5-6:   Phase 4 - Advanced Quiz System
Week 7-8:   Phase 5 - Lesson System & Learning Paths
Week 9-10:  Phase 6 - AI-Powered Features
```

### Priority Matrix:

```
High Impact, High Effort:
├── Phase 3: Flashcard System (Critical for retention)
├── Phase 4: Quiz System (Critical for assessment)
└── Phase 5: Lesson System (Core product value)

High Impact, Low Effort:
├── Phase 2: Firebase Migration (Unblocks everything)
└── Dictionary Enhancement (Improves UX immediately)

Low Impact, High Effort:
└── Phase 6: AI Features (Nice-to-have, complex)

Low Impact, Low Effort:
└── Minor UI polish, bug fixes
```

### Recommended Order:

**MVP Launch** (Weeks 1-6):
1. ✅ Phase 2: Firebase Migration (Week 1) - BLOCKER
2. ✅ Dictionary Enhancement (Week 1) - Quick wins
3. ✅ Phase 3: Flashcard System (Weeks 2-3) - Core feature
4. ✅ Phase 4: Quiz System (Weeks 4-5) - Core feature
5. ⏸️ Basic gamification (Week 6) - XP/Gems working

**Post-MVP** (Weeks 7-10):
6. Phase 5: Lesson System (Weeks 7-8) - Content-heavy
7. Phase 6: AI Features (Weeks 9-10) - Enhancement
8. Social features (Leaderboard, friends)
9. Parent dashboard
10. Offline mode

---

## 🎯 Success Metrics (KPIs)

### User Engagement:
- Daily Active Users (DAU): Target 1,000+
- Session Duration: Target 15+ minutes
- Retention (Day 7): Target 40%+
- Retention (Day 30): Target 20%+

### Learning Metrics:
- Words Learned per User: Target 50+ per month
- Flashcard Review Rate: Target 80%+ daily
- Quiz Completion Rate: Target 70%+
- Average Quiz Score: Target 75%+

### Technical Metrics:
- App Launch Time: < 2 seconds
- API Response Time: < 500ms
- Crash Rate: < 1%
- Audio Playback Success: > 95%

---

## 🚀 Launch Strategy

### Beta Testing (Week 6):
1. Internal testing (50 users)
2. Fix critical bugs
3. Gather feedback
4. Iterate on UX

### Soft Launch (Week 8):
1. TestFlight beta (500 users)
2. Monitor analytics
3. A/B test features
4. Optimize onboarding

### Public Launch (Week 10):
1. App Store submission
2. Marketing campaign
3. Press release
4. Social media push

---

## 📝 Next Immediate Actions

### This Week:
1. **Run Firebase Migration**
   ```bash
   python3 migrate_perfect_to_firebase.py
   ```
2. **Verify Data in Firebase Console**
   - dictionaries: 1,414 documents ✅
   - categories: 20 documents ✅

3. **Test Dictionary Features**
   - Category browsing
   - Word search
   - Audio playback
   - Word detail view

### Next Week:
1. **Start Flashcard System**
   - Implement SM-2 algorithm
   - Create FlashcardProgress model
   - Build enhanced flashcard UI

2. **Design Lesson Content**
   - Outline 50 lessons
   - Select vocabulary per lesson
   - Design exercise sequences

---

**Document Version**: 1.0
**Last Updated**: November 23, 2025
**Status**: Ready for Phase 2 Implementation 🚀
