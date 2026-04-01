import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Settings")
                    .font(.title2.italic())
                Text("Preferences coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
