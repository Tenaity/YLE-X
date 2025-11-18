# 🔥 Firebase Migration Guide (JavaScript)

**Date**: November 18, 2025
**Status**: Ready to Execute

---

## 📋 Prerequisites

### 1. Node.js Installation
```bash
# Check if Node.js is installed
node --version  # Should be >= 14.0.0
npm --version

# If not installed, install Node.js:
# Ubuntu/Debian:
sudo apt update
sudo apt install nodejs npm

# macOS (Homebrew):
brew install node

# Or download from: https://nodejs.org/
```

### 2. Install Dependencies
```bash
cd /home/user/YLE-X

# Install required packages
npm install

# This installs:
# - firebase-admin: Firebase SDK for Node.js
# - csv-parser: CSV parsing library
```

### 3. Get Firebase Service Account Key
```bash
# 1. Go to Firebase Console
https://console.firebase.google.com

# 2. Select your YLE X project (or create new)

# 3. Click ⚙️ Settings → Project Settings

# 4. Go to "Service Accounts" tab

# 5. Click "Generate new private key"

# 6. Download serviceAccountKey.json

# 7. Move to project directory
mv ~/Downloads/serviceAccountKey.json /home/user/YLE-X/

# 8. Verify file exists
ls -lah serviceAccountKey.json
```

---

## 🚀 Running the Migration

### Step 1: Dry Run (Test First)
```bash
cd /home/user/YLE-X

# Run in DRY RUN mode (no actual upload)
node migrate-to-firebase.js

# Or use npm script
npm run migrate
```

**Expected Output**:
```
======================================================================
📖 Cambridge Vocabulary 2018 → Firebase Migration (JavaScript)
======================================================================

⚠️  DRY RUN MODE

📁 [DRY RUN] Categories (would upload 20 categories)

📚 Migrating vocabulary...
   CSV: Cam_Voca_2018.csv
   Mode: DRY RUN

   Total: 1414 words

   [DRY RUN] Would upload 1414 words

======================================================================
📊 Migration Summary:
   ✅ Success: 1414/1414

📈 Data Completeness:
   Translation Vi:    1414 (100.0%)
   Definition En:     1414 (100.0%)
   Definition Vi:     1414 (100.0%)
   IPA British:       1414 (100.0%)
   IPA American:      1414 (100.0%)
   Audio British:     1074 (76.0%)
   Audio American:    1074 (76.0%)
   Examples (En):     1414 (100.0%)
   Examples (Vi):     1414 (100.0%)
======================================================================

✅ Migration complete!

💡 Next steps:
   1. Review output above
   2. Set CONFIG.dryRun = false in this file
   3. Run: node migrate-to-firebase.js
```

### Step 2: Review Output
- Check if all 1,414 words were parsed
- Verify 100% completeness for critical fields
- Look for any error messages

### Step 3: Live Upload
```bash
# Edit migrate-to-firebase.js
# Change line 24:
#   dryRun: true,  →  dryRun: false,

# Or use this command to change it:
sed -i 's/dryRun: true/dryRun: false/' migrate-to-firebase.js

# Run live migration
node migrate-to-firebase.js

# You'll be prompted to confirm:
# Continue? (yes/no): yes
```

**Expected Time**: 2-5 minutes for 1,414 words

**Expected Output**:
```
======================================================================
📖 Cambridge Vocabulary 2018 → Firebase Migration (JavaScript)
======================================================================

🚀 LIVE MODE

   Continue? (yes/no): yes

✅ Firebase initialized

📁 Uploading categories...
   ✅ Animals: 63 words
   ✅ School: 95 words
   ✅ Food & Drink: 87 words
   ... (20 categories)
✅ Categories complete

📚 Migrating vocabulary...
   CSV: Cam_Voca_2018.csv
   Mode: LIVE

   Total: 1414 words

   Uploaded 500/1414...
   Uploaded 1000/1414...
   Uploaded 1414/1414...

======================================================================
📊 Migration Summary:
   ✅ Success: 1414/1414

📈 Data Completeness:
   Translation Vi:    1414 (100.0%)
   Definition En:     1414 (100.0%)
   ...
======================================================================

✅ Migration complete!

💡 Next steps:
   1. Verify data in Firebase Console
   2. Create Firestore indexes (see docs)
   3. Start building Swift UI!
```

---

## 🗄️ Verify in Firebase Console

### 1. Check Collections
```bash
# Go to Firestore Database in Firebase Console
https://console.firebase.google.com/project/YOUR_PROJECT/firestore

# You should see:
# - categories (20 documents)
# - dictionaries (1414 documents)
```

### 2. Spot Check Words
```
# Click on "dictionaries" collection
# Open a few random words, e.g., "cat", "hello", "school"

# Verify each document has:
✅ word, british, american
✅ translationVi, definitionEn, definitionVi
✅ pronunciation.british.ipa, pronunciation.american.ipa
✅ examples array (3 items)
✅ categories array
✅ levels array
```

### 3. Check Categories
```
# Click on "categories" collection
# Open a few categories, e.g., "animals", "school"

# Verify each has:
✅ name, nameVi
✅ icon, color
✅ wordCount (correct number)
```

---

## 📊 Create Firestore Indexes

Firestore requires composite indexes for complex queries.

### Option A: Automatic (Recommended)
Firebase will prompt you to create indexes when you first run queries in your app. Just click the link and it will auto-create.

### Option B: Manual
```bash
# 1. Go to Firestore → Indexes
https://console.firebase.google.com/project/YOUR_PROJECT/firestore/indexes

# 2. Click "Create Index"

# 3. Add these indexes:
```

**Index 1: Category + Level Query**
```
Collection ID: dictionaries
Fields indexed:
  - categories (Array)
  - levels (Array)
  - word (Ascending)
Query scope: Collection
```

**Index 2: Search by Level**
```
Collection ID: dictionaries
Fields indexed:
  - primaryLevel (Ascending)
  - word (Ascending)
Query scope: Collection
```

**Index 3: Multi-category Query** (Optional)
```
Collection ID: dictionaries
Fields indexed:
  - categories (Array)
  - primaryLevel (Ascending)
  - word (Ascending)
Query scope: Collection
```

---

## 🧪 Test Queries

After migration, test these queries in Firebase Console:

### Query 1: Get all words in "animals" category
```javascript
// Go to Firestore → Query Builder
// Or use Firebase Console's "Filter" feature

Collection: dictionaries
Where: categories array-contains "animals"
```

**Expected**: ~63 documents

### Query 2: Get starters-level words
```javascript
Collection: dictionaries
Where: levels array-contains "starters"
Order by: word
```

**Expected**: ~499 documents

### Query 3: Get animals for starters
```javascript
Collection: dictionaries
Where: categories array-contains "animals"
Where: levels array-contains "starters"
```

**Expected**: ~20-30 documents

---

## 🔧 Troubleshooting

### Issue 1: "Cannot find module 'firebase-admin'"
```bash
# Install dependencies
npm install

# Or install individually
npm install firebase-admin csv-parser
```

### Issue 2: "ENOENT: no such file or directory, open 'serviceAccountKey.json'"
```bash
# Make sure serviceAccountKey.json is in the same directory as the script
ls -lah serviceAccountKey.json

# If not, download from Firebase Console and place it there
```

### Issue 3: "Permission denied: Missing or insufficient permissions"
```bash
# Check Firebase rules
# Go to Firestore → Rules

# For development, use this (DO NOT use in production):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Temporary for testing
    }
  }
}

# After testing, change to proper security rules
```

### Issue 4: "Quota exceeded" or "Rate limit"
```bash
# Firestore free tier limits:
# - 20,000 writes/day
# - 50,000 reads/day

# If you hit limits:
# 1. Wait 24 hours
# 2. Or upgrade to Blaze plan (pay-as-you-go)
# 3. Or reduce batch size in script (CONFIG.batchSize)
```

### Issue 5: Slow upload speed
```bash
# Current batch size: 500 words per batch
# If too slow, increase to 500:

# Edit migrate-to-firebase.js, line 25:
batchSize: 500, // Increase if slow

# Note: Firestore max is 500 writes per batch
```

---

## 📊 Firebase Structure Summary

### Collections Created
```
firestore/
├── categories/          (20 documents)
│   ├── animals
│   ├── school
│   ├── food_and_drink
│   └── ... (17 more)
│
└── dictionaries/        (1,414 documents)
    ├── cat
    ├── dog
    ├── hello
    └── ... (1,411 more)
```

### Document Structure

**categories/{categoryId}**:
```javascript
{
  categoryId: "animals",
  name: "Animals",
  nameVi: "Động Vật",
  icon: "🐾",
  color: "#4ECDC4",
  order: 1,
  wordCount: 63,
  description: "Words related to animals",
  descriptionVi: "Từ vựng về động vật"
}
```

**dictionaries/{wordId}**:
```javascript
{
  wordId: "cat",
  word: "cat",
  british: "cat",
  american: "cat",

  partOfSpeech: ["noun"],
  primaryPos: "noun",

  levels: ["starters"],
  primaryLevel: "starters",

  categories: ["animals"],

  translationVi: "con mèo",
  definitionEn: "A small furry animal...",
  definitionVi: "Một con vật nhỏ...",

  pronunciation: {
    british: {
      ipa: "/kæt/",
      audioUrl: "https://cambridge.../cat_uk.mp3",
      audioSource: "Cambridge"
    },
    american: {
      ipa: "/kæt/",
      audioUrl: "https://cambridge.../cat_us.mp3",
      audioSource: "Cambridge"
    }
  },

  examples: [
    {
      level: "starters",
      sentenceEn: "I have a cat.",
      sentenceVi: "Em có một con mèo."
    },
    {
      level: "movers",
      sentenceEn: "My cat is sleeping.",
      sentenceVi: "Con mèo của em đang ngủ."
    },
    {
      level: "flyers",
      sentenceEn: "Cats are independent animals.",
      sentenceVi: "Mèo là loài vật độc lập."
    }
  ],

  difficulty: 1,
  frequency: "common",
  xpValue: 5,
  gemsValue: 1,

  imageUrl: "",
  emoji: "",

  addedDate: Timestamp,
  lastUpdated: Timestamp,

  dataCompleteness: {
    hasTranslation: true,
    hasDefinitionEn: true,
    hasDefinitionVi: true,
    hasIPABritish: true,
    hasIPAAmerican: true,
    hasAudioBritish: true,
    hasAudioAmerican: true,
    hasExamplesEn: true,
    hasExamplesVi: true
  }
}
```

---

## 💾 Firestore Storage Estimate

### Storage Calculation
```
1 word document ≈ 5-8 KB
1,414 words × 7 KB average = ~10 MB total

Categories: 20 × 1 KB = 20 KB
```

**Total Storage**: ~10 MB

**Firestore Free Tier**: 1 GB storage
→ You're using **1%** of free tier!

### Cost Estimate (Blaze Plan)
```
Storage: $0.18 per GB/month
10 MB = $0.002/month ≈ FREE

Reads: $0.06 per 100K reads
Expected: 10K reads/day = 300K/month
Cost: $0.18/month

Writes: $0.18 per 100K writes
Expected: 1K writes/day = 30K/month
Cost: $0.05/month

TOTAL: ~$0.25/month (virtually free)
```

---

## ✅ Success Checklist

After migration, confirm:

- [ ] 20 categories uploaded to Firebase
- [ ] 1,414 words uploaded to Firebase
- [ ] Spot-checked 10 random words (all fields present)
- [ ] Categories have correct word counts
- [ ] No error messages in console
- [ ] Firebase Console shows correct data
- [ ] Indexes created (or will auto-create)
- [ ] Ready to build Swift UI!

---

## 🚀 Next Steps

### Immediate (Today):
1. ✅ Run migration script
2. ✅ Verify data in Firebase Console
3. ✅ Create indexes (or wait for auto-create)

### This Week:
1. Start Swift implementation
2. Create Models (DictionaryWord, Category)
3. Create ViewModels (DictionaryViewModel)
4. Build Category Grid UI

### Week 2-3:
1. Build Word List & Detail views
2. Implement Audio Player
3. Add Search functionality
4. Create Flashcard mode
5. Test & polish
6. Deploy to TestFlight! 🎉

---

## 📝 Migration Script Options

You can customize the script by editing `migrate-to-firebase.js`:

### Change CSV File
```javascript
// Line 22
CSV_FILE: 'Cam_Voca_2018.csv',  // Change to your file
```

### Change Batch Size
```javascript
// Line 25
batchSize: 500,  // Adjust for speed (max 500)
```

### Skip Categories Upload
```javascript
// In main(), comment out:
// await uploadCategories();
```

### Change Dry Run Mode
```javascript
// Line 24
dryRun: false,  // false = live upload
```

---

## 📞 Support

If you encounter issues:

1. **Check Node.js version**: `node --version` (need >= 14)
2. **Check dependencies**: `npm install`
3. **Check Firebase key**: `ls serviceAccountKey.json`
4. **Check CSV file**: `head -5 Cam_Voca_2018.csv`
5. **Check Firebase Console**: Verify project exists
6. **Check network**: Ensure internet connection

---

**Status**: ✅ Ready to Run
**Estimated Time**: 5-10 minutes total
**Cost**: $0 (free tier)

---

**Created**: November 18, 2025
**Last Updated**: November 18, 2025
