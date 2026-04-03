import SwiftUI

struct DayPillView: View {
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
        .foregroundStyle(.white)
        .frame(width: 60, height: 50)
        .background(isSelected ? Color.green : Color(white: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HStack {
        DayPillView(dayLabel: "Mon", workoutName: "Leg day", isSelected: true)
        DayPillView(dayLabel: "Tue", workoutName: "Chest day", isSelected: false)
    }
    .padding()
    .background(Color.black)
}
