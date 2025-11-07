# Phase 2 - Test Setup Instructions

## 🚀 Quick Setup for Testing

### Step 1: Verify Firebase Configuration

```bash
# Check if Firestore is enabled
1. Go to Firebase Console
2. Project: YLE X
3. Navigate to Firestore Database
4. Verify these collections exist:
   - badges
   - missions
   - petTypes
   - gamificationConfig
   - userLevels (empty, created per user)
   - virtualPets (empty, created per user)
```

### Step 2: Create Test User

Option A: **Use existing account**
```
Email: test@example.com
Password: Test@123456
```

Option B: **Create new test account**
1. Open YLE X app
2. Sign up with:
   - Email: test-phase2-[today's date]@example.com
   - Password: Test@123456
3. Verify email if required

### Step 3: Import Test Data (If Not Done)

If data hasn't been imported yet, run this in Firebase Console:

**Upload badges to `/badges` collection:**
```javascript
{
  "badge_first_lesson": {
    "id": "badge_first_lesson",
    "name": "First Step",
    "description": "Complete your first lesson",
    "icon": "star",
    "emoji": "🎓",
    "rarity": "common",
    "color": "#4CAF50",
    "requirement": {
      "type": "lessons_completed",
      "value": 1
    },
    "xpReward": 10
  },
  // ... (add more badges from FIREBASE_PHASE2_DATA.json)
}
```

**Upload missions to `/missions` collection:**
```javascript
{
  "mission_daily_1": {
    "id": "mission_daily_1",
    "title": "Daily Learner",
    "description": "Complete 1 lesson today",
    "icon": "book",
    "emoji": "📚",
    "difficulty": "easy",
    "category": "daily",
    "resetDaily": true,
    "requirement": {
      "type": "lessons_completed",
      "value": 1
    },
    "reward": {
      "xp": 25,
      "coins": 10
    },
    "active": true,
    "createdAt": "2025-11-07T00:00:00Z"
  },
  // ... (add more missions)
}
```

---

## 🧪 Test Cases by Feature

### Test 1: Launch App & Check Dashboard
```
1. Open YLE X app
2. Log in with test account
3. Navigate to Profile tab
4. Verify Gamification section is visible
5. Should show 4 cards: Level, Badges, Missions, Pet
```

**Expected Result**: ✅ Gamification section visible with all 4 cards

---

### Test 2: Check Initial Level
```
1. From Profile, click "My Level" card
2. Observe the level display
```

**Expected Result**:
- ✅ Shows "Level 1"
- ✅ XP: 0/100
- ✅ Animated progress ring at 0%
- ✅ Status: "Beginner"

---

### Test 3: Adopt Your First Pet
```
1. From Profile, click "Pet" card
2. See adoption modal with 5 pet types
3. Select a pet (e.g., Dragon 🐉)
4. Enter pet name (e.g., "Fluffy")
5. Click "Adopt Dragon"
```

**Expected Result**:
- ✅ Modal closes
- ✅ Pet view shows selected pet
- ✅ Pet stats visible (Health: 50, Happiness: 50)
- ✅ Pet saved to Firebase at `virtualPets/{userId}`

---

### Test 4: Interact with Pet
```
1. In Pet view, tap the dragon emoji multiple times
2. Click "Feed" button (fork & knife)
3. Wait a moment, check Health stat
4. Click "Play" button (gamepad)
5. Wait a moment, check Happiness stat
```

**Expected Result**:
- ✅ Pet scales up with animation on tap
- ✅ Health increases after feed (visual + Firebase)
- ✅ Happiness increases after play (visual + Firebase)
- ✅ Stats update smoothly

---

### Test 5: View Badges
```
1. From Profile, click "Badges" card
2. Observe unlocked/locked badges
3. Click on an unlocked badge
4. See badge details modal
5. Close modal and return to gallery
```

**Expected Result**:
- ✅ Badge gallery loads with animation
- ✅ Shows correct locked/unlocked count
- ✅ Badge details modal shows: name, description, rarity, XP reward
- ✅ Navigation works smoothly

---

### Test 6: Complete Daily Mission
```
1. From Profile, click "Missions" card
2. Click "Daily" tab
3. Find a mission with progress < 100%
4. If mission is not completable through UI, manually update:
   - Go to Firebase Console
   - Find `userLevels/{userId}/missionProgress`
   - Set completed = requirement.value
   - Set isCompleted = true
5. Refresh view or navigate away and back
6. Click gift icon on completed mission
```

**Expected Result**:
- ✅ Mission shows 100% progress
- ✅ Gift icon appears when at 100%
- ✅ Clicking gift updates mission to completed
- ✅ Checkmark shows instead of progress
- ✅ XP reward reflected in totalRewardXP

---

### Test 7: Check Level Up
```
1. Manually increase totalXP to cross next level threshold:
   - Go to Firebase Console
   - Find `userLevels/{userId}`
   - Change totalXP from 0 to 150 (crosses Level 2 threshold)
2. Refresh UserLevelView or navigate away and back
3. Check if level updated
```

**Expected Result**:
- ✅ Level changed to 2
- ✅ XP progress bar updates
- ✅ Progress ring animates
- ✅ Level title might change (depends on thresholds)

---

### Test 8: Mission Streak
```
1. In Firebase Console, find `userLevels/{userId}`
2. Set streakDays = 7
3. Go to MissionsView
4. Check streak display in header
5. In UserLevelView, check Streak card
```

**Expected Result**:
- ✅ Streak shows "7" in MissionsView
- ✅ Streak shows "7 Day Streak" in UserLevelView
- ✅ Flame icon displays (🔥)
- ✅ Milestone notification shows for 7+ days

---

## 🔍 Database Verification Checklist

After testing, verify in Firebase Console:

- [ ] `userLevels/{userId}` document exists with:
  - `userId`: string
  - `currentLevel`: number
  - `totalXP`: number
  - `streakDays`: number
  - `badgesUnlocked`: array
  - `missionProgress`: object
  - `petId`: string (if pet adopted)

- [ ] `virtualPets/{userId}` document exists with:
  - `userId`: string
  - `type`: string (dragon, cat, fox, etc.)
  - `name`: string (user's pet name)
  - `level`: number (1-5)
  - `health`: number (0-100)
  - `happiness`: number (0-100)
  - `experience`: number
  - `adoptedAt`: timestamp
  - `lastFedAt`: timestamp (after feeding)
  - `lastPlayedAt`: timestamp (after playing)

- [ ] `missions` collection has documents with proper structure
- [ ] `badges` collection has documents with proper structure

---

## 🐛 Troubleshooting

### Issue: Views load blank/no data

**Solution:**
1. Check Firebase connection
2. Verify user is authenticated
3. Check console for errors (Xcode)
4. Ensure data exists in Firebase for the current user

### Issue: Pet not saving

**Solution:**
1. Verify Firebase authentication is working
2. Check Firebase security rules allow writes
3. Look for error logs in Xcode console
4. Manually verify document in Firebase Console

### Issue: Missions not updating

**Solution:**
1. Force quit app and reopen
2. Check if updateMissionProgress() is being called
3. Verify user ID is correct
4. Check Firestore security rules

### Issue: XP not increasing

**Solution:**
1. Ensure totalXP field exists in userLevels document
2. Check if addXP() method is being called
3. Verify type is number, not string

---

## ✅ Sign-Off for Setup

- [ ] Firebase configured and verified
- [ ] Test user created
- [ ] Test data imported (or manually created)
- [ ] All collections verified in Console
- [ ] Ready to begin manual testing

**Date Setup Completed**: _______________
**Tester**: _______________

---

## 📞 Need Help?

If stuck during testing:
1. Check this guide again
2. Check PHASE2_TESTING_GUIDE.md
3. Review Firebase Console for data issues
4. Check Xcode console for error messages
5. Verify network connection
