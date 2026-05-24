import SwiftUI
import Combine

// 3 step onboarding wizard
class SetupViewModel: ObservableObject {
    @Published var currentStep = 0
    let totalSteps = 3

    @Published var selectedGender: User.Gender = .male
    @Published var selectedHeight: Int = 0
    @Published var selectedWeight: Int = 70

    @Published var selectedGoal: User.FitnessGoal = .maintainBody

    @Published var recommendedCalories: Int = 2200
    @Published var proteinGoal: Int = 165
    @Published var carbsGoal: Int = 220
    @Published var fatsGoal: Int = 73
    @Published var workoutPlan: [(name: String, day: String)] = []
    @Published var generatedDayPlans: [DayPlan] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOnboardingComplete = false

    var firestoreService = FirestoreService()

    var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    var canContinueStep1: Bool {
        selectedHeight > 0
    }

    func nextStep() {
        if currentStep == 0 {
            guard canContinueStep1 else { return }
        }
        if currentStep == 1 {
            calcCalories()
            generatePlan()
        }
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func saveProfile(userId: String, fullName: String, email: String) {
        isLoading = true

        let height = Double(selectedHeight > 0 ? selectedHeight : 170)
        let user = User(
            fullName: fullName,
            email: email,
            gender: selectedGender,
            height: height,
            weight: Double(selectedWeight),
            fitnessGoal: selectedGoal,
            recommendedCalories: recommendedCalories,
            stepGoal: 10000,
            distanceUnit: .km,
            createdAt: Date(),
            proteinGoal: proteinGoal,
            carbsGoal: carbsGoal,
            fatsGoal: fatsGoal
        )

        firestoreService.saveUser(user, userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error
                    print("save user failed: \(error)")
                } else {
                    self?.savePlan(userId: userId)
                }
            }
        }
    }

    // mifflin st jeor formula 
    private func calcCalories() {
        let height = Double(selectedHeight > 0 ? selectedHeight : 170)
        let weight = Double(selectedWeight)

        // mifflin st jeor formula 
        let bmr: Double
        if selectedGender == .male {
            bmr = 10 * weight + 6.25 * height - 5 * 25 + 5
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * 25 - 161
        }

        let tdee = bmr * 1.55 // moderate activity multiplier

        switch selectedGoal {
        case .loseWeight:
            recommendedCalories = Int(tdee - 500)
        case .gainMuscle:
            recommendedCalories = Int(tdee + 300)
        case .maintainBody:
            recommendedCalories = Int(tdee)
        case .improveEndurance:
            recommendedCalories = Int(tdee + 200)
        }

            // 4 cals per gram protein/carbs, 9 per gram fat
        let cals = Double(recommendedCalories)
        switch selectedGoal {
        case .loseWeight:
            proteinGoal = Int(cals * 0.35 / 4)
            carbsGoal = Int(cals * 0.4 / 4)
            fatsGoal = Int(cals * 0.25 / 9)
        case .gainMuscle:
            proteinGoal = Int(cals * 0.3 / 4)
            carbsGoal = Int(cals * 0.5 / 4)
            fatsGoal = Int(cals * 0.2 / 9)
        case .maintainBody, .improveEndurance:
            proteinGoal = Int(cals * 0.25 / 4)
            carbsGoal = Int(cals * 0.55 / 4)
            fatsGoal = Int(cals * 0.2 / 9)
        }
    }

    // builds a weekly plan based on goal
    private func generatePlan() {
        switch selectedGoal {
        case .loseWeight:
            let upperBody: [PlannedExercise] = [
                PlannedExercise(name: "Bench Press", sets: 3, reps: "8-10"),
                PlannedExercise(name: "Lat Pulldown", sets: 3, reps: "10-12"),
                PlannedExercise(name: "Push-ups", sets: 3, reps: "Failure"),
                PlannedExercise(name: "Lateral Raises", sets: 3, reps: "15"),
                PlannedExercise(name: "Pec Flies", sets: 2, reps: "12-15"),
                PlannedExercise(name: "Tricep Dips", sets: 3, reps: "10-12"),
                PlannedExercise(name: "Bicep Curls", sets: 3, reps: "12")
            ]
            let lowerBody: [PlannedExercise] = [
                PlannedExercise(name: "Squats", sets: 4, reps: "10"),
                PlannedExercise(name: "Deadlifts", sets: 3, reps: "8"),
                PlannedExercise(name: "Calf Raises", sets: 4, reps: "15-20")
            ]
            generatedDayPlans = [
                DayPlan(dayOfWeek: .monday, workoutName: "Upper Body", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: upperBody),
                DayPlan(dayOfWeek: .tuesday, workoutName: "Lower Body", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: lowerBody),
                DayPlan(dayOfWeek: .wednesday, workoutName: "Cardio", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: []),
                DayPlan(dayOfWeek: .thursday, workoutName: "Upper Body", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: upperBody),
                DayPlan(dayOfWeek: .friday, workoutName: "Lower Body", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: lowerBody),
                DayPlan(dayOfWeek: .saturday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: []),
                DayPlan(dayOfWeek: .sunday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: [])
            ]

        case .gainMuscle:
            let upperBody: [PlannedExercise] = [
                PlannedExercise(name: "Bench Press", sets: 4, reps: "6-8"),
                PlannedExercise(name: "Lat Pulldown", sets: 4, reps: "8-10"),
                PlannedExercise(name: "Lateral Raises", sets: 4, reps: "12"),
                PlannedExercise(name: "Tricep Dips", sets: 3, reps: "8-10"),
                PlannedExercise(name: "Pec Flies", sets: 3, reps: "10-12"),
                PlannedExercise(name: "Bicep Curls", sets: 3, reps: "10-12"),
                PlannedExercise(name: "Push-ups", sets: 2, reps: "Failure")
            ]
            let lowerBody: [PlannedExercise] = [
                PlannedExercise(name: "Squats", sets: 4, reps: "8-10"),
                PlannedExercise(name: "Deadlifts", sets: 4, reps: "6-8"),
                PlannedExercise(name: "Calf Raises", sets: 5, reps: "12-15")
            ]
            generatedDayPlans = [
                DayPlan(dayOfWeek: .monday, workoutName: "Upper Body", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 8, isCompleted: false, exercises: upperBody),
                DayPlan(dayOfWeek: .tuesday, workoutName: "Lower Body", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 8, isCompleted: false, exercises: lowerBody),
                DayPlan(dayOfWeek: .wednesday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: []),
                DayPlan(dayOfWeek: .thursday, workoutName: "Upper Body", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 8, isCompleted: false, exercises: upperBody),
                DayPlan(dayOfWeek: .friday, workoutName: "Lower Body", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 8, isCompleted: false, exercises: lowerBody),
                DayPlan(dayOfWeek: .saturday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: []),
                DayPlan(dayOfWeek: .sunday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: [])
            ]

        case .maintainBody, .improveEndurance:
            let pushExercises: [PlannedExercise] = [
                PlannedExercise(name: "Bench Press", sets: 3, reps: "8-10"),
                PlannedExercise(name: "Push-ups", sets: 3, reps: "Failure"),
                PlannedExercise(name: "Pec Flies", sets: 3, reps: "12-15"),
                PlannedExercise(name: "Lateral Raises", sets: 3, reps: "15"),
                PlannedExercise(name: "Tricep Dips", sets: 3, reps: "10-12")
            ]
            let pullExercises: [PlannedExercise] = [
                PlannedExercise(name: "Lat Pulldown", sets: 4, reps: "10-12"),
                PlannedExercise(name: "Deadlifts", sets: 3, reps: "8"),
                PlannedExercise(name: "Bicep Curls", sets: 3, reps: "12-15")
            ]
            let legExercises: [PlannedExercise] = [
                PlannedExercise(name: "Squats", sets: 4, reps: "10"),
                PlannedExercise(name: "Calf Raises", sets: 4, reps: "15-20")
            ]
            generatedDayPlans = [
                DayPlan(dayOfWeek: .monday, workoutName: "Push", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: pushExercises),
                DayPlan(dayOfWeek: .tuesday, workoutName: "Pull", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: pullExercises),
                DayPlan(dayOfWeek: .wednesday, workoutName: "Legs", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 10, isCompleted: false, exercises: legExercises),
                DayPlan(dayOfWeek: .thursday, workoutName: "Rest", exerciseIds: [], setsPerExercise: 0, repsPerExercise: 0, isCompleted: false, exercises: []),
                DayPlan(dayOfWeek: .friday, workoutName: "Push", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: pushExercises),
                DayPlan(dayOfWeek: .saturday, workoutName: "Pull", exerciseIds: [], setsPerExercise: 3, repsPerExercise: 10, isCompleted: false, exercises: pullExercises),
                DayPlan(dayOfWeek: .sunday, workoutName: "Legs", exerciseIds: [], setsPerExercise: 4, repsPerExercise: 10, isCompleted: false, exercises: legExercises)
            ]
        }

        workoutPlan = generatedDayPlans.map { (name: $0.workoutName, day: $0.dayOfWeek.rawValue) }
    }

    private func savePlan(userId: String) {
        let plan = WorkoutPlan(userId: userId, days: generatedDayPlans)

        firestoreService.saveWorkoutPlan(plan, userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error
                    print("save plan failed: \(error)")
                } else {
                    self?.isOnboardingComplete = true
                    print("saved ok")
                }
            }
        }
    }
}
