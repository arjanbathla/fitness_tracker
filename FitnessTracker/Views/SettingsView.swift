import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @EnvironmentObject var authViewModel: LoginViewModel
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("distanceUnit") private var distanceUnit = "Km"
    @AppStorage("dailyReminders") private var dailyReminders = false

    // alert flags
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack {
                        Toggle("Daily Reminders", isOn: $dailyReminders)
                            .toggleStyle(.switch)
                            .tint(.green)
                            .onChange(of: dailyReminders) {
                                if dailyReminders {
                                    NotificationService.shared.requestPermission()

                                    guard let uid = Auth.auth().currentUser?.uid else {
                                        print("no user logged in")
                                        return
                                    }
                                    let db = Firestore.firestore()
                                    db.collection("workoutPlans").document(uid).getDocument { doc, error in
                                        if let error = error {
                                            print("error: \(error)")
                                            return
                                        }
                                        if let plan = try? doc?.data(as: WorkoutPlan.self) {
                                            NotificationService.shared.scheduleDailyReminder(for: plan)
                                        }
                                    }
                                } else {
                                    NotificationService.shared.cancelDailyReminders()
                                }
                            }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    VStack {
                        Toggle(isOn: Binding(
                            get: { !isDarkMode },
                            set: { isDarkMode = !$0 }
                        )) {
                            Text("Light mode")
                        }
                        .toggleStyle(.switch)
                        .tint(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Text("Unit Settings")
                        .font(.headline)

                    VStack {
                        HStack {
                            Text("Distance")
                            Spacer()
                            Picker("Distance", selection: $distanceUnit) {
                                Text("Km").tag("Km")
                                Text("Miles").tag("Miles")
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Spacer().frame(height: 16)

                    Button {
                        showSignOutConfirm = true
                    } label: {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primaryCTA)
                            .cornerRadius(12)
                    }

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    authViewModel.deleteAccount()
                }
            } message: {
                Text("Are you sure? This will permanently delete your account and all data.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LoginViewModel())
}
