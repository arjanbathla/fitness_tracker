# Fitness Tab Design

## Overview

Build the fitness tab with a weekly workout plan, exercise list, search/browse all exercises, exercise detail with video, and toast feedback messages. Excludes the nearby gyms map (placeholder button only).

Matches mockups: `screen 13.png` (workout plan), `screen 17.png` (workout plan variant), `screen 19.png` (browse all), `screen 20.png` (filtered search), `screen 21.png` (exercise detail), `screen 12.png` / `screen 14.png` (complete/delete confirmation), `screen 16.png` (workout deleted toast)

## Files to Create/Edit

| File | Action | Purpose |
|------|--------|---------|
| `ViewModels/FitnessViewModel.swift` | Create | Fetches workout plan + exercises from Firestore, manages selected day, search, toast |
| `Views/Fitness/FitnessView.swift` | Replace | Main workout plan screen with day pills, exercise list, search bar |
| `Views/Fitness/ExerciseBrowseView.swift` | Create | Full exercise list with search filtering |
| `Views/Fitness/ExerciseDetailView.swift` | Create | Exercise detail with video/image player and description |
| `Views/Components/DayPillView.swift` | Create | Reusable horizontal day pill (label + workout name) |
| `Views/Components/ExerciseCardView.swift` | Create | Reusable exercise row card (name, sets x reps, chevron) |
| `Views/Components/ToastView.swift` | Create | Auto-dismissing bottom toast overlay |

## FitnessViewModel

- ObservableObject with @Published properties
- Uses FirestoreService for all Firestore access (lab guide pattern)
- Properties:
  - `workoutPlan: WorkoutPlan?` — user's full plan from Firestore
  - `selectedDayIndex: Int` — which day pill is selected (0-4 for Mon-Fri)
  - `selectedDayPlan: DayPlan?` — computed from workoutPlan.days based on selectedDayIndex
  - `exercises: [Exercise]` — all exercises loaded from Firestore
  - `dayExercises: [Exercise]` — exercises for the selected day (matched by exerciseIds in the DayPlan)
  - `toastMessage: String?` — shown when non-nil, auto-clears after 2 seconds
  - `showCompleteAlert: Bool` — confirmation for marking complete
  - `showDeleteAlert: Bool` — confirmation for deleting workout
- Methods:
  - `loadData()` — fetches workout plan and exercises via FirestoreService
  - `markCompleted()` — sets selectedDayPlan.isCompleted = true, saves to Firestore, shows toast "Workout added"
  - `deleteWorkout()` — resets the day's exercises, saves to Firestore, shows toast "Workout deleted"
  - `showToast(_ message:)` — sets toastMessage, auto-clears after 2s with DispatchQueue.main.asyncAfter
- Uses completion handler callbacks (not async/await)
- Gets userId from Auth.auth().currentUser?.uid

## FitnessView Layout (screen 13 / screen 17)

Top-to-bottom in a ScrollView inside NavigationStack, dark background:

1. **Title**: "Your workout plan" in white italic

2. **Day pills row**: Horizontal ScrollView with 5 pills (Mon–Fri). Each pill shows short day name at top ("Mon", "Tue", etc.) and workout name below ("Leg day", "Chest day", etc.). Selected pill is green, others are dark grey. Tapping changes selectedDayIndex.

3. **Search bar + View all**: HStack with a search icon TextField ("Search Exercise") and a green "View all" button. "View all" navigates to ExerciseBrowseView. Search bar is for quick filtering of the day's exercises (not the full browse).

4. **Selected day header**: "Monday – leg day routine" text + completion badge pill ("workout not completed" grey / "workout completed" green). Tapping the badge shows confirmation alert.

5. **Exercise list**: VStack of ExerciseCardView rows. Each shows exercise name, "3 sets, 10 reps" subtitle, chevron. Tapping navigates to ExerciseDetailView.

6. **"View nearby gyms" button**: Full-width green button at bottom. Disabled placeholder for now (no navigation).

7. **Toast overlay**: ToastView shown at bottom when toastMessage is non-nil.

## ExerciseBrowseView (screen 19 / screen 20)

- Presented via NavigationLink from "View all" button
- Search bar at top with "Search Exercise" placeholder + green "Cancel" button (dismisses view)
- List of all exercises from Firestore
- Each row: exercise name (bold) + muscle group label below, chevron on right
- Client-side filtering: as user types, filter by exercise name OR muscleGroup (case-insensitive contains)
- Tapping a row navigates to ExerciseDetailView

## ExerciseDetailView (screen 21)

- NavigationStack back button, exercise name as navigation title
- Top: image/video area. Uses AsyncImage to load from exercise.videoURL. Shows a placeholder mountain-like image with a play button overlay. If the URL is a video, use VideoPlayer from AVKit; if image, use AsyncImage.
- Below: exercise description text in white
- Dark background

## DayPillView

- Parameters: `dayLabel: String` ("Mon"), `workoutName: String` ("Leg day"), `isSelected: Bool`
- Green background when selected, dark grey otherwise
- Rounded rectangle, vertically stacked text (day on top, workout below)

## ExerciseCardView

- Parameters: `exercise: Exercise`, `setsPerExercise: Int`, `repsPerExercise: Int`
- HStack: VStack(name bold, "N sets, N reps" grey subtitle) + Spacer + chevron
- Dark grey rounded rect background

## ToastView

- Parameters: `message: String`
- Dark capsule at bottom of screen with white text
- Appears with slide-up animation, auto-dismisses after 2 seconds

## Confirmation Alerts

- **Mark complete**: Alert with "Have you completed this workout?" + Yes/Cancel buttons. On Yes, calls viewModel.markCompleted()
- **Delete workout**: Alert with "Do you want to delete this workout?" + Yes/Cancel buttons. On Yes, calls viewModel.deleteWorkout()

## Colours

- Day pill selected: .green
- Day pill unselected: Color(white: 0.11)
- Card background: Color(white: 0.11)
- "View nearby gyms" button: green gradient (blue-to-green)
- Completion badge completed: .green
- Completion badge not completed: .gray
- Toast: dark grey capsule with white text
- Page background: .black

## Data Flow

```
FitnessView
  @StateObject viewModel = FitnessViewModel()

  .onAppear:
    viewModel.loadData()

  NavigationLink -> ExerciseBrowseView(exercises: viewModel.exercises)
  NavigationLink -> ExerciseDetailView(exercise: selectedExercise)
```

FitnessViewModel fetches workout plan + exercises on loadData(). Day pill selection is local state in the viewModel. Exercise detail receives the Exercise model directly.

## Patterns to Follow

- ObservableObject + @Published + @StateObject (per CLAUDE.md)
- Completion handler callbacks, not async/await
- FirestoreService for all Firestore access
- Simple naming, casual comments, undergrad coding style
- NavigationStack + NavigationLink for drill-down navigation
- .alert() for confirmation dialogs
- No nearby gyms functionality (button present but disabled)
