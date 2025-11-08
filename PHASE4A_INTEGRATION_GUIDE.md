# Phase 4A - Quick Integration Guide

## 🚀 5-Minute Setup

### Step 1: Add Permissions to Info.plist

Right-click `Info.plist` → Open As → Source Code, then add:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>YLE X needs speech recognition to help you practice English pronunciation</string>

<key>NSMicrophoneUsageDescription</key>
<string>YLE X needs microphone access to record your voice for pronunciation practice</string>
```

---

### Step 2: Test Standalone (5 minutes)

Add a quick test button anywhere in your app:

```swift
import SwiftUI

struct TestSpeakingButton: View {
    var body: some View {
        NavigationLink(destination: SpeakingExerciseView(
            exercise: SpeakingExercise.sample()
        )) {
            HStack {
                Image(systemName: "mic.fill")
                Text("Test Speaking Practice")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.appPrimary)
            .cornerRadius(AppRadius.md)
        }
    }
}
```

**Test on real device** (simulator has no microphone):
1. Tap "Test Speaking Practice"
2. Grant permissions
3. Read "Hello, how are you today?"
4. Tap microphone to record
5. Speak clearly
6. Tap stop
7. View feedback

---

### Step 3: Integrate with Lessons

Add speaking practice to your existing lesson system:

```swift
// In LessonDetailView or Exercise flow

NavigationLink(destination: SpeakingExerciseView(
    exercise: SpeakingExercise(
        id: UUID().uuidString,
        type: .sentenceReading,
        targetText: lesson.practiceText,  // From your lesson
        ipaText: lesson.ipaText ?? "",    // Add IPA to lesson model
        difficulty: mapDifficulty(lesson.level),
        tips: [
            "Listen to the example first",
            "Speak at a natural pace",
            "Focus on clear pronunciation"
        ],
        maxAttempts: 3
    )
)) {
    HStack {
        Image(systemName: "mic.circle.fill")
        Text("Practice Speaking")
        Spacer()
        Image(systemName: "chevron.right")
    }
    .padding()
    .background(Color.appSecondary.opacity(0.1))
    .cornerRadius(AppRadius.md)
}

// Helper function
func mapDifficulty(_ level: YLELevel) -> ExerciseDifficulty {
    switch level {
    case .starters: return .beginner
    case .movers: return .intermediate
    case .flyers: return .advanced
    }
}
```

---

### Step 4: Add to Lesson Model (Optional)

Extend your existing Lesson model:

```swift
extension Lesson {
    var speakingExercise: SpeakingExercise {
        SpeakingExercise(
            id: self.id,
            type: .sentenceReading,
            targetText: self.title, // or specific practice sentence
            ipaText: self.ipaText ?? "",
            difficulty: self.level == .starters ? .beginner :
                       self.level == .movers ? .intermediate : .advanced,
            tips: self.speakingTips ?? [],
            maxAttempts: 3
        )
    }
}
```

Then use:
```swift
NavigationLink(destination: SpeakingExerciseView(
    exercise: lesson.speakingExercise
)) {
    Text("Practice Speaking")
}
```

---

### Step 5: Update Lesson Firebase Data (Optional)

Add speaking practice data to Firestore lessons:

```javascript
// In Firebase Console or migration script
{
  "lessons": {
    "lesson_001": {
      // ... existing fields
      "practiceText": "Hello, my name is Sarah. How are you?",
      "ipaText": "/həˈləʊ maɪ neɪm ɪz ˈsɛərə haʊ ɑː juː/",
      "speakingTips": [
        "Focus on the 'Sarah' pronunciation",
        "Pause naturally between sentences",
        "Speak at a comfortable pace"
      ]
    }
  }
}
```

---

## 🎯 Common Use Cases

### 1. Vocabulary Practice

```swift
NavigationLink(destination: SpeakingExerciseView(
    exercise: SpeakingExercise(
        id: word.id,
        type: .wordRepetition,
        targetText: word.text,
        ipaText: word.ipaUS,
        difficulty: .beginner,
        tips: ["Say it slowly first", "Then repeat faster"],
        maxAttempts: 5
    )
)) {
    Text("Practice '\(word.text)'")
}
```

### 2. Sentence Reading

```swift
NavigationLink(destination: SpeakingExerciseView(
    exercise: SpeakingExercise(
        id: UUID().uuidString,
        type: .sentenceReading,
        targetText: "The quick brown fox jumps over the lazy dog",
        ipaText: "/ðə kwɪk braʊn fɒks dʒʌmps ˈəʊvə ðə ˈleɪzi dɒg/",
        difficulty: .intermediate,
        tips: ["Focus on 'th' sounds", "Clear 'r' pronunciation"],
        maxAttempts: 3
    )
)) {
    Text("Read Sentence")
}
```

### 3. Dialogue Practice

```swift
NavigationLink(destination: SpeakingExerciseView(
    exercise: SpeakingExercise(
        id: UUID().uuidString,
        type: .conversation,
        targetText: "Hello! Nice to meet you. How are you today?",
        ipaText: "/həˈləʊ naɪs tuː miːt juː haʊ ɑː juː təˈdeɪ/",
        difficulty: .beginner,
        tips: ["Sound natural and friendly", "Smile while speaking"],
        maxAttempts: 3
    )
)) {
    Text("Practice Dialogue")
}
```

---

## 🛠️ Customization Options

### Change TTS Voice

In `SpeakingExerciseView.swift`, modify `playExample()`:

```swift
private func playExample() {
    let utterance = AVSpeechUtterance(string: exercise.targetText)

    // Use British English
    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

    // Or list all available voices
    // let voices = AVSpeechSynthesisVoice.speechVoices()
    // voices.forEach { print($0.language, $0.name) }

    utterance.rate = 0.4 // 0.0-1.0 (slower for kids)
    utterance.pitchMultiplier = 1.0 // 0.5-2.0

    synthesizer.speak(utterance)
}
```

### Adjust Scoring Threshold

In `SpeechRecognitionService.swift`, modify `analyzePronunciation()`:

```swift
// Make scoring more lenient for kids
if similarity >= 0.85 { // Was 0.9
    status = .correct
    accuracy = 100
    correctCount += 1
} else if similarity >= 0.5 { // Was 0.6
    status = .mispronounced
    accuracy = similarity * 100
}
```

### Change Max Attempts

```swift
SpeakingExercise(
    // ...
    maxAttempts: 5 // Default is 3
)
```

---

## 📊 Track User Progress

### Save Results to Firebase

```swift
// After receiving pronunciationScore
func saveSpeakingResult(_ score: PronunciationScore, exerciseId: String) async {
    guard let userId = Auth.auth().currentUser?.uid else { return }

    let result: [String: Any] = [
        "exerciseId": exerciseId,
        "userId": userId,
        "overallScore": score.overallScore,
        "accuracy": score.accuracy,
        "fluency": score.fluency,
        "completeness": score.completeness,
        "timestamp": Timestamp(date: Date()),
        "attemptNumber": currentAttempt
    ]

    try? await Firestore.firestore()
        .collection("speakingResults")
        .document()
        .setData(result)
}
```

### Award XP for Practice

```swift
// In SpeakingFeedbackView "Continue" button
func awardXPForSpeaking() async {
    guard let userId = Auth.auth().currentUser?.uid else { return }

    let xpAmount: Int
    if score.overallScore >= 90 {
        xpAmount = 50 // Excellent
    } else if score.overallScore >= 75 {
        xpAmount = 30 // Good
    } else {
        xpAmount = 10 // Participation
    }

    try? await Firestore.firestore()
        .collection("userLevels")
        .document(userId)
        .updateData([
            "totalXP": FieldValue.increment(Int64(xpAmount)),
            "weeklyXP": FieldValue.increment(Int64(xpAmount))
        ])
}
```

---

## 🐛 Troubleshooting

### Issue: "Speech Recognition Not Available"

**Solution**:
- Check internet connection (required for first-time download)
- Go to Settings → General → Keyboard → Enable Dictation
- Restart device

### Issue: No sound when playing example

**Solution**:
- Check device is not in silent mode
- Increase volume
- Test with headphones

### Issue: Microphone not working

**Solution**:
- Check Info.plist has `NSMicrophoneUsageDescription`
- Go to Settings → Privacy → Microphone → Enable for YLE X
- Test microphone in Voice Memos app

### Issue: Low recognition accuracy

**Solution**:
- Speak closer to microphone
- Reduce background noise
- Speak more clearly and slowly
- Try in quieter environment

### Issue: "Permission Denied" alert loops

**Solution**:
```swift
// Add this check before requesting
if SFSpeechRecognizer.authorizationStatus() == .authorized {
    // Already authorized, don't request again
    return
}
```

---

## ✅ Testing Checklist

Before releasing to users:

- [ ] **Real Device Testing** (simulator can't test microphone)
- [ ] **Permissions work** on fresh install
- [ ] **Recording quality good** in normal environment
- [ ] **Speech recognition accurate** with child voices
- [ ] **Feedback helpful** and encouraging
- [ ] **UI responsive** and smooth
- [ ] **No crashes** during long recording sessions
- [ ] **Battery usage acceptable**
- [ ] **Works offline** (iOS 13+ with on-device recognition)

---

## 📱 Best Practices

### For Young Learners

1. **Simple Targets**: Start with single words, then phrases
2. **Clear Instructions**: "Read what you see"
3. **Positive Feedback**: Always encourage, even low scores
4. **Visual Cues**: Use large text, clear IPA
5. **Short Sessions**: 3-5 exercises max per session

### For Pronunciation Quality

1. **Good Examples**: Use high-quality TTS or recordings
2. **Slow Rate**: 0.3-0.5x speed for beginners
3. **Clear IPA**: Show pronunciation guide
4. **Tips Upfront**: Give pronunciation hints before attempt
5. **Multiple Attempts**: Allow 3-5 tries to improve

### For User Engagement

1. **Celebrate Success**: Animations, confetti, sounds
2. **Track Progress**: Show improvement over time
3. **Gamify**: Add streaks, achievements for speaking practice
4. **Social**: Compare pronunciation scores with friends
5. **Rewards**: Award XP, badges for consistent practice

---

## 🎉 You're Ready!

Phase 4A is now integrated and ready to use. Your students can:

✅ Practice pronunciation with AI feedback
✅ See exactly where they need improvement
✅ Get personalized tips
✅ Track their progress
✅ Build confidence speaking English

**All for $0 using 100% Apple native frameworks!** 🚀

---

**Need Help?**
- Check PHASE4A_SPEECH_COMPLETE.md for detailed documentation
- Review code comments in each file
- Test with SpeakingExercise.sample() first
- Start simple, add complexity gradually

**Happy Teaching!** 📚🎤
