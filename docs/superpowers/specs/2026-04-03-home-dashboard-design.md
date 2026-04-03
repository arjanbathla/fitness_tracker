# Home Dashboard Design

## Overview

Build the home dashboard screen — the first screen users see after login. Shows a personalised greeting, today's workout from the weekly plan, a calories progress ring, and a live step counter with distance.

Matches mockup: `docs/screens/screen 10.png`

## Files to Create/Edit

| File | Action | Purpose |
|------|--------|---------|
| `ViewModels/HomeViewModel.swift` | Create | Fetches user profile, today's workout plan, and daily stats from Firestore |
| `Services/StepCounterService.swift` | Create | Wraps CMPedometer, publishes live step count and distance |
| `Views/Components/ProgressRingView.swift` | Create | Reusable circular progress ring (orange for calories) |
| `Views/Home/HomeView.swift` | Edit | Replace placeholder with full dashboard UI |

## HomeViewModel

- ObservableObject with @Published properties
- Uses existing `FirestoreService` pattern from the Firestore lab guide
- Properties:
  - `userName: String` — from Firestore user document
  - `greeting: String` — "Good Morning," / "Good Afternoon," / "Good Evening," based on current hour
  - `todayWorkout: DayPlan?` — today's plan from the user's WorkoutPlan document
  - `caloriesConsumed: Int` — from DailyStats or 0 if none
  - `caloriesTarget: Int` — from User.recommendedCalories
  - `stepGoal: Int` — from User.stepGoal (default 10000)
- Fetches on `loadData(userId:)`:
  1. `FirestoreService.getUser(userId:)` to get name, calorie target, step goal
  2. `FirestoreService.getWorkoutPlans(userId:)` to get today's DayPlan by matching current day of week
- Uses completion handler callbacks (not async/await per CLAUDE.md)

## StepCounterService

- ObservableObject following the same pattern as the accelerometer lab's MotionManager class
- Uses CMPedometer (not CMMotionManager) for step data
- @Published properties: `steps: Int`, `distance: Double` (in km)
- `startCounting()` — queries pedometer from midnight today, receives live updates
- `stopCounting()` — stops pedometer updates
- Called via `.onAppear` / `.onDisappear` in HomeView

## ProgressRingView

- Reusable SwiftUI view for circular progress
- Parameters: `progress: Double` (0.0–1.0), `lineWidth: CGFloat`, `color: Color`
- Grey track circle behind, coloured arc on top
- Used for the orange calories ring on the dashboard

## HomeView Layout

Top-to-bottom in a ScrollView, dark background:

1. **Greeting section** (no card, just text)
   - "Good Morning," in grey, small font
   - "Arjan Bathla" (user's fullName) in white, large bold italic + wave emoji

2. **Weekly schedule card** (dark grey rounded rect)
   - Header: "Weekly schedule - Today" in white italic
   - Pill/badge: today's workout name + "not completed" / "completed" status
   - Status colour: grey for not completed, green for completed

3. **Calories card** (dark grey rounded rect)
   - "Calories" title centered
   - Orange ProgressRingView with "1850 / 2200" text inside
   - Small percentage bar below the ring

4. **Steps card** (dark grey rounded rect)
   - "Steps" title centered
   - Large bold step count (e.g. "8500")
   - "/ 10000 Steps" subtitle
   - Blue horizontal progress bar with percentage label
   - "Distance: 6.2km" below

## Colours

- Card background: Color(white: 0.11) (#1C1C1E)
- Calories ring: .orange
- Steps bar: .blue
- Completed badge: .green
- Page background: .black

## Data Flow

```
HomeView
  @StateObject homeViewModel = HomeViewModel()
  @StateObject stepCounter = StepCounterService()

  .onAppear:
    homeViewModel.loadData(userId: currentUser.uid)
    stepCounter.startCounting()
  .onDisappear:
    stepCounter.stopCounting()
```

HomeView reads steps/distance from stepCounter directly. Everything else comes from homeViewModel.

## Patterns to Follow

- `ObservableObject` + `@Published` + `@StateObject` (per CLAUDE.md, not @Observable)
- Completion handler callbacks, not async/await (per CLAUDE.md)
- FirestoreService for all Firestore access (per Firestore lab guide)
- CMPedometer in a service class with start/stop (per accelerometer lab pattern)
- Simple naming, casual comments, undergrad coding style (per CLAUDE.md)
