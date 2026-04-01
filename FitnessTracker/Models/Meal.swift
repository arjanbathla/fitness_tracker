import Foundation

struct Meal: Identifiable, Codable {
    var id: String
    var userId: String
    var date: Date
    var foodName: String
    var mealType: MealType
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
    var quantity: Int

    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
    }
}
