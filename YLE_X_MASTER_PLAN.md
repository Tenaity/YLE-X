# YLE X - Master Plan & Roadmap 🚀

**Date**: November 8, 2025
**Status**: Strategic Planning Phase
**Target**: Vietnamese Students (Ages 7-12) Learning English

---

## 📊 PHASE AUDIT: Current State Analysis

### ✅ What We Have Built (Phase 1-5A Complete)

#### **Core Systems**
1. **Authentication** ✅
   - Firebase Auth (Email/Password, Google Sign-In)
   - User profiles with avatars
   - Onboarding flow

2. **Learning Paths** ✅
   - **Linear Path (Main Quest)**: 3 phases (Starters → Movers → Flyers)
   - **Sandbox Path (Side Quest)**: 7 islands with topics
   - Progress tracking per path

3. **AI Learning Features** ✅
   - Speech recognition (Apple Speech Framework)
   - Pronunciation scoring (Levenshtein algorithm)
   - Real-time feedback
   - IPA chart with 44 phonemes
   - Speaking exercises

4. **Gamification (Basic)** ✅
   - XP system (experience points)
   - Gems (currency)
   - Levels
   - Streaks (day counter)
   - Progress tracking

5. **Social Features (Partial)** ✅
   - Leaderboard structure
   - Friend system (basic)
   - User rankings

6. **UI/UX** ✅
   - Home dashboard
   - Profile view
   - Tab bar navigation
   - Animations & haptics

---

## 🎮 GAME ECONOMY DESIGN

### Current Problems to Solve:
1. **XP vs Points vs Gems** - Too many currencies, confusing
2. **Pet System** - Not integrated with progression
3. **No clear monetization** - How to make money?
4. **Repetition without rewards** - Why replay lessons?

---

## 💎 UNIFIED CURRENCY & REWARD SYSTEM (Proposed)

### **3-Tier Economy**

#### 1. **XP (Experience Points)** - The Core Metric
**Purpose**: Measure overall learning progress
**How to Earn**:
- Complete lessons: 10-50 XP (based on difficulty)
- Daily streak bonus: +20 XP/day
- Perfect score (100%): +10 XP bonus
- Boss battles: 100 XP
- Daily challenges: 30 XP

**What It Does**:
- Determines player **Level** (1-100)
- Unlocks new content at milestones
- Cannot be spent (permanent progress)

**Conversion**:
```
Level 1: 0 XP
Level 2: 100 XP
Level 3: 250 XP
Level 5: 500 XP
Level 10: 1,500 XP
...
Level 100: 100,000 XP (exponential curve)
```

---

#### 2. **Gems 💎** - Premium Currency
**Purpose**: Unlock premium content, cosmetics, power-ups
**How to Earn** (Free):
- Complete rounds: 2-5 gems
- Boss battles: 10 gems
- Daily login: 1 gem
- Weekly challenges: 5 gems
- Achievements: 3-10 gems
- Leaderboard top 10: 5-20 gems/week

**How to Buy** (Real Money - IAP):
```
Starter Pack:    50 gems  = $0.99  USD
Popular Pack:   150 gems  = $2.99  USD ⭐ Best Value
Premium Pack:   500 gems  = $7.99  USD
Mega Pack:    1,200 gems  = $14.99 USD
```

**What to Spend On**:
- Unlock Sandbox islands: 50-100 gems
- Unlock topics early: 20 gems
- Pet eggs: 30-100 gems
- Pet food/evolution: 10-50 gems
- Cosmetics (avatars, themes): 20-150 gems
- Power-ups (see below)
- Extra lives for retries: 5 gems

---

#### 3. **Hearts ❤️** - Energy System (NEW!)
**Purpose**: Limit daily free play, encourage IAP or skill improvement
**How It Works**:
- Start with 5 hearts/day
- Lose 1 heart on failed lesson (score < 60%)
- Keep hearts on passing (score ≥ 60%)
- Regenerate 1 heart every 30 minutes (max 5)
- Full refill at midnight

**How to Get More Hearts**:
- Wait for regeneration (free)
- Watch ad: +1 heart (max 3 ads/day)
- Spend 5 gems: +1 heart
- Spend 20 gems: Full refill (5 hearts)
- Premium subscription: Unlimited hearts

**Why This Works**:
- Casual players: Play 5-10 lessons/day for free
- Motivated students: Can watch ads or buy gems
- Creates urgency: "Don't waste hearts, study well!"
- Parents approve: Limits screen time naturally

---

## 🐾 PET SYSTEM - Companion & Motivation

### **Concept**: Your Learning Buddy
Vietnamese students love cute characters (see: LINE, Zalo stickers). Pets are **not just cosmetic** - they are **learning companions**.

### **Pet Mechanics**

#### **1. Getting Your First Pet**
- **Free Starter Pet** (choose 1 after onboarding):
  - 🐶 **Lucky** (Dog) - "Loyal learner, never gives up"
  - 🐱 **Mimi** (Cat) - "Curious and clever"
  - 🐰 **Bunny** (Rabbit) - "Fast learner, loves challenges"

- Each pet has unique **personality** affecting rewards:
  - Lucky: +5% XP on all lessons
  - Mimi: +3 gems on perfect scores
  - Bunny: +10% speed bonus in timed challenges

#### **2. Pet Progression**
Pets **level up** alongside the player:
```
Pet XP = Player XP / 2

Pet Level 1 → 10: Baby form (smol, cute)
Pet Level 11 → 30: Teen form (bigger, cooler)
Pet Level 31 → 60: Adult form (badass, awesome effects)
Pet Level 61+: Legendary form (glowing, particles, prestige)
```

#### **3. Pet Care = Engagement**
- **Feed Pet**: Costs 5 gems, gives +10% XP boost for 24h
- **Play with Pet**: Daily mini-game (vocabulary quiz), earn 1-3 gems
- **Pet Mood**:
  - Happy (daily login + complete 1 lesson): Normal bonuses
  - Sad (no login 2+ days): Bonuses disabled
  - Excited (7-day streak): Double bonuses!

#### **4. Pet Collection** (Gacha System)
- **Pet Eggs**: 30 gems (common), 100 gems (rare)
- **Drop Rates**:
  - Common (60%): Basic animals (dog, cat, rabbit, bird)
  - Rare (30%): Cool animals (dragon, phoenix, unicorn)
  - Legendary (10%): Vietnamese mythical creatures (Rồng, Kỳ Lân, Phượng Hoàng)

- **Why Collect?**:
  - Different bonuses (some pets give +gems, some +XP, some +hearts)
  - Show off in profile & leaderboard
  - Trade with friends (future feature)

---

## 🎯 MONETIZATION STRATEGY

### **Free-to-Play with Optional IAP (In-App Purchases)**

#### **Tier 1: Completely Free Experience**
What students can do **without paying**:
- ✅ Complete all Main Quest lessons (Starters → Flyers)
- ✅ Unlock 2 free Sandbox islands (Animals, Games)
- ✅ 1 free starter pet
- ✅ Daily 5 hearts (+ 3 from ads)
- ✅ Earn gems slowly from gameplay
- ✅ Basic avatars & themes
- ✅ Leaderboard participation

**Goal**: Provide **full educational value** for free. Parents are happy, kids learn.

---

#### **Tier 2: Premium Features (IAP)**

##### **A. One-Time Purchases (Gems)**
See currency system above. Main uses:
- Unlock Sandbox islands faster (instead of grinding gems)
- Buy pet eggs
- Get cosmetics (flex factor)

##### **B. Subscription: "YLE Premium" 🌟**
**Price**: 29,000 VND/month (~$1.19 USD) or 290,000 VND/year (~$11.90 USD)

**Benefits**:
- ✅ **Unlimited Hearts** - No energy restrictions
- ✅ **2x Gem Earnings** - Earn gems twice as fast
- ✅ **Exclusive Pet** - Premium-only legendary pet
- ✅ **Ad-Free Experience** - No video ads
- ✅ **Early Access** - New content 1 week early
- ✅ **Priority Support** - Help via chat
- ✅ **Family Sharing** - Up to 3 devices

**Target**: Parents who want their kids to study without limits (~$12/year is cheaper than 1 English workbook)

---

##### **C. Redo for Leaderboard (Competitive Feature)**
**Problem**: Student completes a lesson with 75%, but wants 100% for leaderboard ranking.

**Solutions**:
1. **Free Retry Once/Day**: First redo is free per lesson
2. **Gem Retry**: 3 gems per additional retry
3. **Premium Users**: 3 free retries/day

**Why This Works**:
- Encourages mastery (not just completion)
- Competitive students will spend gems
- Premium feels valuable

---

##### **D. Daily Lesson Cap (Optional Revenue)**
**Controversial but effective**:
- Free users: 10 lessons/day max (resets at midnight)
- Want to study more? Pay 10 gems for +5 lessons
- Premium users: Unlimited lessons

**Parent Perspective**:
- Actually **healthy** screen time limit
- Motivated students can "earn" extra lessons by doing well
- Creates perceived value for Premium

**Alternative (Less Aggressive)**:
- No lesson cap
- But bonus rewards (2x XP, gems) only for first 10 lessons/day
- After that, lessons still count but give base rewards

---

## 📖 STORY & GAMIFICATION

### **Core Narrative: The YLE Quest**

#### **Setting**: The Kingdom of Englishia 🏰
Long ago, the Kingdom of Englishia was filled with magic - the **Magic of Communication**. People spoke a universal language (English) that connected all lands.

But one day, an evil sorcerer **The Silencer** 🧙‍♂️ cast a spell that made people forget English. The kingdom fell into silence.

**Your Mission**: You are a young Hero chosen by the **Council of Wise Owls** 🦉 to restore the Magic of Communication by mastering English.

---

#### **The Three Phases = Three Kingdoms**

##### **Phase 1: Starters Kingdom** 🌱
- **Theme**: Farmlands & Villages (beginner, simple life)
- **Boss**: **Grammar Goblin** 👹 (tests basic grammar)
- **Companion**: Your starter pet joins you here
- **Story**: Learn the basics to communicate with villagers

##### **Phase 2: Movers Kingdom** 🏔️
- **Theme**: Mountains & Forests (adventure, exploration)
- **Boss**: **Vocabulary Vulture** 🦅 (tests word knowledge)
- **Story**: Venture into wild lands, learn from travelers

##### **Phase 3: Flyers Kingdom** 🏰
- **Theme**: Sky Castle (advanced, prestigious)
- **Boss**: **The Silencer** 🧙‍♂️ (final boss, comprehensive test)
- **Story**: Face the source of evil, restore communication magic

**After defeating The Silencer**:
- ✅ Unlock **Post-Game Content** (advanced lessons)
- ✅ Get **Legendary Hero Pet**
- ✅ Access **Mentor Mode** (help new players)

---

#### **Sandbox = The Exploration Guild**
Side quests that don't follow the main story:
- **Animals Island**: Study creatures from around the world
- **Games Island**: Learn through fun activities
- **IPA Mastery**: Train with the **Phonetic Monks** 🧘
- **Pronunciation Lab**: Practice with **Echo Spirits** 👻

Each island has its own **mini-story** and **island guardian** boss.

---

## 🗺️ FUTURE ROADMAP (Post-Launch)

### **Phase 6: Social Features** 🤝
**Timeline**: 2-3 months after launch

**Features**:
1. **Friend System**
   - Add friends via code or QR
   - See friends' progress
   - Send/receive gem gifts (1 gem/day)
   - Challenge friends to duels

2. **Leaderboard Expansion**
   - Daily/Weekly/All-Time rankings
   - School leaderboards (students from same school compete)
   - City/Province rankings (pride factor!)

3. **Guilds/Teams**
   - Create or join a team (max 10 members)
   - Team challenges (everyone contributes XP)
   - Team rewards (all members get gems)

---

### **Phase 7: Content Expansion** 📚
**Timeline**: 3-4 months

**New Learning Modes**:
1. **Story Mode**: Read English stories with comprehension quizzes
2. **Math in English**: Learn math concepts in English (bilingual)
3. **Science Explorer**: Fun science facts in English
4. **Comics & Animation**: Interactive English comics

**Why This Works**:
- Students learn English **through content they enjoy**
- Crossover: English becomes a **tool** not just a subject
- Parents see holistic education value

---

### **Phase 8: Multiplayer Features** 🎮
**Timeline**: 4-6 months

**Features**:
1. **Live Battles**: Real-time vocabulary/grammar duels
2. **Co-op Boss Raids**: Team up to defeat mega-bosses
3. **Trading System**: Trade pets, cosmetics with friends
4. **Tournaments**: Weekly competitions with prizes

---

### **Phase 9: AI Tutor & Personalization** 🤖
**Timeline**: 6-8 months

**AI Features**:
1. **Adaptive Difficulty**: AI adjusts lesson difficulty based on performance
2. **Weakness Detection**: AI identifies weak areas (e.g., user struggles with /th/ sound)
3. **Custom Study Plans**: AI generates personalized weekly plans
4. **Voice Chat Tutor**: Practice conversation with AI (ChatGPT-style)

**Why Later?**:
- Requires significant AI/ML development
- Need data from first users to train models
- Focus on core features first

---

### **Phase 10: Offline Mode & Accessibility** 📴
**Timeline**: 6-8 months

**Features**:
1. **Download Lessons**: Study offline (sync when online)
2. **Low-Data Mode**: Reduce internet usage
3. **Vietnamese Interface**: Full app translation
4. **Dark Mode**: Eye comfort

**Why Important**:
- Vietnam has areas with poor internet
- Data costs are a concern for some families
- Inclusivity for all economic backgrounds

---

## 🗄️ DATABASE DESIGN

### **Firestore Structure (Optimized)**

```
firestore
│
├── users/
│   ├── {userId}
│   │   ├── profile
│   │   │   ├── displayName: string
│   │   │   ├── email: string
│   │   │   ├── avatarUrl: string
│   │   │   ├── level: number
│   │   │   ├── totalXP: number
│   │   │   ├── createdAt: timestamp
│   │   │   └── lastLogin: timestamp
│   │   │
│   │   ├── economy
│   │   │   ├── gems: number
│   │   │   ├── hearts: number
│   │   │   ├── heartsLastRefill: timestamp
│   │   │   ├── gemsEarned: number (lifetime)
│   │   │   ├── gemsSpent: number (lifetime)
│   │   │   └── isPremium: boolean
│   │   │
│   │   ├── pets/
│   │   │   ├── {petId}
│   │   │   │   ├── name: string
│   │   │   │   ├── species: string
│   │   │   │   ├── rarity: string
│   │   │   │   ├── level: number
│   │   │   │   ├── xp: number
│   │   │   │   ├── mood: string
│   │   │   │   ├── lastFed: timestamp
│   │   │   │   ├── bonusType: string
│   │   │   │   ├── bonusValue: number
│   │   │   │   └── isActive: boolean
│   │   │
│   │   ├── progress
│   │   │   ├── currentPhase: string
│   │   │   ├── currentRound: number
│   │   │   ├── streak: number
│   │   │   ├── lastStudyDate: timestamp
│   │   │   ├── totalLessonsCompleted: number
│   │   │   ├── perfectScoresCount: number
│   │   │   ├── linearProgress: map
│   │   │   └── sandboxProgress: map
│   │   │
│   │   ├── achievements/
│   │   │   ├── {achievementId}
│   │   │   │   ├── name: string
│   │   │   │   ├── unlockedAt: timestamp
│   │   │   │   └── rewardClaimed: boolean
│   │   │
│   │   ├── friends/
│   │   │   ├── {friendId}
│   │   │   │   ├── addedAt: timestamp
│   │   │   │   └── lastInteraction: timestamp
│   │   │
│   │   └── transactions/
│   │       ├── {transactionId}
│   │       │   ├── type: string (gem_purchase, gem_spent, etc)
│   │       │   ├── amount: number
│   │       │   ├── reason: string
│   │       │   └── timestamp: timestamp
│
├── lessons/
│   ├── {levelId}
│   │   ├── {roundId}
│   │   │   ├── {lessonId}
│   │   │   │   ├── type: string
│   │   │   │   ├── content: map
│   │   │   │   ├── difficulty: number
│   │   │   │   ├── xpReward: number
│   │   │   │   ├── gemsReward: number
│   │   │   │   └── order: number
│
├── aiActivities/
│   ├── {levelId}
│   │   ├── {activityId}
│   │   │   ├── type: string
│   │   │   ├── targetText: string
│   │   │   ├── ipaGuide: string
│   │   │   ├── difficulty: number
│   │   │   ├── xpReward: number
│   │   │   ├── gemsReward: number
│   │   │   ├── pathCategory: string
│   │   │   └── order: number
│
├── leaderboards/
│   ├── global/
│   │   ├── daily/
│   │   │   ├── {date}
│   │   │   │   ├── topUsers: array
│   │   │   │   │   ├── userId: string
│   │   │   │   │   ├── displayName: string
│   │   │   │   │   ├── xp: number
│   │   │   │   │   ├── rank: number
│   │   │   │   │   └── petName: string
│   │   │
│   │   ├── weekly/
│   │   └── allTime/
│   │
│   ├── schools/
│   │   ├── {schoolId}
│   │   │   ├── topUsers: array
│   │
│   └── provinces/
│       ├── {provinceId}
│       │   ├── topUsers: array
│
├── pets/
│   ├── {petSpecies}
│   │   ├── name: string
│   │   ├── rarity: string
│   │   ├── baseStats: map
│   │   ├── evolutionStages: array
│   │   ├── bonusType: string
│   │   └── imageUrl: string
│
├── achievements/
│   ├── {achievementId}
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── icon: string
│   │   ├── gemReward: number
│   │   ├── xpReward: number
│   │   ├── requirement: map
│   │   └── rarity: string
│
└── config/
    ├── gameBalance
    │   ├── xpCurve: array
    │   ├── gemPrices: map
    │   ├── heartRegenMinutes: number
    │   └── dailyLessonCap: number
    │
    └── features
        ├── premiumEnabled: boolean
        ├── leaderboardEnabled: boolean
        ├── petsEnabled: boolean
        └── maintenanceMode: boolean
```

---

### **Key Database Optimizations**

#### 1. **Denormalization for Speed**
Instead of:
```javascript
// BAD: Multiple reads
user.pets[petId] → pets/{petId} → petSpecies/{species}
```

Do:
```javascript
// GOOD: Single read, duplicate essential data
user.pets[petId] = {
  name: "Lucky",
  species: "dog",
  bonusType: "xp",        // Duplicated from pets collection
  bonusValue: 1.05,       // Duplicated from pets collection
  level: 5
}
```

#### 2. **Indexed Fields for Leaderboard**
```javascript
// Create composite index on users collection
users: {
  index: ["totalXP", "desc", "lastUpdated", "desc"]
}
```

#### 3. **Sharded Counters for High Traffic**
For global stats (total users, lessons completed):
```
stats/
  ├── userCount_shard_0: 1234
  ├── userCount_shard_1: 1187
  ├── userCount_shard_2: 1056
  └── ... (sum all shards for total)
```

#### 4. **Batch Writes for Progress**
When user completes a lesson:
```javascript
batch.update(userDoc, {
  "economy.gems": increment(5),
  "economy.hearts": max(current, 5),
  totalXP: increment(30),
  "progress.totalLessonsCompleted": increment(1)
});

batch.set(lessonProgressDoc, {
  score: 95,
  completedAt: serverTimestamp(),
  attemptsCount: 1
});

await batch.commit(); // Atomic operation
```

---

## 🎯 PRIORITY FEATURES FOR LAUNCH (MVP)

### **Must-Have (Week 1-2)**
1. ✅ Fix all current bugs (Done!)
2. ✅ Hearts system implementation
3. ✅ Pet system (basic - starter pet only)
4. ✅ Retry with gems
5. ✅ Leaderboard (daily only)

### **Should-Have (Week 3-4)**
1. Premium subscription setup (Apple IAP)
2. Gem purchase IAP
3. Achievement system
4. Daily challenges
5. Polish UI/UX

### **Nice-to-Have (Week 5-6)**
1. Friend system (basic)
2. Weekly leaderboard
3. More pet species
4. Cosmetic shop
5. Beta testing with 50 students

---

## 💰 REVENUE PROJECTIONS (Rough Estimates)

### **Conservative Scenario (1,000 active users)**
- 5% buy gems: 50 users × $2.99/month = $149.50/month
- 10% subscribe Premium: 100 users × $1.19/month = $119/month
- **Total**: ~$268/month = **$3,216/year**

### **Optimistic Scenario (10,000 active users)**
- 5% buy gems: 500 users × $2.99/month = $1,495/month
- 10% subscribe Premium: 1,000 users × $1.19/month = $1,190/month
- **Total**: ~$2,685/month = **$32,220/year**

### **Target Scenario (50,000 active users by Year 2)**
- 5% buy gems: 2,500 users × $2.99/month = $7,475/month
- 10% subscribe Premium: 5,000 users × $1.19/month = $5,950/month
- **Total**: ~$13,425/month = **$161,100/year**

**Note**: These are rough estimates. Actual conversion depends on content quality, marketing, and user engagement.

---

## 🧠 KEY DESIGN PRINCIPLES

### **1. Education First, Game Second**
- Learning outcomes are priority #1
- Gamification should **motivate**, not **distract**
- Parents must see clear educational value

### **2. Fair Free-to-Play**
- 100% of educational content is accessible for free
- IAP is for **convenience** and **cosmetics**, not content
- No "pay-to-win" in educational progress

### **3. Culturally Relevant**
- Vietnamese students love: cute characters, collecting, competition
- Leaderboards tap into cultural value of academic achievement
- Story should feel familiar yet exciting

### **4. Sustainable Monetization**
- Premium at $1.19/month is cheaper than a snack
- Parents see value: "unlimited learning for less than a notebook"
- Gem prices are accessible to Vietnamese spending power

### **5. Data Privacy & Safety**
- COPPA compliant (users under 13)
- No personal data sold
- Parental controls available
- Safe social features (no chat, only emojis/reactions)

---

## 📝 NEXT STEPS (Action Items)

### **For Discussion**
1. **Story Approval**: Do you like the "Kingdom of Englishia" narrative?
2. **Currency Balance**: Is Hearts system too restrictive?
3. **Premium Pricing**: Is 29,000 VND/month right for Vietnam market?
4. **Pet Priority**: Should we focus on pets or other features first?
5. **Content Timeline**: How fast can we create lessons for all 60 rounds?

### **Technical Implementation**
1. Implement Hearts system
2. Build Pet database & UI
3. Setup Apple IAP (gems + subscription)
4. Create retry flow with gem payment
5. Enhance leaderboard with daily rankings

### **Content Creation**
1. Write story dialogue for each phase
2. Design boss battle challenges
3. Create pet artwork (or find artist)
4. Write achievement descriptions
5. Plan daily challenge pool (30-50 challenges)

---

## 🤔 Questions for You

1. **Market**: Do you want to focus on Vietnam only, or Southeast Asia?
2. **Age Range**: Confirm 7-12 years old, or expand to 7-15?
3. **School Integration**: Should we pitch this to schools as a classroom tool?
4. **Marketing Budget**: Do you have budget for user acquisition ads?
5. **Team**: Are you solo, or do you have designers/content creators?
6. **Timeline**: When do you want to launch publicly?

---

**End of Master Plan Document**

---

**Status**: Ready for Review & Discussion
**Next**: Your feedback → Iterate → Implement Priority Features

