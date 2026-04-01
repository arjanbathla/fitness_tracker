import SwiftUI

struct FitnessView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "figure.run")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Fitness")
                    .font(.title2.italic())
                Text("Workout plans coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Fitness")
        }
    }
}

#Preview {
    FitnessView()
}
