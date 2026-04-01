import SwiftUI

struct MealTrackerView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "fork.knife")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Add Meal")
                    .font(.title2.italic())
                Text("Meal tracking coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Add Meal")
        }
    }
}

#Preview {
    MealTrackerView()
}
