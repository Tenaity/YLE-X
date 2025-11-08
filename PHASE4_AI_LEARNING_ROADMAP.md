# Phase 4 - AI-Powered Learning System Roadmap

## 🎯 Overview

**Goal**: Create an intelligent, interactive learning experience with AI-powered pronunciation assessment, vocabulary learning, IPA phonetics, and speaking practice.

**Timeline**: ~20-25 hours development
**Priority**: High (Core learning features)
**Tech Stack**: Speech Recognition, AI/ML APIs, Core Audio, AVFoundation

---

## 📋 Feature Breakdown

### Part A: Speech Recognition & Pronunciation Assessment 🎤

#### 1. **Speech-to-Text Integration**

**Technologies**:
- Apple Speech Framework (iOS native)
- Google Cloud Speech-to-Text API (more accurate)
- AssemblyAI (specialized for education)

**Features**:
- [ ] Real-time speech recognition
- [ ] Accuracy detection (word-by-word)
- [ ] Pronunciation scoring (0-100%)
- [ ] Fluency measurement
- [ ] Intonation analysis

**Implementation**:
```swift
// Core/Services/SpeechRecognitionService.swift
class SpeechRecognitionService {
    func startRecording()
    func stopRecording() -> SpeechResult
    func analyzePronunciation(expected: String, actual: String) -> PronunciationScore
}

struct PronunciationScore {
    let accuracy: Double        // 0-100%
    let fluency: Double         // 0-100%
    let completeness: Double    // 0-100%
    let prosody: Double         // Intonation/rhythm
    let wordScores: [WordScore] // Individual word scores
}
```

#### 2. **Pronunciation Assessment AI**

**API Options**:
- **Azure Cognitive Services** - Pronunciation Assessment API ⭐ RECOMMENDED
- **Google Cloud Speech-to-Text** - With pronunciation feedback
- **AssemblyAI** - Accuracy + confidence scores

**Features**:
- [ ] Phoneme-level analysis
- [ ] Word-level accuracy
- [ ] Sentence fluency
- [ ] Stress pattern detection
- [ ] Common error identification

**Scoring Criteria**:
```
Total Score = (
    Accuracy × 40% +      // Pronunciation correctness
    Fluency × 30% +       // Speaking smoothness
    Completeness × 20% +  // All words spoken
    Prosody × 10%         // Natural rhythm/intonation
)
```

#### 3. **Interactive Speaking Exercises**

**Exercise Types**:
- [ ] **Word Repetition** - Practice single words
- [ ] **Sentence Reading** - Read full sentences
- [ ] **Conversation Practice** - Dialogue simulation
- [ ] **Story Reading** - Read short stories
- [ ] **Free Speaking** - Describe images/scenarios

**UI Flow**:
```
SpeakingExerciseView
├─ Display target text
├─ Show IPA pronunciation
├─ Play native audio example
├─ Record button (hold to speak)
├─ Real-time waveform visualization
├─ Submit for AI analysis
└─ Show detailed feedback
```

---

### Part B: IPA & Phonetics System 📝

#### 1. **IPA Display Integration**

**Features**:
- [ ] Show IPA for every word
- [ ] British vs American pronunciation toggle
- [ ] Syllable breakdown
- [ ] Stress marking
- [ ] Audio playback per phoneme

**Data Structure**:
```swift
struct Word {
    let text: String
    let ipaUK: String          // British IPA
    let ipaUS: String          // American IPA
    let syllables: [String]    // ["hel", "lo"]
    let stressPattern: [Int]   // [0, 1] - 0=unstressed, 1=stressed
    let audioURL: String       // TTS or pre-recorded
    let difficulty: Difficulty
}

// Example:
Word(
    text: "hello",
    ipaUK: "/həˈləʊ/",
    ipaUS: "/həˈloʊ/",
    syllables: ["hel", "lo"],
    stressPattern: [0, 1],
    audioURL: "audio/hello.mp3",
    difficulty: .beginner
)
```

#### 2. **Phoneme Learning Module**

**Vowels & Consonants**:
- [ ] All 44 English phonemes
- [ ] Visual mouth positions
- [ ] Audio examples
- [ ] Minimal pairs (bit/beat, ship/sheep)
- [ ] Practice exercises

**Categories**:
```
Vowels (20):
├─ Short vowels (7): /ɪ/, /e/, /æ/, /ɒ/, /ʌ/, /ʊ/, /ə/
├─ Long vowels (5): /iː/, /ɑː/, /ɔː/, /uː/, /ɜː/
└─ Diphthongs (8): /eɪ/, /aɪ/, /ɔɪ/, /aʊ/, /əʊ/, /ɪə/, /eə/, /ʊə/

Consonants (24):
├─ Plosives (6): /p/, /b/, /t/, /d/, /k/, /g/
├─ Fricatives (9): /f/, /v/, /θ/, /ð/, /s/, /z/, /ʃ/, /ʒ/, /h/
├─ Affricates (2): /tʃ/, /dʒ/
├─ Nasals (3): /m/, /n/, /ŋ/
├─ Liquids (2): /l/, /r/
└─ Glides (2): /w/, /j/
```

**UI Component**:
```swift
PhonemeCardView
├─ IPA symbol (large, clear)
├─ Example words (3-5)
├─ Mouth position diagram
├─ Audio play button
├─ Practice recording
└─ Similar sounds comparison
```

#### 3. **IPA Learning Games**

- [ ] **Phoneme Matching** - Match IPA to word
- [ ] **Sound Recognition** - Hear and identify
- [ ] **Minimal Pairs** - Distinguish similar sounds
- [ ] **IPA Typing** - Type the correct IPA
- [ ] **Pronunciation Quiz** - Multiple choice

---

### Part C: Smart Vocabulary Learning 📚

#### 1. **AI-Powered Vocabulary System**

**Features**:
- [ ] Spaced repetition algorithm (SM-2 or Anki-style)
- [ ] Context-based learning
- [ ] Image association
- [ ] Sentence examples
- [ ] Synonym/antonym relationships
- [ ] Usage frequency data

**Vocabulary Card Structure**:
```swift
struct VocabularyCard {
    let id: String
    let word: String
    let ipaUK: String
    let ipaUS: String
    let definition: String
    let examples: [String]           // 3-5 example sentences
    let imageURL: String?            // Visual association
    let audioURL: String
    let level: YLELevel              // Starters/Movers/Flyers
    let topic: Topic                 // Animals, Food, Family...
    let partOfSpeech: PartOfSpeech
    let synonyms: [String]
    let antonyms: [String]
    let collocations: [String]       // Common word pairs
    let difficulty: Int              // 1-10

    // Spaced Repetition
    var easeFactor: Double           // 2.5 default
    var interval: Int                // Days until next review
    var repetitions: Int             // Times reviewed
    var nextReviewDate: Date
}
```

#### 2. **Spaced Repetition Algorithm**

**SM-2 Algorithm Implementation**:
```swift
class SpacedRepetitionService {
    func calculateNextReview(
        card: VocabularyCard,
        quality: Int  // 0-5 rating
    ) -> (interval: Int, easeFactor: Double)

    func getDueCards() -> [VocabularyCard]
    func markAsReviewed(card: VocabularyCard, rating: Int)
}

// Quality ratings:
// 5 - Perfect response
// 4 - Correct after hesitation
// 3 - Correct with difficulty
// 2 - Incorrect but remembered
// 1 - Incorrect, seemed familiar
// 0 - Complete blackout
```

#### 3. **Interactive Vocabulary Exercises**

**Exercise Types**:
- [ ] **Flashcards** - Traditional flip cards
- [ ] **Multiple Choice** - Select correct definition
- [ ] **Fill in the Blank** - Complete sentences
- [ ] **Matching** - Word to definition/image
- [ ] **Spelling** - Type the word from audio
- [ ] **Usage** - Use word in a sentence
- [ ] **Listening** - Hear and identify

**Gamification**:
- [ ] Streak counter (days studied)
- [ ] Daily goal (e.g., 20 words)
- [ ] Mastery levels (Learning → Familiar → Mastered)
- [ ] Word bank (personal collection)
- [ ] Review heatmap (calendar view)

---

### Part D: Speaking Practice & AI Conversation 🗣️

#### 1. **AI Conversation Partner**

**Technology Options**:
- **OpenAI GPT-4 + Whisper** ⭐ RECOMMENDED
- **Google Dialogflow CX**
- **Azure Bot Service**

**Features**:
- [ ] Natural conversation flow
- [ ] Context-aware responses
- [ ] Difficulty adjustment
- [ ] Error correction
- [ ] Encouragement and tips

**Conversation Scenarios**:
```
Beginner:
├─ Introduce yourself
├─ Order food at restaurant
├─ Ask for directions
├─ Shopping dialogue
└─ Daily routine talk

Intermediate:
├─ Describe your hobby
├─ Talk about travel experience
├─ Discuss weather/news
├─ Express opinions
└─ Make plans with friend

Advanced:
├─ Debate a topic
├─ Tell a story
├─ Job interview simulation
├─ Problem-solving discussion
└─ Cultural exchange
```

#### 2. **Real-time Feedback System**

**During Speaking**:
- [ ] Waveform visualization
- [ ] Volume indicator
- [ ] Timer display
- [ ] Pause detection
- [ ] Background noise warning

**After Speaking**:
- [ ] Overall score (0-100)
- [ ] Accuracy breakdown
- [ ] Grammar corrections
- [ ] Vocabulary suggestions
- [ ] Fluency metrics
- [ ] Pronunciation errors highlighted

**Feedback UI**:
```swift
SpeakingFeedbackView
├─ Score display (circular progress)
├─ Metrics cards
│  ├─ Accuracy: 85%
│  ├─ Fluency: 78%
│  ├─ Grammar: 90%
│  └─ Vocabulary: 82%
├─ Transcript with highlights
│  ├─ ✅ Correct words (green)
│  ├─ ⚠️ Minor errors (yellow)
│  └─ ❌ Major errors (red)
├─ Detailed suggestions
└─ Try again / Next button
```

#### 3. **Pronunciation Drill System**

**Target Sounds**:
- [ ] Difficult vowel sounds (/æ/ vs /e/, /ɪ/ vs /iː/)
- [ ] Consonant clusters (str-, spr-, -ths)
- [ ] Silent letters (knife, knight, lamb)
- [ ] Word stress patterns
- [ ] Sentence intonation

**Drill Format**:
```
1. Listen to native speaker
2. See IPA + visual guide
3. Practice recording (3 attempts)
4. AI scores each attempt
5. Get personalized tips
6. Master and unlock next
```

---

## 🗂️ File Structure

```
Features/
├── AILearning/
│   ├── Models/
│   │   ├── VocabularyCard.swift
│   │   ├── PhonemeData.swift
│   │   ├── SpeechResult.swift
│   │   ├── PronunciationScore.swift
│   │   └── ConversationSession.swift
│   │
│   ├── Services/
│   │   ├── SpeechRecognitionService.swift
│   │   ├── PronunciationAssessmentService.swift
│   │   ├── SpacedRepetitionService.swift
│   │   ├── VocabularyService.swift
│   │   ├── IPAService.swift
│   │   ├── TTSService.swift (Text-to-Speech)
│   │   └── AIConversationService.swift
│   │
│   └── Views/
│       ├── Speaking/
│       │   ├── SpeakingExerciseView.swift
│       │   ├── RecordingView.swift
│       │   ├── WaveformVisualizerView.swift
│       │   └── SpeakingFeedbackView.swift
│       │
│       ├── Vocabulary/
│       │   ├── VocabularyFlashcardView.swift
│       │   ├── VocabularyQuizView.swift
│       │   ├── WordDetailView.swift
│       │   └── ReviewCalendarView.swift
│       │
│       ├── Phonetics/
│       │   ├── IPAChartView.swift
│       │   ├── PhonemeCardView.swift
│       │   ├── PhonemeQuizView.swift
│       │   └── MinimalPairsView.swift
│       │
│       └── Conversation/
│           ├── AIConversationView.swift
│           ├── ConversationHistoryView.swift
│           └── TopicSelectionView.swift

Core/
└── Audio/
    ├── AudioRecorder.swift
    ├── AudioPlayer.swift
    ├── AudioAnalyzer.swift
    └── WaveformGenerator.swift
```

---

## 🎨 UI/UX Design

### 1. Speaking Exercise Layout

```
┌─────────────────────────────┐
│   🎤 Pronunciation Practice │
├─────────────────────────────┤
│                             │
│   Target: "Hello, how are   │
│           you today?"       │
│                             │
│   IPA: /həˈləʊ haʊ ɑː juː  │
│        təˈdeɪ/              │
│                             │
│   [🔊 Play Example]         │
│                             │
│   ────────────────────      │
│   ▁▂▃▅▆▇█▇▆▅▃▂▁    [Wave]  │
│   ────────────────────      │
│                             │
│   [🔴 Hold to Record]       │
│                             │
│   Attempts: 1/3  Time: 5s   │
│                             │
└─────────────────────────────┘
```

### 2. Feedback Display

```
┌─────────────────────────────┐
│   📊 Your Score: 87/100     │
├─────────────────────────────┤
│        ╭─────╮              │
│        │ 87% │  Great!      │
│        ╰─────╯              │
├─────────────────────────────┤
│ Accuracy:      ████████░ 85%│
│ Fluency:       ███████░░ 78%│
│ Pronunciation: █████████ 92%│
│ Completeness:  ██████████100%│
├─────────────────────────────┤
│ Transcript:                 │
│ ✅ Hello, ⚠️ how ✅ are     │
│ ✅ you ❌ toady?            │
│                             │
│ Issues:                     │
│ • "toady" → "today"         │
│   Try: /təˈdeɪ/            │
│                             │
│ [🔄 Try Again] [➡️ Next]   │
└─────────────────────────────┘
```

### 3. Vocabulary Flashcard

```
┌─────────────────────────────┐
│         📚 Flashcard        │
├─────────────────────────────┤
│                             │
│         [Image: 🐱]         │
│                             │
│           CAT               │
│                             │
│      /kæt/ 🇬🇧  /kæt/ 🇺🇸    │
│                             │
│      [🔊 Listen]            │
│                             │
│   ┌─────────────────────┐   │
│   │ Tap to flip for     │   │
│   │ definition          │   │
│   └─────────────────────┘   │
│                             │
│   Progress: ████░░░░  4/10  │
│   Next review: Tomorrow     │
│                             │
│   [😫] [😐] [😊] [🎉]      │
│   Hard  OK  Good Easy       │
└─────────────────────────────┘
```

### 4. IPA Chart

```
┌─────────────────────────────┐
│      🔤 IPA Vowel Chart     │
├─────────────────────────────┤
│                             │
│  Short Vowels:              │
│  [ɪ] [e] [æ] [ɒ] [ʌ] [ʊ] [ə]│
│                             │
│  Long Vowels:               │
│  [iː] [ɑː] [ɔː] [uː] [ɜː]   │
│                             │
│  Diphthongs:                │
│  [eɪ] [aɪ] [ɔɪ] [aʊ] [əʊ]  │
│  [ɪə] [eə] [ʊə]             │
│                             │
│  Tap any phoneme to:        │
│  • Hear pronunciation       │
│  • See examples             │
│  • Practice                 │
│                             │
└─────────────────────────────┘
```

---

## 🔧 Technical Implementation

### Phase 4A: Speech Recognition Foundation (Priority 1)

#### Step 1: Setup Speech Recognition Service
```swift
import Speech
import AVFoundation

@MainActor
class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization()
    func startRecording() throws
    func stopRecording()
    func analyzePronunciation(expected: String) -> PronunciationScore
}
```

#### Step 2: Audio Recording & Playback
```swift
class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?

    func startRecording(filename: String) throws
    func stopRecording() -> URL?
    func playRecording(url: URL)
    func deleteRecording(url: URL)
}
```

#### Step 3: Waveform Visualization
```swift
struct WaveformView: View {
    let samples: [Float]  // Audio amplitude samples
    let color: Color

    var body: some View {
        Canvas { context, size in
            let path = createWaveformPath(samples: samples, size: size)
            context.stroke(path, with: .color(color), lineWidth: 2)
        }
    }
}
```

#### Step 4: Pronunciation Assessment API
```swift
// Azure Cognitive Services Integration
class PronunciationAssessmentService {
    func assessPronunciation(
        audioURL: URL,
        referenceText: String
    ) async throws -> PronunciationResult {
        // Call Azure API
        // Return detailed scores
    }
}

struct PronunciationResult: Codable {
    let accuracyScore: Double
    let fluencyScore: Double
    let completenessScore: Double
    let prosodyScore: Double
    let pronunciationScore: Double  // Overall
    let words: [WordResult]
}

struct WordResult: Codable {
    let word: String
    let accuracyScore: Double
    let errorType: String?  // "Mispronunciation", "Omission", etc.
}
```

---

### Phase 4B: IPA & Phonetics (Priority 2)

#### Step 1: IPA Data Structure
```swift
struct Phoneme: Identifiable, Codable {
    let id: String
    let symbol: String        // IPA symbol
    let type: PhonemeType     // Vowel/Consonant
    let examples: [String]    // ["cat", "bat", "mat"]
    let audioURL: String
    let mouthDiagram: String  // Image URL
    let description: String
    let similarSounds: [String]  // Related phonemes
}

enum PhonemeType: String, Codable {
    case shortVowel, longVowel, diphthong
    case plosive, fricative, affricate
    case nasal, liquid, glide
}
```

#### Step 2: IPA Service
```swift
class IPAService {
    static let shared = IPAService()

    private let dictionary: [String: IPAEntry] = [:]

    func getIPA(for word: String, accent: Accent = .american) -> String?
    func loadPhonemeData() async throws
    func getPhoneme(symbol: String) -> Phoneme?
}

struct IPAEntry: Codable {
    let word: String
    let ipaUK: String
    let ipaUS: String
    let syllables: [String]
    let stress: [Int]
}
```

#### Step 3: Phoneme Learning Views
```swift
struct PhonemeCardView: View {
    let phoneme: Phoneme
    @State private var isPlaying = false

    var body: some View {
        VStack {
            // IPA symbol (large)
            Text(phoneme.symbol)
                .font(.system(size: 80))

            // Examples
            ForEach(phoneme.examples, id: \.self) { example in
                Text(example)
            }

            // Audio button
            Button("Play Sound") {
                playPhoneme()
            }

            // Mouth diagram
            AsyncImage(url: URL(string: phoneme.mouthDiagram))
        }
    }
}
```

---

### Phase 4C: Smart Vocabulary (Priority 3)

#### Step 1: Spaced Repetition Algorithm
```swift
class SpacedRepetitionService {
    // SM-2 Algorithm
    func calculateNextReview(
        card: VocabularyCard,
        quality: Int  // 0-5
    ) -> UpdatedCard {
        var ef = card.easeFactor
        var interval = card.interval
        var repetitions = card.repetitions

        if quality >= 3 {
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * ef)
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }

        ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        ef = max(1.3, ef)

        let nextDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())!

        return UpdatedCard(
            easeFactor: ef,
            interval: interval,
            repetitions: repetitions,
            nextReviewDate: nextDate
        )
    }

    func getDueCards() -> [VocabularyCard] {
        // Return cards due for review
    }
}
```

#### Step 2: Flashcard UI
```swift
struct FlashcardView: View {
    let card: VocabularyCard
    @State private var isFlipped = false
    @State private var dragAmount = CGSize.zero

    var body: some View {
        ZStack {
            // Front (word + image)
            if !isFlipped {
                VStack {
                    AsyncImage(url: URL(string: card.imageURL ?? ""))
                    Text(card.word)
                        .font(.largeTitle)
                    Text(card.ipaUS)
                        .foregroundColor(.secondary)
                }
            } else {
                // Back (definition + examples)
                VStack {
                    Text(card.definition)
                    ForEach(card.examples, id: \.self) { example in
                        Text(example)
                            .italic()
                    }
                }
            }
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation {
                isFlipped.toggle()
            }
        }
    }
}
```

#### Step 3: Review Calendar
```swift
struct ReviewCalendarView: View {
    let reviewData: [Date: Int]  // Date -> count

    var body: some View {
        // Heatmap-style calendar showing review frequency
        // Similar to GitHub contributions graph
    }
}
```

---

### Phase 4D: AI Conversation (Priority 4)

#### Step 1: OpenAI Integration
```swift
class AIConversationService {
    private let apiKey = "YOUR_OPENAI_API_KEY"

    func startConversation(topic: String, level: String) async throws -> String

    func sendMessage(_ message: String) async throws -> String

    func getConversationFeedback() async throws -> ConversationFeedback
}

struct ConversationFeedback: Codable {
    let grammarErrors: [GrammarError]
    let vocabularySuggestions: [String]
    let pronunciationTips: [String]
    let overallScore: Int
}
```

#### Step 2: Conversation UI
```swift
struct AIConversationView: View {
    @StateObject private var service = AIConversationService()
    @State private var messages: [Message] = []
    @State private var isRecording = false

    var body: some View {
        VStack {
            // Message list
            ScrollView {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                }
            }

            // Recording controls
            HStack {
                Button("Record") {
                    toggleRecording()
                }

                Button("Type") {
                    showTextInput()
                }
            }
        }
    }
}
```

---

## 🎯 API Services Needed

### 1. Speech Recognition
- **Apple Speech Framework** (Free, built-in)
- **Google Cloud Speech-to-Text** ($0.006/15s)
- **AssemblyAI** ($0.00025/s)

### 2. Pronunciation Assessment
- **Azure Cognitive Services** ⭐ RECOMMENDED
  - $1.50/1000 requests
  - Word/phoneme-level scores
  - Best accuracy for education

### 3. Text-to-Speech (TTS)
- **Apple AVSpeechSynthesizer** (Free, built-in)
- **Google Cloud TTS** ($4/1M characters)
- **ElevenLabs** (Premium quality, $5-99/month)

### 4. IPA Dictionary
- **Free APIs**:
  - CMU Pronouncing Dictionary
  - Wiktionary API
- **Premium**:
  - Oxford Dictionaries API
  - Merriam-Webster API

### 5. AI Conversation
- **OpenAI GPT-4** ($0.03/1K tokens)
- **Anthropic Claude** ($0.015/1K tokens)
- **Google Gemini** (Free tier available)

---

## 📊 Data Requirements

### 1. Vocabulary Database
```json
{
  "words": [
    {
      "id": "cat_001",
      "word": "cat",
      "ipaUK": "/kæt/",
      "ipaUS": "/kæt/",
      "definition": "A small domesticated carnivorous mammal",
      "examples": [
        "I have a cat at home.",
        "The cat is sleeping on the sofa.",
        "My cat loves to play with yarn."
      ],
      "imageURL": "https://example.com/cat.jpg",
      "audioURL": "https://example.com/cat.mp3",
      "level": "starters",
      "topic": "animals",
      "partOfSpeech": "noun",
      "difficulty": 1
    }
  ]
}
```

### 2. Phoneme Database
```json
{
  "phonemes": [
    {
      "id": "vowel_short_i",
      "symbol": "ɪ",
      "type": "shortVowel",
      "examples": ["bit", "sit", "kit"],
      "audioURL": "phonemes/short_i.mp3",
      "mouthDiagram": "phonemes/short_i_mouth.png",
      "description": "Short 'i' sound",
      "similarSounds": ["iː"]
    }
  ]
}
```

### 3. Conversation Templates
```json
{
  "scenarios": [
    {
      "id": "restaurant_order",
      "title": "Ordering at a Restaurant",
      "level": "beginner",
      "systemPrompt": "You are a friendly waiter. Help the student practice ordering food.",
      "suggestedResponses": [
        "What would you like to order?",
        "Would you like anything to drink?",
        "Anything else?"
      ]
    }
  ]
}
```

---

## 🚀 Implementation Priority

### Week 1-2: Speech Recognition & Basic Pronunciation
1. ✅ Setup Speech Recognition Service
2. ✅ Audio recording/playback
3. ✅ Waveform visualization
4. ✅ Basic pronunciation scoring
5. ✅ Speaking exercise UI

### Week 3: IPA & Phonetics
1. ✅ IPA data structure
2. ✅ Phoneme database
3. ✅ IPA chart view
4. ✅ Phoneme card view
5. ✅ Audio playback

### Week 4: Vocabulary System
1. ✅ Vocabulary card model
2. ✅ Spaced repetition algorithm
3. ✅ Flashcard UI
4. ✅ Quiz modes
5. ✅ Progress tracking

### Week 5: AI Integration
1. ✅ Pronunciation assessment API
2. ✅ AI conversation service
3. ✅ Feedback display
4. ✅ Polish & testing

---

## 💰 Cost Estimation (Monthly for 1000 active users)

### API Costs
- **Azure Pronunciation Assessment**: ~$50-100/month
- **OpenAI GPT-4**: ~$100-200/month
- **Cloud Storage (audio files)**: ~$20/month
- **TTS (if not using Apple)**: ~$30/month

**Total**: ~$200-350/month for 1000 users

### Free Alternatives
- Apple Speech Framework (Free)
- Apple TTS (Free)
- Self-hosted IPA dictionary (Free)
- Limited GPT features (Use GPT-3.5)

**Total with free tier**: ~$50/month

---

## ✅ Definition of Done

Phase 4A (Speech) is complete when:
- [ ] Speech recognition works accurately
- [ ] Audio recording has good quality
- [ ] Waveform displays in real-time
- [ ] Basic pronunciation scoring works
- [ ] User can practice and get feedback

Phase 4B (IPA) is complete when:
- [ ] All 44 phonemes documented
- [ ] IPA displays for words
- [ ] Audio playback works
- [ ] Phoneme learning exercises functional

Phase 4C (Vocabulary) is complete when:
- [ ] Flashcards work smoothly
- [ ] Spaced repetition calculates correctly
- [ ] Due cards display properly
- [ ] Progress tracks accurately

Phase 4D (AI) is complete when:
- [ ] Pronunciation assessment API integrated
- [ ] Detailed feedback displays
- [ ] AI conversation responds naturally
- [ ] Grammar/vocabulary suggestions work

---

**Ready to start?** Let me know and I'll begin with:
1. Creating speech recognition models
2. Building SpeechRecognitionService
3. Creating speaking exercise UI
4. Setting up audio recording

Or would you like me to adjust the plan first? 🚀
