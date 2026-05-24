import SwiftUI

// last step of onboarding - shows the generated plan summary
struct CompletionStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: SetupViewModel
    var onViewDashboard: () -> Void

    private var cardBg: Color {
        colorScheme == .dark ? Color(white: 0.12) : Color(.systemGray6)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Profile setup complete")
                    .font(.system(size: 26, weight: .bold))
                    .italic()
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("recommended daily calories")
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    Text("\(viewModel.recommendedCalories)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AppColors.primaryCTA)
                }

                // generated plan preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personalised workout plan")
                        .font(.title3)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundStyle(.primary)

                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.workoutPlan.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text(item.day)
                                    .font(.body)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(cardBg)

                            if index < viewModel.workoutPlan.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    let vm = SetupViewModel()
    CompletionStepView(viewModel: vm, onViewDashboard: {})
        .onAppear {
            vm.recommendedCalories = 2200
            vm.workoutPlan = [
                (name: "Legs", day: "Day 1"),
                (name: "Push", day: "Day 2"),
                (name: "Pull", day: "Day 3"),
                (name: "Rest", day: "Day 4"),
                (name: "Legs", day: "Day 5")
            ]
        }
}
