import SwiftUI

struct MealTrackerView: View {
    @StateObject private var viewModel = MealTrackerViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        macroRingsRow

                        caloriesBar

                        mealSection("Breakfast", meals: viewModel.breakfastMeals)

                        mealSection("Lunch", meals: viewModel.lunchMeals)

                        mealSection("Dinner", meals: viewModel.dinnerMeals)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }

                if let msg = viewModel.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: viewModel.toastMessage)
                }
            }
            .background(Color.black)
            .alert("Delete item", isPresented: $viewModel.showDeleteAlert) {
                Button("Yes", role: .destructive) { viewModel.deleteMeal() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this meal?")
            }
            .onAppear { viewModel.loadMeals() }
        }
    }

    private var header: some View {
        HStack {
            Text("Todays meals")
                .font(.title.bold().italic())
                .foregroundStyle(.white)

            Spacer()

            NavigationLink(destination: LogMealsView(viewModel: viewModel)) {
                Text("Add Meal +")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.top, 8)
    }

    private var macroRingsRow: some View {
        HStack(spacing: 20) {
            Spacer()
            MacroRingView(
                current: viewModel.totalProtein,
                target: Double(viewModel.user?.proteinGoal ?? 165),
                color: .purple,
                label: "Protein"
            )
            MacroRingView(
                current: viewModel.totalCarbs,
                target: Double(viewModel.user?.carbsGoal ?? 220),
                color: Color(red: 0.2, green: 0.8, blue: 0.7),
                label: "Carbs"
            )
            MacroRingView(
                current: viewModel.totalFats,
                target: Double(viewModel.user?.fatsGoal ?? 73),
                color: Color(red: 0.9, green: 0.2, blue: 0.6),
                label: "Fats"
            )
            Spacer()
        }
    }

    private var caloriesBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Calories")
                .font(.headline)
                .foregroundStyle(.white)

            let target = viewModel.user?.recommendedCalories ?? 2200
            let progress = target > 0 ? Double(viewModel.totalCalories) / Double(target) : 0

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(width: geo.size.width * min(progress, 1.0), height: 20)
                }
                .frame(height: 20)

                HStack {
                    Spacer()
                    Text("\(viewModel.totalCalories)/\(target)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
        }
    }

    private func mealSection(_ title: String, meals: [Meal]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.italic())
                .foregroundStyle(.white)
                .padding(.top, 4)

            if meals.isEmpty {
                Text("No meals logged")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 4)
            } else {
                ForEach(meals) { meal in
                    mealRow(meal)
                }
            }
        }
    }

    private func mealRow(_ meal: Meal) -> some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.foodName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("\(meal.calories)kcal | Carbs \(Int(meal.carbs))g | Protein \(Int(meal.protein))g | Fats \(Int(meal.fats))g")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                viewModel.mealToDelete = meal
                viewModel.showDeleteAlert = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding(10)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    MealTrackerView()
        .preferredColorScheme(.dark)
}
