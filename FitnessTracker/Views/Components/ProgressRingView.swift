import SwiftUI

struct ProgressRingView: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 12
    var color: Color = .orange

    var body: some View {
        ZStack {
            // grey track
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)

            // coloured arc
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    ProgressRingView(progress: 0.65, color: .orange)
        .frame(width: 120, height: 120)
        .padding()
        .background(Color.black)
}
