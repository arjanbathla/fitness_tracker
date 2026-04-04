import SwiftUI

struct MacroRingView: View {
    var current: Double
    var target: Double
    var color: Color
    var label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                ProgressRingView(
                    progress: target > 0 ? current / target : 0,
                    lineWidth: 8,
                    color: color
                )

                VStack(spacing: 0) {
                    Text("\(Int(current))g")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Text("/ \(Int(target))g")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 80, height: 80)

            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        MacroRingView(current: 100, target: 120, color: .purple, label: "Protein")
        MacroRingView(current: 140, target: 200, color: Color(red: 0.2, green: 0.8, blue: 0.7), label: "Carbs")
        MacroRingView(current: 40, target: 50, color: Color(red: 0.9, green: 0.2, blue: 0.6), label: "Fats")
    }
    .padding()
    .background(Color.black)
}
