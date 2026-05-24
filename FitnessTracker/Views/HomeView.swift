import SwiftUI

// home dashboard - calories ring, steps, todays schedule
struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var stepCounter = StepCounterService()

    // dark/light bg for cards
    private var cardBg: Color {
        colorScheme == .dark ? Color(white: 0.11) : Color(.systemGray6)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    HStack {
                        Text(viewModel.userName)
                            .font(.title.bold().italic())
                            .foregroundStyle(.primary)
                        Text("👋")
                            .font(.title2)
                    }
                }
                .padding(.top, 16)

                // weekly schedule card
                weeklyScheduleCard

                // calories card
                caloriesCard

                // steps card
                stepsCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.getData()
            stepCounter.startCounting()
        }
        .onDisappear {
            stepCounter.stopCounting()
        }
    }

    private var weeklyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly schedule - Today")
                .font(.headline.italic())
                .foregroundStyle(.primary)

            if let workout = viewModel.todayWorkout {
                HStack {
                    Text("\(workout.workoutName) - \(workout.isCompleted ? "completed" : "not completed")")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(workout.isCompleted ? Color.green : Color.red)
                        .clipShape(Capsule())

                    Spacer()
                }
            } else {
                Text("Rest day")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // orange ring + percentage bar
    private var caloriesCard: some View {
        let consumed = viewModel.caloriesConsumed
        let target = viewModel.caloriesTarget
        let progress = target > 0 ? Double(consumed) / Double(target) : 0
        let percent = Int(progress * 100)

        return VStack(spacing: 16) {
            Text("Calories")
                .font(.headline.italic())
                .foregroundStyle(.primary)

            ZStack {
                ProgressRingView(progress: progress, lineWidth: 14, color: .orange)
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    Text("/ \(target)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            // percentage bar
            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(percent)%")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // step count from CoreMotion + converts to miles if needed
    private var stepsCard: some View {
        let steps = stepCounter.steps
        let goal = viewModel.stepGoal
        let progress = goal > 0 ? Double(steps) / Double(goal) : 0
        let percent = Int(progress * 100)
        let distanceUnit = UserDefaults.standard.string(forKey: "distanceUnit") ?? "Km" // from settings
        let distanceValue: Double = distanceUnit == "Miles" ? stepCounter.distance * 0.621371 : stepCounter.distance

        return VStack(spacing: 12) {
            Text("Steps")
                .font(.headline.italic())
                .foregroundStyle(.primary)

            Text("\(steps)")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.primary)

            Text("/ \(goal) Steps")
                .font(.subheadline)
                .foregroundStyle(.gray)

            // progress bar
            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(percent)%")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .frame(width: 35, alignment: .trailing)
            }

            Text("Distance: \(String(format: "%.1f", distanceValue)) \(distanceUnit.lowercased())")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
