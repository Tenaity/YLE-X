# AGENTS.md

**YLE X - Cambridge Young Learners English Learning Platform**

> A comprehensive iOS educational app for Vietnamese children (ages 7-12) learning English through the Cambridge YLE curriculum with gamification, AI-powered learning, and dual learning paths.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Data Structure](#data-structure)
4. [Features & Modules](#features--modules)
5. [Build & Test](#build--test)
6. [Firebase Structure](#firebase-structure)
7. [Coding Conventions](#coding-conventions)
8. [Git Workflow](#git-workflow)
9. [Common Tasks](#common-tasks)
10. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

### What is YLE X?

YLE X is an iOS educational platform designed for Vietnamese children (ages 7-12) to learn English following the Cambridge Young Learners English (YLE) curriculum. The app features:

- **1,414 Cambridge YLE words** with complete audio, IPA, definitions, and examples
- **Dual learning paths**: Linear journey (structured lessons) + Sandbox exploration (topic-based)
- **AI-powered features**: Speech recognition, pronunciation feedback, IPA learning
- **Gamification**: XP, levels, gems, pet companions, missions, leaderboards
- **Comprehensive dictionary**: British/American audio, Vietnamese translations, age-appropriate examples
- **Multiple learning modes**: Flashcards, quizzes, speaking exercises, listening practice

### Tech Stack

- **Platform**: iOS 16.0+
- **Language**: Swift 5.9+, SwiftUI
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **AI/ML**: OpenAI GPT-4 (content generation), Speech Recognition API
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependencies**: Firebase SDK, AVFoundation, Combine

### Key Statistics

- **Vocabulary**: 1,414 Cambridge YLE words
- **Audio Coverage**: 79.8% British, 86.4% American (Cambridge Dictionary)
- **YLE Levels**: 3 (Starters age 7-8, Movers age 8-11, Flyers age 9-12)
- **Categories**: 20 topic categories (Animals, Food, School, etc.)
- **Parts of Speech**: 13 types
- **Data Completeness**: 100% (all fields AI-generated via N8N + GPT-4)

---

## 🏗️ Architecture

### Project Structure

```
YLE X/
├── App/
│   ├── YLE_XApp.swift              # App entry point
│   └── MainAppFlow.swift           # Main navigation flow
│
├── Core/
│   ├── Models/                     # Data models
│   │   ├── DictionaryWord.swift    # Main vocabulary model (1,414 words)
│   │   ├── Lesson.swift            # Lesson structure (linear + sandbox)
│   │   ├── Exercise.swift          # Exercise types
│   │   ├── UserProgress.swift      # User learning progress
│   │   ├── Gamification.swift      # XP, levels, missions
│   │   └── Social.swift            # Leaderboard, friends
│   │
│   ├── Services/                   # Business logic services
│   │   ├── FirebaseManager.swift   # Firestore CRUD operations
│   │   ├── AuthService.swift       # Authentication (Phone, Google, Apple)
│   │   ├── AudioService.swift      # Audio playback (British/American)
│   │   ├── ContentService.swift    # Fetch lessons, vocabulary
│   │   ├── ProgressService.swift   # Track user progress
│   │   ├── GamificationService.swift # XP, gems, missions
│   │   └── LeaderboardService.swift  # Social features
│   │
│   ├── Enums/
│   │   ├── YLELevel.swift          # Starters, Movers, Flyers
│   │   └── Skill.swift             # Vocabulary, Listening, etc.
│   │
│   └── Extensions/                 # Helper extensions
│
├── Features/                       # Feature modules (MVVM)
│   ├── Authentication/             # Login, signup, phone auth
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   ├── Onboarding/                 # First-time user experience
│   │   ├── Views/OnboardingView.swift
│   │   └── ViewModels/OnboardingManager.swift
│   │
│   ├── Home/                       # Main dashboard
│   │   ├── Views/HomeView.swift
│   │   ├── Views/ProfileView.swift
│   │   └── ViewModels/HomeViewModel.swift
│   │
│   ├── Dictionary/                 # 1,414 words feature ⭐
│   │   ├── Models/
│   │   │   ├── DictionaryWord.swift      # Main word model
│   │   │   ├── VocabularyCategory.swift  # 20 categories
│   │   │   └── FlashcardProgress.swift   # Spaced repetition
│   │   ├── ViewModels/
│   │   │   ├── DictionaryViewModel.swift # Search, filter, fetch
│   │   │   ├── QuizViewModel.swift       # Quiz logic
│   │   │   └── FlashcardViewModel.swift  # Flashcard system
│   │   ├── Views/
│   │   │   ├── VocabularyCategoriesView.swift  # Grid of categories
│   │   │   ├── WordListView.swift              # Words in category
│   │   │   ├── WordDetailView.swift            # Word card with audio
│   │   │   ├── FlashcardView.swift             # Swipe flashcards
│   │   │   └── QuizView.swift                  # Multiple choice quiz
│   │   └── Services/
│   │       └── AudioPlayerService.swift  # Play British/American audio
│   │
│   ├── Learning/                   # Lessons & exercises
│   │   ├── Views/
│   │   │   ├── LinearJourneyView.swift   # Structured path
│   │   │   ├── SandboxMapView.swift      # Exploration mode
│   │   │   ├── LessonListView.swift
│   │   │   ├── LessonDetailView.swift
│   │   │   └── ExerciseView.swift
│   │   └── ViewModels/
│   │       ├── LearningViewModel.swift
│   │       └── ExerciseViewModel.swift
│   │
│   ├── AILearning/                 # AI-powered features
│   │   ├── Services/
│   │   │   ├── SpeechRecognitionService.swift
│   │   │   └── AILearningService.swift
│   │   ├── Views/Speaking/
│   │   │   ├── SpeakingExerciseView.swift
│   │   │   ├── SpeakingFeedbackView.swift
│   │   │   └── WaveformVisualizerView.swift
│   │   └── Views/
│   │       └── IPALearningView.swift
│   │
│   ├── Gamification/               # XP, missions, pets
│   │   ├── Views/
│   │   │   ├── PetCompanionView.swift
│   │   │   ├── MissionsView.swift
│   │   │   └── UserLevelView.swift
│   │   └── Services/
│   │       └── GamificationService.swift
│   │
│   └── Social/                     # Leaderboard
│       └── Views/LeaderboardView.swift
│
├── Shared/                         # Reusable components
│   ├── DesignSystem/               # App-wide design tokens
│   │   ├── AppColor.swift          # Color palette
│   │   ├── AppFont.swift           # Typography scale
│   │   ├── AppSpacing.swift        # Layout spacing
│   │   ├── AppRadius.swift         # Border radius
│   │   ├── AppShadow.swift         # Shadow styles
│   │   ├── AppAnimation.swift      # Animation constants
│   │   ├── AppGradient.swift       # Gradient styles
│   │   ├── AppGlass.swift          # Glassmorphism
│   │   └── AppButton.swift         # Button components
│   │
│   ├── Components/                 # Reusable UI components
│   │   └── StatCard.swift
│   │
│   ├── Extensions/
│   │   ├── View+App.swift          # SwiftUI view extensions
│   │   └── Constants.swift         # App constants
│   │
│   └── Managers/
│       ├── HapticManager.swift     # Haptic feedback
│       └── SoundManager.swift      # Sound effects
│
└── Resources/
    ├── Assets.xcassets/            # Images, colors
    ├── GoogleService-Info.plist    # Firebase config
    └── Info.plist                  # App configuration
```

### Architecture Pattern: MVVM

```
┌─────────────────────────────────────────────────────────┐
│                         View                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  SwiftUI Views (WordDetailView.swift)            │  │
│  │  - UI rendering                                  │  │
│  │  - User interaction                              │  │
│  │  - @StateObject, @ObservedObject                 │  │
│  └──────────────────────────────────────────────────┘  │
│                          ↕                              │
│                     @Published                          │
│                          ↕                              │
│                     ViewModel                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  @MainActor class DictionaryViewModel            │  │
│  │  - Business logic                                │  │
│  │  - State management (@Published)                 │  │
│  │  - Calls Services                                │  │
│  └──────────────────────────────────────────────────┘  │
│                          ↕                              │
│                      Service                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  FirebaseManager, AudioService                   │  │
│  │  - Data fetching                                 │  │
│  │  - Business operations                           │  │
│  │  - Network calls                                 │  │
│  └──────────────────────────────────────────────────┘  │
│                          ↕                              │
│                       Model                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │  DictionaryWord, Lesson, UserProgress            │  │
│  │  - Data structures                               │  │
│  │  - Codable, Identifiable                         │  │
│  │  - No business logic                             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Separation of Concerns**: Views only handle UI, ViewModels handle logic, Services handle data
2. **Reactive Programming**: Uses Combine framework for reactive data flow
3. **Dependency Injection**: Services injected into ViewModels for testability
4. **Single Source of Truth**: @Published properties in ViewModels
5. **Modular Features**: Each feature is self-contained with its own Models/Views/ViewModels

---

## 📊 Data Structure

### 1. Dictionary Word (DictionaryWord.swift)

**Complete Cambridge YLE vocabulary dataset with AI-generated content**

```swift
struct DictionaryWord: Identifiable, Codable {
    // Basic Info
    var id: String?              // Document ID (e.g., "cat", "hello")
    let word: String             // Main word
    let british: String          // British spelling
    let american: String         // American spelling
    let irregularPlural: Bool?   // Has irregular plural

    // Grammar
    let partOfSpeech: [String]   // ["noun", "verb"]
    let primaryPos: String       // "noun"

    // YLE Levels
    let levels: [String]         // ["starters", "movers"]
    let primaryLevel: String     // "starters"

    // Categories
    let categories: [String]     // ["animals", "food_and_drink"]

    // AI-Generated Content (GPT-4 via N8N)
    let translationVi: String    // Vietnamese translation
    let definitionEn: String     // English definition (10-15 words)
    let definitionVi: String     // Vietnamese definition (10-20 words)

    // Pronunciation (separate for British/American)
    let pronunciation: Pronunciation {
        british: PronunciationData {
            ipa: String          // British IPA (/ˈkæt/)
            audioUrl: String     // Cambridge audio URL
            audioSource: String  // "Cambridge"
        }
        american: PronunciationData {
            ipa: String          // American IPA (/ˈkæt/)
            audioUrl: String     // Cambridge audio URL
            audioSource: String  // "Cambridge"
        }
    }

    // Examples (3 levels × 2 languages)
    let examples: [Example] {
        level: String            // "starters", "movers", "flyers"
        sentenceEn: String       // English example
        sentenceVi: String       // Vietnamese translation
    }

    // Media
    let imageUrl: String?        // Optional image
    let emoji: String?           // Emoji representation

    // Gamification
    let difficulty: Int          // 1=Starters, 2=Movers, 3=Flyers
    let xpValue: Int            // XP reward
    let gemsValue: Int          // Gems reward

    // Metadata
    let addedDate: Date?
    let lastUpdated: Date?
    let dataCompleteness: DataCompleteness
}
```

**Data Source**: `Cam_Voca_2018.csv` (1,414 words, 59 columns)

**AI Generation Pipeline**:
1. N8N workflow reads CSV (58 base columns)
2. GPT-4 Turbo generates 11 fields per word:
   - `translationVi`, `definitionEn`, `definitionVi`
   - `ipaGB`, `ipaUS`
   - `exampleStarters`, `exampleMovers`, `exampleFlyers`
   - `exampleStartersVi`, `exampleMoversVi`, `exampleFlyersVi`
3. Validation script checks completeness
4. Migration script uploads to Firestore

**Audio Coverage**:
- British: 79.8% (1,128 words) Cambridge Dictionary
- American: 86.4% (1,222 words) Cambridge Dictionary
- Fallback: Legacy sources + TTS (100% total coverage)

### 2. Vocabulary Categories (VocabularyCategory.swift)

**20 topic-based categories for organizing vocabulary**

```swift
struct VocabularyCategory: Identifiable, Codable {
    var id: String?              // "animals", "food_and_drink"
    let categoryId: String       // Same as id
    let name: String             // "Animals"
    let nameVi: String           // "Động vật"
    let description: String      // Description
    let emoji: String            // "🐾"
    let order: Int               // Display order (1-20)
    let wordCount: Int           // Number of words in category
}
```

**Available Categories** (from CSV analysis):
1. Animals (animals) 🐾
2. Body & Face (body_and_face) 👤
3. Clothes (clothes) 👕
4. Colours (colours) 🎨
5. Family & Friends (family_and_friends) 👨‍👩‍👧‍👦
6. Food & Drink (food_and_drink) 🍎
7. Health (health) 🏥
8. Home (home) 🏠
9. Materials (materials) 🔨
10. Names (names) 📛
11. Numbers (numbers) 🔢
12. Places & Directions (places_and_directions) 🗺️
13. School (school) 🎒
14. Sports & Leisure (sports_and_leisure) ⚽
15. Time (time) ⏰
16. Toys (toys) 🧸
17. Transport (transport) 🚗
18. Weather (weather) ☀️
19. Work (work) 💼
20. World Around Us (world_around_us) 🌍

### 3. Lesson Structure (Lesson.swift)

**Dual learning paths: Linear (structured) + Sandbox (exploration)**

```swift
enum LearningPathType: String, Codable {
    case linear   // Main quest: Starters → Movers → Flyers
    case sandbox  // Side quest: Topic islands, mini-games
}

struct Lesson: Identifiable, Codable {
    var id: String?
    let title: String             // "Lesson 1: Greetings"
    let description: String
    let level: String             // "starters", "movers", "flyers"
    let skill: String             // "vocabulary", "listening"
    let order: Int                // Lesson sequence
    let xpReward: Int             // XP earned
    let gemsReward: Int           // Gems earned
    let isLocked: Bool            // Requires previous completion
    let thumbnailEmoji: String    // Visual representation
    let estimatedMinutes: Int     // Time to complete
    let totalExercises: Int       // Number of exercises

    // Dual-path support
    let pathType: LearningPathType     // .linear or .sandbox
    let pathCategory: String?          // "Vocab Island", "Grammar Beach"
    let isBoss: Bool                   // Is this a boss battle?
    let requiredGemsToUnlock: Int      // Cost for sandbox items
}
```

**Learning Paths**:

**Linear Path** (Main Quest):
- Starters (7-8 years, A1) → Movers (8-11 years, A1-A2) → Flyers (9-12 years, A2)
- Sequential lessons unlock as you complete previous ones
- Structured curriculum following Cambridge YLE syllabus
- Progress tracked per level

**Sandbox Path** (Side Quest):
- Topic-based islands (Animals Island, Food Island, etc.)
- Unlock with gems earned from linear path
- Explore freely, no sequence required
- Mini-games, pronunciation workshops, IPA learning

### 4. Exercise Types (Exercise.swift)

```swift
enum ExerciseType: String, Codable {
    case multipleChoice      // Select correct answer
    case fillInBlank        // Type missing word
    case matchPairs         // Connect words to definitions
    case listening          // Listen and select
    case speaking           // Pronunciation practice
    case writing            // Type the word
}

struct Exercise: Identifiable, Codable {
    var id: String?
    let type: ExerciseType
    let question: String
    let options: [String]        // For multiple choice
    let correctAnswer: String
    let explanation: String
    let audioUrl: String?        // For listening exercises
    let xpValue: Int
}
```

### 5. User Progress (UserProgress.swift)

```swift
struct UserProgress: Identifiable, Codable {
    var id: String?              // User ID
    let currentLevel: String     // "starters", "movers", "flyers"
    let totalXP: Int
    let totalGems: Int
    let userLevel: Int           // Overall level (1-100)
    let completedLessons: [String]
    let masteredWords: [String]
    let learningWords: [String]
    let dailyStreak: Int
    let lastActiveDate: Date
}
```

### 6. Gamification (Gamification.swift)

```swift
struct UserLevel: Codable {
    let level: Int               // 1-100
    let title: String            // "Beginner Explorer"
    let currentXP: Int
    let xpToNextLevel: Int
}

struct Mission: Identifiable, Codable {
    var id: String?
    let title: String            // "Complete 5 lessons"
    let description: String
    let type: String             // "daily", "weekly", "achievement"
    let progress: Int
    let target: Int
    let gemsReward: Int
    let isCompleted: Bool
}

struct PetCompanion: Codable {
    let name: String
    let type: String             // "cat", "dog", "dragon"
    let level: Int
    let happiness: Int           // 0-100
    let lastFed: Date
}
```

---

## 🎨 Features & Modules

### Feature 1: Dictionary (1,414 Cambridge Words) ⭐

**Location**: `Features/Dictionary/`

**Core Functionality**:
- Browse 20 topic categories (grid view)
- Filter by YLE level (Starters/Movers/Flyers)
- Search by English word or Vietnamese translation
- View word details (audio, IPA, definitions, examples)
- Play British or American pronunciation
- Flashcard mode with spaced repetition
- Quiz mode (multiple choice, listening, translation)

**Key Files**:
- `DictionaryViewModel.swift` - Main logic (search, filter, fetch)
- `WordDetailView.swift` - Word card with audio player
- `VocabularyCategoriesView.swift` - Category grid
- `FlashcardViewModel.swift` - Spaced repetition algorithm
- `QuizViewModel.swift` - Quiz generation and scoring
- `AudioPlayerService.swift` - Audio playback management

**Data Flow**:
```
1. User opens Dictionary
2. DictionaryViewModel.fetchCategories()
3. Display 20 categories from Firestore
4. User selects "Animals" 🐾
5. DictionaryViewModel.fetchWords(category: "animals", level: .starters)
6. Firestore query: dictionaries collection WHERE categories CONTAINS "animals"
7. Display word list (cat, dog, elephant...)
8. User taps "cat" 🐱
9. Navigate to WordDetailView
10. Display word, IPA, audio buttons, definitions, examples
11. User taps British audio 🇬🇧
12. AudioPlayerService.play(url: pronunciation.british.audioUrl)
13. AVPlayer streams Cambridge Dictionary audio
```

**Firestore Queries**:
```swift
// Fetch categories
db.collection("categories")
  .order(by: "order")
  .getDocuments()

// Fetch words by category
db.collection("dictionaries")
  .whereField("categories", arrayContains: "animals")
  .whereField("levels", arrayContains: "starters")
  .order(by: "word")
  .getDocuments()

// Search by word ID
db.collection("dictionaries")
  .whereField("wordId", isGreaterThanOrEqualTo: "cat")
  .whereField("wordId", isLessThan: "cat\u{f8ff}")
  .getDocuments()
```

**Audio Priority System**:
1. Cambridge Dictionary URL (79.8% British, 86.4% American)
2. Legacy audio sources (Vocabulary.com, Oxford)
3. iOS TTS fallback (AVSpeechSynthesizer)

### Feature 2: Learning Paths

**Location**: `Features/Learning/`

**Dual-Path System**:

#### Linear Journey (Main Quest)
- **Structure**: Sequential lessons (Lesson 1 → Lesson 2 → ...)
- **Progression**: Unlock next lesson by completing previous
- **Levels**: Starters → Movers → Flyers
- **Rewards**: XP + Gems
- **Boss Battles**: Mock tests at end of each level
- **UI**: Vertical scroll with locked/unlocked states

#### Sandbox Map (Side Quest)
- **Structure**: Topic islands (Vocab Island, Grammar Beach, Pronunciation Workshop)
- **Progression**: Unlock with gems earned from linear path
- **Freedom**: Explore any unlocked island in any order
- **Content**: Mini-games, topic-specific exercises, challenges
- **Rewards**: Bonus XP + special achievements
- **UI**: Interactive map with islands

**Key Files**:
- `LinearJourneyView.swift` - Sequential lesson path
- `SandboxMapView.swift` - Exploration mode map
- `LessonDetailView.swift` - Lesson overview + exercises
- `ExerciseView.swift` - Exercise player
- `LearningViewModel.swift` - Progress tracking

### Feature 3: AI Learning Features

**Location**: `Features/AILearning/`

**Speech Recognition & Pronunciation**:
- Record user pronunciation
- Compare with native speaker (British/American)
- Provide feedback on accuracy, fluency, intonation
- Visual waveform during recording
- Replay and compare

**IPA Learning Mode**:
- Interactive IPA chart
- Learn phonetic symbols
- Practice with example words
- Hear British vs American differences

**Key Files**:
- `SpeechRecognitionService.swift` - iOS Speech framework
- `SpeakingExerciseView.swift` - Recording UI
- `SpeakingFeedbackView.swift` - Show pronunciation score
- `WaveformVisualizerView.swift` - Audio visualization
- `IPALearningView.swift` - IPA educational content

### Feature 4: Gamification System

**Location**: `Features/Gamification/`

**Components**:
1. **XP & Levels**: Earn XP → Level up → Unlock new content
2. **Gems Economy**: Earn from lessons → Spend on sandbox islands
3. **Daily Missions**: Complete tasks for bonus rewards
4. **Pet Companion**: Virtual pet that grows with your progress
5. **Achievements**: Special badges for milestones
6. **Leaderboard**: Compete with friends and global users

**Key Files**:
- `GamificationService.swift` - XP calculations, level progression
- `UserLevelView.swift` - Display user level and progress bar
- `MissionsView.swift` - Daily/weekly missions
- `PetCompanionView.swift` - Virtual pet interaction
- `LeaderboardView.swift` - Rankings and social features

### Feature 5: Authentication

**Location**: `Features/Authentication/`

**Supported Methods**:
1. **Phone Number** (SMS OTP via Firebase)
2. **Google Sign-In**
3. **Apple Sign-In**

**Flow**:
```
1. User opens app
2. Check if authenticated (AuthService.currentUser)
3. If not → Show AuthFlowView
4. User selects phone auth
5. Enter phone number → Send OTP
6. Enter OTP → Verify
7. Create/update user profile in Firestore
8. Navigate to MainAppFlow
```

**Key Files**:
- `AuthService.swift` - Firebase Auth wrapper
- `AuthViewModel.swift` - Auth state management
- `PhoneNumberInputView.swift` - Phone number entry
- `OTPVerificationView.swift` - OTP code entry
- `GoogleSignInButton.swift` - Google integration
- `AppleSignInButton.swift` - Apple Sign-In integration

---

## 🔨 Build & Test

### Prerequisites

```bash
# Required
- Xcode 15.0+
- iOS 16.0+ Deployment Target
- Swift 5.9+
- CocoaPods or Swift Package Manager

# Firebase Setup
1. Download GoogleService-Info.plist from Firebase Console
2. Place in YLE X/ directory (next to Info.plist)
3. Never commit this file to git (already in .gitignore)
```

### Installation

```bash
# Clone repository
git clone <repository-url>
cd "YLE X"

# Install dependencies (if using CocoaPods)
pod install

# Open project
open "YLE X.xcworkspace"  # If using CocoaPods
# OR
open "YLE X.xcodeproj"     # If using SPM
```

### Build Commands

```bash
# Build for simulator
xcodebuild -scheme "YLE X" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build for device
xcodebuild -scheme "YLE X" -destination 'generic/platform=iOS' build

# Run tests
xcodebuild test -scheme "YLE X" -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Clean build folder
xcodebuild clean -scheme "YLE X"
```

### Running the App

**In Xcode**:
1. Select target device/simulator (iPhone 15 Pro recommended)
2. Select scheme: "YLE X"
3. Press Cmd+R to build and run
4. Or Product → Run

**First Launch Checklist**:
- [ ] Firebase connection successful (check Xcode console)
- [ ] Categories load (20 items)
- [ ] Dictionary loads (1,414 words)
- [ ] Audio playback works (tap British/American buttons)
- [ ] Search works (try "cat", "táo")
- [ ] Authentication works (phone/Google/Apple)

### Testing

**Unit Tests**: `YLE XTests/YLE_XTests.swift`
- Model tests (DictionaryWord, Lesson)
- ViewModel tests (DictionaryViewModel, AuthViewModel)
- Service tests (FirebaseManager, AudioService)

**UI Tests**: `YLE XUITests/YLE_XUITests.swift`
- Navigation flows
- Search functionality
- Audio playback
- Authentication flows

```bash
# Run all tests
cmd + U

# Run specific test class
xcodebuild test -scheme "YLE X" -only-testing:YLE_XTests/DictionaryViewModelTests

# Run specific test
xcodebuild test -scheme "YLE X" -only-testing:YLE_XTests/DictionaryViewModelTests/testSearchWords
```

### Debugging

**Common Debug Points**:
```swift
// DictionaryViewModel.swift:100 - Categories fetch
print("✅ Loaded \(categories.count) categories")

// DictionaryViewModel.swift:158 - Words fetch
print("✅ Loaded \(fetchedWords.count) words for \(category.name)")

// AudioPlayerService.swift - Audio playback
print("🔊 Playing audio: \(url)")

// FirebaseManager.swift - Firestore queries
print("📊 Query result: \(snapshot.documents.count) documents")
```

**Enable Verbose Logging**:
```swift
// In YLE_XApp.swift init()
FirebaseConfiguration.shared.setLoggerLevel(.debug)
```

---

## 🔥 Firebase Structure

### Firestore Collections

#### 1. `dictionaries` Collection

**Purpose**: Store all 1,414 Cambridge YLE vocabulary words

**Document ID**: `wordId` (normalized word: lowercase, spaces→underscores, apostrophes removed)

**Example**: `dictionaries/cat`

```javascript
{
  // Basic Info
  "word": "cat",
  "british": "cat",
  "american": "cat",
  "wordId": "cat",
  "irregular_plural": false,

  // Grammar
  "partOfSpeech": ["noun"],
  "primaryPos": "noun",

  // YLE Levels
  "levels": ["starters"],
  "primaryLevel": "starters",

  // Categories
  "categories": ["animals"],

  // AI-Generated Content
  "translationVi": "con mèo",
  "definitionEn": "A small furry animal with four legs and a tail.",
  "definitionVi": "Một con vật nhỏ có lông mềm với bốn chân và một cái đuôi.",

  // Pronunciation
  "pronunciation": {
    "british": {
      "ipa": "/kæt/",
      "audioUrl": "https://dictionary.cambridge.org/media/english/uk_pron/...",
      "audioSource": "Cambridge"
    },
    "american": {
      "ipa": "/kæt/",
      "audioUrl": "https://dictionary.cambridge.org/media/english/us_pron/...",
      "audioSource": "Cambridge"
    }
  },

  // Examples
  "examples": [
    {
      "level": "starters",
      "sentenceEn": "I have a cat.",
      "sentenceVi": "Em có một con mèo."
    },
    {
      "level": "movers",
      "sentenceEn": "My cat is sleeping on the sofa.",
      "sentenceVi": "Con mèo của em đang ngủ trên ghế sofa."
    },
    {
      "level": "flyers",
      "sentenceEn": "Cats are independent animals that make great pets.",
      "sentenceVi": "Mèo là loài vật độc lập và là thú cưng tuyệt vời."
    }
  ],

  // Media
  "imageUrl": null,
  "emoji": "🐱",

  // Gamification
  "difficulty": 1,
  "frequency": "common",
  "xpValue": 5,
  "gemsValue": 1,

  // Metadata
  "addedDate": Timestamp,
  "lastUpdated": Timestamp,

  // Data Completeness Tracking
  "dataCompleteness": {
    "hasTranslation": true,
    "hasDefinitionEn": true,
    "hasDefinitionVi": true,
    "hasIPABritish": true,
    "hasIPAAmerican": true,
    "hasAudioBritish": true,
    "hasAudioAmerican": true,
    "hasExamplesEn": true,
    "hasExamplesVi": true
  }
}
```

**Indexes Required**:
```
Collection: dictionaries
- wordId (Ascending)
- categories (Array) + levels (Array) + word (Ascending)
- levels (Array) + word (Ascending)
- primaryLevel (Ascending) + word (Ascending)
```

#### 2. `categories` Collection

**Purpose**: Store 20 vocabulary categories with word counts

**Document ID**: Category ID (e.g., `animals`, `food_and_drink`)

**Example**: `categories/animals`

```javascript
{
  "categoryId": "animals",
  "name": "Animals",
  "nameVi": "Động vật",
  "description": "Learn words about animals and pets",
  "emoji": "🐾",
  "order": 1,
  "wordCount": 89,  // Auto-calculated during migration
  "color": "#FF6B6B",  // Optional: category color
  "imageUrl": null
}
```

**All 20 Categories**:
1. animals (Động vật) 🐾
2. body_and_face (Cơ thể và khuôn mặt) 👤
3. clothes (Quần áo) 👕
4. colours (Màu sắc) 🎨
5. family_and_friends (Gia đình và bạn bè) 👨‍👩‍👧‍👦
6. food_and_drink (Đồ ăn và thức uống) 🍎
7. health (Sức khỏe) 🏥
8. home (Nhà cửa) 🏠
9. materials (Vật liệu) 🔨
10. names (Tên) 📛
11. numbers (Số) 🔢
12. places_and_directions (Địa điểm và phương hướng) 🗺️
13. school (Trường học) 🎒
14. sports_and_leisure (Thể thao và giải trí) ⚽
15. time (Thời gian) ⏰
16. toys (Đồ chơi) 🧸
17. transport (Phương tiện) 🚗
18. weather (Thời tiết) ☀️
19. work (Công việc) 💼
20. world_around_us (Thế giới xung quanh) 🌍

#### 3. `users` Collection

**Purpose**: User profiles and progress

**Document ID**: User UID from Firebase Auth

**Example**: `users/{userId}`

```javascript
{
  "uid": "abc123",
  "email": "user@example.com",
  "displayName": "Nguyễn Văn A",
  "phoneNumber": "+84901234567",
  "photoURL": "https://...",

  // Learning Progress
  "currentLevel": "starters",
  "totalXP": 1250,
  "totalGems": 45,
  "userLevel": 12,

  // Completed Content
  "completedLessons": ["lesson1", "lesson2", ...],
  "masteredWords": ["cat", "dog", "apple", ...],
  "learningWords": ["elephant", "beautiful", ...],

  // Streaks
  "dailyStreak": 7,
  "lastActiveDate": Timestamp,

  // Pet Companion
  "petCompanion": {
    "name": "Fluffy",
    "type": "cat",
    "level": 5,
    "happiness": 85
  },

  // Preferences
  "preferredAccent": "british",  // or "american"
  "notificationsEnabled": true,

  // Metadata
  "createdAt": Timestamp,
  "lastUpdated": Timestamp
}
```

#### 4. `lessons` Collection

**Purpose**: Store all lessons (linear + sandbox)

**Document ID**: Auto-generated

**Example**: `lessons/{lessonId}`

```javascript
{
  "title": "Lesson 1: Greetings",
  "description": "Learn how to say hello and goodbye",
  "level": "starters",
  "skill": "vocabulary",
  "order": 1,
  "xpReward": 50,
  "gemsReward": 5,
  "isLocked": false,
  "thumbnailEmoji": "👋",
  "estimatedMinutes": 15,
  "totalExercises": 10,

  // Dual-path support
  "pathType": "linear",  // or "sandbox"
  "pathCategory": null,  // or "Vocab Island"
  "isBoss": false,
  "requiredGemsToUnlock": 0,  // For sandbox items

  // Content
  "exercises": [...],  // Array of exercise IDs
  "vocabulary": ["hello", "goodbye", "thank_you"],  // Word IDs

  "createdAt": Timestamp
}
```

#### 5. `userProgress` Collection

**Purpose**: Track individual user progress per lesson/word

**Document ID**: `{userId}_{contentId}`

**Example**: `userProgress/abc123_lesson1`

```javascript
{
  "userId": "abc123",
  "contentId": "lesson1",
  "contentType": "lesson",  // or "word", "flashcard"
  "status": "completed",  // "not_started", "in_progress", "completed", "mastered"
  "score": 90,
  "attempts": 2,
  "lastAttemptDate": Timestamp,
  "timeSpentSeconds": 450,
  "xpEarned": 50,
  "gemsEarned": 5
}
```

#### 6. `flashcardProgress` Collection

**Purpose**: Spaced repetition algorithm data

**Document ID**: `{userId}_{wordId}`

**Example**: `flashcardProgress/abc123_cat`

```javascript
{
  "userId": "abc123",
  "wordId": "cat",
  "easeFactor": 2.5,  // Spaced repetition algorithm
  "interval": 7,  // Days until next review
  "nextReviewDate": Timestamp,
  "reviewCount": 5,
  "correctCount": 4,
  "lastReviewed": Timestamp,
  "level": "learning"  // "new", "learning", "review", "mastered"
}
```

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Public read access to dictionaries and categories
    match /dictionaries/{wordId} {
      allow read: if true;
      allow write: if false;  // Only admin can write
    }

    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false;
    }

    match /lessons/{lessonId} {
      allow read: if true;
      allow write: if false;
    }

    // User-specific data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /userProgress/{progressId} {
      allow read, write: if request.auth != null &&
                            progressId.startsWith(request.auth.uid + '_');
    }

    match /flashcardProgress/{progressId} {
      allow read, write: if request.auth != null &&
                            progressId.startsWith(request.auth.uid + '_');
    }
  }
}
```

### Data Migration

**Script**: `migrate_perfect_to_firebase.py`

**Usage**:
```bash
# 1. Dry run (test without writing)
python3 migrate_perfect_to_firebase.py
# Output: Preview of data to be uploaded

# 2. Live upload
# Edit script: DRY_RUN = False
python3 migrate_perfect_to_firebase.py
# Confirm: yes

# 3. Verify
# Check Firebase Console → Firestore
# - dictionaries: 1,414 documents
# - categories: 20 documents
```

**What it does**:
1. Reads `Cam_Voca_2018.csv` (1,414 words, 59 columns)
2. Parses each row into `DictionaryWord` structure
3. Generates `wordId` (normalized: lowercase, remove apostrophes, spaces→underscores)
4. Creates 20 category documents with word counts
5. Uploads to Firestore with batched writes (500 per batch)
6. Tracks data completeness for each word

---

## 📝 Coding Conventions

### Swift Style Guide

**Follow Apple's Swift API Design Guidelines**

#### Naming Conventions

```swift
// ✅ GOOD
class DictionaryViewModel: ObservableObject { }
func fetchWords(for category: VocabularyCategory) async { }
let selectedWord: DictionaryWord?
@Published var isLoading = false

// ❌ BAD
class dictionary_view_model { }  // Wrong casing
func GetWords(category: String) { }  // Wrong verb tense, wrong type
var loading: Bool  // Not descriptive
```

**Rules**:
- Classes: `PascalCase` (e.g., `DictionaryViewModel`)
- Functions: `camelCase`, verb-based (e.g., `fetchCategories()`)
- Variables: `camelCase`, noun-based (e.g., `selectedCategory`)
- Constants: `camelCase` (e.g., `maxRetryCount`)
- Enums: `PascalCase` for type, `camelCase` for cases
  ```swift
  enum YLELevel: String {
      case starters
      case movers
      case flyers
  }
  ```

#### MVVM Pattern

```swift
// ✅ GOOD: Proper MVVM separation

// Model (Data only, no logic)
struct DictionaryWord: Codable {
    let word: String
    let translationVi: String
}

// ViewModel (Logic + State)
@MainActor
class DictionaryViewModel: ObservableObject {
    @Published var words: [DictionaryWord] = []
    @Published var isLoading = false

    func fetchWords() async {
        isLoading = true
        // Fetch logic
        isLoading = false
    }
}

// View (UI only)
struct WordListView: View {
    @StateObject private var viewModel = DictionaryViewModel()

    var body: some View {
        List(viewModel.words) { word in
            Text(word.word)
        }
        .task {
            await viewModel.fetchWords()
        }
    }
}

// ❌ BAD: Logic in View
struct WordListView: View {
    @State private var words: [DictionaryWord] = []

    var body: some View {
        List(words) { word in
            Text(word.word)
        }
        .task {
            // ❌ Firestore call directly in View
            let snapshot = try await db.collection("dictionaries").getDocuments()
            words = snapshot.documents.compactMap { ... }
        }
    }
}
```

#### Async/Await

```swift
// ✅ GOOD: Modern async/await
func fetchWords() async {
    do {
        let snapshot = try await db.collection("dictionaries").getDocuments()
        words = snapshot.documents.compactMap { try? $0.data(as: DictionaryWord.self) }
    } catch {
        print("Error: \(error)")
    }
}

// ❌ BAD: Old completion handlers
func fetchWords(completion: @escaping ([DictionaryWord]) -> Void) {
    db.collection("dictionaries").getDocuments { snapshot, error in
        // Callback hell
    }
}
```

#### SwiftUI Best Practices

```swift
// ✅ GOOD: Extracted views
struct WordDetailView: View {
    let word: DictionaryWord

    var body: some View {
        VStack {
            WordHeaderView(word: word)
            DefinitionsSection(word: word)
            ExamplesSection(word: word)
            AudioControls(word: word)
        }
    }
}

// ❌ BAD: Massive view body
struct WordDetailView: View {
    let word: DictionaryWord

    var body: some View {
        VStack {
            // 200 lines of nested views...
        }
    }
}
```

**View Extraction Rules**:
- If view body > 50 lines → Extract subviews
- If logic repeated → Extract to computed property or function
- If complex layout → Extract to separate View struct

#### Error Handling

```swift
// ✅ GOOD: Typed errors
enum DictionaryError: LocalizedError {
    case fetchFailed(String)
    case notFound
    case networkError

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to load: \(message)"
        case .notFound:
            return "No words found"
        case .networkError:
            return "Network error"
        }
    }
}

// ❌ BAD: Generic errors
func fetchWords() {
    // ...
    } catch {
        print("Error")  // Not descriptive
    }
}
```

#### Comments

```swift
// ✅ GOOD: Meaningful comments for complex logic
/// Normalizes search query to match Firestore wordId generation
/// - Converts to lowercase
/// - Replaces spaces with underscores
/// - Removes apostrophes
func normalizeQuery(_ query: String) -> String {
    query.lowercased()
        .replacingOccurrences(of: " ", with: "_")
        .replacingOccurrences(of: "'", with: "")
}

// ❌ BAD: Obvious comments
let count = words.count  // Get the count  ← Useless comment
```

**Comment Guidelines**:
- Use `///` for documentation comments
- Explain **why**, not **what**
- Document complex algorithms
- Document public APIs
- Don't comment obvious code

#### File Organization

```swift
// Recommended file structure

import Foundation
import FirebaseFirestore

// MARK: - Main Type

struct DictionaryWord: Identifiable, Codable {
    // MARK: - Properties

    var id: String?
    let word: String

    // MARK: - Initialization

    init(...) { }

    // MARK: - Methods

    func example(for level: YLELevel) -> Example? { }
}

// MARK: - Supporting Types

struct Example: Codable {
    let level: String
    let sentenceEn: String
}

// MARK: - Preview Helpers

#if DEBUG
extension DictionaryWord {
    static let sample = DictionaryWord(...)
}
#endif
```

#### Design System Usage

**Always use design system tokens, never hardcoded values**

```swift
// ✅ GOOD: Use design system
Text("Hello")
    .font(AppFont.title1)
    .foregroundColor(AppColor.textPrimary)
    .padding(AppSpacing.md)
    .background(AppColor.surfaceCard)
    .cornerRadius(AppRadius.lg)

// ❌ BAD: Hardcoded values
Text("Hello")
    .font(.system(size: 24, weight: .bold))  // ❌ Hardcoded
    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.4))  // ❌ Hardcoded
    .padding(16)  // ❌ Hardcoded
    .background(Color.white)  // ❌ Hardcoded
    .cornerRadius(12)  // ❌ Hardcoded
```

**Design System Tokens** (in `Shared/DesignSystem/`):

```swift
// AppColor.swift
static let textPrimary = Color("TextPrimary")
static let surfaceCard = Color("SurfaceCard")
static let accentBlue = Color("AccentBlue")

// AppFont.swift
static let title1 = Font.system(size: 28, weight: .bold)
static let body = Font.system(size: 16, weight: .regular)

// AppSpacing.swift
static let xs: CGFloat = 4
static let sm: CGFloat = 8
static let md: CGFloat = 16
static let lg: CGFloat = 24

// AppRadius.swift
static let sm: CGFloat = 8
static let md: CGFloat = 12
static let lg: CGFloat = 16

// AppShadow.swift
static let card = Shadow(
    color: Color.black.opacity(0.1),
    radius: 8,
    x: 0,
    y: 2
)
```

---

## 🔄 Git Workflow

### Branch Strategy

```
main (production)
  └── develop (staging)
        ├── feature/dictionary-search
        ├── feature/flashcard-mode
        ├── bugfix/audio-playback
        └── hotfix/firebase-auth
```

**Branch Naming**:
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Urgent production fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `style`: Formatting, missing semicolons, etc.
- `test`: Adding tests
- `chore`: Maintain (dependencies, build)

**Examples**:

```bash
# ✅ GOOD
feat(dictionary): Add flashcard mode with spaced repetition

Implemented flashcard view with swipe gestures and spaced
repetition algorithm. Users can now review words efficiently.

Closes #42

# ✅ GOOD
fix(audio): Resolve British audio not playing for some words

Issue was caused by incorrect URL encoding in AudioPlayerService.
Added URL encoding for special characters.

Fixes #38

# ❌ BAD
fixed stuff
Update files
WIP
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Screenshots (if UI changes)
[Add screenshots]

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guide
- [ ] No hardcoded values (uses design system)
- [ ] MVVM pattern followed
- [ ] Error handling implemented
- [ ] Documentation updated
```

### Workflow

```bash
# 1. Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/dictionary-search

# 2. Make changes, commit frequently
git add .
git commit -m "feat(dictionary): Add search by Vietnamese translation"

# 3. Push to remote
git push origin feature/dictionary-search

# 4. Create Pull Request on GitHub
# - Target: develop branch
# - Add description, screenshots, testing notes
# - Request review

# 5. After approval, merge to develop
# Squash merge recommended for cleaner history

# 6. Delete feature branch
git branch -d feature/dictionary-search
git push origin --delete feature/dictionary-search
```

---

## ⚙️ Common Tasks

### Task 1: Add New Word to Dictionary

**Scenario**: You need to add a new word to the dictionary collection

```swift
// 1. Create DictionaryWord object
let newWord = DictionaryWord(
    word: "apple",
    british: "apple",
    american: "apple",
    irregularPlural: false,
    partOfSpeech: ["noun"],
    primaryPos: "noun",
    levels: ["starters"],
    primaryLevel: "starters",
    categories: ["food_and_drink"],
    translationVi: "táo",
    definitionEn: "A round, sweet fruit that grows on trees.",
    definitionVi: "Một loại trái cây tròn, ngọt, mọc trên cây.",
    pronunciation: Pronunciation(
        british: PronunciationData(
            ipa: "/ˈæp.əl/",
            audioUrl: "https://dictionary.cambridge.org/media/...",
            audioSource: "Cambridge"
        ),
        american: PronunciationData(
            ipa: "/ˈæp.əl/",
            audioUrl: "https://dictionary.cambridge.org/media/...",
            audioSource: "Cambridge"
        )
    ),
    examples: [
        Example(level: "starters", sentenceEn: "I like apples.", sentenceVi: "Em thích táo.")
    ],
    imageUrl: nil,
    emoji: "🍎",
    difficulty: 1,
    frequency: "common",
    xpValue: 5,
    gemsValue: 1,
    addedDate: Date(),
    lastUpdated: Date(),
    dataCompleteness: DataCompleteness(...)
)

// 2. Upload to Firestore
let db = Firestore.firestore()
try await db.collection("dictionaries").document("apple").setData(from: newWord)
```

**Better approach**: Use the CSV + migration script for bulk updates

### Task 2: Add New Learning Lesson

```swift
// 1. Create Lesson object
let lesson = Lesson(
    title: "Greetings",
    description: "Learn basic greetings",
    level: "starters",
    skill: "vocabulary",
    order: 1,
    xpReward: 50,
    gemsReward: 5,
    isLocked: false,
    thumbnailEmoji: "👋",
    estimatedMinutes: 15,
    totalExercises: 10,
    pathType: .linear,
    pathCategory: nil,
    isBoss: false,
    requiredGemsToUnlock: 0
)

// 2. Add to Firestore
let db = Firestore.firestore()
try await db.collection("lessons").addDocument(data: lesson.dictionary)
```

### Task 3: Implement New Exercise Type

```swift
// 1. Add to ExerciseType enum (Exercise.swift)
enum ExerciseType: String, Codable {
    case multipleChoice
    case fillInBlank
    case matchPairs
    case listening
    case speaking
    case writing
    case dragAndDrop  // ← New type
}

// 2. Create view for new exercise (ExerciseView.swift)
struct DragAndDropExerciseView: View {
    let exercise: Exercise

    var body: some View {
        // UI implementation
    }
}

// 3. Add to ExerciseView switch statement
switch exercise.type {
case .dragAndDrop:
    DragAndDropExerciseView(exercise: exercise)
// ... other cases
}
```

### Task 4: Update Design System

```swift
// 1. Add new color to Assets.xcassets
// - Right click Assets → New Color Set → Name: "SuccessGreen"
// - Set Any Appearance: #4CAF50
// - Set Dark Appearance: #66BB6A

// 2. Add to AppColor.swift
extension Color {
    static let successGreen = Color("SuccessGreen")
}

// 3. Use in views
Text("Correct!")
    .foregroundColor(.successGreen)
```

### Task 5: Debug Firestore Query Issues

```swift
// Enable Firestore debug logging
// In YLE_XApp.swift

init() {
    FirebaseApp.configure()

    // Enable debug logging
    let settings = Firestore.firestore().settings
    settings.isSSLEnabled = true
    Firestore.firestore().settings = settings

    // Print all queries
    #if DEBUG
    FirebaseConfiguration.shared.setLoggerLevel(.debug)
    #endif
}

// In ViewModel, add detailed logging
func fetchWords() async {
    print("🔍 [Dictionary] Starting fetch")
    print("🔍 [Dictionary] Category: \(category.categoryId)")
    print("🔍 [Dictionary] Level: \(level?.rawValue ?? "all")")

    do {
        let snapshot = try await query.getDocuments()
        print("✅ [Dictionary] Fetched \(snapshot.documents.count) documents")

        for doc in snapshot.documents {
            print("  📄 Doc ID: \(doc.documentID)")
        }
    } catch {
        print("❌ [Dictionary] Error: \(error.localizedDescription)")
    }
}
```

---

## 🐛 Troubleshooting

### Issue 1: Audio Not Playing

**Symptoms**:
- Tap British/American audio button → No sound
- Console shows: "Failed to play audio"

**Diagnosis**:
```swift
// Add logging in AudioPlayerService.swift
func play(url: String) {
    print("🔊 [Audio] Attempting to play: \(url)")

    guard let audioURL = URL(string: url) else {
        print("❌ [Audio] Invalid URL: \(url)")
        return
    }

    print("✅ [Audio] Valid URL created")

    player = AVPlayer(url: audioURL)
    player?.play()

    print("✅ [Audio] Player started")
}
```

**Common Causes**:
1. **Invalid URL** → Check `audioUrl` field in Firestore
2. **Network error** → Check internet connection
3. **HTTPS required** → All URLs must be HTTPS
4. **Audio format unsupported** → Use MP3 format

**Solutions**:
```swift
// Solution 1: Validate URL before playing
guard let url = URL(string: audioUrl),
      url.scheme == "https" else {
    print("❌ Invalid or non-HTTPS URL")
    return
}

// Solution 2: Add error observer
player?.currentItem?.addObserver(
    self,
    forKeyPath: "status",
    options: [.new],
    context: nil
)

// Solution 3: Fallback to TTS
if pronunciation.british.audioUrl.isEmpty {
    useTTSFallback(word: word, accent: .british)
}
```

### Issue 2: Firestore Query Returns Empty

**Symptoms**:
- Categories/words not loading
- Empty list in UI

**Diagnosis**:
```swift
// Check Firestore connection
func testFirestoreConnection() async {
    do {
        let snapshot = try await db.collection("dictionaries").limit(to: 1).getDocuments()
        print("✅ Firestore connected: \(snapshot.documents.count) doc(s)")
    } catch {
        print("❌ Firestore error: \(error)")
    }
}
```

**Common Causes**:
1. **No internet** → Check network
2. **Wrong collection name** → Check spelling ("dictionaries" not "dictionary")
3. **Security rules blocking** → Check Firestore rules
4. **No data in Firestore** → Run migration script

**Solutions**:
```swift
// Solution 1: Check collection exists
let collections = try await db.collection("dictionaries").getDocuments()
print("Documents in dictionaries: \(collections.documents.count)")

// Solution 2: Simplify query for testing
// Remove filters temporarily
let snapshot = try await db.collection("dictionaries")
    .limit(to: 10)
    .getDocuments()

// Solution 3: Check security rules in Firebase Console
// Rules → Ensure read access is allowed
```

### Issue 3: App Crashes on Launch

**Symptoms**:
- App crashes immediately after launch
- Error: "GoogleService-Info.plist not found"

**Solution**:
```bash
# 1. Verify GoogleService-Info.plist exists
ls "YLE X/GoogleService-Info.plist"

# 2. If missing, download from Firebase Console
# - Project Settings → Your apps → Download plist
# - Place in "YLE X/" directory (same level as Info.plist)

# 3. Verify it's added to target
# - Xcode → Select file → File Inspector → Target Membership → Check "YLE X"

# 4. Clean build
# Xcode → Product → Clean Build Folder (Cmd+Shift+K)
# Rebuild (Cmd+B)
```

### Issue 4: Search Not Working

**Symptoms**:
- Type in search bar → No results
- Vietnamese search not working

**Diagnosis**:
```swift
// Add logging in DictionaryViewModel.searchWords()
func searchWords(query: String) async {
    print("🔍 [Search] Query: \(query)")

    let normalized = normalizeQuery(query)
    print("🔍 [Search] Normalized: \(normalized)")

    let snapshot = try await db.collection("dictionaries")
        .whereField("wordId", isGreaterThanOrEqualTo: normalized)
        .whereField("wordId", isLessThan: normalized + "\u{f8ff}")
        .getDocuments()

    print("🔍 [Search] Results: \(snapshot.documents.count)")
}
```

**Common Causes**:
1. **Query normalization mismatch** → `wordId` in Firestore doesn't match normalized query
2. **Missing index** → Firestore requires composite index
3. **Case sensitivity** → Firestore queries are case-sensitive

**Solutions**:
```swift
// Solution 1: Ensure consistent normalization
// Migration script uses: .toLowerCase().replace(/\s+/g, '_').replace(/'/g, '')
// Swift must match exactly:
func normalizeQuery(_ query: String) -> String {
    query.lowercased()
        .replacingOccurrences(of: " ", with: "_")
        .replacingOccurrences(of: "'", with: "")
        .replacingOccurrences(of: "-", with: "_")
}

// Solution 2: Create Firestore index
// Error message will provide link to create index automatically

// Solution 3: Test with known word
// Try searching "cat" which definitely exists
```

### Issue 5: SwiftUI Preview Not Working

**Symptoms**:
- Preview shows "Cannot preview in this file"
- Preview crashes

**Solution**:
```swift
// Ensure preview has all required data

#if DEBUG
extension DictionaryWord {
    static let sample = DictionaryWord(
        // ... all required fields
    )
}

struct WordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WordDetailView(word: .sample)
            .environmentObject(DictionaryViewModel())  // If needed
    }
}
#endif
```

### Issue 6: Build Errors After Git Pull

**Symptoms**:
- Project won't build after pulling latest code
- Missing files or dependencies

**Solution**:
```bash
# 1. Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. Clean build folder in Xcode
# Product → Clean Build Folder (Cmd+Shift+K)

# 3. Update dependencies (if using CocoaPods)
pod install
pod update

# 4. Restart Xcode

# 5. Rebuild
# Product → Build (Cmd+B)
```

---

## 📚 Additional Resources

### Documentation Links

- **Firebase iOS SDK**: https://firebase.google.com/docs/ios/setup
- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui
- **Combine Framework**: https://developer.apple.com/documentation/combine
- **Swift API Design Guidelines**: https://swift.org/documentation/api-design-guidelines/

### Internal Documentation

- `/docs/PERFECT_IMPLEMENTATION_COMPLETE.md` - Full implementation roadmap
- `/docs/N8N_SINGLE_PROMPT.md` - AI content generation guide
- `/docs/DEPLOYMENT_CHECKLIST.md` - Deployment steps
- `/docs/READY_TO_DEPLOY.md` - Pre-deployment checklist
- `migrate_perfect_to_firebase.py` - Data migration script
- `validate_perfect_csv.py` - Data validation script

### Data Files

- `Cam_Voca_2018.csv` - Master vocabulary dataset (1,414 words, 59 columns)
- `Cambridge_Vocabulary_2018_PERFECT.csv` - Legacy name (same file)

### Project Contacts

- **Project Lead**: [Name]
- **iOS Developer**: [Name]
- **Backend**: Firebase
- **AI Content**: OpenAI GPT-4

---

## 🎓 Learning Resources for New Developers

### Understanding the Codebase

**Start here** (in order):
1. Read `AGENTS.md` (this file) - Architecture overview
2. Open `YLE_XApp.swift` - App entry point
3. Read `DictionaryWord.swift` - Core data model
4. Read `DictionaryViewModel.swift` - Main business logic
5. Open `WordDetailView.swift` - Example view
6. Review `FirebaseManager.swift` - Data layer

### Key Concepts to Understand

1. **MVVM Pattern**: Model-View-ViewModel architecture
2. **SwiftUI**: Declarative UI framework
3. **Combine**: Reactive programming with `@Published`
4. **Firebase Firestore**: NoSQL database queries
5. **Async/Await**: Modern Swift concurrency
6. **Design System**: Reusable UI tokens

### Common Beginner Mistakes

❌ **Putting Firestore calls in Views**
```swift
// BAD
struct WordListView: View {
    @State private var words: [DictionaryWord] = []

    var body: some View {
        List(words)
            .task {
                let snapshot = try await db.collection("dictionaries").getDocuments()
                words = snapshot.documents.compactMap { ... }
            }
    }
}
```

✅ **Use ViewModel**
```swift
// GOOD
struct WordListView: View {
    @StateObject private var viewModel = DictionaryViewModel()

    var body: some View {
        List(viewModel.words)
            .task {
                await viewModel.fetchWords()
            }
    }
}
```

---

## 📊 Project Metrics

### Codebase Statistics

```
Total Files: ~100 Swift files
Total Lines: ~15,000 lines of Swift code
Models: 15 core models
ViewModels: 12 ViewModels
Views: 40+ SwiftUI views
Services: 10 service classes
```

### Data Statistics

```
Total Words: 1,414
YLE Levels: 3 (Starters, Movers, Flyers)
Categories: 20
Parts of Speech: 13
Audio Coverage: 86.4% (American), 79.8% (British)
Data Completeness: 100% (all fields AI-generated)
```

### Performance Targets

```
App Launch: < 2 seconds
Category Load: < 500ms
Word Search: < 300ms
Audio Playback: < 1 second
Firestore Query: < 500ms
```

---

## 🔮 Future Enhancements

### Planned Features (Not Yet Implemented)

1. **Offline Mode**: Cache vocabulary for offline access
2. **Social Learning**: Friends, challenges, group learning
3. **Parent Dashboard**: Track child's progress
4. **AI Tutor**: Conversational AI for practice
5. **Augmented Reality**: AR word recognition
6. **Story Mode**: Narrative-based learning
7. **Voice Cloning**: Practice with celebrity voices
8. **Multiplayer Games**: Real-time competitions

### Technical Debt

- [ ] Implement unit tests for all ViewModels
- [ ] Add UI tests for critical flows
- [ ] Refactor large views (>100 lines)
- [ ] Add analytics tracking
- [ ] Implement proper error reporting (Crashlytics)
- [ ] Add performance monitoring
- [ ] Optimize Firestore queries (pagination)
- [ ] Implement proper caching strategy

---

## 📝 Changelog

### Version 1.0.0 (Current)

**Features**:
- ✅ 1,414 Cambridge YLE words with complete data
- ✅ Dictionary with 20 categories
- ✅ British/American audio playback
- ✅ Search (English + Vietnamese)
- ✅ Word detail cards
- ✅ Flashcard mode
- ✅ Quiz mode
- ✅ Dual learning paths (Linear + Sandbox)
- ✅ Gamification (XP, levels, gems)
- ✅ Pet companion
- ✅ Missions
- ✅ Leaderboard
- ✅ Authentication (Phone, Google, Apple)
- ✅ AI speech recognition
- ✅ IPA learning mode

**Data**:
- ✅ 100% vocabulary completeness
- ✅ AI-generated content (GPT-4)
- ✅ Vietnamese translations
- ✅ Age-appropriate examples (3 levels)
- ✅ IPA for both accents

---

**Last Updated**: November 23, 2025
**Document Version**: 1.0.0
**Maintained By**: YLE X Development Team

---

*This AGENTS.md file follows the open standard for AI coding agent instructions. For more information, visit https://agents.md/*
