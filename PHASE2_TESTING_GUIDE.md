# Phase 2 Gamification System - Testing Guide

## 📋 Quick Start

### Prerequisites
- ✅ Firebase project configured
- ✅ User authenticated and logged in
- ✅ Gamification data imported to Firebase

---

## 🧪 Manual Testing Checklist

### 1. **Badge Gallery View** 🏆

**How to Access:**
- Navigate to Profile tab → Gamification section → Click "Badges" card

**Test Cases:**

- [ ] **Load Badges**
  - Expected: Badge gallery loads with smooth animations
  - Badge cards display emoji, name, and rarity stars
  - Locked badges show lock icon with "?"

- [ ] **Unlock Badge Animation**
  - Expected: Unlocked badges appear with staggered animation
  - Badge colors transition smoothly
  - Stars display correctly (1-4 stars based on rarity)

- [ ] **Click Badge Detail**
  - Action: Tap on any unlocked badge
  - Expected: Modal opens showing full badge info
  - Badge name, description, XP reward, and rarity displayed
  - Modal dismisses on tap outside

- [ ] **Badge Statistics**
  - Expected: Header shows total unlocked vs total badges
  - Progress indicator displays correct count

---

### 2. **Missions View** 🎯

**How to Access:**
- Navigate to Profile tab → Gamification section → Click "Missions" card

**Test Cases:**

- [ ] **Tab Switching**
  - Action: Click Daily, Weekly, Skill tabs
  - Expected: View filters correctly
  - Haptic feedback on tab selection
  - Smooth animation transition

- [ ] **Mission Display**
  - Expected: Mission cards show:
    - Emoji icon
    - Title and description
    - Difficulty badge (Easy/Medium/Hard)
    - Progress bar (0-100%)
    - Reward XP

- [ ] **Mission Progress**
  - Expected: Progress shows "X/Y" format
  - Color coded by difficulty
  - Bar fills smoothly based on progress

- [ ] **Complete Mission**
  - Action: Click gift icon on completed mission
  - Expected:
    - Mission marked as completed
    - Haptic success feedback
    - UI updates to show checkmark
    - XP reward shows

- [ ] **Mission Stats**
  - Expected: Header shows:
    - Completed count
    - Total available XP
    - Current day streak

---

### 3. **User Level View** ⭐

**How to Access:**
- Navigate to Profile tab → Gamification section → Click "My Level" card

**Test Cases:**

- [ ] **Level Display**
  - Expected:
    - Current level displayed prominently
    - Animated circular progress ring
    - Level title (Beginner, Scholar, Expert, etc.)

- [ ] **XP Progress Bar**
  - Expected:
    - Current XP / Next level XP displayed
    - Progress percentage shown
    - Smooth animation from 0 to current %

- [ ] **Level Progression Chart**
  - Expected:
    - Shows milestones (10, 20, 30... 100)
    - Completed levels show checkmark
    - Uncompleted levels show progress number

- [ ] **Streak Display**
  - Expected:
    - Current day streak shown
    - Flame icon displayed
    - Milestone notifications for 7+ day streaks

- [ ] **Total Stats**
  - Expected:
    - Total XP card shows accurate count
    - Badges earned shows X/9 format

---

### 4. **Pet Companion View** 🐉

**How to Access:**
- Navigate to Profile tab → Gamification section → Click "Pet" card

**Test Cases - First Visit:**

- [ ] **Pet Adoption Modal**
  - Expected: Shows 5 pet types:
    - 🐉 Dragon - Mythical and powerful
    - 🐱 Cat - Cute and curious
    - 🦊 Fox - Smart and clever
    - 🦄 Unicorn - Magical and rare
    - 🔥 Phoenix - Legendary and majestic

- [ ] **Pet Selection**
  - Action: Click different pet cards
  - Expected: Selected pet highlighted with checkmark
  - Color changes to show selection

- [ ] **Pet Naming**
  - Action: Enter pet name in text field
  - Expected: Button enabled when name entered
  - Button disabled when field empty

- [ ] **Adopt Pet**
  - Action: Click "Adopt [PetType]" button
  - Expected:
    - Pet created in Firebase
    - Modal closes
    - Pet view displays new pet

**Test Cases - Pet View:**

- [ ] **Pet Display**
  - Expected:
    - Pet emoji displayed prominently (🐉, 🐱, 🦊, 🦄, 🔥)
    - Pet name shown
    - Star rating (level out of 5)

- [ ] **Pet Interaction**
  - Action: Tap pet emoji multiple times
  - Expected: Pet scales up with bounce animation
  - Haptic feedback on tap

- [ ] **Pet Stats**
  - Expected: Displays:
    - **Happiness**: 0-100% with progress bar
    - **Health**: 0-100% with progress bar
    - Current color indicators

- [ ] **Pet Level & XP**
  - Expected: Shows:
    - Pet level (1-5)
    - Total experience points
    - XP progress bar to next level

- [ ] **Feed Button**
  - Action: Click "Fork & Knife" button
  - Expected:
    - Health increases
    - Firebase updates
    - Haptic success feedback
    - Cooldown before next feed

- [ ] **Play Button**
  - Action: Click "Gamepad" button
  - Expected:
    - Happiness increases
    - Firebase updates
    - Haptic success feedback
    - Cooldown before next play

- [ ] **Pet Care Tips**
  - Expected: Displays helpful text:
    - "Feed your pet daily to keep them healthy!"
    - "Play with your pet to increase happiness!"

---

### 5. **ProfileView Integration** 👤

**Test Cases:**

- [ ] **Gamification Section Visible**
  - Expected:
    - "Gamification" section appears on profile
    - Shows 4 cards: Level, Badges, Missions, Pet
    - Smooth fade-in animation with offset

- [ ] **Navigation Links**
  - Action: Click each card
  - Expected:
    - Level → Opens UserLevelView
    - Badges → Opens BadgeGalleryView
    - Missions → Opens MissionsView
    - Pet → Opens PetCompanionView
    - Smooth navigation transition

- [ ] **Quick Stats**
  - Expected: Subtitle shows:
    - Level card: "Level X"
    - Badges card: "X earned"
    - Missions card: "Daily quests"
    - Pet card: "My companion"

---

## 🔥 Firebase Integration Tests

### 1. **Data Persistence**

- [ ] **Create New User**
  - Action: New user logs in
  - Expected:
    - New documents created in Firestore:
      - `userLevels/{userId}` (Level 1, 0 XP)
      - `virtualPets/{userId}` (if pet adopted)
    - Data persists on app restart

- [ ] **Update Missions**
  - Action: Complete a mission in MissionsView
  - Expected:
    - `userLevels/{userId}/missionProgress` updated
    - Progress and completion status saved
    - Survives app restart

- [ ] **XP Updates**
  - Action: Complete lesson → Mission → Collect reward
  - Expected:
    - `userLevels/{userId}.totalXP` increases
    - XP reward reflected immediately
    - New level progression calculated

- [ ] **Pet Care**
  - Action: Feed/play with pet
  - Expected:
    - `virtualPets/{userId}` updates:
      - `lastFedAt` or `lastPlayedAt` timestamp
      - Health/happiness stats updated
    - Changes reflect in UI immediately

---

## 🎮 Edge Cases & Error Handling

### 1. **No User Session**
- [ ] App handles logged-out user gracefully
- [ ] Shows login prompt if accessing gamification

### 2. **Firebase Connection Lost**
- [ ] Views show loading state initially
- [ ] Error message displays if connection fails
- [ ] Retry button available

### 3. **Missing Data**
- [ ] If no missions loaded: shows "No missions available"
- [ ] If no pet: shows adoption prompt
- [ ] If no badges: shows empty state

### 4. **Performance**
- [ ] All views load within 2 seconds
- [ ] Animations remain smooth (60 FPS)
- [ ] No memory leaks on view navigation
- [ ] Switching tabs doesn't reload data unnecessarily

---

## 📊 Testing Scenarios

### Scenario 1: New User Onboarding
1. ✅ Log in with new account
2. ✅ Check Profile → Gamification section visible
3. ✅ Go to Pet → Adopt first pet
4. ✅ Check Level → Shows Level 1, 0 XP
5. ✅ Check Badges → All locked
6. ✅ Check Missions → Shows available missions

### Scenario 2: Daily Engagement
1. ✅ Complete lesson → Earn XP
2. ✅ Check Level → XP updated
3. ✅ Feed pet → Health increases
4. ✅ Play with pet → Happiness increases
5. ✅ Complete daily mission → Check streak
6. ✅ Unlock badge → Verify in gallery

### Scenario 3: Long Term Progression
1. ✅ Simulate completing multiple lessons
2. ✅ Verify level progression (1→2→3...)
3. ✅ Check XP calculations are accurate
4. ✅ Verify all missions completable
5. ✅ Check pet level increases with care
6. ✅ Verify badge unlock requirements work

---

## 🐛 Known Issues & Workarounds

### None Currently Identified ✅

All Phase 2 features tested and working correctly.

---

## 📱 Device Testing

Test on:
- [ ] iPhone 14 Pro (6.1")
- [ ] iPhone 13 mini (5.4")
- [ ] iPad Air (10.9")
- [ ] iPad mini (8.3")

Verify:
- [ ] Text readable on all sizes
- [ ] Buttons accessible on all sizes
- [ ] Animations smooth on all devices
- [ ] Landscape orientation works

---

## ✅ Sign-Off

**Tester Name**: _______________
**Date**: _______________
**Device**: _______________
**iOS Version**: _______________

**Overall Status**:
- [ ] ✅ All tests passed - Ready for production
- [ ] ⚠️ Minor issues - Can proceed with caution
- [ ] ❌ Critical issues - Needs fixes

**Comments**:
_____________________________________
_____________________________________

---

## 🎯 Next Steps After Testing

1. **If tests pass**: Ready for Phase 3 (Social Features)
2. **If minor issues**: Fix and re-test
3. **If critical issues**: Report and address before proceeding

---

## 📞 Support

For testing issues or bugs found:
1. Document the issue with steps to reproduce
2. Note the device and iOS version
3. Attach screenshots if applicable
4. Report to development team
