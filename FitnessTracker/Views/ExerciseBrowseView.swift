import SwiftUI

// browse and pick exercises to add to your plan
struct ExerciseBrowseView: View {
    @Environment(\.colorScheme) private var colorScheme
    var exercises: [Exercise]
    var initialSearch: String = ""
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    // filter by name or muscle group
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
                        .foregroundStyle(.primary)
                }
                .padding(10)
                .background(colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray5))
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
                                        .foregroundStyle(.primary)
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
                            .background(colorScheme == .dark ? Color(white: 0.11) : Color(.systemGray6))
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .tint(.blue)
        .navigationBarHidden(true)
        .onAppear {
            if searchText.isEmpty && !initialSearch.isEmpty {
                searchText = initialSearch
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseBrowseView(exercises: [
            Exercise(name: "Squats", muscleGroup: .legs, equipment: "Barbell", difficulty: .beginner, description: "A leg exercise", videoURL: ""),
            Exercise(name: "Bench press", muscleGroup: .chest, equipment: "Barbell", difficulty: .intermediate, description: "A chest exercise", videoURL: ""),
        ])
    }
}
