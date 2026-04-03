import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var stepCounter = StepCounterService()

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
                            .foregroundStyle(.white)
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
        .background(Color.black)
        .onAppear {
            viewModel.loadData()
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
                .foregroundStyle(.white)

            if let workout = viewModel.todayWorkout {
                HStack {
                    Text("\(workout.workoutName) day - \(workout.isCompleted ? "completed" : "not completed")")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(workout.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
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
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var caloriesCard: some View {
        let consumed = viewModel.caloriesConsumed
        let target = viewModel.caloriesTarget
        let progress = target > 0 ? Double(consumed) / Double(target) : 0
        let percent = Int(progress * 100)

        return VStack(spacing: 16) {
            Text("Calories")
                .font(.headline.italic())
                .foregroundStyle(.white)

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
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var stepsCard: some View {
        let steps = stepCounter.steps
        let goal = viewModel.stepGoal
        let progress = goal > 0 ? Double(steps) / Double(goal) : 0
        let percent = Int(progress * 100)

        return VStack(spacing: 12) {
            Text("Steps")
                .font(.headline.italic())
                .foregroundStyle(.white)

            Text("\(steps)")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)

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

            Text("Distance: \(String(format: "%.1f", stepCounter.distance))km")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
