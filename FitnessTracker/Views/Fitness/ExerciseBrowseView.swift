import SwiftUI

struct ExerciseBrowseView: View {
    var exercises: [Exercise]
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var filtered: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.muscleGroup.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // search bar
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("Search Exercise", text: $searchText)
                        .foregroundStyle(.white)
                }
                .padding(10)
                .background(Color(white: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.green)
                .font(.subheadline.bold())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // exercise list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filtered) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.body.bold())
                                        .foregroundStyle(.white)
                                    Text(exercise.muscleGroup.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(14)
                            .background(Color(white: 0.11))
                        }
                    }
                }
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        ExerciseBrowseView(exercises: [
            Exercise(name: "Squats", muscleGroup: .legs, equipment: "Barbell", difficulty: .beginner, description: "A leg exercise", videoURL: ""),
            Exercise(name: "Bench press", muscleGroup: .chest, equipment: "Barbell", difficulty: .intermediate, description: "A chest exercise", videoURL: ""),
        ])
    }
    .preferredColorScheme(.dark)
}
