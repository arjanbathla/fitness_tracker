import Foundation
import FirebaseFirestore

struct WorkoutPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var days: [DayPlan]
}

struct PlannedExercise: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var sets: Int
    var reps: String
}

struct DayPlan: Identifiable, Codable {
    var id: String { dayOfWeek.rawValue }
    var dayOfWeek: DayOfWeek
    var workoutName: String
    var exerciseIds: [String] // refs to exercise docs
    var setsPerExercise: Int
    var repsPerExercise: Int
    var isCompleted: Bool
    var exercises: [PlannedExercise]?

    enum DayOfWeek: String, Codable, CaseIterable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }

    static let restDay = DayPlan(
        dayOfWeek: .saturday,
        workoutName: "Rest",
        exerciseIds: [],
        setsPerExercise: 0,
        repsPerExercise: 0,
        isCompleted: false
    )
}
