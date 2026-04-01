import Foundation

struct WorkoutSession: Identifiable, Codable {
    var id: String
    var userId: String
    var date: Date
    var dayPlan: DayPlan
    var completedAt: Date?

    var isCompleted: Bool {
        completedAt != nil
    }
}
