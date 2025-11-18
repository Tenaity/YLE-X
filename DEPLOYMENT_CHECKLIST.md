# 🚀 YLE Dictionary - Deployment Checklist

**Date Created**: November 13, 2025
**Status**: Ready for N8N Implementation
**Total Cost**: $17 (N8N + AI generation)
**Total Time**: 6-8 hours

---

## ✅ Phase 1: Data Preparation (COMPLETE)

### Files Ready:
- ✅ `Cambridge_Vocabulary_2018_PERFECT.csv` (58 columns, 1,414 words)
- ✅ `migrate_perfect_to_firebase.py` (production-ready migration script)
- ✅ `N8N_SINGLE_PROMPT.md` (complete N8N guide with mega prompt)
- ✅ `PERFECT_IMPLEMENTATION_COMPLETE.md` (full documentation)

### Data Coverage:
- ✅ 1,414 Cambridge YLE vocabulary words
- ✅ British audio: 79.8% (1,128 words from Cambridge)
- ✅ American audio: 86.4% (1,222 words from Cambridge)
- ✅ Fallback system: Cambridge → Old sources → TTS
- ✅ 11 empty fields ready for AI generation

### CSV Structure (58 columns):
```
Base Data (40 columns):
  ✅ word, british, american
  ✅ partOfSpeech (13 types)
  ✅ levels (starters, movers, flyers)
  ✅ categories (20 types)

Audio (3 columns):
  ✅ cambridgeAudioGB (British Cambridge audio)
  ✅ cambridgeAudioUS (American Cambridge audio)
  ✅ audioValue (old source fallback)

Content to Generate (11 columns):
  🔲 translationVi (Vietnamese translation)
  🔲 definitionEn (English definition)
  🔲 definitionVi (Vietnamese definition)
  🔲 ipaGB (British IPA)
  🔲 ipaUS (American IPA)
  🔲 exampleStarters (English, age 7-8)
  🔲 exampleMovers (English, age 8-11)
  🔲 exampleFlyers (English, age 9-12)
  🔲 exampleStartersVi (Vietnamese, age 7-8)
  🔲 exampleMoversVi (Vietnamese, age 8-11)
  🔲 exampleFlyersVi (Vietnamese, age 9-12)
```

**Phase 1 Status**: ✅ **COMPLETE - Ready for Phase 2**

---

## 🔲 Phase 2: N8N Setup (30 minutes)

### Step 1: Install N8N
```bash
# If not already installed
npm install n8n -g

# Start N8N
n8n start

# Access at: http://localhost:5678
```
**Status**: 🔲 Not started

---

### Step 2: Configure OpenAI API Key

1. Go to N8N Settings → Credentials
2. Add new credential: "OpenAI API"
3. Enter your OpenAI API key
4. Test connection

**API Key Requirements**:
- Model: GPT-4 Turbo (`gpt-4-turbo-preview`)
- Rate limit: 10,000 tokens/min minimum
- Budget: ~$20 (actual cost ~$17)

**Status**: 🔲 Not configured

---

### Step 3: Create N8N Workflow

**Use guide**: [N8N_SINGLE_PROMPT.md](N8N_SINGLE_PROMPT.md)

**Nodes to create** (in order):
1. 🔲 CSV Reader → Read `Cambridge_Vocabulary_2018_PERFECT.csv`
2. 🔲 Split In Batches → Batch size: 10 words
3. 🔲 Function → Build prompt with word context
4. 🔲 OpenAI → GPT-4 Turbo with JSON mode
5. 🔲 Function → Parse & validate JSON (11 fields)
6. 🔲 Error Trigger → Retry failed calls (max 3 retries)
7. 🔲 Wait → 2 seconds between batches (rate limiting)
8. 🔲 CSV Writer → Update PERFECT.csv with results
9. 🔲 Function → Progress logger (every 100 words)

**Workflow file**: Save as `yle_dictionary_ai_generation.json`

**Status**: 🔲 Not created

---

### Step 4: Test with Sample Words

**Test 1**: Single word (5 minutes)
```json
{
  "word": "apple",
  "partOfSpeech": "noun",
  "primaryLevel": "Starters",
  "categories": "Food & Drink"
}
```

**Expected output**:
- ✅ All 11 fields present
- ✅ Valid JSON format
- ✅ IPA notation correct (British vs American)
- ✅ Examples age-appropriate
- ✅ Vietnamese natural and accurate

**Status**: 🔲 Not tested

---

**Test 2**: 10 diverse words (10 minutes)

Pick varied words to test:
- Different parts of speech (noun, verb, adjective)
- Different levels (Starters, Movers, Flyers)
- Different categories (Animals, Food, School, Sports)

**Words to test**:
1. apple (noun, Starters, Food)
2. run (verb, Starters, Sports)
3. happy (adjective, Starters, Feelings)
4. elephant (noun, Movers, Animals)
5. teach (verb, Movers, School)
6. beautiful (adjective, Flyers, General)
7. bicycle (noun, Movers, Transport)
8. weather (noun, Flyers, Weather)
9. grandmother (noun, Starters, Family)
10. excited (adjective, Movers, Feelings)

**Validation checklist**:
- 🔲 All 10 words processed successfully
- 🔲 No JSON parsing errors
- 🔲 IPA format correct (/ˈæp.əl/)
- 🔲 Examples use target word
- 🔲 Vietnamese translations natural
- 🔲 Difficulty appropriate for level

**Status**: 🔲 Not tested

---

**Phase 2 Status**: 🔲 **NOT STARTED**

---

## 🔲 Phase 3: Full AI Generation (4-6 hours)

### Before Starting:

**Pre-flight checklist**:
- ✅ OpenAI API key configured
- ✅ OpenAI account has $20+ credit
- ✅ N8N workflow tested with 10 words
- ✅ CSV backup created
- ✅ Monitor tab open for progress

**Backup CSV**:
```bash
cp Cambridge_Vocabulary_2018_PERFECT.csv Cambridge_Vocabulary_2018_PERFECT_BACKUP.csv
```

**Status**: 🔲 Backup not created

---

### Run Full Batch:

**Settings**:
- Batch size: 10 words
- Total words: 1,414
- Total batches: 142 batches
- Rate limit: 2 seconds between batches
- Estimated time: 4-6 hours
- Estimated cost: $16.97

**Start workflow**:
1. Open N8N workflow
2. Click "Execute Workflow"
3. Monitor progress in execution log
4. Do NOT close browser tab

**Status**: 🔲 Not started

---

### Monitor Progress:

**Expected output every 100 words**:
```
✅ Processed 100/1414 words (7.1%)
✅ Processed 200/1414 words (14.1%)
✅ Processed 300/1414 words (21.2%)
...
✅ Processed 1400/1414 words (99.0%)
✅ Processed 1414/1414 words (100.0%)
```

**Error handling**:
- Automatic retry: 3 attempts per word
- If word fails 3 times: Skip and log error
- Review errors after completion

**Status**: 🔲 Not monitored

---

### Completion Stats to Track:

After completion, check:
```python
# Run validation script
python3 validate_completion.py

# Expected output:
translationVi:     1414/1414 (100.0%)
definitionEn:      1414/1414 (100.0%)
definitionVi:      1414/1414 (100.0%)
ipaGB:             1414/1414 (100.0%)
ipaUS:             1414/1414 (100.0%)
exampleStarters:   1414/1414 (100.0%)
exampleMovers:     1414/1414 (100.0%)
exampleFlyers:     1414/1414 (100.0%)
exampleStartersVi: 1414/1414 (100.0%)
exampleMoversVi:   1414/1414 (100.0%)
exampleFlyersVi:   1414/1414 (100.0%)

Total errors: 0
Retry count: XX
```

**Status**: 🔲 Not completed

---

**Phase 3 Status**: 🔲 **NOT STARTED**

---

## 🔲 Phase 4: Quality Validation (1 hour)

### Step 1: Automated Validation

**Run validation script**:
```bash
python3 validate_perfect_csv.py
```

**Checks**:
- 🔲 All 11 fields have 100% completion
- 🔲 No empty values
- 🔲 IPA format correct (starts with `/`, ends with `/`)
- 🔲 Examples contain target word
- 🔲 Vietnamese not identical to English
- 🔲 No suspicious characters or encoding issues

**Status**: 🔲 Not validated

---

### Step 2: Manual Spot Check

**Check 20 random words** (5 minutes):

Pick random words and verify:
- Translation accuracy (Vietnamese correct?)
- Definition clarity (age-appropriate?)
- IPA notation (British vs American different?)
- Examples quality (natural? uses word correctly?)
- Vietnamese examples (natural translation? not word-by-word?)

**Sample words to check**:
1. Word #50
2. Word #150
3. Word #300
4. Word #500
5. Word #750
6. Word #1000
7. Word #1200
8. Word #1414 (last word)
... (check 12 more random words)

**Status**: 🔲 Not checked

---

### Step 3: Fix Any Issues

If errors found:
```bash
# Re-run failed words only
python3 rerun_failed_words.py

# Or manually edit CSV for specific issues
```

**Common issues**:
- IPA format incorrect → Re-generate with stricter prompt
- Examples don't use word → Re-generate examples
- Vietnamese unnatural → Re-generate Vietnamese fields

**Status**: 🔲 No issues found yet

---

**Phase 4 Status**: 🔲 **NOT STARTED**

---

## 🔲 Phase 5: Firebase Upload (1 hour)

### Step 1: Get Firebase Credentials

**Download Service Account Key**:
1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Generate new private key
4. Save as `serviceAccountKey.json` in project root

**Status**: 🔲 Not downloaded

---

### Step 2: Install Firebase Admin SDK

```bash
pip install firebase-admin
```

**Status**: 🔲 Not installed

---

### Step 3: Dry Run Migration

```bash
# Test migration without uploading
python3 migrate_perfect_to_firebase.py

# Check output for any errors
```

**Expected output**:
```
📖 PERFECT Migration: Cambridge Vocabulary 2018 → Firebase
======================================================================

⚠️  DRY RUN MODE

📁 [DRY RUN] Categories
   Animals: 89 words
   Food & Drink: 142 words
   ...
   ✅ Categories complete

📚 Migrating vocabulary...
   Total: 1414 words
   Processed 100/1414...
   Processed 200/1414...
   ...
   Processed 1414/1414...

📊 Migration Summary:
   ✅ Success: 1414/1414

📈 Data Completeness:
   Translation Vi:    1414 (100.0%)
   Definition En:     1414 (100.0%)
   Definition Vi:     1414 (100.0%)
   IPA British:       1414 (100.0%)
   IPA American:      1414 (100.0%)
   Audio British:     1128 (79.8%)
   Audio American:    1222 (86.4%)
   Examples (En):     1414 (100.0%)
   Examples (Vi):     1414 (100.0%)
```

**Status**: 🔲 Dry run not completed

---

### Step 4: LIVE Upload to Firebase

**⚠️ IMPORTANT**: This will write to production Firebase!

```bash
# Edit migrate_perfect_to_firebase.py
# Line 27: DRY_RUN = False

# Run live migration
python3 migrate_perfect_to_firebase.py
```

**Confirmation prompt**:
```
🚀 LIVE MODE
   Continue? (yes/no):
```

**Type**: `yes`

**Expected duration**: 5-10 minutes for 1,414 words

**Status**: 🔲 Not uploaded

---

### Step 5: Verify Firebase Data

**Check Firebase Console**:

1. Go to Firestore Database
2. Check `dictionaries` collection: Should have 1,414 documents
3. Check `categories` collection: Should have 20 documents
4. Open random word document → Verify structure

**Random word to check** (e.g., "apple"):
```javascript
dictionaries/apple/
  ├── word: "apple"
  ├── translationVi: "táo"
  ├── definitionEn: "A round, sweet fruit..."
  ├── definitionVi: "Một loại trái cây tròn..."
  ├── pronunciation:
  │   ├── british:
  │   │   ├── ipa: "/ˈæp.əl/"
  │   │   └── audioUrl: "https://dictionary.cambridge.org/..."
  │   └── american:
  │       ├── ipa: "/ˈæp.əl/"
  │       └── audioUrl: "https://dictionary.cambridge.org/..."
  ├── examples: [
  │   {
  │     level: "starters",
  │     sentenceEn: "I like apples.",
  │     sentenceVi: "Em thích táo."
  │   },
  │   ...
  │ ]
  └── dataCompleteness:
      ├── hasTranslation: true
      ├── hasDefinitionEn: true
      ├── hasDefinitionVi: true
      ├── hasIPABritish: true
      ├── hasIPAAmerican: true
      └── ...
```

**Status**: 🔲 Not verified

---

**Phase 5 Status**: 🔲 **NOT STARTED**

---

## 🔲 Phase 6: Swift App Integration (Week 2-3)

### Week 2: Core Implementation (20 hours)

**Models** (6 hours):
- 🔲 Update `DictionaryWord.swift` with new structure
- 🔲 Add `Pronunciation` struct (British + American)
- 🔲 Add `Example` struct (level + EN + VI)
- 🔲 Add `DataCompleteness` tracking

**ViewModels** (6 hours):
- 🔲 Update `DictionaryViewModel.swift`
- 🔲 Firestore queries (by category, level, search)
- 🔲 Audio playback priority (Cambridge → Old → TTS)
- 🔲 Example filtering by level

**Views** (8 hours):
- 🔲 `DictionaryView.swift` (category grid + search)
- 🔲 `WordDetailView.swift` (word card with all data)
- 🔲 Audio buttons (British 🇬🇧 / American 🇺🇸)
- 🔲 IPA display (separate for each accent)
- 🔲 Definitions (EN + VI)
- 🔲 Examples (3 levels with Vietnamese)

**Status**: 🔲 Not started

---

### Week 3: Advanced Features (24 hours)

**Flashcards** (12 hours):
- 🔲 Flashcard mode
- 🔲 Spaced repetition algorithm
- 🔲 Progress tracking
- 🔲 Swipe gestures

**Quizzes** (12 hours):
- 🔲 Multiple choice (definition → word)
- 🔲 Listening quiz (audio → word)
- 🔲 Translation quiz (EN → VI)
- 🔲 Level-based difficulty

**Status**: 🔲 Not started

---

**Phase 6 Status**: 🔲 **NOT STARTED**

---

## 📊 Overall Progress

```
Phase 1: Data Preparation         ✅ COMPLETE
Phase 2: N8N Setup                🔲 NOT STARTED (30 min)
Phase 3: AI Generation            🔲 NOT STARTED (4-6 hours)
Phase 4: Quality Validation       🔲 NOT STARTED (1 hour)
Phase 5: Firebase Upload          🔲 NOT STARTED (1 hour)
Phase 6: Swift Implementation     🔲 NOT STARTED (2-3 weeks)

TOTAL PROGRESS: 16.7% (1/6 phases)
```

---

## 💰 Cost Tracker

| Item | Budgeted | Actual | Status |
|------|----------|--------|--------|
| CSV Preparation | $0 | $0 | ✅ Complete |
| Audio URLs | $0 | $0 | ✅ Complete |
| N8N + AI (GPT-4 Turbo) | $17 | $0 | 🔲 Pending |
| Firebase Firestore | $0 | $0 | 🔲 Free tier |
| Firebase Storage | $0 | $0 | 🔲 Using external URLs |
| **TOTAL** | **$17** | **$0** | **0% spent** |

---

## ⏱️ Time Tracker

| Phase | Estimated | Actual | Status |
|-------|-----------|--------|--------|
| Phase 1 | 2h | 2h | ✅ Complete |
| Phase 2 | 30m | 0m | 🔲 Pending |
| Phase 3 | 4-6h | 0h | 🔲 Pending |
| Phase 4 | 1h | 0h | 🔲 Pending |
| Phase 5 | 1h | 0h | 🔲 Pending |
| **TOTAL (Data)** | **8-10h** | **2h** | **20% complete** |
| Phase 6 | 2-3 weeks | 0h | 🔲 Pending |

---

## 🎯 Next Immediate Steps

### **TODAY** (if proceeding):

1. **Setup N8N** (30 minutes)
   ```bash
   npm install n8n -g
   n8n start
   # Access: http://localhost:5678
   ```

2. **Configure OpenAI API** (5 minutes)
   - Add OpenAI credentials to N8N
   - Test connection

3. **Create workflow** (15 minutes)
   - Follow [N8N_SINGLE_PROMPT.md](N8N_SINGLE_PROMPT.md)
   - Copy system + user prompts
   - Configure 9 nodes

4. **Test with 10 words** (10 minutes)
   - Verify output quality
   - Check JSON format
   - Validate all 11 fields

### **THIS WEEK** (if tests pass):

1. **Run full AI generation** (4-6 hours automated)
   - Start workflow
   - Monitor progress
   - Handle any errors

2. **Quality validation** (1 hour)
   - Run validation scripts
   - Spot-check 20 random words
   - Fix any issues

3. **Upload to Firebase** (1 hour)
   - Download service account key
   - Dry run migration
   - Live upload
   - Verify data

### **NEXT WEEK**:

1. **Swift implementation** (Week 2-3)
   - Update models
   - Implement UI
   - Add audio playback
   - Test thoroughly

---

## 📞 Support Resources

### Documentation:
- ✅ [PERFECT_IMPLEMENTATION_COMPLETE.md](PERFECT_IMPLEMENTATION_COMPLETE.md) - Full overview
- ✅ [N8N_SINGLE_PROMPT.md](N8N_SINGLE_PROMPT.md) - N8N workflow guide
- ✅ [migrate_perfect_to_firebase.py](migrate_perfect_to_firebase.py) - Migration script

### Files:
- ✅ `Cambridge_Vocabulary_2018_PERFECT.csv` - Master data file (58 columns)
- ✅ `migrate_perfect_to_firebase.py` - Firebase upload script
- ✅ `N8N_SINGLE_PROMPT.md` - Complete N8N guide

### Cost References:
- GPT-4 Turbo: $0.03/1K input, $0.06/1K output
- Estimated: ~400 tokens/word × 1,414 words = $16.97
- Firebase: Free tier (under 50K reads/day)

---

## ✅ Sign-Off Checklist

**Before starting Phase 2**, confirm:
- ✅ `Cambridge_Vocabulary_2018_PERFECT.csv` exists (58 columns)
- ✅ `N8N_SINGLE_PROMPT.md` reviewed and understood
- ✅ `migrate_perfect_to_firebase.py` reviewed
- ✅ OpenAI account has $20+ credit
- ✅ Firebase project created
- ✅ Ready to spend 6-8 hours total

**Phase 1 Complete**: ✅ **YES - READY FOR PHASE 2**

---

**Last Updated**: November 13, 2025
**Status**: Phase 1 Complete, Ready for N8N Implementation
