# Phase 3 - Leaderboard & Social Features Roadmap

## 🎯 Overview

**Goal**: Build competitive and collaborative social features to increase user engagement and motivation through friendly competition and community interaction.

**Timeline**: ~10-15 hours development
**Priority**: High (enhances retention and engagement)

---

## 📋 Feature Breakdown

### Part A: Leaderboard System 🏆

#### 1. **Global Leaderboard**
- [ ] **Weekly Leaderboard**
  - Top 100 users ranked by XP earned this week
  - Resets every Monday at midnight
  - Shows: Rank, Avatar, Name, XP, Level
  - Current user highlight (gold background)

- [ ] **All-Time Leaderboard**
  - Top 100 users ranked by total XP
  - Permanent ranking
  - Shows: Rank, Avatar, Name, Total XP, Level

- [ ] **Friends Leaderboard** (Phase 3B)
  - Only shows friends
  - Same metrics as global
  - More intimate competition

#### 2. **Leaderboard UI Components**
- [ ] **LeaderboardView** - Main view with tab switching
- [ ] **LeaderboardRow** - User rank card component
- [ ] **LeaderboardHeader** - Top 3 podium display
- [ ] **LeaderboardFilters** - Weekly/All-Time/Friends tabs
- [ ] **CurrentUserBanner** - "Your Rank" sticky banner

#### 3. **Leaderboard Data Structure**
```swift
struct LeaderboardEntry {
    let userId: String
    let username: String
    let avatar: String // emoji or URL
    let rank: Int
    let xp: Int // weekly or total
    let level: Int
    let streakDays: Int
    let badgeCount: Int
}
```

#### 4. **Firebase Integration**
- [ ] Cloud Functions for leaderboard calculation
- [ ] Scheduled weekly reset (Cloud Scheduler)
- [ ] Real-time leaderboard updates
- [ ] Efficient querying (top 100 only)
- [ ] User rank lookup optimization

---

### Part B: Social Features 👥

#### 1. **Friend System**
- [ ] **Add Friends**
  - Search by username/email
  - Send friend request
  - Accept/Decline requests

- [ ] **Friend List**
  - View all friends
  - See friend status (online, last active)
  - Friend activity feed
  - Remove friend option

- [ ] **Friend Requests**
  - Pending requests inbox
  - Notification badge count
  - Quick accept/decline

#### 2. **User Profile (Public)**
- [ ] **ProfileCard**
  - Avatar/emoji
  - Username
  - Level & XP
  - Badges unlocked
  - Current streak
  - Total lessons completed

- [ ] **Achievements Showcase**
  - Top 6 badges displayed
  - Rarity-based sorting
  - "View All" link to badge gallery

- [ ] **Activity Stats**
  - Lessons this week
  - XP earned this week
  - Current streak
  - Join date

#### 3. **Challenge System**
- [ ] **1v1 Challenges**
  - Challenge friend to complete X lessons
  - Time limit (24h, 7 days, 30 days)
  - Winner gets bonus XP
  - Challenge status tracking

- [ ] **Challenge Types**
  - Most lessons completed
  - Highest XP earned
  - Longest streak maintained
  - Most badges unlocked

#### 4. **Activity Feed**
- [ ] **Friend Activity**
  - "John completed Level 5!"
  - "Sarah unlocked 'Master Badge'"
  - "Mike reached 30-day streak!"
  - Like/Comment system (optional)

---

## 🗂️ File Structure

```
Features/
├── Social/
│   ├── Models/
│   │   ├── Friend.swift
│   │   ├── FriendRequest.swift
│   │   ├── Challenge.swift
│   │   └── ActivityFeedItem.swift
│   │
│   ├── Services/
│   │   ├── SocialService.swift
│   │   └── LeaderboardService.swift
│   │
│   └── Views/
│       ├── LeaderboardView.swift
│       ├── LeaderboardRow.swift
│       ├── LeaderboardPodium.swift
│       ├── FriendsListView.swift
│       ├── FriendRequestsView.swift
│       ├── UserProfileView.swift
│       ├── AddFriendView.swift
│       ├── ChallengeView.swift
│       └── ActivityFeedView.swift

Core/
└── Models/
    └── Social.swift (shared social models)
```

---

## 🎨 UI/UX Design

### LeaderboardView Layout
```
┌─────────────────────────────┐
│   🏆 Leaderboard            │
├─────────────────────────────┤
│ [Weekly] [All-Time] [Friends]│ ← Tabs
├─────────────────────────────┤
│   Podium (Top 3)            │
│     🥈  🥇  🥉              │
│     #2  #1  #3              │
├─────────────────────────────┤
│ 📊 Your Rank: #42           │ ← Sticky banner
├─────────────────────────────┤
│ 4.  👤 User4    1,250 XP    │
│ 5.  👤 User5    1,180 XP    │
│ 6.  👤 User6    1,150 XP    │
│ ...                         │
│ 42. 👤 YOU      850 XP      │ ← Highlighted
│ ...                         │
│ 100.👤 User100  200 XP      │
└─────────────────────────────┘
```

### Friends List Layout
```
┌─────────────────────────────┐
│   👥 Friends (12)           │
├─────────────────────────────┤
│ [All] [Online] [Requests]   │ ← Filters
├─────────────────────────────┤
│ 🔍 Search friends...        │
├─────────────────────────────┤
│ 👤 Sarah - Level 15         │
│    🟢 Online • Streak: 12   │
│    [Challenge] [View]       │
├─────────────────────────────┤
│ 👤 Mike - Level 22          │
│    ⚪ 2h ago • Streak: 45   │
│    [Challenge] [View]       │
├─────────────────────────────┤
│ ...                         │
└─────────────────────────────┘
```

---

## 🔧 Technical Implementation

### Phase 3A: Leaderboard (Priority 1)

#### Step 1: Create Models
```swift
// Core/Models/Social.swift

struct LeaderboardEntry: Identifiable, Codable {
    let id: String // userId
    let username: String
    let avatar: String
    let rank: Int
    let xp: Int
    let level: Int
    let streakDays: Int
    let badgeCount: Int
    var isCurrentUser: Bool = false
}

enum LeaderboardType: String, CaseIterable {
    case weekly = "Weekly"
    case allTime = "All Time"
    case friends = "Friends"
}
```

#### Step 2: Create LeaderboardService
```swift
// Core/Services/LeaderboardService.swift

@MainActor
class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()

    @Published var weeklyLeaderboard: [LeaderboardEntry] = []
    @Published var allTimeLeaderboard: [LeaderboardEntry] = []
    @Published var currentUserRank: Int?
    @Published var isLoading = false

    func fetchWeeklyLeaderboard() async throws
    func fetchAllTimeLeaderboard() async throws
    func fetchUserRank(userId: String, type: LeaderboardType) async throws -> Int?
}
```

#### Step 3: Create LeaderboardView
- Tab switching (Weekly/All-Time/Friends)
- Top 3 podium display with animations
- Scrollable list of ranks 4-100
- Current user sticky banner
- Pull-to-refresh
- Skeleton loading state

#### Step 4: Firebase Structure
```
Firestore Collections:
├── leaderboards/
│   ├── weekly/
│   │   └── entries/ (subcollection)
│   │       ├── {userId} → LeaderboardEntry
│   │       ├── ...
│   │       └── lastUpdated: timestamp
│   │
│   └── allTime/
│       └── entries/ (subcollection)
│           ├── {userId} → LeaderboardEntry
│           └── ...
│
└── userStats/ (for efficient querying)
    └── {userId}
        ├── weeklyXP: number
        ├── totalXP: number
        ├── level: number
        └── lastUpdated: timestamp
```

---

### Phase 3B: Social Features (Priority 2)

#### Step 1: Create Friend Models
```swift
struct Friend: Identifiable, Codable {
    let id: String // userId
    let username: String
    let avatar: String
    let level: Int
    let status: FriendStatus
    let lastActive: Date
    let streakDays: Int
    let friendSince: Date
}

struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let fromUsername: String
    let fromAvatar: String
    let status: RequestStatus
    let createdAt: Date
}

enum FriendStatus: String, Codable {
    case online, offline, away
}

enum RequestStatus: String, Codable {
    case pending, accepted, declined
}
```

#### Step 2: Create SocialService
```swift
@MainActor
class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published var friends: [Friend] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var pendingCount: Int = 0

    func searchUsers(query: String) async throws -> [Friend]
    func sendFriendRequest(toUserId: String) async throws
    func acceptFriendRequest(requestId: String) async throws
    func declineFriendRequest(requestId: String) async throws
    func removeFriend(friendId: String) async throws
    func fetchFriends() async throws
    func fetchFriendRequests() async throws
}
```

#### Step 3: Create Social Views
- **FriendsListView**: List all friends with search
- **FriendRequestsView**: Pending requests inbox
- **AddFriendView**: Search and send requests
- **UserProfileView**: Public profile display

#### Step 4: Firebase Structure
```
Firestore Collections:
├── users/ (existing)
│   └── {userId}
│       ├── username: string
│       ├── avatar: string
│       ├── isPublic: boolean
│       └── ...
│
├── friendships/
│   └── {userId}
│       └── friends/ (subcollection)
│           ├── {friendId} → Friend
│           └── ...
│
└── friendRequests/
    └── {userId}
        └── requests/ (subcollection)
            ├── {requestId} → FriendRequest
            └── ...
```

---

### Phase 3C: Challenge System (Priority 3)

#### Step 1: Create Challenge Model
```swift
struct Challenge: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let type: ChallengeType
    let goal: Int // target value
    let duration: TimeInterval
    let startDate: Date
    let endDate: Date
    let status: ChallengeStatus
    var fromProgress: Int
    var toProgress: Int
    var winnerId: String?
}

enum ChallengeType: String, Codable {
    case lessons, xp, streak, badges
}

enum ChallengeStatus: String, Codable {
    case pending, active, completed, cancelled
}
```

---

## 🎯 Implementation Priority

### Week 1: Core Leaderboard
1. ✅ Create LeaderboardEntry model
2. ✅ Create LeaderboardService
3. ✅ Build LeaderboardView UI
4. ✅ Implement top 3 podium
5. ✅ Add user rank banner
6. ✅ Test with sample data

### Week 2: Social Foundation
1. ✅ Create Friend models
2. ✅ Create SocialService
3. ✅ Build FriendsListView
4. ✅ Implement search & add friends
5. ✅ Friend request system
6. ✅ Test friend interactions

### Week 3: Challenges & Polish
1. ✅ Create Challenge model
2. ✅ Challenge creation UI
3. ✅ Challenge tracking
4. ✅ Activity feed (optional)
5. ✅ Polish animations
6. ✅ Integration testing

---

## 🚀 Quick Start (Next Steps)

### Immediate Actions:
1. **Create Firebase Collections**
   - Set up leaderboards structure
   - Create userStats for efficient queries
   - Set up security rules

2. **Build Models** (30 min)
   - Social.swift with LeaderboardEntry
   - Friend and FriendRequest models
   - Challenge model

3. **Create Services** (2 hours)
   - LeaderboardService with fetch methods
   - SocialService with friend operations
   - Firebase integration

4. **Build UI** (4 hours)
   - LeaderboardView with tabs
   - Top 3 podium component
   - User rank cards
   - Animations

---

## 📊 Success Metrics

### Leaderboard Engagement
- [ ] 60%+ users check leaderboard weekly
- [ ] Average 3+ leaderboard views per session
- [ ] Users climb ranks over time

### Social Engagement
- [ ] 40%+ users add at least 1 friend
- [ ] Average 5 friends per active user
- [ ] 70%+ friend request acceptance rate

### Competition Impact
- [ ] 30% increase in lesson completion
- [ ] 25% increase in daily active users
- [ ] Higher retention rate (7-day, 30-day)

---

## 🎨 Design Assets Needed

- [ ] Trophy icons (gold, silver, bronze)
- [ ] Rank badges (top 10, top 50, top 100)
- [ ] Default avatar emojis (30+ options)
- [ ] Status indicators (online, offline)
- [ ] Challenge icons by type
- [ ] Confetti animation for rank improvements

---

## 🔒 Security Considerations

### Privacy
- [ ] User profiles default to public
- [ ] Option to hide from leaderboard
- [ ] Option to block users
- [ ] Report/flag system

### Data Protection
- [ ] Only public data exposed
- [ ] Friend-only visibility options
- [ ] Firestore security rules
- [ ] Rate limiting on requests

---

## 💡 Future Enhancements (Phase 4+)

- [ ] Group challenges (3+ users)
- [ ] Guild/Clan system
- [ ] Global chat rooms
- [ ] Video call for practice sessions
- [ ] Gifting system (send badges/rewards)
- [ ] Mentor/mentee matching
- [ ] Live tournaments
- [ ] Seasonal leaderboards with prizes

---

## ✅ Definition of Done

Phase 3A (Leaderboard) is complete when:
- [ ] Weekly leaderboard displays top 100
- [ ] All-time leaderboard displays top 100
- [ ] Current user rank is highlighted
- [ ] Top 3 podium has animations
- [ ] Pull-to-refresh works
- [ ] Real-time updates from Firebase
- [ ] No performance issues with 1000+ users

Phase 3B (Social) is complete when:
- [ ] Users can search and add friends
- [ ] Friend requests work (send/accept/decline)
- [ ] Friends list displays correctly
- [ ] User profiles are viewable
- [ ] Online status updates
- [ ] Friend count badge shows

Phase 3C (Challenges) is complete when:
- [ ] Users can challenge friends
- [ ] Challenge progress tracks correctly
- [ ] Winners are determined automatically
- [ ] Bonus XP awards correctly
- [ ] Challenge notifications work

---

**Ready to start?** Let me know and I'll begin with:
1. Creating the models (Social.swift)
2. Building LeaderboardService
3. Creating LeaderboardView UI

Hoặc bạn muốn tôi adjust roadmap trước? 🚀
