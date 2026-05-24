//
//  FitnessTrackerApp.swift
//  FitnessTracker


import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct FitnessTrackerApp: App {
    @StateObject private var authViewModel: LoginViewModel
    @StateObject private var onboardingViewModel = SetupViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = true

    init() {
        FirebaseApp.configure()
        // sign out on launch so the user always sees the login screen
        try? Auth.auth().signOut()
        //setup auth service first
        let service = LoginService()
        _authViewModel = StateObject(wrappedValue: LoginViewModel(authService: service))
        NotificationService.shared.requestPermission() // ask on launch
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch authViewModel.appState {
                case .auth:
                    LoginFlowView(viewModel: authViewModel)

                case .onboarding: // profile setup wizard
                    SetupFlowView(
                        viewModel: onboardingViewModel,
                        userId: Auth.auth().currentUser?.uid ?? "",
                        fullName: authViewModel.signUpName,
                        email: authViewModel.signUpEmail,
                        onComplete: {
                            authViewModel.finishOnboarding()
                        }
                    )

                case .main:
                    ContentView()
                        .environmentObject(authViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authViewModel.appState)
            .preferredColorScheme(isDarkMode ? .dark : .light) // respects user setting
        }
    }
}
