//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by arjan bathla on 01/04/2026.
//

import SwiftUI
import FirebaseCore

@main
struct FitnessTrackerApp: App {
    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        let service = FirebaseAuthService()
        _authViewModel = State(initialValue: AuthViewModel(authService: service))
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environment(authViewModel)
            } else {
                AuthFlowView(viewModel: authViewModel)
            }
        }
    }
}
