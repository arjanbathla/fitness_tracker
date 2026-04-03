# Fitness Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the fitness tab with weekly workout plan (day pills, exercise list), exercise browse/search, exercise detail with video, and toast feedback.

**Architecture:** FitnessView uses a @StateObject FitnessViewModel that fetches the user's WorkoutPlan and all exercises from FirestoreService. NavigationStack with NavigationLink handles drill-down to ExerciseBrowseView and ExerciseDetailView. Toast messages are shown via an overlay. Reusable components (DayPillView, ExerciseCardView, ToastView) keep the main view focused.

**Tech Stack:** SwiftUI, Firebase Firestore, AVKit (video player), FirebaseAuth

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `FitnessTracker/Views/Components/ToastView.swift` | Create | Auto-dismissing bottom toast overlay |
| `FitnessTracker/Views/Components/DayPillView.swift` | Create | Reusable day pill (day label + workout name) |
| `FitnessTracker/Views/Components/ExerciseCardView.swift` | Create | Reusable exercise row card |
| `FitnessTracker/ViewModels/FitnessViewModel.swift` | Create | Fetches plan + exercises, manages state |
| `FitnessTracker/Views/Fitness/ExerciseDetailView.swift` | Create | Exercise detail with video and description |
| `FitnessTracker/Views/Fitness/ExerciseBrowseView.swift` | Create | Browse all exercises with search |
| `FitnessTracker/Views/Fitness/FitnessView.swift` | Replace | Main workout plan screen |

---

### Task 1: Create ToastView

**Files:**
- Create: `FitnessTracker/Views/Components/ToastView.swift`

- [ ] **Step 1: Create ToastView.swift**

```swift
import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(white: 0.2))
            .clipShape(Capsule())
            .shadow(radius: 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            ToastView(message: "Workout added")
                .padding(.bottom, 30)
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Components/ToastView.swift
git commit -m "Add ToastView component"
```

---

### Task 2: Create DayPillView

**Files:**
- Create: `FitnessTracker/Views/Components/DayPillView.swift`

- [ ] **Step 1: Create DayPillView.swift**

```swift
import SwiftUI

struct DayPillView: View {
    var dayLabel: String
    var workoutName: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(dayLabel)
                .font(.caption2.bold())
            Text(workoutName)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(width: 60, height: 50)
        .background(isSelected ? Color.green : Color(white: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HStack {
        DayPillView(dayLabel: "Mon", workoutName: "Leg day", isSelected: true)
        DayPillView(dayLabel: "Tue", workoutName: "Chest day", isSelected: false)
    }
    .padding()
    .background(Color.black)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Components/DayPillView.swift
git commit -m "Add DayPillView component"
```

---

### Task 3: Create ExerciseCardView

**Files:**
- Create: `FitnessTracker/Views/Components/ExerciseCardView.swift`

- [ ] **Step 1: Create ExerciseCardView.swift**

```swift
import SwiftUI

struct ExerciseCardView: View {
    var name: String
    var sets: Int
    var reps: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body.bold())
                    .foregroundStyle(.white)
                Text("\(sets) sets, \(reps) reps")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(14)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ExerciseCardView(name: "Squats", sets: 3, reps: 10)
        .padding()
        .background(Color.black)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Components/ExerciseCardView.swift
git commit -m "Add ExerciseCardView component"
```

---

### Task 4: Create FitnessViewModel

**Files:**
- Create: `FitnessTracker/ViewModels/FitnessViewModel.swift`

- [ ] **Step 1: Create FitnessViewModel.swift**

Uses existing `FirestoreService.getWorkoutPlan(userId:completion:)`, `FirestoreService.loadExercises()`, and `FirestoreService.saveWorkoutPlan(_:userId:completion:)`. Gets userId from `Auth.auth().currentUser?.uid`.

The `dayLabels` array maps indices 0-4 to Mon-Fri. `selectedDayPlan` is computed from the workout plan's days array. `dayExercises` filters the full exercises list by the exerciseIds in the selected day plan.

```swift
import SwiftUI
import Combine
import FirebaseAuth

class FitnessViewModel: ObservableObject {
    @Published var workoutPlan: WorkoutPlan?
    @Published var exercises: [Exercise] = []
    @Published var selectedDayIndex = 0
    @Published var searchText = ""
    @Published var toastMessage: String?
    @Published var showCompleteAlert = false
    @Published var showDeleteAlert = false
    @Published var isLoading = false

    var firestoreService = FirestoreService()

    let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let dayKeys: [DayPlan.DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday]

    var selectedDayPlan: DayPlan? {
        guard let plan = workoutPlan else { return nil }
        let key = dayKeys[selectedDayIndex]
        return plan.days.first { $0.dayOfWeek == key }
    }

    var dayExercises: [Exercise] {
        guard let dayPlan = selectedDayPlan else { return [] }
        if dayPlan.exerciseIds.isEmpty {
            // if no specific exercise ids, filter by muscle group matching workout name
            return exercises.filter { exercise in
                exercise.muscleGroup.rawValue.lowercased().contains(dayPlan.workoutName.lowercased())
            }
        }
        return exercises.filter { exercise in
            dayPlan.exerciseIds.contains(exercise.id ?? "")
        }
    }

    var filteredDayExercises: [Exercise] {
        if searchText.isEmpty { return dayExercises }
        return dayExercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in")
            return
        }

        isLoading = true

        firestoreService.getWorkoutPlan(userId: uid) { [weak self] plan in
            DispatchQueue.main.async {
                self?.workoutPlan = plan
                self?.isLoading = false
            }
        }

        firestoreService.loadExercises()
        // exercises are published on firestoreService.exercises
        // we need to copy them over when they load
        firestoreService.$exercises
            .receive(on: DispatchQueue.main)
            .assign(to: &$exercises)
    }

    func markCompleted() {
        guard let uid = Auth.auth().currentUser?.uid,
              var plan = workoutPlan else { return }

        let key = dayKeys[selectedDayIndex]
        if let idx = plan.days.firstIndex(where: { $0.dayOfWeek == key }) {
            plan.days[idx].isCompleted = true
            workoutPlan = plan

            firestoreService.saveWorkoutPlan(plan, userId: uid) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("save failed: \(error)")
                    } else {
                        self?.showToast("Workout added")
                    }
                }
            }
        }
    }

    func deleteWorkout() {
        guard let uid = Auth.auth().currentUser?.uid,
              var plan = workoutPlan else { return }

        let key = dayKeys[selectedDayIndex]
        if let idx = plan.days.firstIndex(where: { $0.dayOfWeek == key }) {
            plan.days[idx].isCompleted = false
            plan.days[idx].exerciseIds = []
            workoutPlan = plan

            firestoreService.saveWorkoutPlan(plan, userId: uid) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("save failed: \(error)")
                    } else {
                        self?.showToast("Workout deleted")
                    }
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
git add FitnessTracker/ViewModels/FitnessViewModel.swift
git commit -m "Add FitnessViewModel with plan and exercise fetching"
```

---

### Task 5: Create ExerciseDetailView

**Files:**
- Create: `FitnessTracker/Views/Fitness/ExerciseDetailView.swift`

- [ ] **Step 1: Create ExerciseDetailView.swift**

Shows exercise name as nav title, video/image at top loaded from exercise.videoURL, description text below. Uses VideoPlayer from AVKit if the URL looks like a video, otherwise AsyncImage.

```swift
import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    var exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // video or image
                if let url = URL(string: exercise.videoURL) {
                    if exercise.videoURL.hasSuffix(".mp4") || exercise.videoURL.hasSuffix(".mov") {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ZStack {
                                Color(white: 0.15)
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    ZStack {
                        Color(white: 0.15)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(exercise.description)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
            }
            .padding(16)
        }
        .background(Color.black)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            name: "Squats",
            muscleGroup: .legs,
            equipment: "Barbell",
            difficulty: .beginner,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc maximus, nulla ut commodo sagittis, sapien dui mattis dui non pulvinar lorem felis nec erat.",
            videoURL: ""
        ))
    }
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Fitness/ExerciseDetailView.swift
git commit -m "Add ExerciseDetailView with video player and description"
```

---

### Task 6: Create ExerciseBrowseView

**Files:**
- Create: `FitnessTracker/Views/Fitness/ExerciseBrowseView.swift`

- [ ] **Step 1: Create ExerciseBrowseView.swift**

Full list of all exercises with search filtering. Each row shows exercise name + muscle group + chevron. Tapping navigates to ExerciseDetailView. Search filters by name or muscle group (case-insensitive contains).

```swift
import SwiftUI

struct ExerciseBrowseView: View {
    var exercises: [Exercise]
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var filtered: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.muscleGroup.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // search bar
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("Search Exercise", text: $searchText)
                        .foregroundStyle(.white)
                }
                .padding(10)
                .background(Color(white: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.green)
                .font(.subheadline.bold())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // exercise list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filtered) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.body.bold())
                                        .foregroundStyle(.white)
                                    Text(exercise.muscleGroup.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(14)
                            .background(Color(white: 0.11))
                        }
                    }
                }
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        ExerciseBrowseView(exercises: [
            Exercise(name: "Squats", muscleGroup: .legs, equipment: "Barbell", difficulty: .beginner, description: "A leg exercise", videoURL: ""),
            Exercise(name: "Bench press", muscleGroup: .chest, equipment: "Barbell", difficulty: .intermediate, description: "A chest exercise", videoURL: ""),
        ])
    }
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Fitness/ExerciseBrowseView.swift
git commit -m "Add ExerciseBrowseView with search filtering"
```

---

### Task 7: Build FitnessView

**Files:**
- Replace: `FitnessTracker/Views/Fitness/FitnessView.swift`

- [ ] **Step 1: Replace FitnessView with full workout plan screen**

Replace the entire placeholder with the workout plan layout. Uses NavigationStack. Contains day pills row, search bar with "View all" button, selected day header with completion badge, exercise list, "View nearby gyms" button, toast overlay, and confirmation alerts.

```swift
import SwiftUI

struct FitnessView: View {
    @StateObject private var viewModel = FitnessViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your workout plan")
                            .font(.title2.bold().italic())
                            .foregroundStyle(.white)
                            .padding(.top, 8)

                        dayPillsRow

                        searchRow

                        dayHeader

                        exerciseList

                        nearbyGymsButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }

                // toast
                if let msg = viewModel.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: viewModel.toastMessage)
                }
            }
            .background(Color.black)
            .alert("Have you completed this workout?", isPresented: $viewModel.showCompleteAlert) {
                Button("Yes") { viewModel.markCompleted() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Do you want to delete this workout?", isPresented: $viewModel.showDeleteAlert) {
                Button("Yes", role: .destructive) { viewModel.deleteWorkout() }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear { viewModel.loadData() }
        }
    }

    private var dayPillsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    let key = viewModel.dayKeys[index]
                    let dayPlan = viewModel.workoutPlan?.days.first { $0.dayOfWeek == key }
                    let name = dayPlan?.workoutName ?? "Rest"

                    DayPillView(
                        dayLabel: viewModel.dayLabels[index],
                        workoutName: name,
                        isSelected: viewModel.selectedDayIndex == index
                    )
                    .onTapGesture {
                        viewModel.selectedDayIndex = index
                    }
                }
            }
        }
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField("Search Exercise", text: $viewModel.searchText)
                    .foregroundStyle(.white)
            }
            .padding(10)
            .background(Color(white: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            NavigationLink(destination: ExerciseBrowseView(exercises: viewModel.exercises)) {
                Text("View all")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dayPlan = viewModel.selectedDayPlan {
                HStack {
                    Text("\(dayPlan.dayOfWeek.rawValue) – \(dayPlan.workoutName.lowercased()) routine")
                        .font(.headline.italic())
                        .foregroundStyle(.white)

                    Spacer()
                }

                HStack(spacing: 12) {
                    Button {
                        viewModel.showCompleteAlert = true
                    } label: {
                        Text(dayPlan.isCompleted ? "workout completed" : "workout not completed")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(dayPlan.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                    }

                    if dayPlan.isCompleted {
                        Button {
                            viewModel.showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            } else {
                Text("Rest day")
                    .font(.headline.italic())
                    .foregroundStyle(.gray)
            }
        }
    }

    private var exerciseList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.filteredDayExercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    ExerciseCardView(
                        name: exercise.name,
                        sets: viewModel.selectedDayPlan?.setsPerExercise ?? 3,
                        reps: viewModel.selectedDayPlan?.repsPerExercise ?? 10
                    )
                }
            }
        }
    }

    private var nearbyGymsButton: some View {
        Button {
            // placeholder - nearby gyms not yet implemented
        } label: {
            Text("View nearby gyms")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
}

#Preview {
    FitnessView()
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Commit**

```bash
git add FitnessTracker/Views/Fitness/FitnessView.swift
git commit -m "Build FitnessView with day pills, exercise list, search, and toast"
```
