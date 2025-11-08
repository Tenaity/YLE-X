# Phase 3A - Firebase Setup Guide

## 🚀 Quick Setup (5 minutes)

### Step 1: Add weeklyXP Field to Existing Users

**Option A: Firebase Console (Manual)**

1. Go to Firebase Console → Firestore Database
2. Navigate to `userLevels` collection
3. For each user document, add:
   ```json
   {
     "weeklyXP": 0,
     "username": "User1",
     "avatar": "👤"
   }
   ```

**Option B: Cloud Function (Automatic)**

Create a one-time migration function:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.migrateToWeeklyXP = functions.https.onRequest(async (req, res) => {
  try {
    const usersSnapshot = await admin.firestore()
      .collection('userLevels')
      .get();

    const batch = admin.firestore().batch();
    let count = 0;

    usersSnapshot.forEach(doc => {
      const data = doc.data();

      batch.update(doc.ref, {
        weeklyXP: 0,
        username: data.username || `User${count + 1}`,
        avatar: data.avatar || '👤'
      });

      count++;
    });

    await batch.commit();

    res.json({
      success: true,
      message: `Migrated ${count} users successfully`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});
```

Then call: `https://YOUR-PROJECT.cloudfunctions.net/migrateToWeeklyXP`

---

### Step 2: Create Firestore Indexes

Required for efficient leaderboard queries:

**Firebase Console → Firestore → Indexes → Composite**

1. **Weekly Leaderboard Index**:
   - Collection: `userLevels`
   - Fields:
     - `weeklyXP` (Descending)
   - Query scope: Collection

2. **All-Time Leaderboard Index**:
   - Collection: `userLevels`
   - Fields:
     - `totalXP` (Descending)
   - Query scope: Collection

**Or use automatic indexing**:
Just run the app - Firebase will suggest indexes when you query.

---

### Step 3: Update XP Award Logic

Modify your existing XP reward functions to update **both** fields:

```swift
// In GamificationService.swift or LessonService.swift
func addXP(_ amount: Int, to userId: String) async throws {
    let userRef = db.collection("userLevels").document(userId)

    try await userRef.updateData([
        "totalXP": FieldValue.increment(Int64(amount)),
        "weeklyXP": FieldValue.increment(Int64(amount))  // ⭐ NEW
    ])

    // Reload user level
    if let userLevel = try? await userRef.getDocument().data(as: UserLevel.self) {
        self.userLevel = userLevel
    }
}
```

**Update in**:
- Mission completion rewards
- Lesson completion rewards
- Badge unlocking rewards
- Pet interaction rewards

---

### Step 4: Schedule Weekly Reset (Optional - Production)

**Cloud Function to reset weekly XP every Monday:**

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Runs every Monday at 00:00 UTC
exports.resetWeeklyLeaderboard = functions.pubsub
  .schedule('0 0 * * 1')
  .timeZone('UTC')
  .onRun(async (context) => {
    console.log('Starting weekly leaderboard reset...');

    try {
      const usersSnapshot = await admin.firestore()
        .collection('userLevels')
        .get();

      const batchSize = 500;
      let batch = admin.firestore().batch();
      let operationCount = 0;
      let totalCount = 0;

      for (const doc of usersSnapshot.docs) {
        batch.update(doc.ref, { weeklyXP: 0 });
        operationCount++;
        totalCount++;

        // Firestore batch limit is 500
        if (operationCount === batchSize) {
          await batch.commit();
          batch = admin.firestore().batch();
          operationCount = 0;
        }
      }

      // Commit remaining operations
      if (operationCount > 0) {
        await batch.commit();
      }

      console.log(`Weekly reset complete: ${totalCount} users updated`);
      return null;
    } catch (error) {
      console.error('Weekly reset failed:', error);
      throw error;
    }
  });
```

**Deploy**:
```bash
firebase deploy --only functions:resetWeeklyLeaderboard
```

---

### Step 5: Create Test Data (Development Only)

```javascript
const admin = require('firebase-admin');
admin.initializeApp();

async function createTestLeaderboard() {
  const db = admin.firestore();
  const batch = db.batch();

  const avatars = ['👤', '🧑', '👨', '👩', '🧒', '👶', '🧓', '👴', '👵'];
  const usernames = [
    'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank', 'Grace', 'Henry',
    'Ivy', 'Jack', 'Kelly', 'Liam', 'Mia', 'Noah', 'Olivia', 'Peter',
    'Quinn', 'Rachel', 'Sam', 'Tina', 'Uma', 'Victor', 'Wendy', 'Xander',
    'Yara', 'Zack'
  ];

  for (let i = 1; i <= 100; i++) {
    const userId = `test_user_${i.toString().padStart(3, '0')}`;
    const username = i <= usernames.length
      ? usernames[i - 1]
      : `TestUser${i}`;

    const userData = {
      userId: userId,
      username: username,
      avatar: avatars[i % avatars.length],
      currentLevel: Math.max(1, Math.floor(50 - (i / 2))),
      totalXP: Math.max(100, 10000 - (i * 80)),
      weeklyXP: Math.max(50, 1000 - (i * 8)),
      streakDays: Math.floor(Math.random() * 100),
      badgesUnlocked: [],
      missionProgress: {},
      petId: null,
      lastLoginDate: admin.firestore.Timestamp.now()
    };

    const userRef = db.collection('userLevels').doc(userId);
    batch.set(userRef, userData);

    // Commit every 500 operations (Firestore limit)
    if (i % 500 === 0) {
      await batch.commit();
    }
  }

  // Commit remaining
  await batch.commit();
  console.log('✅ Created 100 test users for leaderboard');
}

createTestLeaderboard()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('Error:', err);
    process.exit(1);
  });
```

**Run**:
```bash
node createTestData.js
```

---

## 📊 Sample Firebase Structure

### userLevels/{userId}

```json
{
  "userId": "user123",
  "username": "Alice",
  "avatar": "👤",
  "currentLevel": 15,
  "totalXP": 5280,
  "weeklyXP": 450,
  "streakDays": 12,
  "badgesUnlocked": ["badge_first_lesson", "badge_7_day_streak"],
  "missionProgress": {
    "mission_daily_1": {
      "missionId": "mission_daily_1",
      "completed": 1,
      "total": 1,
      "isCompleted": true,
      "claimedAt": "2025-11-07T10:30:00Z"
    }
  },
  "petId": "dragon_001",
  "lastLoginDate": "2025-11-07T10:00:00Z"
}
```

---

## 🔍 Testing Queries

### Test Weekly Leaderboard Query

```javascript
const top100 = await db.collection('userLevels')
  .orderBy('weeklyXP', 'desc')
  .limit(100)
  .get();

console.log('Weekly Top 3:');
top100.docs.slice(0, 3).forEach((doc, i) => {
  const data = doc.data();
  console.log(`${i + 1}. ${data.username} - ${data.weeklyXP} XP`);
});
```

### Test All-Time Leaderboard Query

```javascript
const allTime = await db.collection('userLevels')
  .orderBy('totalXP', 'desc')
  .limit(100)
  .get();

console.log('All-Time Top 3:');
allTime.docs.slice(0, 3).forEach((doc, i) => {
  const data = doc.data();
  console.log(`${i + 1}. ${data.username} - ${data.totalXP} XP`);
});
```

### Find User Rank

```javascript
async function getUserRank(userId, type = 'weekly') {
  const field = type === 'weekly' ? 'weeklyXP' : 'totalXP';

  // Get user's XP
  const userDoc = await db.collection('userLevels').doc(userId).get();
  const userXP = userDoc.data()[field];

  // Count users with higher XP
  const higherCount = await db.collection('userLevels')
    .where(field, '>', userXP)
    .get();

  return higherCount.size + 1;
}

const rank = await getUserRank('user123', 'weekly');
console.log(`User rank: #${rank}`);
```

---

## 🚨 Troubleshooting

### Issue: "Missing index" error

**Solution**:
1. Click the link in error message
2. Firebase Console will open index creation page
3. Click "Create Index"
4. Wait 2-5 minutes for index to build

### Issue: Empty leaderboard

**Checklist**:
- [ ] Do users have `weeklyXP` field?
- [ ] Do users have `username` field?
- [ ] Do users have `avatar` field?
- [ ] Is Firebase Auth working?
- [ ] Check console for errors

### Issue: Current user not highlighted

**Cause**: `isCurrentUser` flag not set correctly

**Solution**: Verify userId comparison in LeaderboardService:
```swift
let currentUserId = Auth.auth().currentUser?.uid
// ...
isCurrentUser: userId == currentUserId
```

### Issue: Slow query performance

**Solutions**:
1. Verify indexes are built (green checkmark in Console)
2. Limit to 100 users (already implemented)
3. Use pagination if needed (future enhancement)

---

## 📈 Performance Tips

### 1. Limit Query Results
✅ Already implemented: `.limit(to: 100)`

### 2. Use Indexes
✅ Required indexes documented above

### 3. Cache Data
```swift
// Optional: Add caching to LeaderboardService
private var cachedLeaderboard: [LeaderboardEntry] = []
private var lastFetch: Date?

func fetchWithCache() async throws {
    if let lastFetch = lastFetch,
       Date().timeIntervalSince(lastFetch) < 60 {
        // Use cached data if less than 60 seconds old
        return
    }

    try await fetchWeeklyLeaderboard()
    lastFetch = Date()
}
```

### 4. Pagination (Future)
```swift
func fetchNextPage(after lastEntry: LeaderboardEntry) async throws {
    let snapshot = try await db.collection("userLevels")
        .order(by: "weeklyXP", descending: true)
        .start(after: [lastEntry.xp])
        .limit(to: 50)
        .getDocuments()
}
```

---

## ✅ Verification Checklist

- [ ] `weeklyXP` field exists on all users
- [ ] `username` field exists on all users
- [ ] `avatar` field exists on all users
- [ ] Indexes created for `weeklyXP` and `totalXP`
- [ ] XP award logic updates both fields
- [ ] Test users created (if development)
- [ ] Weekly reset function deployed (if production)
- [ ] Leaderboard displays correctly in app
- [ ] Current user highlighted
- [ ] Tab switching works
- [ ] Pull-to-refresh works

---

## 🎉 Ready to Test!

Once setup is complete, test the leaderboard:

1. **Open YLE X app**
2. **Tap Leaderboard tab** (or Profile → Leaderboard)
3. **Verify**:
   - Top 3 podium displays
   - Rankings show correctly
   - Current user highlighted (if in top 100)
   - Tab switching works
   - Pull-to-refresh updates data

---

**Setup Time**: ~5-10 minutes
**Status**: Ready for Firebase configuration
**Next**: Test with real or sample data

