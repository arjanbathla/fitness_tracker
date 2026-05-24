import SwiftUI

// terms and conditions text shown in a sheet
struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms and Conditions")
                        .font(.title.bold())

                    Text("Last updated: April 2026")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Welcome to Fitness Tracker. By creating an account and using this app you agree to the terms below. Please read them before signing up.")

                    Text("1. Using the app")
                        .font(.headline)
                    Text("Fitness Tracker is a personal fitness and nutrition tracking app. You can use it to log workouts, track meals, monitor your steps and find nearby gyms. The app is provided as-is and is intended for general fitness use, not as medical advice. If you have a health condition, talk to a doctor before starting any new exercise or diet plan.")

                    Text("2. Your account")
                        .font(.headline)
                    Text("You need to be at least 16 years old to use Fitness Tracker. You are responsible for keeping your login details safe. If someone else uses your account, that is on you, not us. You can delete your account at any time from the settings page, and your data will be removed from our servers.")

                    Text("3. Your data")
                        .font(.headline)
                    Text("We store the information you give us (name, email, height, weight, fitness goals, workout history and meal logs) in Firebase so the app can work properly. We do not sell your data to anyone. We do not share it with third parties except where it is needed for the app to function, like sending nutrition queries to the Edamam API or location requests to Google Maps.")

                    Text("4. Health and safety")
                        .font(.headline)
                    Text("Always train within your limits. Fitness Tracker does not check whether the workouts it suggests are safe for you personally. If something hurts or feels wrong, stop. We are not responsible for any injuries that happen while using the app or following its suggestions.")

                    Text("5. Changes to these terms")
                        .font(.headline)
                    Text("We might update these terms from time to time. If we make a big change we will let you know in the app. Carrying on using the app after that counts as agreeing to the new version.")

                    Text("6. Contact")
                        .font(.headline)
                    Text("If you have any questions about these terms or about your data, you can get in touch through the support email listed in the app store.")
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TermsAndConditionsView()
}
