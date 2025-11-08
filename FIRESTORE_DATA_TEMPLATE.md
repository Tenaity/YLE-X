# Firestore Data Import Template

**When ready to populate Firestore**, use this template structure for each collection.

---

## Collection: `lessons`

### Linear Path Lesson (Starters Phase)

```json
{
  "id": "lesson_starters_1",
  "title": "Colors & Shapes",
  "description": "Learn basic colors and shapes in English",
  "level": "starters",
  "skill": "vocabulary",
  "order": 1,
  "xpReward": 50,
  "gemsReward": 10,
  "isLocked": false,
  "thumbnailEmoji": "🎨",
  "estimatedMinutes": 10,
  "totalExercises": 5,
  "pathType": "linear",
  "pathCategory": null,
  "isBoss": false,
  "requiredGemsToUnlock": 0
}
```

### Linear Path Boss Battle (Round 20)

```json
{
  "id": "lesson_starters_boss",
  "title": "Starters Mock Test",
  "description": "Complete YLE Starters mock examination",
  "level": "starters",
  "skill": "mixed",
  "order": 20,
  "xpReward": 500,
  "gemsReward": 100,
  "isLocked": false,
  "thumbnailEmoji": "🏆",
  "estimatedMinutes": 45,
  "totalExercises": 30,
  "pathType": "linear",
  "pathCategory": null,
  "isBoss": true,
  "requiredGemsToUnlock": 0
}
```

### Sandbox Lesson (Vocabulary Island - Animals Topic)

```json
{
  "id": "lesson_vocab_animals_easy_1",
  "title": "Animals - Easy Level 1",
  "description": "Learn basic animal vocabulary",
  "level": "starters",
  "skill": "vocabulary",
  "order": 1,
  "xpReward": 10,
  "gemsReward": 2,
  "isLocked": false,
  "thumbnailEmoji": "🦁",
  "estimatedMinutes": 5,
  "totalExercises": 5,
  "pathType": "sandbox",
  "pathCategory": "Vocabulary Island - Animals",
  "isBoss": false,
  "requiredGemsToUnlock": 0
}
```

### Sandbox Lesson (Locked - Requires Gems)

```json
{
  "id": "lesson_vocab_dinosaurs_easy_1",
  "title": "Dinosaurs - Easy Level 1",
  "description": "Learn dinosaur vocabulary",
  "level": "starters",
  "skill": "vocabulary",
  "order": 1,
  "xpReward": 10,
  "gemsReward": 2,
  "isLocked": false,
  "thumbnailEmoji": "🦕",
  "estimatedMinutes": 5,
  "totalExercises": 5,
  "pathType": "sandbox",
  "pathCategory": "Vocabulary Island - Dinosaurs",
  "isBoss": false,
  "requiredGemsToUnlock": 75
}
```

---

## Collection: `aiActivities`

### Pronunciation Workshop Activity

```json
{
  "id": "ai_pronunciation_vowels_1",
  "type": "pronunciation",
  "level": "starters",
  "pathCategory": "Pronunciation Workshop - Vowels",
  "title": "Practice Vowel Sounds",
  "description": "Master the 5 primary English vowel sounds",
  "targetText": "apple",
  "ipaGuide": "/ˈæpəl/",
  "difficulty": 2,
  "xpReward": 30,
  "gemsReward": 6,
  "estimatedMinutes": 8,
  "order": 1,
  "thumbnailEmoji": "🎤"
}
```

### IPA Workshop Activity

```json
{
  "id": "ai_ipa_workshop_phoneme_1",
  "type": "ipaWorkshop",
  "level": "starters",
  "pathCategory": "IPA Mastery - Vowels",
  "title": "IPA /ə/ (Schwa Sound)",
  "description": "Learn and practice the schwa vowel sound",
  "targetText": "about",
  "ipaGuide": "/əˈbaʊt/",
  "difficulty": 1,
  "xpReward": 20,
  "gemsReward": 4,
  "estimatedMinutes": 5,
  "order": 1,
  "thumbnailEmoji": "📖"
}
```

### Vocabulary with IPA Activity

```json
{
  "id": "ai_vocab_ipa_animals_1",
  "type": "vocabularyWithIPA",
  "level": "starters",
  "pathCategory": "Vocabulary with IPA",
  "title": "Animals - Pronunciation & Meaning",
  "description": "Learn animal vocabulary with correct pronunciation",
  "targetText": "elephant",
  "ipaGuide": "/ˈɛlɪfənt/",
  "difficulty": 1,
  "xpReward": 25,
  "gemsReward": 5,
  "estimatedMinutes": 6,
  "order": 1,
  "thumbnailEmoji": "🐘"
}
```

### Listening Comprehension Activity

```json
{
  "id": "ai_listening_colors_1",
  "type": "listeningComp",
  "level": "starters",
  "pathCategory": "Listening Comprehension",
  "title": "Listen and Identify Colors",
  "description": "Listen to color words and identify the correct color",
  "targetText": "blue",
  "ipaGuide": "/bluː/",
  "difficulty": 1,
  "xpReward": 20,
  "gemsReward": 4,
  "estimatedMinutes": 4,
  "order": 1,
  "thumbnailEmoji": "👂"
}
```

---

## Collection: `userProgress/{userId}/pathProgress`

### Initial State Document (`learningPathState`)

```json
{
  "id": "user123",
  "userId": "user123",
  "linearProgress": {
    "id": "user123",
    "userId": "user123",
    "currentPhase": "Starters",
    "currentRound": 1,
    "roundsCompleted": [],
    "bossesDefeated": [],
    "totalXPEarned": 0,
    "totalGemsEarned": 0,
    "createdAt": "2025-11-08T10:00:00Z",
    "lastUpdatedAt": "2025-11-08T10:00:00Z"
  },
  "sandboxProgress": {
    "id": "user123",
    "userId": "user123",
    "unlockedIslands": [],
    "unlockedTopics": [],
    "unlockedSkills": [],
    "unlockedGames": [],
    "completedActivities": [],
    "activityScores": {},
    "topicProgress": {},
    "totalGemsSpent": 0,
    "totalActivitiesCompleted": 0,
    "createdAt": "2025-11-08T10:00:00Z",
    "lastUpdatedAt": "2025-11-08T10:00:00Z"
  },
  "totalXP": 0,
  "totalGems": 0,
  "currentLevel": 1,
  "lastUpdatedAt": "2025-11-08T10:00:00Z"
}
```

### After User Progress Document

```json
{
  "id": "user123",
  "userId": "user123",
  "linearProgress": {
    "id": "user123",
    "userId": "user123",
    "currentPhase": "Starters",
    "currentRound": 6,
    "roundsCompleted": [
      "lesson_starters_1",
      "lesson_starters_2",
      "lesson_starters_3",
      "lesson_starters_4",
      "lesson_starters_5"
    ],
    "bossesDefeated": [],
    "totalXPEarned": 250,
    "totalGemsEarned": 50,
    "createdAt": "2025-11-08T10:00:00Z",
    "lastUpdatedAt": "2025-11-08T12:30:00Z"
  },
  "sandboxProgress": {
    "id": "user123",
    "userId": "user123",
    "unlockedIslands": ["vocab_island"],
    "unlockedTopics": ["vocab_animals"],
    "unlockedSkills": [],
    "unlockedGames": [],
    "completedActivities": [
      "lesson_vocab_animals_easy_1",
      "lesson_vocab_animals_easy_2"
    ],
    "activityScores": {
      "lesson_vocab_animals_easy_1": 95,
      "lesson_vocab_animals_easy_2": 88
    },
    "topicProgress": {
      "vocab_animals": {
        "id": "vocab_animals",
        "topicName": "Animals",
        "easyCompleted": 2,
        "mediumCompleted": 0,
        "hardCompleted": 0,
        "bestScore": 95,
        "averageScore": 91.5,
        "lastCompletedAt": "2025-11-08T12:15:00Z"
      }
    },
    "totalGemsSpent": 0,
    "totalActivitiesCompleted": 2,
    "createdAt": "2025-11-08T10:00:00Z",
    "lastUpdatedAt": "2025-11-08T12:30:00Z"
  },
  "totalXP": 270,
  "totalGems": 50,
  "currentLevel": 1,
  "lastUpdatedAt": "2025-11-08T12:30:00Z"
}
```

---

## Sample Data Structure for Import

### Starters Phase Linear Path (Full Example - 5 lessons + boss)

```json
[
  {
    "id": "lesson_starters_1",
    "title": "Colors & Shapes",
    "description": "Learn basic colors and shapes",
    "level": "starters",
    "skill": "vocabulary",
    "order": 1,
    "xpReward": 50,
    "gemsReward": 10,
    "isLocked": false,
    "thumbnailEmoji": "🎨",
    "estimatedMinutes": 10,
    "totalExercises": 5,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": false,
    "requiredGemsToUnlock": 0
  },
  {
    "id": "lesson_starters_2",
    "title": "Animals",
    "description": "Learn animal names and sounds",
    "level": "starters",
    "skill": "vocabulary",
    "order": 2,
    "xpReward": 50,
    "gemsReward": 10,
    "isLocked": false,
    "thumbnailEmoji": "🦁",
    "estimatedMinutes": 10,
    "totalExercises": 5,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": false,
    "requiredGemsToUnlock": 0
  },
  {
    "id": "lesson_starters_3",
    "title": "Numbers 1-10",
    "description": "Count and recognize numbers",
    "level": "starters",
    "skill": "vocabulary",
    "order": 3,
    "xpReward": 50,
    "gemsReward": 10,
    "isLocked": false,
    "thumbnailEmoji": "🔢",
    "estimatedMinutes": 10,
    "totalExercises": 5,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": false,
    "requiredGemsToUnlock": 0
  },
  {
    "id": "lesson_starters_4",
    "title": "Family Members",
    "description": "Learn family vocabulary",
    "level": "starters",
    "skill": "vocabulary",
    "order": 4,
    "xpReward": 50,
    "gemsReward": 10,
    "isLocked": false,
    "thumbnailEmoji": "👨‍👩‍👧",
    "estimatedMinutes": 10,
    "totalExercises": 5,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": false,
    "requiredGemsToUnlock": 0
  },
  {
    "id": "lesson_starters_5",
    "title": "Body Parts",
    "description": "Learn names of body parts",
    "level": "starters",
    "skill": "vocabulary",
    "order": 5,
    "xpReward": 50,
    "gemsReward": 10,
    "isLocked": false,
    "thumbnailEmoji": "👋",
    "estimatedMinutes": 10,
    "totalExercises": 5,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": false,
    "requiredGemsToUnlock": 0
  },
  {
    "id": "lesson_starters_boss",
    "title": "Starters Mock Test",
    "description": "Complete YLE Starters examination",
    "level": "starters",
    "skill": "mixed",
    "order": 20,
    "xpReward": 500,
    "gemsReward": 100,
    "isLocked": false,
    "thumbnailEmoji": "🏆",
    "estimatedMinutes": 45,
    "totalExercises": 30,
    "pathType": "linear",
    "pathCategory": null,
    "isBoss": true,
    "requiredGemsToUnlock": 0
  }
]
```

---

## Data Import Requirements

When you provide sample content, please structure it as:

### Lessons
- One JSON object per lesson
- Required fields: id, title, level, skill, order, xpReward, gemsReward, pathType
- For linear: order 1-19, then 20 for boss
- For sandbox: include pathCategory and requiredGemsToUnlock

### AI Activities
- One JSON object per activity
- Required fields: id, type, level, pathCategory, title, targetText
- Types: "pronunciation", "vocabularyWithIPA", "listeningComp", "ipaWorkshop", "conversationPractice"

### User Progress
- One document per user
- Initialize with empty progress
- Structure matches `LearningPathState` model

---

## Next Steps

1. **Prepare your content** - Adapt above templates with your lesson/activity data
2. **Provide to me** - Share JSON files or spreadsheet format
3. **Import to Firestore** - I can help set up import script or you can use Firebase Console
4. **Verify data** - Test that UI correctly queries and displays content

**Ready to import data?** Let me know the format you prefer to work with!
