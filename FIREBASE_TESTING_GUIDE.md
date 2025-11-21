# Firebase Testing Guide - Dictionary Feature

## ✅ Pre-Testing Checklist

Before testing, ensure:
- [ ] Firebase SDK is configured in your Xcode project
- [ ] `GoogleService-Info.plist` is added to the project
- [ ] Firestore security rules allow read access
- [ ] Data is imported (1,414 words + 20 categories)
- [ ] Device/Simulator has internet connection

## 📊 Data Verification

### Expected Firebase Structure

```
Firestore Database:
├── dictionaries/ (1,414 documents)
│   ├── word_abandon
│   ├── word_ability
│   └── ... (1,412 more)
└── categories/ (20 documents)
    ├── animals
    ├── body_health
    └── ... (18 more)
```

### Quick Firebase Console Check

1. Open Firebase Console → Firestore Database
2. Check `categories` collection → Should have **20 documents**
3. Check `dictionaries` collection → Should have **1,414 documents**
4. Verify sample document structure:

**Sample Category Document** (`animals`):
```json
{
  "categoryId": "animals",
  "name": "Animals",
  "nameVi": "Động vật",
  "icon": "🐾",
  "color": "#FF6B6B",
  "order": 1,
  "wordCount": 87
}
```

**Sample Word Document** (`word_cat`):
```json
{
  "word": "cat",
  "british": "cat",
  "american": "cat",
  "partOfSpeech": ["noun"],
  "levels": ["starters"],
  "categories": ["animals"],
  "translationVi": "con mèo",
  "definitionEn": "a small animal with fur, four legs, and a tail",
  "definitionVi": "một con vật nhỏ có lông, bốn chân và đuôi",
  "pronunciation": {
    "british": {
      "ipa": "/kæt/",
      "audioUrl": "https://...",
      "audioSource": "cambridge",
      "hasAudio": true
    }
  },
  "examples": [...],
  "difficulty": 1,
  "xpValue": 5,
  "gemsValue": 2
}
```

## 🧪 Testing Scenarios

### Test 1: Category Grid Loading ✅

**Steps:**
1. Launch app → Navigate to Learn tab
2. Select "Dictionary" mode
3. Wait for categories to load

**Expected Results:**
- ✅ Loading indicator appears briefly
- ✅ 20 colorful category cards display in 2-column grid
- ✅ Each card shows: icon, English name, Vietnamese name, word count
- ✅ Cards have vibrant colors (Animals=red, Food=green, etc.)
- ✅ Pull-to-refresh works

**Troubleshooting:**
- If empty: Check Firebase connection and security rules
- If slow: Check network connection
- If wrong count: Verify `wordCount` field in categories

---

### Test 2: Level Selection 🎯

**Steps:**
1. On Category screen, tap level badge at top
2. Try selecting different levels (Starters/Movers/Flyers)

**Expected Results:**
- ✅ Level selector sheet appears with 3 levels
- ✅ Each level shows icon, name, Vietnamese name, age range
- ✅ Selected level has checkmark
- ✅ Closing sheet returns to categories with new level selected

---

### Test 3: Word List Loading 📝

**Steps:**
1. Select "Animals" category
2. Verify word list loads

**Expected Results:**
- ✅ Words load for selected level
- ✅ Header shows word count (e.g., "87 words")
- ✅ Each word row shows: word, translation, POS badge, IPA
- ✅ Audio button visible on each row
- ✅ Level filter chips appear (Starters/Movers/Flyers)

**Test Different Levels:**
- Tap "Movers" chip → Word list updates
- Tap "Flyers" chip → Word list updates
- Enable "All Levels" toggle → Shows words from all levels

---

### Test 4: Search Functionality 🔍

**Steps:**
1. In word list, tap search bar
2. Type "cat"
3. Clear search

**Expected Results:**
- ✅ Search filters words in real-time
- ✅ Searches both English and Vietnamese
- ✅ Empty state appears if no results
- ✅ Clear button (X) appears when typing
- ✅ Search is case-insensitive

**Test Cases:**
- Search "cat" → Should find "cat"
- Search "mèo" → Should find "cat" (Vietnamese search)
- Search "xyz123" → Should show "No results"

---

### Test 5: Audio Playback 🔊

**Steps:**
1. On word row, tap audio button
2. Wait for audio to play

**Expected Results:**
- ✅ Audio plays (Cambridge/Legacy/TTS)
- ✅ Speaker icon animates (wave.3.fill)
- ✅ Haptic feedback on tap
- ✅ Audio stops when tapping another word

**Audio Tiers:**
- **Tier 1 (Cambridge)**: High-quality professional recording
- **Tier 2 (Legacy)**: Standard quality recording
- **Tier 3 (TTS)**: Synthetic voice (always works)

**Test Multiple Accents:**
1. Open word detail view
2. Tap British audio button → Should play British pronunciation
3. Tap American audio button → Should play American pronunciation

---

### Test 6: Word Detail View 📖

**Steps:**
1. Tap on any word row
2. Explore detail view

**Expected Results:**
- ✅ Large word display with emoji and translation
- ✅ Dual audio buttons (British 🇬🇧 + American 🇺🇸)
- ✅ IPA notation for both accents
- ✅ English and Vietnamese definitions
- ✅ Example sentences (filtered by level)
- ✅ Grammar section (POS, levels, irregular plural if applicable)
- ✅ Category tags in FlowLayout

**Example Filtering:**
- Starters level → Shows only Starters examples
- Movers level → Shows Starters + Movers examples
- Flyers level → Shows all examples

---

### Test 7: Level Filtering & Toggle 🎚️

**Steps:**
1. In word list, tap level chips
2. Enable "All Levels" toggle

**Expected Results:**
- ✅ Tapping level chip fetches filtered words
- ✅ Selected chip highlighted with level color
- ✅ "All Levels" toggle in toolbar
- ✅ When toggled, level chips disappear
- ✅ Word count updates based on filter

---

### Test 8: Performance Testing ⚡

**Steps:**
1. Navigate through multiple categories quickly
2. Search with different queries
3. Toggle levels repeatedly

**Expected Results:**
- ✅ Smooth animations (no lag)
- ✅ Quick loading (caching works)
- ✅ No memory leaks
- ✅ Debounced search (300ms delay)
- ✅ LazyVStack/LazyVGrid loads efficiently

---

### Test 9: Edge Cases 🔧

**Test Empty States:**
1. Select level with no words in category
   - ✅ Shows "No words found" with level emoji
   - ✅ Suggests trying different level

2. Search with no results
   - ✅ Shows "No results for 'xyz'"
   - ✅ Suggests trying different search

**Test Network Issues:**
1. Turn off Wi-Fi/Data
2. Try loading categories
   - ✅ Shows appropriate error message
   - ✅ Retry button available

---

## 🐛 Common Issues & Solutions

### Issue 1: Categories Not Loading

**Symptoms:**
- Empty screen or "No Categories Found"
- Loading indicator never stops

**Solutions:**
1. Check Firebase security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /categories/{document=**} {
      allow read: if true;
    }
    match /dictionaries/{document=**} {
      allow read: if true;
    }
  }
}
```

2. Verify Firebase initialization in `AppDelegate.swift`:
```swift
import Firebase

@main
struct YLE_XApp: App {
    init() {
        FirebaseApp.configure()
    }
}
```

3. Check `GoogleService-Info.plist` is in project

---

### Issue 2: Audio Not Playing

**Symptoms:**
- Tapping audio button does nothing
- No sound output

**Solutions:**
1. Check audio URLs in Firebase (should not be empty)
2. Verify TTS fallback is working
3. Check device volume and silent mode
4. Test on real device (Simulator may have audio issues)

---

### Issue 3: Slow Performance

**Symptoms:**
- Categories/Words take long to load
- UI freezes

**Solutions:**
1. Check network speed
2. Verify caching is working (should be instant on 2nd load)
3. Check Firebase query limits (currently 200 words per query)
4. Enable Firebase indexing for better performance

---

### Issue 4: Wrong Word Count

**Symptoms:**
- Category shows incorrect word count
- "87 words" but only 20 appear

**Solutions:**
1. Verify level filtering is applied correctly
2. Check if "All Levels" toggle affects count
3. Verify Firebase documents have correct `levels` array
4. Re-run migration script if data is corrupt

---

## 📊 Expected Data Coverage

### Word Distribution by Level:
- **Starters**: ~400 words
- **Movers**: ~500 words
- **Flyers**: ~500 words
- **Total**: 1,414 words (some words appear in multiple levels)

### Audio Coverage:
- **Cambridge Audio**: 76% (1,074 words)
- **Legacy Audio**: 14% (198 words)
- **TTS Fallback**: 100% (all words)

### Category Distribution (Top 5):
1. **Animals**: 87 words
2. **Food & Drink**: 95 words
3. **Body & Health**: 67 words
4. **Family & Friends**: 54 words
5. **School**: 78 words

---

## ✅ Final Checklist

After completing all tests:

- [ ] 20 categories load correctly
- [ ] Words load for each category
- [ ] Level filtering works (Starters/Movers/Flyers)
- [ ] Search works (English + Vietnamese)
- [ ] Audio plays for all 3 tiers
- [ ] Word detail shows complete information
- [ ] Performance is smooth (no lag)
- [ ] Empty states appear correctly
- [ ] Navigation works (back buttons, links)
- [ ] Pull-to-refresh works

---

## 🎉 Success Criteria

Your Dictionary feature is **production-ready** if:

1. ✅ All 1,414 words are accessible
2. ✅ Audio playback works reliably (3-tier system)
3. ✅ Search is fast and accurate
4. ✅ UI is smooth and responsive
5. ✅ No crashes or freezes
6. ✅ Data persists across app restarts (Firebase caching)
7. ✅ Works offline for previously loaded data

---

## 📞 Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Verify Firebase Console data structure
3. Review `DictionaryViewModel` logs
4. Test on both Simulator and real device

**Happy Testing! 🚀**
