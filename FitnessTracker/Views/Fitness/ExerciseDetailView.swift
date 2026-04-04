import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    var exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // video or image
                if let url = URL(string: exercise.videoURL) {
                    if exercise.videoURL.hasSuffix(".mp4") || exercise.videoURL.hasSuffix(".mov") {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ZStack {
                                Color(white: 0.15)
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    ZStack {
                        Color(white: 0.15)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(exercise.description)
                    .font(.body.italic())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
            }
            .padding(16)
        }
        .background(Color.black)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            name: "Squats",
            muscleGroup: .legs,
            equipment: "Barbell",
            difficulty: .beginner,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc maximus, nulla ut commodo sagittis, sapien dui mattis dui non pulvinar lorem felis nec erat.",
            videoURL: ""
        ))
    }
    .preferredColorScheme(.dark)
}
