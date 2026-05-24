import Foundation
import FirebaseFirestore

struct WorkoutSession: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var date: Date
    var dayPlan: DayPlan
    var completedAt: Date?

    // computed from timestamp
    var isCompleted: Bool {
        completedAt != nil
    }
}
