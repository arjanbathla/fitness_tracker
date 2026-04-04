import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
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
    var proteinGoal: Int
    var carbsGoal: Int
    var fatsGoal: Int

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

    init(fullName: String, email: String, gender: Gender, height: Double, weight: Double, fitnessGoal: FitnessGoal, recommendedCalories: Int, stepGoal: Int, distanceUnit: DistanceUnit, createdAt: Date, proteinGoal: Int? = nil, carbsGoal: Int? = nil, fatsGoal: Int? = nil) {
        self.fullName = fullName
        self.email = email
        self.gender = gender
        self.height = height
        self.weight = weight
        self.fitnessGoal = fitnessGoal
        self.recommendedCalories = recommendedCalories
        self.stepGoal = stepGoal
        self.distanceUnit = distanceUnit
        self.createdAt = createdAt
        self.proteinGoal = proteinGoal ?? (recommendedCalories * 30 / 100 / 4)
        self.carbsGoal = carbsGoal ?? (recommendedCalories * 40 / 100 / 4)
        self.fatsGoal = fatsGoal ?? (recommendedCalories * 30 / 100 / 9)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        email = try container.decode(String.self, forKey: .email)
        gender = try container.decode(Gender.self, forKey: .gender)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        fitnessGoal = try container.decode(FitnessGoal.self, forKey: .fitnessGoal)
        recommendedCalories = try container.decode(Int.self, forKey: .recommendedCalories)
        stepGoal = try container.decode(Int.self, forKey: .stepGoal)
        distanceUnit = try container.decode(DistanceUnit.self, forKey: .distanceUnit)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        proteinGoal = (try? container.decode(Int.self, forKey: .proteinGoal)) ?? (recommendedCalories * 30 / 100 / 4)
        carbsGoal = (try? container.decode(Int.self, forKey: .carbsGoal)) ?? (recommendedCalories * 40 / 100 / 4)
        fatsGoal = (try? container.decode(Int.self, forKey: .fatsGoal)) ?? (recommendedCalories * 30 / 100 / 9)
    }

    static let `default` = User(
        fullName: "",
        email: "",
        gender: .male,
        height: 170,
        weight: 70,
        fitnessGoal: .maintainBody,
        recommendedCalories: 2200,
        stepGoal: 10000,
        distanceUnit: .km,
        createdAt: .now,
        proteinGoal: 165,
        carbsGoal: 220,
        fatsGoal: 73
    )
}
