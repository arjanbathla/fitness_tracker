# Project: Fitness Tracker

## Overview
A unified iOS fitness app that combines workout tracking, nutrition management, exercise guidance, and progress analytics into one seamless experience. Targets health-conscious students, young professionals, and gym-goers.

## Architecture
- **Pattern:** MVVM (Model-View-ViewModel)
- **UI Framework:** SwiftUI
- **Minimum Target:** iOS 17.0
- **Language:** Swift 6
- **Package Manager:** Swift Package Manager

## Project Structure
```
FitnessTracker/
├── App/                      # App entry point, app-level config
├── Models/
│   ├── User.swift            # User profile (age, weight, height, gender, goals)
│   ├── Exercise.swift        # Exercise metadata (name, muscle group, equipment, difficulty)
│   ├── WorkoutPlan.swift     # Weekly plan with day-exercise assignments
│   ├── WorkoutSession.swift  # Completed workout log entry
│   ├── Meal.swift            # Logged meal with nutritional data
│   └── DailyStats.swift      # Aggregated daily calories, steps, macros
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── HomeViewModel.swift
│   ├── FitnessViewModel.swift
│   ├── MealTrackerViewModel.swift
│   ├── AnalyticsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Auth/                 # Splash, Login, SignUp, PasswordReset, EmailConfirmation
│   ├── Onboarding/           # ProfileSetup (basic info, fitness goal, completion summary)
│   ├── Home/                 # Dashboard with calories ring, steps bar, weekly schedule
│   ├── Fitness/              # Workout plan, exercise list, exercise detail, nearby gyms
│   ├── MealTracker/          # Today's meals, log meals search, add meal, intake summary
│   ├── Analytics/            # Dashboard with charts (steps, calories, workouts)
│   ├── Settings/             # Notifications, appearance, units, sign out, delete account
│   └── Components/           # Reusable: ProgressRing, MacroRings, ExerciseCard, MealCard, DayPill
├── Services/
│   ├── AuthService.swift         # Firebase Auth (email/password, Google, Apple sign-in)
│   ├── FirestoreService.swift    # Firestore CRUD for all collections
│   ├── NutritionAPIService.swift # Nutritionix or Spoonacular for food data
│   ├── HealthKitService.swift    # CoreMotion steps, HealthKit integration
│   ├── LocationService.swift     # MapKit, GPS for nearby gyms
│   └── StorageService.swift      # Firebase Cloud Storage for exercise media
├── Utilities/
│   ├── Extensions/
│   ├── Constants.swift       # Colours, API keys, default values
│   └── Helpers.swift
└── Resources/                # Assets, SF Symbols, Localisation
```

## Design System
- **Theme:** Dark-first design with full light mode support
- **Background:** Dark mode = pure black (#000000), light mode = white
- **Primary CTA colour:** Yellow (#FFD700) for all main buttons
- **Secondary accents:** Orange for calories ring, Blue for steps bar, Purple/Green/Magenta for macro rings
- **Cards:** Rounded rectangles with subtle dark grey fill in dark mode
- **Typography:** System font (SF Pro), italic style for screen headings
- **Tab bar:** 5 tabs — Home, Fitness, Add Meal (centre), Analytics, Settings
- **Icons:** SF Symbols with text labels in tab bar
- **Feedback:** Bottom toast/snackbar for confirmations ("Workout added", "Meal added")

## Coding Conventions
- Swift concurrency (async/await) for all async work — no Combine unless wrapping existing APIs
- Prefer structs/enums over classes where possible
- Extract subviews when a view body exceeds ~40 lines
- ViewModels are @Observable classes, one per major screen
- Dependency injection via @Environment, not singletons
- File names match their primary type
- Business logic stays out of Views
- Typed errors with Swift's Error protocol, user-facing messages via ViewModel

## Backend & Services
- **Auth:** Firebase Authentication (email/password + OAuth Google/Apple)
- **Database:** Firebase Firestore
- **Storage:** Firebase Cloud Storage (exercise demo videos/GIFs)
- **Nutrition API:** Nutritionix or Spoonacular
- **Steps:** CoreMotion for real-time step counting
- **Maps:** MapKit for nearby gyms
- **Local cache:** SQLite for analytics chart data
- **Offline:** Queue meal/workout logs offline, sync on reconnect

## Dependencies
- Firebase SDK (Auth, Firestore, Cloud Storage, Cloud Functions)
- Swift Charts (built-in)
- MapKit + CoreLocation (built-in)
- CoreMotion (built-in)
- HealthKit (built-in)

## Testing
- Unit tests for all ViewModels using Swift Testing
- Mock service layers via protocols
- @Testable import for internal access

## Build & Run
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' test
```

## Key Design Decisions
- Yellow (#FFD700) is the universal CTA colour across all screens
- Blue-to-purple gradient for onboarding "Save and Continue" buttons
- Calorie ring = orange, steps bar = blue (consistent on home + intake screens)
- Macro rings: purple (protein), blue-green (carbs), magenta (fats)
- Exercise detail screen: video/GIF player at top, text instructions below
- Nearby gyms: MapKit pins + bottom list with distance and "Directions" buttons
- Add meal flow: search → select food → popup (quantity stepper + meal type dropdown) → confirm
- Profile onboarding is a multi-step wizard with progress bar (basic info → fitness goal → summary)
- Weekly workout plan displays as horizontally scrollable day pills (Mon–Fri) with colour coding

## Reference Docs
- Full PRD: `docs/prd.md`
- Screen mockups: `docs/screens/` (33 labelled PNGs)
- Original spec: `docs/mobile_report.docx`
