import Foundation

struct Exercise: Identifiable, Codable {
    var id: String
    var name: String
    var muscleGroup: MuscleGroup
    var equipment: String
    var difficulty: Difficulty
    var description: String
    var videoURL: String

    enum MuscleGroup: String, Codable, CaseIterable {
        case legs = "Legs"
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case arms = "Arms"
        case core = "Core"
        case cardio = "Cardio"
    }

    enum Difficulty: String, Codable, CaseIterable {
        case beginner
        case intermediate
        case advanced
    }
}
