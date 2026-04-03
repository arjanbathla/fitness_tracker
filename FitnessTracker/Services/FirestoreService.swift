import Foundation
import Combine
import FirebaseFirestore

class FirestoreService: ObservableObject {
    @Published var users: [User] = []
    @Published var exercises: [Exercise] = []
    @Published var meals: [Meal] = []
    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var dailyStats: [DailyStats] = []

    private var db = Firestore.firestore()

    func getUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting users: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.users = documents.compactMap { doc -> User? in
                try? doc.data(as: User.self)
            }
            print("got \(self.users.count) users")
        }
    }

    func getUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("error getting user: \(error)")
                completion(nil)
                return
            }
            let user = try? document?.data(as: User.self)
            completion(user)
        }
    }

    func saveUser(_ user: User, userId: String, completion: @escaping (String?) -> Void) {
        do {
            try db.collection("users").document(userId).setData(from: user)
            completion(nil)
        } catch {
            completion(error.localizedDescription)
        }
    }

    func loadExercises() {
        db.collection("exercises").getDocuments { (snapshot, error) in
            if let error = error {
                print("error loading exercises: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.exercises = documents.compactMap { doc -> Exercise? in
                try? doc.data(as: Exercise.self)
            }
            print("got \(self.exercises.count) exercises")
        }
    }

    func getMeals(userId: String) {
        db.collection("meals").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting meals: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.meals = documents.compactMap { doc -> Meal? in
                try? doc.data(as: Meal.self)
            }
            print("got \(self.meals.count) meals")
        }
    }

    func saveMeal(_ meal: Meal, completion: @escaping (String?) -> Void) {
        do {
            _ = try db.collection("meals").addDocument(from: meal)
            completion(nil)
        } catch {
            completion(error.localizedDescription)
        }
    }

    func saveWorkoutPlan(_ plan: WorkoutPlan, userId: String, completion: @escaping (String?) -> Void) {
        do {
            try db.collection("workoutPlans").document(userId).setData(from: plan)
            completion(nil)
        } catch {
            completion(error.localizedDescription)
        }
    }

    func getWorkoutPlans(userId: String) {
        db.collection("workoutPlans").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting workout plans: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.workoutPlans = documents.compactMap { doc -> WorkoutPlan? in
                try? doc.data(as: WorkoutPlan.self)
            }
        }
    }

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

    func getWorkoutSessions(userId: String) {
        db.collection("workoutSessions").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting sessions: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.workoutSessions = documents.compactMap { doc -> WorkoutSession? in
                try? doc.data(as: WorkoutSession.self)
            }
        }
    }

    func getDailyStats(userId: String) {
        db.collection("dailyStats").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting stats: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.dailyStats = documents.compactMap { doc -> DailyStats? in
                try? doc.data(as: DailyStats.self)
            }
        }
    }
}
