import Foundation

struct DailyStats: Identifiable, Codable {
    var id: String
    var userId: String
    var date: Date
    var steps: Int
    var distance: Double
    var caloriesConsumed: Int
    var caloriesBurned: Int
    var workoutsCompleted: Int
    var proteinTotal: Double
    var carbsTotal: Double
    var fatsTotal: Double

    static let empty = DailyStats(
        id: "",
        userId: "",
        date: .now,
        steps: 0,
        distance: 0,
        caloriesConsumed: 0,
        caloriesBurned: 0,
        workoutsCompleted: 0,
        proteinTotal: 0,
        carbsTotal: 0,
        fatsTotal: 0
    )
}
