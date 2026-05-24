import SwiftUI

// pill shape for each day
struct DayPillView: View {
    @Environment(\.colorScheme) private var colorScheme
    var dayLabel: String
    var workoutName: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(dayLabel)
                .font(.caption2.bold())
            Text(workoutName)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .frame(width: 60, height: 50)
        .background(isSelected ? Color.green : (colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray5)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HStack {
        DayPillView(dayLabel: "Mon", workoutName: "Leg day", isSelected: true)
        DayPillView(dayLabel: "Tue", workoutName: "Chest day", isSelected: false)
    }
    .padding()
}
