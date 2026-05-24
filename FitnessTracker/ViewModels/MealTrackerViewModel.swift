import SwiftUI
import Combine
import FirebaseAuth

class MealTrackerViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var user: User?
    @Published var searchText = ""
    @Published var searchResults: [EdamamFood] = []
    @Published var toastMessage: String?
    @Published var showDeleteAlert = false
    @Published var isSearching = false

    var mealToDelete: Meal?

    var firestoreService = FirestoreService()
    var edamamService = EdamamService()

    // split meals by type for the sections
    var breakfastMeals: [Meal] { meals.filter { $0.mealType == .breakfast } }
    var lunchMeals: [Meal] { meals.filter { $0.mealType == .lunch } }
    var dinnerMeals: [Meal] { meals.filter { $0.mealType == .dinner } }

    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { meals.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { meals.reduce(0) { $0 + $1.carbs } }
    var totalFats: Double { meals.reduce(0) { $0 + $1.fats } }

    func loadMeals() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in")
            return
        }

        firestoreService.getUser(userId: uid) { [weak self] user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }

        firestoreService.getTodaysMeals(userId: uid) { [weak self] meals in
            DispatchQueue.main.async {
                self?.meals = meals
            }
        }
    }

    func searchFood() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        edamamService.searchFood(query: searchText) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
                self?.isSearching = false
            }
        }
    }

    // multiply everything by quantity
    func addMeal(food: EdamamFood, quantity: Int, mealType: Meal.MealType) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let meal = Meal(
            userId: uid,
            date: Date(),
            foodName: food.name,
            mealType: mealType,
            calories: food.calories * quantity,
            protein: food.protein * Double(quantity),
            carbs: food.carbs * Double(quantity),
            fats: food.fats * Double(quantity),
            quantity: quantity
        )

        firestoreService.saveMeal(meal) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("save meal failed: \(error)")
                } else {
                    self?.showToast("Meal added")
                    self?.loadMeals()
                }
            }
        }
    }

    func deleteMeal() {
        guard let meal = mealToDelete, let id = meal.id else { return }

        firestoreService.deleteMeal(mealId: id) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("delete failed: \(error)")
                } else {
                    self?.showToast("Meal Deleted")
                    self?.loadMeals()
                }
            }
        }
    }

    //disappears after 2 secs
    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.toastMessage = nil
        }
    }
}
