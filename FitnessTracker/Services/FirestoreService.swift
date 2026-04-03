import Foundation
import FirebaseFirestore

class FirestoreService: ObservableObject {
    @Published var users: [User] = []
    @Published var exercises: [Exercise] = []
    @Published var meals: [Meal] = []
    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var dailyStats: [DailyStats] = []

    private var db = Firestore.firestore()

    // MARK: - Users

    func fetchUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'users' collection.")
                return
            }

            self.users = documents.compactMap { docSnapshot -> User? in
                try? docSnapshot.data(as: User.self)
            }

            print("Fetched users: \(self.users)")
        }
    }

    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error getting user: \(error.localizedDescription)")
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

    // MARK: - Exercises

    func fetchExercises() {
        db.collection("exercises").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'exercises' collection.")
                return
            }

            self.exercises = documents.compactMap { docSnapshot -> Exercise? in
                try? docSnapshot.data(as: Exercise.self)
            }

            print("Fetched exercises: \(self.exercises)")
        }
    }

    // MARK: - Meals

    func fetchMeals(userId: String) {
        db.collection("meals").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'meals' collection.")
                return
            }

            self.meals = documents.compactMap { docSnapshot -> Meal? in
                try? docSnapshot.data(as: Meal.self)
            }

            print("Fetched meals: \(self.meals)")
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

    // MARK: - Workout Plans

    func fetchWorkoutPlans(userId: String) {
        db.collection("workoutPlans").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'workoutPlans' collection.")
                return
            }

            self.workoutPlans = documents.compactMap { docSnapshot -> WorkoutPlan? in
                try? docSnapshot.data(as: WorkoutPlan.self)
            }

            print("Fetched workout plans: \(self.workoutPlans)")
        }
    }

    // MARK: - Workout Sessions

    func fetchWorkoutSessions(userId: String) {
        db.collection("workoutSessions").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'workoutSessions' collection.")
                return
            }

            self.workoutSessions = documents.compactMap { docSnapshot -> WorkoutSession? in
                try? docSnapshot.data(as: WorkoutSession.self)
            }

            print("Fetched workout sessions: \(self.workoutSessions)")
        }
    }

    // MARK: - Daily Stats

    func fetchDailyStats(userId: String) {
        db.collection("dailyStats").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in 'dailyStats' collection.")
                return
            }

            self.dailyStats = documents.compactMap { docSnapshot -> DailyStats? in
                try? docSnapshot.data(as: DailyStats.self)
            }

            print("Fetched daily stats: \(self.dailyStats)")
        }
    }
}
