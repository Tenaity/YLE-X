# Phase 2 - Quick Reference Card

## 🎮 How to Access Each Feature

### From Profile View (Main Entry Point)

```
Profile Tab → Scroll down to "Gamification" section
```

Choose one of 4 cards:

| Card | Feature | Function |
|------|---------|----------|
| ⭐ My Level | UserLevelView | Track level (1-100) and XP progress |
| 🏆 Badges | BadgeGalleryView | View unlocked and locked achievements |
| 🎯 Missions | MissionsView | Complete daily/weekly/skill missions |
| 🐉 Pet | PetCompanionView | Adopt and care for virtual pet |

---

## 📊 Level System (1-100)

| Level Range | Title | Icon |
|-------------|-------|------|
| 1-10 | Beginner | 🌱 |
| 11-25 | Learner | 📚 |
| 26-50 | Scholar | 🎓 |
| 51-75 | Expert | ⚡ |
| 76-99 | Master | 👑 |
| 100 | Grand Master | 👑✨ |

**XP Thresholds:**
- Level 1: 0 XP
- Level 2: 100 XP
- Level 3: 250 XP
- Level 4: 450 XP
- ...continues with increasing requirements

---

## 🏆 Badge System

**4 Rarity Levels:**

| Rarity | Color | Stars | Emoji |
|--------|-------|-------|-------|
| Common | Green | ⭐ | 🌱 |
| Rare | Blue | ⭐⭐ | 💫 |
| Epic | Purple | ⭐⭐⭐ | 🔮 |
| Legendary | Gold | ⭐⭐⭐⭐ | 👑 |

**Sample Badges:**
- 🎓 First Step - Complete 1 lesson (Common, 10 XP)
- 📚 Word Master - Vocabulary exercises (Rare, 25 XP)
- 🔥 7 Day Streak - Maintain 7-day streak (Epic, 50 XP)
- 👑 Grand Master - Reach level 100 (Legendary, 500 XP)

---

## 🎯 Mission Types

### Daily Missions (Reset Daily)
- 📚 Complete 1 lesson → 25 XP
- 🎯 Complete 5 exercises → 40 XP
- 🎓 Score 80%+ on quiz → 35 XP

### Weekly Missions (Reset Weekly)
- 📖 Complete 10 lessons → 150 XP
- 💪 Master 5 topics → 120 XP
- 🏅 Earn 3 badges → 100 XP

### Skill-Based Missions
- Vocabulary focused
- Grammar focused
- Pronunciation focused

**Progress Indicators:**
- 0-49% → Progress bar (blue)
- 50-99% → Progress bar (yellow)
- 100% → Gift icon (clickable)
- Completed → Checkmark ✓

---

## 🐉 Pet System

### 5 Pet Types

| Pet | Emoji | Description |
|-----|-------|-------------|
| Dragon | 🐉 | Mythical and powerful |
| Cat | 🐱 | Cute and curious |
| Fox | 🦊 | Smart and clever |
| Unicorn | 🦄 | Magical and rare |
| Phoenix | 🔥 | Legendary and majestic |

### Pet Stats

| Stat | Range | Effects |
|------|-------|---------|
| **Health** | 0-100% | Decreases daily, fed with Feed button |
| **Happiness** | 0-100% | Decreases daily, increases with Play button |
| **Level** | 1-5 | Increases with total care (feed + play) |
| **Experience** | Unlimited | Accumulates, resets per level |

### Pet Actions

| Action | Button | Effect | Cooldown |
|--------|--------|--------|----------|
| Feed | 🍴 | +10 Health | ~2 hours |
| Play | 🎮 | +10 Happiness | ~2 hours |
| View Stats | Display | See health/happiness/level | None |

---

## 📱 Navigation Map

```
YLE X App
│
├─ Home Tab
│  ├─ Lessons
│  ├─ Exercises
│  └─ Progress
│
├─ Learn Tab
│  ├─ Lesson List
│  └─ Exercise View
│
├─ Leaderboard Tab
│  └─ Rankings
│
├─ Profile Tab ⭐ (Gamification Access)
│  ├─ User Info
│  ├─ Stats
│  ├─ Achievements (Phase 1)
│  │
│  └─ 🎮 Gamification Section (NEW)
│     ├─ ⭐ My Level → UserLevelView
│     ├─ 🏆 Badges → BadgeGalleryView
│     ├─ 🎯 Missions → MissionsView
│     └─ 🐉 Pet → PetCompanionView
│
└─ Settings Tab
   ├─ Account
   ├─ Notifications
   └─ About
```

---

## 🎮 Common Actions

### To Unlock a Badge
1. Complete the requirement (e.g., complete 1 lesson for "First Step")
2. Go to BadgeGalleryView
3. Badge automatically appears in unlocked section

### To Complete a Mission
1. Go to MissionsView
2. Complete the required action (e.g., complete lesson)
3. Progress bar updates
4. When at 100%, gift icon appears
5. Click gift icon to claim reward

### To Level Up
1. Complete lessons/missions to earn XP
2. Each action awards XP to your total
3. When XP reaches next level threshold, level increases automatically
4. Level appears in UserLevelView

### To Care for Pet
1. Go to PetCompanionView
2. Click "Feed" to increase health
3. Click "Play" to increase happiness
4. Check stats to see current health/happiness
5. Return daily to maintain streak

---

## 🔑 Key Concepts

### XP (Experience Points)
- Earned from: Lessons, missions, badges
- Used for: Level progression
- Display: In UserLevelView and stats
- Max: No limit (but levels cap at 100)

### Streak (Day Streak)
- Counts: Consecutive days of activity
- Reset: If no activity for 1 day
- Reward: Multipliers and special badges at 7, 30, 365 days
- Display: In MissionsView and UserLevelView

### Firebase Persistence
- All data saved to Firestore in real-time
- Syncs across devices
- Survives app restart
- No local caching (always fresh from server)

---

## ⚡ Quick Stats

| Metric | Value |
|--------|-------|
| Max Level | 100 |
| XP for Level 100 | ~340,000 |
| Total Badges | 9 |
| Pet Types | 5 |
| Daily Missions | 3 |
| Weekly Missions | 3 |
| Pet Max Level | 5 |
| Health/Happiness Range | 0-100% |

---

## 🎯 Getting Started (First 5 Minutes)

1. **Login** → Open YLE X app
2. **Navigate** → Tap Profile tab
3. **Adopt Pet** → Click "Pet" card → Select pet → Name it → "Adopt"
4. **Check Level** → Click "My Level" card
5. **View Missions** → Click "Missions" card
6. **See Badges** → Click "Badges" card

---

## 📲 UI Patterns

### Animations
- **Entrance**: Fade in + offset (staggered)
- **Transitions**: Smooth (appBouncy, appSmooth)
- **Interactions**: Scale effects on buttons

### Colors
- **Primary**: .appPrimary (Purple)
- **Accent**: .appAccent (Cyan/Blue)
- **Success**: .appSuccess (Green)
- **Warning**: .appWarning (Yellow/Orange)
- **Error**: .appError (Red)
- **Badge Gold**: .appBadgeGold (Gold)

### Feedback
- **Haptic**: Light tap on interaction
- **Success**: Strong haptic + visual change
- **Progress**: Animated bar fill

---

## 🆘 Common Questions

**Q: Why is my level not increasing?**
A: Levels only increase when XP crosses the threshold for the next level. Check UserLevelView to see current XP progress.

**Q: Can I have multiple pets?**
A: Currently, you can adopt one pet. Caring for it increases its level.

**Q: How often can I feed/play with my pet?**
A: Actions have a cooldown (~2 hours). Check last action timestamp.

**Q: Are badges permanent?**
A: Yes, once unlocked, they're always in your collection. They don't disappear.

**Q: Can I change my pet's name?**
A: Currently, no. If needed, adopt a new pet (deletes old one).

**Q: Do missions reset?**
A: Daily missions reset at midnight. Weekly missions reset on Sundays.

**Q: What happens if I don't play for a day?**
A: Your streak resets. Caring for pet stats (health/happiness) decreases if not maintained.

---

## 📊 Data Structure (Developer Reference)

### User Level Document
```
userLevels/{userId}
├─ userId: String
├─ currentLevel: Int (1-100)
├─ totalXP: Int
├─ streakDays: Int
├─ lastLoginDate: Timestamp
├─ badgesUnlocked: [String]
├─ missionProgress: {
│  └─ missionId: {
│     ├─ completed: Int
│     ├─ total: Int
│     ├─ isCompleted: Bool
│     └─ claimedAt: Timestamp
│  }
└─ petId: String
```

### Virtual Pet Document
```
virtualPets/{userId}
├─ userId: String
├─ type: String (enum: dragon, cat, fox, unicorn, phoenix)
├─ name: String
├─ level: Int (1-5)
├─ happiness: Int (0-100)
├─ health: Int (0-100)
├─ experience: Int
├─ adoptedAt: Timestamp
├─ lastFedAt: Timestamp (nullable)
└─ lastPlayedAt: Timestamp (nullable)
```

---

## ✨ Tips & Tricks

1. **Complete lessons regularly** → Earn XP and unlock badges
2. **Do missions daily** → Build streak and earn extra XP
3. **Feed and play pet daily** → Keep stats high and increase level
4. **Check back often** → New missions appear, stats change
5. **Share progress** → Show off your level and badges in leaderboard

---

**Version**: 1.0
**Last Updated**: November 7, 2025
**Status**: ✅ All Features Working
