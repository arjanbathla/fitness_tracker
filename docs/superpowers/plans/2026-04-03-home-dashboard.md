# Home Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the home dashboard screen with greeting, weekly schedule card, calories ring, and live step counter.

**Architecture:** HomeView uses two @StateObject services — HomeViewModel for Firestore data and StepCounterService for live pedometer data. A reusable ProgressRingView component draws the calories circle. The current user's UID comes from `Auth.auth().currentUser?.uid`.

**Tech Stack:** SwiftUI, Firebase Firestore, CoreMotion (CMPedometer), FirebaseAuth

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `FitnessTracker/Services/StepCounterService.swift` | Create | CMPedometer wrapper — publishes live steps and distance |
| `FitnessTracker/Views/Components/ProgressRingView.swift` | Create | Reusable circular progress ring view |
| `FitnessTracker/Services/FirestoreService.swift` | Modify | Add `getWorkoutPlan(userId:completion:)` method for single-document fetch |
| `FitnessTracker/ViewModels/HomeViewModel.swift` | Create | Fetches user profile + workout plan from Firestore, computes greeting |
| `FitnessTracker/Views/Home/HomeView.swift` | Replace | Full dashboard UI with all 3 cards |

---

### Task 1: Create StepCounterService

**Files:**
- Create: `FitnessTracker/Services/StepCounterService.swift`

- [ ] **Step 1: Create StepCounterService.swift**

Following the accelerometer lab's MotionManager pattern (ObservableObject + @Published + start/stop methods), but using CMPedometer instead of CMMotionManager:

```swift
import Foundation
import CoreMotion

class StepCounterService: ObservableObject {
    private var pedometer = CMPedometer()

    @Published var steps: Int = 0
    @Published var distance: Double = 0.0 // in km

    func startCounting() {
        // check if step counting is available
        guard CMPedometer.isStepCountingAvailable() else {
            print("step counting not available")
            return
        }

        // query from midnight today
        let midnight = Calendar.current.startOfDay(for: Date())

        pedometer.startUpdates(from: midnight) { [weak self] data, error in
            if let error = error {
                print("pedometer error: \(error)")
                return
            }
            guard let data = data else { return }

            DispatchQueue.main.async {
                self?.steps = data.numberOfSteps.intValue
                if let dist = data.distance {
                    self?.distance = dist.doubleValue / 1000.0
                }
            }
        }
    }

    func stopCounting() {
        pedometer.stopUpdates()
    }
}
```

- [ ] **Step 2: Build to verify no compile errors**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Services/StepCounterService.swift
git commit -m "Add StepCounterService using CMPedometer"
```

---

### Task 2: Create ProgressRingView

**Files:**
- Create: `FitnessTracker/Views/Components/ProgressRingView.swift`

- [ ] **Step 1: Create ProgressRingView.swift**

A reusable circular progress ring — grey track behind, coloured arc on top:

```swift
import SwiftUI

struct ProgressRingView: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 12
    var color: Color = .orange

    var body: some View {
        ZStack {
            // grey track
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)

            // coloured arc
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    ProgressRingView(progress: 0.65, color: .orange)
        .frame(width: 120, height: 120)
        .padding()
        .background(Color.black)
}
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Views/Components/ProgressRingView.swift
git commit -m "Add reusable ProgressRingView component"
```

---

### Task 3: Add getWorkoutPlan method to FirestoreService

**Files:**
- Modify: `FitnessTracker/Services/FirestoreService.swift`

The onboarding saves the workout plan as a single document at `workoutPlans/{userId}`. The existing `getWorkoutPlans(userId:)` queries by field, but we need a direct document fetch with a completion handler so HomeViewModel can use it.

- [ ] **Step 1: Add getWorkoutPlan method**

Add this method to `FirestoreService`, after the existing `getWorkoutPlans(userId:)` method (around line 111):

```swift
func getWorkoutPlan(userId: String, completion: @escaping (WorkoutPlan?) -> Void) {
    db.collection("workoutPlans").document(userId).getDocument { (document, error) in
        if let error = error {
            print("error getting workout plan: \(error)")
            completion(nil)
            return
        }
        let plan = try? document?.data(as: WorkoutPlan.self)
        completion(plan)
    }
}
```

This follows the same pattern as the existing `getUser(userId:completion:)` method at line 30.

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Services/FirestoreService.swift
git commit -m "Add getWorkoutPlan single-document fetch to FirestoreService"
```

---

### Task 4: Create HomeViewModel

**Files:**
- Create: `FitnessTracker/ViewModels/HomeViewModel.swift`

- [ ] **Step 1: Create HomeViewModel.swift**

Uses FirestoreService with completion handlers (not async/await). Gets the current user's uid from `Auth.auth().currentUser?.uid`. Computes greeting based on time of day. Finds today's DayPlan by matching the current weekday.

```swift
import SwiftUI
import Combine
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var userName = ""
    @Published var greeting = ""
    @Published var todayWorkout: DayPlan?
    @Published var caloriesConsumed = 0
    @Published var caloriesTarget = 2200
    @Published var stepGoal = 10000
    @Published var isLoading = false

    var firestoreService = FirestoreService()

    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in")
            return
        }

        isLoading = true
        updateGreeting()

        // get user profile
        firestoreService.getUser(userId: uid) { [weak self] user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let user = user {
                    self.userName = user.fullName
                    self.caloriesTarget = user.recommendedCalories
                    self.stepGoal = user.stepGoal
                }

                // get workout plan
                self.firestoreService.getWorkoutPlan(userId: uid) { [weak self] plan in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.isLoading = false
                        if let plan = plan {
                            self.todayWorkout = self.getTodayPlan(from: plan)
                        }
                    }
                }
            }
        }
    }

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            greeting = "Good Morning,"
        } else if hour < 17 {
            greeting = "Good Afternoon,"
        } else {
            greeting = "Good Evening,"
        }
    }

    private func getTodayPlan(from plan: WorkoutPlan) -> DayPlan? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let dayMap: [Int: DayPlan.DayOfWeek] = [
            2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday, 1: .sunday
        ]
        guard let today = dayMap[weekday] else { return nil }
        return plan.days.first { $0.dayOfWeek == today }
    }
}
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/ViewModels/HomeViewModel.swift
git commit -m "Add HomeViewModel with Firestore data fetching"
```

---

### Task 5: Build HomeView

**Files:**
- Replace: `FitnessTracker/Views/Home/HomeView.swift`

- [ ] **Step 1: Replace HomeView with full dashboard**

Replace the entire contents of `HomeView.swift` with the dashboard layout matching `docs/screens/screen 10.png`. Uses @StateObject for both HomeViewModel and StepCounterService. Dark background, 3 cards (weekly schedule, calories, steps).

```swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var stepCounter = StepCounterService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    HStack {
                        Text(viewModel.userName)
                            .font(.title.bold().italic())
                            .foregroundStyle(.white)
                        Text("👋")
                            .font(.title2)
                    }
                }
                .padding(.top, 16)

                // weekly schedule card
                weeklyScheduleCard

                // calories card
                caloriesCard

                // steps card
                stepsCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.black)
        .onAppear {
            viewModel.loadData()
            stepCounter.startCounting()
        }
        .onDisappear {
            stepCounter.stopCounting()
        }
    }

    // MARK: - Weekly Schedule

    private var weeklyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly schedule - Today")
                .font(.headline.italic())
                .foregroundStyle(.white)

            if let workout = viewModel.todayWorkout {
                HStack {
                    Text("\(workout.workoutName) day - \(workout.isCompleted ? "completed" : "not completed")")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(workout.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                        .clipShape(Capsule())

                    Spacer()
                }
            } else {
                Text("Rest day")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Calories

    private var caloriesCard: some View {
        let consumed = viewModel.caloriesConsumed
        let target = viewModel.caloriesTarget
        let progress = target > 0 ? Double(consumed) / Double(target) : 0
        let percent = Int(progress * 100)

        return VStack(spacing: 16) {
            Text("Calories")
                .font(.headline.italic())
                .foregroundStyle(.white)

            ZStack {
                ProgressRingView(progress: progress, lineWidth: 14, color: .orange)
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    Text("/ \(target)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            // percentage bar
            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(percent)%")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Steps

    private var stepsCard: some View {
        let steps = stepCounter.steps
        let goal = viewModel.stepGoal
        let progress = goal > 0 ? Double(steps) / Double(goal) : 0
        let percent = Int(progress * 100)

        return VStack(spacing: 12) {
            Text("Steps")
                .font(.headline.italic())
                .foregroundStyle(.white)

            Text("\(steps)")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)

            Text("/ \(goal) Steps")
                .font(.subheadline)
                .foregroundStyle(.gray)

            // progress bar
            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(percent)%")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .frame(width: 35, alignment: .trailing)
            }

            Text("Distance: \(String(format: "%.1f", stepCounter.distance))km")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Views/Home/HomeView.swift
git commit -m "Build home dashboard with greeting, schedule, calories ring, and step counter"
```

---

### Task 6: Add new files to Xcode project

**Files:**
- Modify: `FitnessTracker.xcodeproj/project.pbxproj`

Xcode projects using the default file system sync (Xcode 16+) should pick up new files automatically. If the project uses explicit file references, you may need to add files via Xcode. Verify by building.

- [ ] **Step 1: Verify all new files are included in the build**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -10
```

If any "no such module" or "cannot find type" errors appear for the new files, open the project in Xcode and drag the missing files into the correct groups:
- `StepCounterService.swift` → Services group
- `ProgressRingView.swift` → Views/Components group
- `HomeViewModel.swift` → ViewModels group

- [ ] **Step 2: Final commit if pbxproj changed**

```bash
git add -A
git commit -m "Add new dashboard files to Xcode project"
```
