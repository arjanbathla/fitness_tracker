import Foundation

struct User: Identifiable, Codable {
    var id: String
    var fullName: String
    var email: String
    var gender: Gender
    var height: Double
    var weight: Double
    var fitnessGoal: FitnessGoal
    var recommendedCalories: Int
    var stepGoal: Int
    var distanceUnit: DistanceUnit
    var createdAt: Date

    enum Gender: String, Codable, CaseIterable {
        case male
        case female
    }

    enum FitnessGoal: String, Codable, CaseIterable {
        case loseWeight
        case gainMuscle
        case maintainBody
        case improveEndurance

        var title: String {
            switch self {
            case .loseWeight: "Lose Weight"
            case .gainMuscle: "Gain Muscle"
            case .maintainBody: "Maintain Body"
            case .improveEndurance: "Improve Endurance"
            }
        }
    }

    enum DistanceUnit: String, Codable, CaseIterable {
        case km
        case miles
    }

    static let `default` = User(
        id: "",
        fullName: "",
        email: "",
        gender: .male,
        height: 170,
        weight: 70,
        fitnessGoal: .maintainBody,
        recommendedCalories: 2200,
        stepGoal: 10000,
        distanceUnit: .km,
        createdAt: .now
    )
}
