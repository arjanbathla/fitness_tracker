# Meal Tracker Design

## Overview

Build the meal tracker tab with today's meals screen (macro rings, calorie bar, grouped meals), log meals search screen using Edamam Food Database API, add meal popup with quantity stepper and meal type picker, delete meal confirmation, and toast feedback. Save meals to Firestore using FirestoreService pattern.

Matches mockups: `screen 22.png` (today's meals), `screen 23.png` (delete confirmation), `screen 24.png` (today's meals with toast), `screen 25.png` (log meals search), `screen 26.png` (add meal popup)

## Files to Create/Edit

| File | Action | Purpose |
|------|--------|---------|
| `Utilities/Constants.swift` | Create | Edamam API credentials (App ID + App Key) |
| `Services/EdamamService.swift` | Create | URLSession calls to Edamam Food Database API |
| `Models/User.swift` | Modify | Add proteinGoal, carbsGoal, fatsGoal fields |
| `ViewModels/MealTrackerViewModel.swift` | Create | Manages meals, search state, macro totals, CRUD |
| `Views/MealTracker/MealTrackerView.swift` | Replace | Today's meals with macro rings + calorie bar + grouped meals |
| `Views/MealTracker/LogMealsView.swift` | Create | Search screen with Edamam API results + add meal popup |
| `Views/Components/MacroRingView.swift` | Create | Reusable labeled macro ring (value/target + label below) |

## Constants

```swift
struct Constants {
    static let edamamAppId = "901b44bd"
    static let edamamAppKey = "1b4b28deed3ae699e7a7e339974abf81"
}
```

## EdamamService

- ObservableObject with `@Published var searchResults: [EdamamFood]`
- Struct `EdamamFood`: name (String), calories (Int), protein (Double), carbs (Double), fats (Double)
- Method: `searchFood(query: String, completion: @escaping ([EdamamFood]) -> Void)`
- Calls `https://api.edamam.com/api/food-database/v2/parser?ingr=QUERY&app_id=ID&app_key=KEY`
- Parses JSON response: `hints` array -> each item has `food` object with `label`, `nutrients.ENERC_KCAL`, `nutrients.PROCNT`, `nutrients.CHOCDF`, `nutrients.FAT`
- Uses URLSession.shared.dataTask with completion handler (not async/await)
- Parses with JSONSerialization (not Codable, undergrad style)
- Returns up to 10 results

## User Model Changes

Add three new fields to User struct:

```swift
var proteinGoal: Int
var carbsGoal: Int
var fatsGoal: Int
```

Update `User.default` static property with defaults calculated from 2200 calories:
- proteinGoal: 165 (30% of 2200 / 4 cal per gram)
- carbsGoal: 220 (40% of 2200 / 4 cal per gram)
- fatsGoal: 73 (30% of 2200 / 9 cal per gram)

These fields need `CodingKeys` with default values so existing Firestore users without these fields don't crash on decode. Use a custom `init(from decoder:)` that falls back to defaults.

## MealTrackerViewModel

- ObservableObject with @Published properties
- Uses FirestoreService for all Firestore access
- Uses EdamamService for food search
- Properties:
  - `meals: [Meal]` — today's meals from Firestore
  - `user: User?` — for macro/calorie targets
  - `searchText: String` — bound to search bar in LogMealsView
  - `searchResults: [EdamamFood]` — results from Edamam API
  - `toastMessage: String?` — shown when non-nil, auto-clears after 2s
  - `showDeleteAlert: Bool` — confirmation for deleting a meal
  - `mealToDelete: Meal?` — which meal is pending deletion
  - `isSearching: Bool` — loading state for API calls
- Computed:
  - `breakfastMeals: [Meal]` — meals.filter { $0.mealType == .breakfast }
  - `lunchMeals: [Meal]` — meals.filter { $0.mealType == .lunch }
  - `dinnerMeals: [Meal]` — meals.filter { $0.mealType == .dinner }
  - `totalCalories: Int` — sum of all meals' calories
  - `totalProtein: Double` — sum of all meals' protein
  - `totalCarbs: Double` — sum of all meals' carbs
  - `totalFats: Double` — sum of all meals' fats
- Methods:
  - `loadMeals()` — fetches user profile + today's meals from Firestore via FirestoreService
  - `searchFood()` — calls EdamamService with searchText, populates searchResults
  - `addMeal(food: EdamamFood, quantity: Int, mealType: Meal.MealType)` — creates Meal, saves to Firestore, reloads meals, shows toast "Meal added"
  - `deleteMeal()` — deletes mealToDelete from Firestore, reloads meals, shows toast "Meal Deleted"
  - `showToast(_ message:)` — sets toastMessage, auto-clears after 2s
- Uses completion handler callbacks (not async/await)
- Gets userId from Auth.auth().currentUser?.uid

## MealTrackerView Layout (screen 22)

Top-to-bottom in a ScrollView inside NavigationStack, dark background:

1. **Header**: HStack with "Todays meals" in white italic title + green "Add Meal +" button on right. The button is a NavigationLink to LogMealsView.

2. **Macro rings row**: HStack with three MacroRingViews:
   - Protein: purple ring, shows "100g / 120g" inside, "Protein" label below
   - Carbs: blue-green ring (Color(red: 0.2, green: 0.8, blue: 0.7)), shows "140g / 200g", "Carbs" label
   - Fats: magenta ring, shows "40g / 50g", "Fats" label
   - Current values are totalProtein/totalCarbs/totalFats, targets from user model

3. **Calories bar**: "Calories" label + horizontal progress bar (orange fill on grey track) showing "1800/2200". Uses ProgressView or GeometryReader for the bar. Current = totalCalories, target = user.recommendedCalories.

4. **Meal groups**: Three sections — Breakfast, Lunch, Dinner (italic headers). Each section shows meals for that type. Each meal row is an HStack:
   - Food emoji icon (🍎 for simplicity, or use systemName "fork.knife")
   - VStack: food name (bold) + macro text ("300kcal | Carbs 50g | Protein 5g | Fats 20g") in grey
   - Red minus circle button on right for delete

5. **Delete alert**: .alert with "Are you sure you want to delete this meal" + Yes/Cancel buttons

6. **Toast overlay**: ToastView at bottom when toastMessage is non-nil

## MacroRingView

- Parameters: `current: Double`, `target: Double`, `color: Color`, `label: String`
- ProgressRingView with overlay text showing "Xg / Yg" centered inside
- Label text below the ring
- Ring size ~80x80

## LogMealsView (screen 25)

- Presented via NavigationLink from "Add Meal +" button
- NavigationStack title: "Log meals" italic
- Search bar at top: HStack with magnifying glass + TextField "Search food"
- Below search: "Recent Meals" header (only shown when no search active)
- Results list: each row is HStack with food emoji, VStack(name bold, macro text grey), green "+" button
- Tapping "+" sets selectedFood and shows the add meal popup as an overlay
- The popup is shown as a `.overlay` or `.sheet` on the LogMealsView

## Add Meal Popup (screen 26)

- Shown as a dark overlay on LogMealsView when a food is selected
- Content: dark rounded rectangle with:
  - Food name (bold, white)
  - "Quantity" label + stepper (1-10, default 1)
  - "Meal type" label + Picker (Breakfast/Lunch/Dinner) with menu style
  - "Add meal" green button — calls viewModel.addMeal(), dismisses popup
  - "Close" red button — dismisses popup
- Calories and macros multiply by quantity
- After adding: shows toast "Meal added"

## FirestoreService Changes

Add two new methods to FirestoreService:

- `getTodaysMeals(userId: String, completion: @escaping ([Meal]) -> Void)` — queries meals collection filtered by userId and today's date
- `deleteMeal(mealId: String, completion: @escaping (String?) -> Void)` — deletes a meal document by ID

The existing `saveMeal` method already works for adding meals.

## Colours

- Protein ring: `.purple`
- Carbs ring: `Color(red: 0.2, green: 0.8, blue: 0.7)` (blue-green/teal)
- Fats ring: `Color(red: 0.9, green: 0.2, blue: 0.6)` (magenta)
- Calories bar fill: `.orange`
- Calories bar track: `Color.gray.opacity(0.3)`
- "Add Meal +" button: `.green`
- Delete button: `.red`
- Meal type headers: italic white
- Macro text: `.gray`
- Page background: `.black`

## Data Flow

```
MealTrackerView
  @StateObject viewModel = MealTrackerViewModel()

  .onAppear:
    viewModel.loadMeals()

  NavigationLink -> LogMealsView(viewModel: viewModel)
    User searches -> viewModel.searchFood()
    User taps "+" -> shows AddMealPopup overlay
    AddMealPopup calls viewModel.addMeal() -> saves to Firestore -> reloads meals -> toast
```

MealTrackerViewModel holds all state. LogMealsView receives it as @ObservedObject. AddMealPopup is a view shown as an overlay, calling back into the viewModel.

## Patterns to Follow

- ObservableObject + @Published + @StateObject (per CLAUDE.md)
- Completion handler callbacks, not async/await
- FirestoreService for all Firestore access
- Simple naming, casual comments, undergrad coding style
- NavigationStack + NavigationLink for drill-down navigation
- .alert() for confirmation dialogs
- ToastView for feedback (reuse existing component)
- ProgressRingView for macro rings (reuse existing component)
