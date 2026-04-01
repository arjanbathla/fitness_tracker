import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Analytics")
                    .font(.title2.italic())
                Text("Charts and insights coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    AnalyticsView()
}
