import SwiftUI

// search for food and add meals with quantity picker popup
struct LogMealsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: MealTrackerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFood: EdamamFood? // for the popup
    @State private var quantity = 1
    @State private var mealType: Meal.MealType = .breakfast
    @State private var showPopup = false

    private var cardBg: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray5)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Spacer()
                    Text("No results found")
                        .foregroundStyle(.gray)
                    Spacer()
                } else {
                    List(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, food in
                        foodRow(food)
                            .listRowBackground(colorScheme == .dark ? Color(white: 0.11) : Color(.systemGray6))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }

            // add meal popup overlay
            if showPopup, let food = selectedFood {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { showPopup = false }

                addMealPopup(food: food)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Log meals")
        .navigationBarTitleDisplayMode(.large)
    }

    // search bar at top, calls edamam api on submit
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField("Search food", text: $viewModel.searchText)
                    .foregroundStyle(.primary)
                    .onSubmit {
                        viewModel.searchFood()
                    }
            }
            .padding(10)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    //each search result
    private func foodRow(_ food: EdamamFood) -> some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text("\(food.calories)kcal | Carbs \(Int(food.carbs))g | Protein \(Int(food.protein))g | Fats \(Int(food.fats))g")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                selectedFood = food
                quantity = 1
                mealType = .breakfast
                showPopup = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    // popup with quantity stepper and meal type picker
    private func addMealPopup(food: EdamamFood) -> some View {
        VStack(spacing: 16) {
            Text(food.name)
                .font(.headline.bold())
                .foregroundStyle(.primary)

            Text("\(food.calories * quantity)kcal | Carbs \(Int(food.carbs * Double(quantity)))g | Protein \(Int(food.protein * Double(quantity)))g | Fats \(Int(food.fats * Double(quantity)))g")
                .font(.caption)
                .foregroundStyle(.gray)

            HStack {
                Text("Quantity")
                    .foregroundStyle(.primary)
                Spacer()
                Stepper("\(quantity)", value: $quantity, in: 1...10)
                    .labelsHidden()
                Text("\(quantity)")
                    .foregroundStyle(.primary)
                    .frame(width: 24)
            }

            HStack {
                Text("Meal type")
                    .foregroundStyle(.primary)
                Spacer()
                Picker("Meal type", selection: $mealType) {
                    ForEach(Meal.MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .tint(.primary)
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.addMeal(food: food, quantity: quantity, mealType: mealType)
                    showPopup = false
                    dismiss()
                } label: {
                    Text("Add meal")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    showPopup = false
                } label: {
                    Text("Close")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }
}

#Preview {
    NavigationStack {
        LogMealsView(viewModel: MealTrackerViewModel())
    }
}
