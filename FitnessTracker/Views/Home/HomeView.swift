import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "house.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Home")
                    .font(.title2.italic())
                Text("Dashboard coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
