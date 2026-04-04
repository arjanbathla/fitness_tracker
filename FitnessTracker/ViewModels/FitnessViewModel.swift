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

        // seed exercises if none exist, then load them
        firestoreService.seedExercises { [weak self] in
            self?.firestoreService.loadExercises()
        }
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
