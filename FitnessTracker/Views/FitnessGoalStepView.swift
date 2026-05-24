import SwiftUI

// second step of onboarding - pick your fitness goal
struct FitnessGoalStepView: View {
    @ObservedObject var viewModel: SetupViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Choose your fitness goal")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .italic()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(User.FitnessGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoal == goal
                        ) {
                            viewModel.selectedGoal = goal
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct GoalCard: View {
    let goal: User.FitnessGoal
    let isSelected: Bool
    let onTap: () -> Void

    private var cardColor: Color {
        switch goal {
        case .loseWeight: Color(red: 0.55, green: 0.3, blue: 0.7)
        case .gainMuscle: Color(red: 0.2, green: 0.4, blue: 0.8)
        case .maintainBody: Color(red: 0.2, green: 0.6, blue: 0.6)
        case .improveEndurance: Color(red: 0.9, green: 0.5, blue: 0.2)
        }
    }

    private var iconName: String {
        switch goal {
        case .loseWeight: "flame.fill"
        case .gainMuscle: "dumbbell.fill"
        case .maintainBody: "scalemass.fill"
        case .improveEndurance: "bolt.heart.fill"
        }
    }

    private var subtitle: String {
        switch goal {
        case .loseWeight: "Slim down sustainably"
        case .gainMuscle: "Build strength and definition"
        case .maintainBody: "Keep your current progress"
        case .improveEndurance: "Improve stamina and recovery"
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundStyle(.white)

                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryCTA : Color.clear, lineWidth: 3)
            )
        }
    }
}

#Preview {
    FitnessGoalStepView(viewModel: SetupViewModel())
}
