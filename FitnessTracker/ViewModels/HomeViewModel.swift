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
