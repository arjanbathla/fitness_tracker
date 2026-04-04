import SwiftUI

struct FitnessView: View {
    @StateObject private var viewModel = FitnessViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your workout plan")
                            .font(.title2.bold().italic())
                            .foregroundStyle(.white)
                            .padding(.top, 8)

                        dayPillsRow

                        searchRow

                        dayHeader

                        exerciseList

                        nearbyGymsButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }

                // toast
                if let msg = viewModel.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: viewModel.toastMessage)
                }
            }
            .background(Color.black)
            .alert("Have you completed this workout?", isPresented: $viewModel.showCompleteAlert) {
                Button("Yes") { viewModel.markCompleted() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Do you want to delete this workout?", isPresented: $viewModel.showDeleteAlert) {
                Button("Yes", role: .destructive) { viewModel.deleteWorkout() }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear { viewModel.loadData() }
        }
    }

    private var dayPillsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    let key = viewModel.dayKeys[index]
                    let dayPlan = viewModel.workoutPlan?.days.first { $0.dayOfWeek == key }
                    let name = dayPlan?.workoutName ?? "Rest"

                    DayPillView(
                        dayLabel: viewModel.dayLabels[index],
                        workoutName: name,
                        isSelected: viewModel.selectedDayIndex == index
                    )
                    .onTapGesture {
                        viewModel.selectedDayIndex = index
                    }
                }
            }
        }
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField("Search Exercise", text: $viewModel.searchText)
                    .foregroundStyle(.white)
            }
            .padding(10)
            .background(Color(white: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            NavigationLink(destination: ExerciseBrowseView(exercises: viewModel.exercises)) {
                Text("View all")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dayPlan = viewModel.selectedDayPlan {
                HStack {
                    Text("\(dayPlan.dayOfWeek.rawValue) – \(dayPlan.workoutName.lowercased()) routine")
                        .font(.headline.italic())
                        .foregroundStyle(.white)

                    Spacer()
                }

                HStack(spacing: 12) {
                    Button {
                        viewModel.showCompleteAlert = true
                    } label: {
                        Text(dayPlan.isCompleted ? "workout completed" : "workout not completed")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(dayPlan.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                    }

                    if dayPlan.isCompleted {
                        Button {
                            viewModel.showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            } else {
                Text("Rest day")
                    .font(.headline.italic())
                    .foregroundStyle(.gray)
            }
        }
    }

    private var exerciseList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.filteredDayExercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    ExerciseCardView(
                        name: exercise.name,
                        sets: viewModel.selectedDayPlan?.setsPerExercise ?? 3,
                        reps: viewModel.selectedDayPlan?.repsPerExercise ?? 10
                    )
                }
            }
        }
    }

    private var nearbyGymsButton: some View {
        NavigationLink(destination: NearbyGymsView()) {
            Text("View nearby gyms")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
}

#Preview {
    FitnessView()
        .preferredColorScheme(.dark)
}
