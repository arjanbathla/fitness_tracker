import SwiftUI

struct ExerciseCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    var name: String
    var sets: Int
    var reps: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                Text("\(sets) x \(reps)")
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ExerciseCardView(name: "Squats", sets: 3, reps: "10")
        .padding()
}
