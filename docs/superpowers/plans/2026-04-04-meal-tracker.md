# Meal Tracker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the meal tracker tab with macro rings, calorie bar, grouped meals, Edamam food search, add meal popup, and delete confirmation.

**Architecture:** MealTrackerViewModel owns all state. MealTrackerView shows today's meals with macro rings. LogMealsView searches Edamam API and shows an add meal popup overlay. EdamamService handles API calls. FirestoreService handles persistence.

**Tech Stack:** SwiftUI, Firebase Firestore, Edamam Food Database API, URLSession

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `FitnessTracker/Utilities/Constants.swift` | Create | Edamam API credentials |
| `FitnessTracker/Models/User.swift` | Modify | Add macro goal fields + custom decoder |
| `FitnessTracker/Services/EdamamService.swift` | Create | Food search API calls |
| `FitnessTracker/Services/FirestoreService.swift` | Modify | Add getTodaysMeals + deleteMeal methods |
| `FitnessTracker/ViewModels/MealTrackerViewModel.swift` | Create | All meal tracker state and logic |
| `FitnessTracker/Views/Components/MacroRingView.swift` | Create | Labeled ring with value/target text |
| `FitnessTracker/Views/MealTracker/MealTrackerView.swift` | Replace | Today's meals screen |
| `FitnessTracker/Views/MealTracker/LogMealsView.swift` | Create | Search + add meal popup |

---

### Task 1: Constants + User Model Changes

**Files:**
- Create: `FitnessTracker/Utilities/Constants.swift`
- Modify: `FitnessTracker/Models/User.swift`
- Modify: `FitnessTracker/ViewModels/OnboardingViewModel.swift`

- [ ] **Step 1: Create Constants.swift**

Create `FitnessTracker/Utilities/Constants.swift`:

```swift
import Foundation

struct Constants {
    static let edamamAppId = "901b44bd"
    static let edamamAppKey = "1b4b28deed3ae699e7a7e339974abf81"
}
```

- [ ] **Step 2: Add macro goal fields to User model**

In `FitnessTracker/Models/User.swift`, add three new fields after `distanceUnit`:

```swift
var proteinGoal: Int
var carbsGoal: Int
var fatsGoal: Int
```

Then add a custom `init(from:)` so existing Firestore users without these fields don't crash. Add this inside the User struct after the enums:

```swift
    init(fullName: String, email: String, gender: Gender, height: Double, weight: Double, fitnessGoal: FitnessGoal, recommendedCalories: Int, stepGoal: Int, distanceUnit: DistanceUnit, createdAt: Date, proteinGoal: Int? = nil, carbsGoal: Int? = nil, fatsGoal: Int? = nil) {
        self.fullName = fullName
        self.email = email
        self.gender = gender
        self.height = height
        self.weight = weight
        self.fitnessGoal = fitnessGoal
        self.recommendedCalories = recommendedCalories
        self.stepGoal = stepGoal
        self.distanceUnit = distanceUnit
        self.createdAt = createdAt
        // default macro goals based on calories if not provided
        self.proteinGoal = proteinGoal ?? (recommendedCalories * 30 / 100 / 4)
        self.carbsGoal = carbsGoal ?? (recommendedCalories * 40 / 100 / 4)
        self.fatsGoal = fatsGoal ?? (recommendedCalories * 30 / 100 / 9)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        email = try container.decode(String.self, forKey: .email)
        gender = try container.decode(Gender.self, forKey: .gender)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        fitnessGoal = try container.decode(FitnessGoal.self, forKey: .fitnessGoal)
        recommendedCalories = try container.decode(Int.self, forKey: .recommendedCalories)
        stepGoal = try container.decode(Int.self, forKey: .stepGoal)
        distanceUnit = try container.decode(DistanceUnit.self, forKey: .distanceUnit)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        proteinGoal = (try? container.decode(Int.self, forKey: .proteinGoal)) ?? (recommendedCalories * 30 / 100 / 4)
        carbsGoal = (try? container.decode(Int.self, forKey: .carbsGoal)) ?? (recommendedCalories * 40 / 100 / 4)
        fatsGoal = (try? container.decode(Int.self, forKey: .fatsGoal)) ?? (recommendedCalories * 30 / 100 / 9)
    }
```

Update the `static let default` to include the new fields:

```swift
    static let `default` = User(
        fullName: "",
        email: "",
        gender: .male,
        height: 170,
        weight: 70,
        fitnessGoal: .maintainBody,
        recommendedCalories: 2200,
        stepGoal: 10000,
        distanceUnit: .km,
        createdAt: .now,
        proteinGoal: 165,
        carbsGoal: 220,
        fatsGoal: 73
    )
```

- [ ] **Step 3: Verify OnboardingViewModel still compiles**

The existing `User(...)` init call in `OnboardingViewModel.swift` (line 48-59) does NOT pass proteinGoal/carbsGoal/fatsGoal — this is fine because the memberwise init has defaults (`nil`) so it will auto-calculate from recommendedCalories. No change needed.

- [ ] **Step 4: Commit**

```bash
git add FitnessTracker/Utilities/Constants.swift FitnessTracker/Models/User.swift
git commit -m "feat: add Constants file and macro goal fields to User model"
```

---

### Task 2: EdamamService

**Files:**
- Create: `FitnessTracker/Services/EdamamService.swift`

- [ ] **Step 1: Create EdamamService**

Create `FitnessTracker/Services/EdamamService.swift`:

```swift
import Foundation
import Combine

struct EdamamFood {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
}

class EdamamService: ObservableObject {
    @Published var searchResults: [EdamamFood] = []

    func searchFood(query: String, completion: @escaping ([EdamamFood]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.edamam.com/api/food-database/v2/parser?ingr=\(encoded)&app_id=\(Constants.edamamAppId)&app_key=\(Constants.edamamAppKey)"

        guard let url = URL(string: urlString) else {
            print("bad url")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("api error: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let hints = json["hints"] as? [[String: Any]] else {
                    completion([])
                    return
                }

                var foods: [EdamamFood] = []
                for hint in hints.prefix(10) {
                    guard let food = hint["food"] as? [String: Any],
                          let label = food["label"] as? String,
                          let nutrients = food["nutrients"] as? [String: Any] else {
                        continue
                    }

                    let cal = Int(nutrients["ENERC_KCAL"] as? Double ?? 0)
                    let prot = nutrients["PROCNT"] as? Double ?? 0
                    let carb = nutrients["CHOCDF"] as? Double ?? 0
                    let fat = nutrients["FAT"] as? Double ?? 0

                    foods.append(EdamamFood(
                        name: label,
                        calories: cal,
                        protein: round(prot * 10) / 10,
                        carbs: round(carb * 10) / 10,
                        fats: round(fat * 10) / 10
                    ))
                }

                // remove duplicates by name
                var seen = Set<String>()
                let unique = foods.filter { seen.insert($0.name).inserted }

                completion(unique)
            } catch {
                print("parse error: \(error)")
                completion([])
            }
        }.resume()
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Services/EdamamService.swift
git commit -m "feat: add EdamamService for food search API"
```

---

### Task 3: FirestoreService Additions

**Files:**
- Modify: `FitnessTracker/Services/FirestoreService.swift`

- [ ] **Step 1: Add getTodaysMeals and deleteMeal methods**

Add these two methods to the end of `FirestoreService` class, before the closing `}` (after the `seedExercises` method):

```swift
    func getTodaysMeals(userId: String, completion: @escaping ([Meal]) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        db.collection("meals")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("error getting meals: \(error)")
                    completion([])
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let meals = documents.compactMap { doc -> Meal? in
                    try? doc.data(as: Meal.self)
                }
                print("got \(meals.count) meals for today")
                completion(meals)
            }
    }

    func deleteMeal(mealId: String, completion: @escaping (String?) -> Void) {
        db.collection("meals").document(mealId).delete { error in
            if let error = error {
                print("error deleting meal: \(error)")
                completion(error.localizedDescription)
            } else {
                print("meal deleted")
                completion(nil)
            }
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Services/FirestoreService.swift
git commit -m "feat: add getTodaysMeals and deleteMeal to FirestoreService"
```

---

### Task 4: MacroRingView Component

**Files:**
- Create: `FitnessTracker/Views/Components/MacroRingView.swift`

- [ ] **Step 1: Create MacroRingView**

Create `FitnessTracker/Views/Components/MacroRingView.swift`:

```swift
import SwiftUI

struct MacroRingView: View {
    var current: Double
    var target: Double
    var color: Color
    var label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                ProgressRingView(
                    progress: target > 0 ? current / target : 0,
                    lineWidth: 8,
                    color: color
                )

                VStack(spacing: 0) {
                    Text("\(Int(current))g")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Text("/ \(Int(target))g")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 80, height: 80)

            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        MacroRingView(current: 100, target: 120, color: .purple, label: "Protein")
        MacroRingView(current: 140, target: 200, color: Color(red: 0.2, green: 0.8, blue: 0.7), label: "Carbs")
        MacroRingView(current: 40, target: 50, color: Color(red: 0.9, green: 0.2, blue: 0.6), label: "Fats")
    }
    .padding()
    .background(Color.black)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Components/MacroRingView.swift
git commit -m "feat: add MacroRingView component"
```

---

### Task 5: MealTrackerViewModel

**Files:**
- Create: `FitnessTracker/ViewModels/MealTrackerViewModel.swift`

- [ ] **Step 1: Create MealTrackerViewModel**

Create `FitnessTracker/ViewModels/MealTrackerViewModel.swift`:

```swift
import SwiftUI
import Combine
import FirebaseAuth

class MealTrackerViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var user: User?
    @Published var searchText = ""
    @Published var searchResults: [EdamamFood] = []
    @Published var toastMessage: String?
    @Published var showDeleteAlert = false
    @Published var isSearching = false

    var mealToDelete: Meal?

    var firestoreService = FirestoreService()
    var edamamService = EdamamService()

    var breakfastMeals: [Meal] { meals.filter { $0.mealType == .breakfast } }
    var lunchMeals: [Meal] { meals.filter { $0.mealType == .lunch } }
    var dinnerMeals: [Meal] { meals.filter { $0.mealType == .dinner } }

    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { meals.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { meals.reduce(0) { $0 + $1.carbs } }
    var totalFats: Double { meals.reduce(0) { $0 + $1.fats } }

    func loadMeals() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in")
            return
        }

        // load user profile for macro targets
        firestoreService.getUser(userId: uid) { [weak self] user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }

        // load today's meals
        firestoreService.getTodaysMeals(userId: uid) { [weak self] meals in
            DispatchQueue.main.async {
                self?.meals = meals
            }
        }
    }

    func searchFood() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        edamamService.searchFood(query: searchText) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
                self?.isSearching = false
            }
        }
    }

    func addMeal(food: EdamamFood, quantity: Int, mealType: Meal.MealType) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let meal = Meal(
            userId: uid,
            date: Date(),
            foodName: food.name,
            mealType: mealType,
            calories: food.calories * quantity,
            protein: food.protein * Double(quantity),
            carbs: food.carbs * Double(quantity),
            fats: food.fats * Double(quantity),
            quantity: quantity
        )

        firestoreService.saveMeal(meal) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("save meal failed: \(error)")
                } else {
                    self?.showToast("Meal added")
                    self?.loadMeals()
                }
            }
        }
    }

    func deleteMeal() {
        guard let meal = mealToDelete, let id = meal.id else { return }

        firestoreService.deleteMeal(mealId: id) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("delete failed: \(error)")
                } else {
                    self?.showToast("Meal Deleted")
                    self?.loadMeals()
                }
            }
        }
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.toastMessage = nil
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/ViewModels/MealTrackerViewModel.swift
git commit -m "feat: add MealTrackerViewModel"
```

---

### Task 6: MealTrackerView

**Files:**
- Replace: `FitnessTracker/Views/MealTracker/MealTrackerView.swift`

- [ ] **Step 1: Replace MealTrackerView with full implementation**

Replace the entire contents of `FitnessTracker/Views/MealTracker/MealTrackerView.swift`:

```swift
import SwiftUI

struct MealTrackerView: View {
    @StateObject private var viewModel = MealTrackerViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        macroRingsRow

                        caloriesBar

                        mealSection("Breakfast", meals: viewModel.breakfastMeals)

                        mealSection("Lunch", meals: viewModel.lunchMeals)

                        mealSection("Dinner", meals: viewModel.dinnerMeals)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }

                if let msg = viewModel.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: viewModel.toastMessage)
                }
            }
            .background(Color.black)
            .alert("Delete item", isPresented: $viewModel.showDeleteAlert) {
                Button("Yes", role: .destructive) { viewModel.deleteMeal() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this meal?")
            }
            .onAppear { viewModel.loadMeals() }
        }
    }

    private var header: some View {
        HStack {
            Text("Todays meals")
                .font(.title.bold().italic())
                .foregroundStyle(.white)

            Spacer()

            NavigationLink(destination: LogMealsView(viewModel: viewModel)) {
                Text("Add Meal +")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.top, 8)
    }

    private var macroRingsRow: some View {
        HStack(spacing: 20) {
            Spacer()
            MacroRingView(
                current: viewModel.totalProtein,
                target: Double(viewModel.user?.proteinGoal ?? 165),
                color: .purple,
                label: "Protein"
            )
            MacroRingView(
                current: viewModel.totalCarbs,
                target: Double(viewModel.user?.carbsGoal ?? 220),
                color: Color(red: 0.2, green: 0.8, blue: 0.7),
                label: "Carbs"
            )
            MacroRingView(
                current: viewModel.totalFats,
                target: Double(viewModel.user?.fatsGoal ?? 73),
                color: Color(red: 0.9, green: 0.2, blue: 0.6),
                label: "Fats"
            )
            Spacer()
        }
    }

    private var caloriesBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Calories")
                .font(.headline)
                .foregroundStyle(.white)

            let target = viewModel.user?.recommendedCalories ?? 2200
            let progress = target > 0 ? Double(viewModel.totalCalories) / Double(target) : 0

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(width: geo.size.width * min(progress, 1.0), height: 20)
                }
                .frame(height: 20)

                HStack {
                    Spacer()
                    Text("\(viewModel.totalCalories)/\(target)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
        }
    }

    private func mealSection(_ title: String, meals: [Meal]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.italic())
                .foregroundStyle(.white)
                .padding(.top, 4)

            if meals.isEmpty {
                Text("No meals logged")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 4)
            } else {
                ForEach(meals) { meal in
                    mealRow(meal)
                }
            }
        }
    }

    private func mealRow(_ meal: Meal) -> some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.foodName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("\(meal.calories)kcal | Carbs \(Int(meal.carbs))g | Protein \(Int(meal.protein))g | Fats \(Int(meal.fats))g")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                viewModel.mealToDelete = meal
                viewModel.showDeleteAlert = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding(10)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    MealTrackerView()
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/MealTracker/MealTrackerView.swift
git commit -m "feat: build MealTrackerView with macro rings and meal list"
```

---

### Task 7: LogMealsView with Add Meal Popup

**Files:**
- Create: `FitnessTracker/Views/MealTracker/LogMealsView.swift`

- [ ] **Step 1: Create LogMealsView**

Create `FitnessTracker/Views/MealTracker/LogMealsView.swift`:

```swift
import SwiftUI

struct LogMealsView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFood: EdamamFood?
    @State private var quantity = 1
    @State private var mealType: Meal.MealType = .breakfast
    @State private var showPopup = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.isSearching {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Spacer()
                    Text("No results found")
                        .foregroundStyle(.gray)
                    Spacer()
                } else {
                    List(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, food in
                        foodRow(food)
                            .listRowBackground(Color(white: 0.11))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }

            // add meal popup overlay
            if showPopup, let food = selectedFood {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { showPopup = false }

                addMealPopup(food: food)
            }
        }
        .background(Color.black)
        .navigationTitle("Log meals")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField("Search food", text: $viewModel.searchText)
                    .foregroundStyle(.white)
                    .onSubmit {
                        viewModel.searchFood()
                    }
            }
            .padding(10)
            .background(Color(white: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func foodRow(_ food: EdamamFood) -> some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("\(food.calories)kcal | Carbs \(Int(food.carbs))g | Protein \(Int(food.protein))g | Fats \(Int(food.fats))g")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                selectedFood = food
                quantity = 1
                mealType = .breakfast
                showPopup = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private func addMealPopup(food: EdamamFood) -> some View {
        VStack(spacing: 16) {
            Text(food.name)
                .font(.headline.bold())
                .foregroundStyle(.white)

            Text("\(food.calories * quantity)kcal | Carbs \(Int(food.carbs * Double(quantity)))g | Protein \(Int(food.protein * Double(quantity)))g | Fats \(Int(food.fats * Double(quantity)))g")
                .font(.caption)
                .foregroundStyle(.gray)

            HStack {
                Text("Quantity")
                    .foregroundStyle(.white)
                Spacer()
                Stepper("\(quantity)", value: $quantity, in: 1...10)
                    .foregroundStyle(.white)
                    .labelsHidden()
                Text("\(quantity)")
                    .foregroundStyle(.white)
                    .frame(width: 24)
            }

            HStack {
                Text("Meal type")
                    .foregroundStyle(.white)
                Spacer()
                Picker("Meal type", selection: $mealType) {
                    ForEach(Meal.MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .tint(.white)
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.addMeal(food: food, quantity: quantity, mealType: mealType)
                    showPopup = false
                    dismiss()
                } label: {
                    Text("Add meal")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    showPopup = false
                } label: {
                    Text("Close")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }
}

#Preview {
    NavigationStack {
        LogMealsView(viewModel: MealTrackerViewModel())
    }
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/MealTracker/LogMealsView.swift
git commit -m "feat: add LogMealsView with search and add meal popup"
```
