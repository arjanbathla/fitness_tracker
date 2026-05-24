import Foundation
import FirebaseFirestore

struct Meal: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var date: Date
    var foodName: String
    var mealType: MealType
    var calories: Int
    var protein: Double // in grams
    var carbs: Double
    var fats: Double
    var quantity: Int

    // no snacks for now
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
    }
}
