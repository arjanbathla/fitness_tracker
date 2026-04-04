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

    func seedExercises(completion: @escaping () -> Void) {
        db.collection("exercises").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let docs = snapshot?.documents, !docs.isEmpty {
                print("exercises already seeded (\(docs.count))")
                completion()
                return
            }

            let exercises: [[String: Any]] = [
                [
                    "name": "Squats",
                    "muscleGroup": "Legs",
                    "equipment": "Barbell",
                    "difficulty": "beginner",
                    "description": "Stand with feet shoulder-width apart, barbell on your upper back. Bend your knees and lower your hips until thighs are parallel to the floor, then push back up through your heels.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Squats"
                ],
                [
                    "name": "Deadlifts",
                    "muscleGroup": "Legs",
                    "equipment": "Barbell",
                    "difficulty": "intermediate",
                    "description": "Stand with feet hip-width apart, barbell over mid-foot. Hinge at the hips, grip the bar, and lift by driving your hips forward while keeping your back straight.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Deadlifts"
                ],
                [
                    "name": "Calf Raises",
                    "muscleGroup": "Legs",
                    "equipment": "Bodyweight",
                    "difficulty": "beginner",
                    "description": "Stand on the edge of a step with heels hanging off. Rise up onto your toes as high as possible, pause, then slowly lower back down below the step level.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Calf+Raises"
                ],
                [
                    "name": "Bench Press",
                    "muscleGroup": "Chest",
                    "equipment": "Barbell",
                    "difficulty": "intermediate",
                    "description": "Lie on a flat bench, grip the barbell slightly wider than shoulder-width. Lower the bar to your chest, then press it back up to full arm extension.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Bench+Press"
                ],
                [
                    "name": "Pec Flies",
                    "muscleGroup": "Chest",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Lie on a flat bench holding dumbbells above your chest with arms slightly bent. Open your arms wide in an arc until you feel a stretch, then squeeze them back together.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Pec+Flies"
                ],
                [
                    "name": "Push-ups",
                    "muscleGroup": "Chest",
                    "equipment": "Bodyweight",
                    "difficulty": "beginner",
                    "description": "Start in a plank position with hands shoulder-width apart. Lower your chest to the ground by bending your elbows, then push back up to the starting position.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Push-ups"
                ],
                [
                    "name": "Lateral Raises",
                    "muscleGroup": "Shoulders",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Stand with dumbbells at your sides, palms facing in. Raise your arms out to the sides until they reach shoulder height, then slowly lower them back down.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Lateral+Raises"
                ],
                [
                    "name": "Lat Pulldown",
                    "muscleGroup": "Back",
                    "equipment": "Cable Machine",
                    "difficulty": "beginner",
                    "description": "Sit at the lat pulldown machine and grip the bar wider than shoulder-width. Pull the bar down to your upper chest while squeezing your shoulder blades together, then slowly release.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Lat+Pulldown"
                ],
                [
                    "name": "Bicep Curls",
                    "muscleGroup": "Arms",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Stand holding dumbbells at your sides with palms facing forward. Curl the weights up towards your shoulders by bending at the elbow, then lower slowly.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Bicep+Curls"
                ],
                [
                    "name": "Tricep Dips",
                    "muscleGroup": "Arms",
                    "equipment": "Parallel Bars",
                    "difficulty": "intermediate",
                    "description": "Grip parallel bars and lift yourself up with arms straight. Lower your body by bending your elbows to about 90 degrees, then press back up to the starting position.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Tricep+Dips"
                ]
            ]

            let batch = self.db.batch()
            for exercise in exercises {
                let ref = self.db.collection("exercises").document()
                batch.setData(exercise, forDocument: ref)
            }

            batch.commit { error in
                if let error = error {
                    print("seed failed: \(error)")
                } else {
                    print("seeded 10 exercises")
                }
                completion()
            }
        }
    }
}
