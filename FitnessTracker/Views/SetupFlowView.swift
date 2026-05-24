import SwiftUI

// multi-step profile setup
struct SetupFlowView: View {
    @ObservedObject var viewModel: SetupViewModel
    var userId: String
    var fullName: String
    var email: String
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Complete your profile")
                    .font(.system(size: 28, weight: .bold))
                    .italic()
                    .foregroundStyle(AppColors.primaryCTA)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                OnboardingProgressBar(progress: viewModel.progress) // the bar at the top
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // switch between the 3 steps
                switch viewModel.currentStep {
                case 0:
                    BasicInfoStepView(viewModel: viewModel)
                case 1:
                    FitnessGoalStepView(viewModel: viewModel)
                case 2:
                    CompletionStepView(
                        viewModel: viewModel,
                        onViewDashboard: onComplete
                    )
                default:
                    EmptyView()
                }

                Spacer()

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                if viewModel.currentStep < 2 {
                    Button {
                        viewModel.nextStep()
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save and Continue")
                                    .font(.title3).fontWeight(.bold).italic()
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.4, blue: 1.0), Color(red: 0.6, green: 0.3, blue: 0.9)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(viewModel.currentStep == 0 && !viewModel.canContinueStep1)
                    .opacity(viewModel.currentStep == 0 && !viewModel.canContinueStep1 ? 0.4 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    Button {
                        viewModel.saveProfile(userId: userId, fullName: fullName, email: email)
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("View dashboard")
                                    .font(.title3).fontWeight(.bold).italic()
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.4, blue: 1.0), Color(red: 0.6, green: 0.3, blue: 0.9)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) { _, complete in
            if complete { onComplete() }
        }
    }
}

// yellow to green gradient bar
struct OnboardingProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(colors: [AppColors.primaryCTA, .green], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * progress, height: 10)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    SetupFlowView(
        viewModel: SetupViewModel(),
        userId: "test",
        fullName: "Test User",
        email: "test@test.com",
        onComplete: {}
    )
}
