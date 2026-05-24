import SwiftUI

// detail page for a single exercise with description
struct ExerciseDetailView: View {
    var exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exercise.description)
                    .font(.body.italic())
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            name: "Squats",
            muscleGroup: .legs,
            equipment: "Barbell",
            difficulty: .beginner,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            videoURL: ""
        ))
    }
}
