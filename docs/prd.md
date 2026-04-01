# Product Requirements Document — Fitness Tracker

## 1. Product Overview

**What is this app?**
Fitness Tracker is a unified iOS app that brings together workout tracking, nutrition management, exercise guidance, and progress analytics into one seamless experience. It targets a generation where obesity is rising and people need an accessible tool to manage their fitness journey without juggling multiple apps for workouts, meals, and health metrics.

**Target Users:** Students, young professionals, and regular gym-goers who are engaged with digital health tools and want to track workouts and diet in one place.

**Target Platform:** iOS 17+
**Language:** Swift / SwiftUI
**Backend:** Firebase (Auth, Firestore, Cloud Storage, Cloud Functions)


## 2. User Roles

| Role | Description |
|------|-------------|
| Guest | Can see the splash screen with "Join Now" and "Login" options. No access to app features. |
| Registered User | Full access: personalised dashboard, workout plans, meal tracking, analytics, settings. |


## 3. Features

### 3.1 Authentication Flow

**Description:** Users create an account or log in via email/password or third-party OAuth (Google/Apple). Includes password reset via email.

**Screens:** `01_splash.png`, `02_login.png`, `03_signup.png`, `06_password_reset.png`, `05_confirmation_email.png`

**User Stories:**
- As a guest, I want to sign up with my name, email, and password so that I can create a personal account.
- As a guest, I want to log in with my email and password so that I can access my data.
- As a user, I want to reset my password via email so that I can recover my account.
- As a guest, I want to sign in with Google or Apple so that I can get started quickly.

**Acceptance Criteria:**
- [ ] Splash screen shows app logo, running illustration, "JOIN NOW" (yellow) and "LOGIN" (white) buttons
- [ ] Sign Up screen collects: Full Name, Email Address, Password, terms checkbox
- [ ] Login screen has: Email Address, Password fields, "Forgot password?" link, Login button (yellow)
- [ ] Password Reset screen: email input + "Send Reset Link" button (yellow)
- [ ] Confirmation Email Sent screen shows: check email instructions, resend option, return to login button
- [ ] "Don't have an account? Sign Up" and "Already have an account? Login" toggle links present
- [ ] Invalid credentials show clear inline error messages
- [ ] Auth state persists across app restarts (Firebase Auth token)

**Technical Notes:**
- Firebase Authentication for email/password + OAuth providers
- Store auth token securely in Keychain
- All text inputs use dark grey rounded fields with placeholder text
- Yellow (#FFD700) for all primary CTA buttons

---

### 3.2 Onboarding / Profile Setup

**Description:** After first sign-up, a multi-step wizard collects user profile data to personalise their experience. A progress bar at the top tracks completion.

**Screens:** `07_profile_basic_info.png`, `10_fitness_goal_selection.png`, `08_profile_setup_complete.png`

**User Stories:**
- As a new user, I want to enter my gender, height, and weight so that the app can personalise my calorie targets.
- As a new user, I want to choose a fitness goal so that my workout plan matches my objectives.
- As a new user, I want to see my recommended daily calories and personalised workout plan before entering the app.

**Acceptance Criteria:**
- [ ] Step 1 — Basic Information: Gender toggle (Male/Female), Height text input, Weight dropdown selector
- [ ] Step 2 — Fitness Goal: 4 goal cards in a 2x2 grid — "Lose Weight" (purple), "Gain Muscle" (blue), "Maintain Body" (teal), "Improve Endurance" (orange)
- [ ] Each goal card has an icon, title, and subtitle description
- [ ] Step 3 — Profile Setup Complete: shows recommended daily calories (e.g. 2200) and a personalised weekly workout plan (e.g. Legs Day 1, Push Day 2, Pull Day 3, Rest Day 4, Legs Day 5)
- [ ] Green/yellow progress bar at top advances through each step
- [ ] "Save and Continue" button (blue-purple gradient) on each step
- [ ] "View dashboard" button on completion screen navigates to Home
- [ ] All profile data saved to Firestore under the user's document

**Technical Notes:**
- Store profile in Firestore: users/{uid} with fields: gender, height, weight, fitnessGoal, recommendedCalories, createdAt
- Generate initial workout plan using Cloud Functions based on selected goal
- Progress bar component is reusable (shows fraction of steps complete)

---

### 3.3 Home Dashboard

**Description:** The main screen users see after login. Shows a personalised greeting, today's workout schedule status, calorie ring, and step counter with distance.

**Screens:** `09_home_dashboard_dark.png`, `30_home_dashboard_light.png`, `17_home_dashboard_variant.png`

**User Stories:**
- As a user, I want to see my name and today's workout at a glance so I know what to focus on.
- As a user, I want to see my calorie intake as a visual ring so I can quickly assess my nutrition.
- As a user, I want to see my daily step count and distance so I can track my activity.

**Acceptance Criteria:**
- [ ] Greeting: "Good Morning, [Name]" with wave emoji, updates by time of day
- [ ] Weekly schedule card: "Weekly schedule – Today" with today's workout (e.g. "Leg day – not completed" / "Leg day – completed" with green badge)
- [ ] Calories card: circular progress ring (orange) showing consumed/target (e.g. 1850/2200), percentage bar below
- [ ] Steps card: large step count (e.g. 8500), target below (/ 10000 Steps), blue horizontal progress bar with percentage, distance in km below
- [ ] Tab bar at bottom: Home (house), Fitness (location pin), Add Meal (plus circle), Analytics (bar chart), Settings (gear)
- [ ] Light mode version uses white background with same layout and coloured cards
- [ ] Tapping the calories card navigates to Today's Intake detail screen

**Technical Notes:**
- Fetch daily stats from Firestore: dailyStats/{uid}/dates/{today}
- Steps from CoreMotion CMPedometer (real-time updates)
- Distance calculated from step count using average stride length
- Cache dashboard data locally for instant loading

---

### 3.4 Workout Plan & Exercise Database

**Description:** Weekly workout plan displayed as day pills (Mon–Fri), with exercises listed below. Users can search/browse all exercises, view details with demo videos, and mark workouts complete. Includes "View nearby gyms" option.

**Screens:** `12_workout_plan.png`, `16_workout_completed.png`, `14_workout_deleted.png`, `19_exercise_browse_all.png`, `18_exercise_search_filtered.png`, `23_exercise_detail_video.png`, `20_nearest_gym_map.png`

**User Stories:**
- As a user, I want to see my weekly workout plan with exercises for each day so I can follow a structured routine.
- As a user, I want to search and browse exercises by muscle group so I can learn proper form.
- As a user, I want to view exercise details with demo videos and instructions.
- As a user, I want to mark my daily workout as completed so I can track adherence.
- As a user, I want to find nearby gyms on a map with directions.

**Acceptance Criteria:**
- [ ] Horizontal scrollable day pills at top: Monday through Friday, colour-coded (green for active days), showing workout name (e.g. "Leg day", "Chest day", "Back day", "Arms day", "Cardio day")
- [ ] Selected day shows: day name + routine title (e.g. "Monday – leg day routine"), completion badge ("workout not completed" / "workout completed" green)
- [ ] Exercise list: vertical cards with exercise name, sets x reps (e.g. "3 sets, 10 reps"), chevron for detail
- [ ] Search bar with "Search Exercise" placeholder and "View all" button
- [ ] Browse all: full scrollable list showing exercise name + muscle group label (e.g. "Squats / Legs", "Bench press / Chest")
- [ ] Filtered search: results filtered by muscle group (e.g. searching "Legs" shows only leg exercises)
- [ ] Exercise detail: back button, exercise name as title, video/GIF player with play button overlay, text description below
- [ ] "View nearby gyms" button (green, full width) at bottom of workout plan
- [ ] Nearby gym screen: MapKit map with red pin annotations, bottom list showing gym name, distance in km, "Directions" button (green) for each
- [ ] Toast notifications: "Workout added" / "Workout deleted" appear at bottom

**Technical Notes:**
- Exercises collection in Firestore: exercises/{id} with fields: name, muscleGroup, equipment, difficulty, description, videoURL
- Videos/GIFs hosted in Firebase Cloud Storage, streamed on detail page
- Client-side filtering for search (filter exercises array by muscleGroup or name)
- Workout plan stored in Firestore: workoutPlans/{uid} with day-to-exercises mapping
- Nearby gyms: MapKit MKLocalSearch with category .gym, show distance using CLLocation
- Missed workout rescheduling via Cloud Functions

---

### 3.5 Meal Tracker & Nutrition

**Description:** Users log meals by searching a nutrition database. The screen shows today's meals grouped by meal type (Breakfast/Lunch/Dinner), macro rings, and calorie progress. Includes a detailed "Today's Intake" screen.

**Screens:** `22_todays_meals.png`, `21_meals_delete_confirm.png`, `24_log_meals_search.png`, `28_add_meal_popup.png`, `11_todays_intake.png`, `13_todays_intake.png`

**User Stories:**
- As a user, I want to see today's meals grouped by Breakfast, Lunch, and Dinner with nutritional info.
- As a user, I want to search for food items and add them to my daily log.
- As a user, I want to see my macro breakdown (protein, carbs, fats) as visual rings.
- As a user, I want to delete a meal entry if I logged it by mistake.
- As a user, I want to see my total calorie and macro intake for today in detail.

**Acceptance Criteria:**
- [ ] Today's Meals screen header: "Todays meals" with "Add Meal +" button (green, top right)
- [ ] Three macro rings at top: Protein (purple, e.g. 100g/120g), Carbs (blue-green, e.g. 140g/200g), Fats (magenta, e.g. 40g/50g)
- [ ] Calories progress bar below macros showing consumed/target (e.g. 1800/2200)
- [ ] Meals grouped under Breakfast, Lunch, Dinner headers (italic)
- [ ] Each meal card: food emoji icon, food name, macro breakdown text (e.g. "300kcal | Carbs 50g | Protein 5g | Fats 20g"), red delete button on right
- [ ] Delete confirmation popup: "Delete item — Are you sure you want to delete this meal" with Yes/No buttons
- [ ] Log Meals screen: search bar at top ("Search food"), recent meals list with food name, macros, green "+" button to add
- [ ] Add meal popup: food name, quantity stepper (+/-), meal type dropdown (Breakfast/Lunch/Dinner), "Add meal" and "Close" buttons
- [ ] Toast: "Meal added" confirmation at bottom
- [ ] Today's Intake detail: calorie ring (orange), percentage bar, three macro rings, "Latest meals" section with recent entries

**Technical Notes:**
- Search food via Nutritionix or Spoonacular API — returns name, calories, protein, carbs, fats per serving
- Store logged meals in Firestore: meals/{uid}/dates/{today}/entries/{mealId}
- Auto-update daily totals when meals are added/deleted
- Macro targets calculated from profile data (weight, goal) during onboarding

---

### 3.6 Analytics Dashboard

**Description:** A dedicated screen for visualising progress over time. Shows summary stats and bar charts for steps and calorie intake, filterable by time range (Today/Week/Month).

**Screens:** `27_analytics_dashboard.png`, `29_analytics_alt.png`

**User Stories:**
- As a user, I want to see my steps, calories burned, and workout count at a glance.
- As a user, I want to view bar charts of my step count and calorie intake over time.
- As a user, I want to switch between Today, Week, and Month views.

**Acceptance Criteria:**
- [ ] Header: "Analytics Dashboard" (italic)
- [ ] Time range tabs: Today / week / month (horizontally aligned, selectable)
- [ ] Summary stats row: Steps (with distance), Calories burned (Kcal), Workouts count — displayed in bordered cards
- [ ] Step counter bar chart: blue bars, labelled by day of week (Monday, Tuesday, Wednesday…)
- [ ] Calorie intake bar chart: orange bars, same day labels
- [ ] Charts scroll vertically on the same screen
- [ ] Charts support zooming and historical comparison via Swift Charts interactivity

**Technical Notes:**
- Use Swift Charts for all graphs
- Query data from Firestore: dailyStats/{uid}/dates/* for the selected range
- Cache queried data in local SQLite for fast chart rendering
- Step data sourced from CoreMotion, calorie data from logged meals + estimated burn

---

### 3.7 Settings & Privacy

**Description:** Users can customise notifications, toggle light/dark mode, change units, sign out, or permanently delete their account.

**Screens:** `32_settings.png`, `33_signout_confirm.png`

**User Stories:**
- As a user, I want to toggle workout alerts and daily reminders on or off.
- As a user, I want to switch between light and dark mode.
- As a user, I want to change my distance units (km/miles).
- As a user, I want to sign out or permanently delete my account and data.

**Acceptance Criteria:**
- [ ] Settings header (italic)
- [ ] Notification Preferences section: "Workout alerts" checkbox, "Daily Reminders" checkbox
- [ ] "Light mode" toggle switch (green when active)
- [ ] Unit Settings section: "Distance (Km)" dropdown selector
- [ ] "Sign Out" button (yellow, full width)
- [ ] "Delete Account" button (red, full width)
- [ ] Sign out confirmation dialog before logging out
- [ ] Account deletion triggers GDPR-compliant full data removal from Firestore

**Technical Notes:**
- Store preferences in UserDefaults (notifications, units, appearance)
- Light/dark mode: respect system setting by default, override with toggle using @AppStorage
- Account deletion: Firebase Cloud Function to cascade-delete all user data from all collections
- GDPR compliance: user can export and delete their data


## 4. Data Model

### User
| Field | Type | Notes |
|-------|------|-------|
| id | String (UID) | Firebase Auth UID |
| fullName | String | From sign-up |
| email | String | Unique, from sign-up |
| gender | String | "male" / "female" |
| height | Double | In cm |
| weight | Double | In kg |
| fitnessGoal | String | "loseWeight" / "gainMuscle" / "maintainBody" / "improveEndurance" |
| recommendedCalories | Int | Calculated during onboarding |
| stepGoal | Int | Default 10000 |
| distanceUnit | String | "km" / "miles" |
| createdAt | Date | Auto-set |

### Exercise
| Field | Type | Notes |
|-------|------|-------|
| id | String | Firestore doc ID |
| name | String | e.g. "Squats" |
| muscleGroup | String | e.g. "Legs", "Chest", "Back", "Shoulders" |
| equipment | String | e.g. "Barbell", "Bodyweight" |
| difficulty | String | "beginner" / "intermediate" / "advanced" |
| description | String | Instructions and safety notes |
| videoURL | String | Firebase Storage URL for demo video/GIF |

### WorkoutPlan
| Field | Type | Notes |
|-------|------|-------|
| id | String | Firestore doc ID |
| userId | String | Owner's UID |
| days | [DayPlan] | Array of day assignments |

### DayPlan (embedded)
| Field | Type | Notes |
|-------|------|-------|
| dayOfWeek | String | "Monday" through "Sunday" |
| workoutName | String | e.g. "Leg day", "Chest day", "Rest" |
| exerciseIds | [String] | References to Exercise documents |
| setsPerExercise | Int | Default 3 |
| repsPerExercise | Int | Default 10 |
| isCompleted | Bool | Toggled by user |

### Meal
| Field | Type | Notes |
|-------|------|-------|
| id | String | Firestore doc ID |
| userId | String | Owner's UID |
| date | Date | Day this meal was logged |
| foodName | String | e.g. "Chicken and rice" |
| mealType | String | "Breakfast" / "Lunch" / "Dinner" |
| calories | Int | kcal |
| protein | Double | grams |
| carbs | Double | grams |
| fats | Double | grams |
| quantity | Int | Number of servings |

### DailyStats
| Field | Type | Notes |
|-------|------|-------|
| id | String | "{uid}_{date}" |
| userId | String | Owner's UID |
| date | Date | The day |
| steps | Int | From CoreMotion |
| distance | Double | km, calculated from steps |
| caloriesConsumed | Int | Sum of logged meals |
| caloriesBurned | Int | Estimated from workouts + steps |
| workoutsCompleted | Int | Count of completed day plans |
| proteinTotal | Double | Sum from meals |
| carbsTotal | Double | Sum from meals |
| fatsTotal | Double | Sum from meals |


## 5. Navigation Flow

```
App Launch
├── First Launch → Splash (Join Now / Login)
│   ├── Join Now → Sign Up → Onboarding Wizard (3 steps) → Home Dashboard
│   └── Login → Home Dashboard
│       └── Forgot Password → Password Reset → Email Confirmation → Login
│
├── Returning User → Home Dashboard (auto-login via stored token)
│
└── Tab Bar (persistent across all main screens)
    ├── Home → Dashboard (calories ring, steps, weekly schedule)
    │   └── Tap calories card → Today's Intake detail
    ├── Fitness → Workout Plan (day pills, exercise list)
    │   ├── Tap exercise → Exercise Detail (video + description)
    │   ├── Search Exercise → Filtered results / Browse all
    │   └── View nearby gyms → Map with gym pins + list
    ├── Add Meal → Today's Meals (macro rings, meal list by type)
    │   ├── Add Meal + → Log Meals search → Select food → Add meal popup → Confirm
    │   └── Delete meal → Confirmation dialog
    ├── Analytics → Analytics Dashboard (time range tabs, charts)
    └── Settings → Notification prefs, Light/Dark toggle, Units, Sign Out, Delete Account
```


## 6. API Endpoints

### Nutrition API (Nutritionix or Spoonacular)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /v1_1/search/instant?query={term} | Search foods by name |
| GET | /v1_1/item?nix_item_id={id} | Get full nutrition data for a food item |

### Firebase Firestore Collections
| Collection | Description |
|------------|-------------|
| users/{uid} | User profile data |
| exercises/{id} | Exercise database (global, read-only for users) |
| workoutPlans/{uid} | User's personalised weekly plan |
| meals/{uid}/dates/{date}/entries/{id} | Logged meals per day |
| dailyStats/{uid}/dates/{date} | Aggregated daily statistics |


## 7. Design & UX Notes

- Dark-first design: pure black (#000000) background, dark grey card fills
- Light mode: white background, maintains same card structure with light grey fills
- Primary CTA: Yellow (#FFD700) for all main action buttons
- Secondary CTA: Blue-to-purple gradient for onboarding "Save and Continue"
- Destructive actions: Red for "Delete Account", red minus circles for meal deletion
- Typography: SF Pro, italic style for all screen headings and section titles
- Calorie ring: orange (#FF9500)
- Steps bar: blue (#007AFF)
- Macro rings: purple (protein), blue-green (carbs), magenta (fats)
- Day pills: green fill for workout days, grey for rest/inactive
- Cards: rounded corners (~12pt), subtle borders or fills to separate from background
- Toast/snackbar: dark pill at bottom of screen for transient confirmations
- Tab bar: 5 items with SF Symbol icons + text labels, always visible on main screens
- All screen mockups are in `docs/screens/` for visual reference


## 8. Non-Functional Requirements

- **Performance:** Dashboard and meal lists should load in under 1 second. Cache Firestore data locally.
- **Offline:** Support offline meal and workout logging. Queue writes and sync when connectivity returns.
- **Security:** All communication over HTTPS with TLS 1.2+. Auth tokens in Keychain. Firestore security rules restrict data to authenticated owner.
- **Privacy:** GDPR compliant. Users can delete all their data. Permission requests explain why data is needed. No data sold to third parties.
- **Accessibility:** Support Dynamic Type for all text. VoiceOver labels on all interactive elements. Sufficient colour contrast in both modes.
- **Permissions:** HealthKit (steps), CoreMotion (pedometer), Location (nearby gyms), Notifications (reminders). App functions without location/notification permissions — those features are simply hidden.


## 9. Out of Scope (v1)

- Barcode scanning for food items (mentioned in spec but deferred)
- Social features / friend lists
- Apple Watch companion app
- Running/cycling route tracking with GPS recording
- Weather integration for outdoor workout planning
- iPad layout
- Push notification scheduling via Cloud Functions
- Workout video recording or camera features
- In-app purchases or subscription tiers


## 10. Implementation Phases

### Phase 1 — Foundation & Auth
- [ ] Xcode project setup with folder structure matching CLAUDE.md
- [ ] Firebase SDK integration (Auth, Firestore, Storage)
- [ ] All data models (User, Exercise, WorkoutPlan, Meal, DailyStats)
- [ ] Auth flow: Splash → Login → Sign Up → Password Reset → Email Confirmation
- [ ] Navigation skeleton: TabView with 5 tabs and empty placeholder screens

### Phase 2 — Onboarding & Home
- [ ] Multi-step onboarding wizard (basic info → fitness goal → completion summary)
- [ ] Profile data saved to Firestore
- [ ] Home dashboard: greeting, weekly schedule card, calories ring, steps counter
- [ ] CoreMotion step counting integration
- [ ] Today's Intake detail screen

### Phase 3 — Fitness & Exercises
- [ ] Workout plan screen with day pills and exercise list
- [ ] Exercise browse/search with client-side filtering
- [ ] Exercise detail screen with video player
- [ ] Mark workout complete/incomplete with toast feedback
- [ ] Seed Firestore with initial exercise database

### Phase 4 — Meal Tracking
- [ ] Today's Meals screen with macro rings and grouped meal list
- [ ] Log Meals search screen with Nutritionix/Spoonacular API integration
- [ ] Add meal popup (quantity + meal type)
- [ ] Delete meal with confirmation dialog
- [ ] Auto-update daily calorie and macro totals

### Phase 5 — Analytics & Settings
- [ ] Analytics dashboard with Swift Charts (steps + calories bar charts)
- [ ] Time range filtering (Today/Week/Month)
- [ ] Settings screen: notifications, light/dark toggle, units, sign out, delete account
- [ ] GDPR account deletion via Cloud Function

### Phase 6 — Maps & Location
- [ ] Nearby gyms screen with MapKit
- [ ] Gym list with distance and directions
- [ ] Location permission handling

### Phase 7 — Polish & Testing
- [ ] Light mode pass across all screens
- [ ] Empty states for all lists (no meals, no exercises, no data)
- [ ] Loading spinners on cards during data fetch
- [ ] Error handling and offline queuing
- [ ] Unit tests for all ViewModels
- [ ] Accessibility pass (Dynamic Type, VoiceOver)
- [ ] TestFlight beta distribution
