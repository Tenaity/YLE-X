# Phase 4D: Firebase Data Import - Quick Steps

**Status**: Data ready ✅ | Ready to import to Firebase

---

## 🚀 Quick Import (2 Options)

### Option 1: Firebase Console (Easiest - 5 minutes)

**Step 1: Create lessons Collection**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your YLE X project
3. Click **Firestore Database**
4. Click **+ Create collection**
5. Name it: `lessons`
6. Click **Auto ID** for first document
7. Add any field (we'll import the full data next)
8. Click **Save**

**Step 2: Import Lessons JSON**
1. In Firestore, click your `lessons` collection
2. Click **⋮** (three dots) menu → **Import documents**
3. Select file: `sample_data.json` from this folder
4. Important: **Only select the lessons array** when importing
5. Click **Import**
6. Wait for completion (~30 seconds)
7. Verify: You should see 63 lesson documents (lesson_starters_1 through lesson_flyers_boss)

**Step 3: Create aiActivities Collection**
1. In Firestore, click **+ Create collection**
2. Name it: `aiActivities`
3. Click **Auto ID** for first document
4. Add any field
5. Click **Save**

**Step 4: Import AI Activities JSON**
1. Click your `aiActivities` collection
2. Click **⋮** → **Import documents**
3. Select file: `sample_data.json`
4. Important: **Only select the aiActivities array** when importing
5. Click **Import**
6. Wait for completion
7. Verify: You should see 10 activity documents

---

### Option 2: Firebase CLI (For developers - 3 minutes)

If you have Firebase CLI installed:

```bash
# 1. Login to Firebase
firebase login

# 2. Navigate to project directory
cd "/Users/tenaity/Documents/YLE X"

# 3. Initialize Firebase (if not done)
firebase init

# 4. Set your project
firebase use <your-project-id>

# 5. Extract and import lessons
firebase firestore:import sample_data.json --collection-path=lessons

# 6. Extract and import AI activities
firebase firestore:import sample_data.json --collection-path=aiActivities
```

---

## ✅ Verify Import Success

After importing, check your Firebase console:

### Lessons Collection
- Should have **63 documents**:
  - lesson_starters_1 to lesson_starters_20 ✅
  - lesson_starters_boss ✅
  - lesson_movers_1 to lesson_movers_20 ✅
  - lesson_movers_boss ✅
  - lesson_flyers_1 to lesson_flyers_20 ✅
  - lesson_flyers_boss ✅
  - lesson_animals_easy_1 to lesson_animals_medium_2 ✅
  - More sandbox lessons (school, games) ✅

### AI Activities Collection
- Should have **10 documents**:
  - ai_pronunciation_vowels_1 to ai_pronunciation_vowels_5 ✅
  - ai_vocabulary_animals_1, ai_vocabulary_animals_2 ✅
  - ai_listening_colors_1, ai_listening_colors_2 ✅
  - ai_ipaworkshop_consonants_1, ai_ipaworkshop_consonants_2 ✅

---

## 🧪 Test in the App

After importing, open the app and:

### LinearJourneyView Test
1. Go to "Hành Trình YLE" tab
2. You should see:
   - 🌱 **Starters Phase** with **20 rounds** visible
   - 🚀 **Movers Phase** (locked until Starters complete)
   - ✈️ **Flyers Phase** (locked until Movers complete)
3. Each round shows:
   - Round number
   - Reward: 50 XP + 10 💎
   - Status indicator

### SandboxMapView Test
1. Go to "Thế Giới Khám Phá" tab
2. You should see:
   - **Free islands**: 🦁 Animals, 🎮 Games
   - **Locked islands**: 🏫 School (50 gems), 💼 Professions (75 gems), etc.
3. Islands show correct gem costs

### Boss Battle Test
1. In LinearJourneyView, complete a round
2. After 20 rounds, boss should appear
3. Boss shows: 500 XP + 100 💎 reward

---

## 🐛 Troubleshooting

**Problem**: "No documents appear after import"
- **Solution**: Check that you selected the correct array (lessons or aiActivities) during import, not the entire JSON

**Problem**: "Import shows errors"
- **Solution**: Validate JSON format. Run this to check:
  ```bash
  python3 -m json.tool sample_data.json > /dev/null && echo "JSON valid ✅" || echo "JSON invalid ❌"
  ```

**Problem**: "App shows 'Loading...' but never loads"
- **Solution**: Check Firebase Rules. Make sure authenticated users can read `lessons` and `aiActivities` collections

**Problem**: "Only partial data imported"
- **Solution**: Sometimes Firebase limits imports to first 100 documents. If needed, split into two imports:
  1. Import lessons_part1.json (first 31 lessons)
  2. Import lessons_part2.json (remaining lessons + AI activities)

---

## 📊 Data Summary

**What's in the JSON**:

```
sample_data.json (41 KB)
├─ lessons array (63 documents)
│  ├─ Starters Phase (20 lessons + 1 boss)
│  ├─ Movers Phase (20 lessons + 1 boss)
│  ├─ Flyers Phase (20 lessons + 1 boss)
│  └─ Sandbox topics (15 lessons for islands)
│
└─ aiActivities array (10 documents)
   ├─ Pronunciation practice (5 vowel sounds)
   ├─ Vocabulary with IPA (2 animals)
   ├─ Listening comprehension (2 colors)
   └─ IPA workshop (2 consonants)
```

**Each lesson has**:
- id, title, description
- level (starters/movers/flyers)
- skill (vocabulary/grammar/listening/etc)
- order (1-20 or 1-3)
- xpReward (50 or 500 for boss)
- gemsReward (10 or 100 for boss)
- pathType (linear or sandbox)
- isBoss (true/false)
- And more metadata...

---

## 🎯 Next After Import

Once data is in Firebase and app shows lessons:

**Option A: Connect Exercise Flow** ⏭️
- Link RoundCard taps to actual lesson content
- Track progress when user completes
- Display earned gems/XP notifications

**Option B: Add to HomeView** 🏠
- Show quick progress cards on main dashboard
- "5/20 Starters Complete"
- "3/12 Islands Discovered"

**Option C: Share & Test** 📱
- Get TestFlight link to testers
- Collect feedback
- Refine based on user experience

---

## 💡 Pro Tips

1. **Backup First**: Export your current Firestore data before importing
2. **Test Data**: Start with a test project to verify import works
3. **Batch Import**: If issues occur, you can delete and re-import
4. **Monitor Costs**: This import should be free tier (under 50K reads)

---

## 📞 Still Need Help?

If import doesn't work:

1. Check file exists: `ls -lah sample_data.json`
2. Validate JSON: `python3 -m json.tool sample_data.json`
3. Verify Firebase project is set up correctly in app
4. Check Firestore Rules allow reads/writes for your auth user

---

**Ready to import?** Follow Option 1 (Firebase Console) - it takes 5 minutes and no technical setup needed! 🚀

---

*Created: November 8, 2025*
*Status: Ready to import ✅*
*Data file: sample_data.json (41 KB)*
