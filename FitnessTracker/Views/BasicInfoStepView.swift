import SwiftUI

// first step of onboarding - gender, height, weight
struct BasicInfoStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: SetupViewModel

    private let heightRange = Array(140...220) // cm range
    private let weightRange = Array(30...200) // kg range

    private var fieldBg: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray6)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Basic information")
                    .font(.title2)
                    .fontWeight(.bold)
                    .italic()
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Gender")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    HStack(spacing: 0) {
                        Button {
                            viewModel.selectedGender = .male
                        } label: {
                            Text("Male")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(viewModel.selectedGender == .male ? AppColors.primaryCTA : Color.gray.opacity(0.3))
                                .foregroundStyle(viewModel.selectedGender == .male ? .black : .primary)
                        }

                        Button {
                            viewModel.selectedGender = .female
                        } label: {
                            Text("Female")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(viewModel.selectedGender == .female ? AppColors.primaryCTA : Color.gray.opacity(0.3))
                                .foregroundStyle(viewModel.selectedGender == .female ? .black : .primary)
                        }
                    }
                    .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Height")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Menu {
                        ForEach(heightRange, id: \.self) { height in
                            Button("\(height) cm") {
                                viewModel.selectedHeight = height
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedHeight > 0 ? "\(viewModel.selectedHeight) cm" : "Select")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(fieldBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Menu {
                        ForEach(weightRange, id: \.self) { weight in
                            Button("\(weight) kg") {
                                viewModel.selectedWeight = weight
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedWeight > 0 ? "\(viewModel.selectedWeight) kg" : "Select")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(fieldBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    BasicInfoStepView(viewModel: SetupViewModel())
}
