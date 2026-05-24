import SwiftUI
import MapKit

// map with nearby gym pins and directions button
struct NearbyGymsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var locationService = LocationService()
    @State private var gyms: [MKMapItem] = []
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // map
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(gyms, id: \.self) { gym in
                    Marker(
                        gym.name ?? "Gym",
                        coordinate: gym.placemark.coordinate
                    )
                    .tint(.red)
                }
            }
            .frame(height: 300)

            // gym list
            if isLoading {
                Spacer()
                ProgressView("Finding nearby gyms...")
                Spacer()
            } else if gyms.isEmpty {
                Spacer()
                Text("No gyms found nearby")
                    .foregroundStyle(.gray)
                Spacer()
            } else {
                List(gyms, id: \.self) { gym in
                    gymRow(gym)
                        .listRowBackground(colorScheme == .dark ? Color(white: 0.11) : Color(.systemGray6))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Nearest gym")
        .navigationBarTitleDisplayMode(.large)
        // wait for location then search once
        .onReceive(locationService.$currentLocation) { location in
            guard let location = location else { return }
            searchGyms(near: location)
            locationService.stopUpdatingLocation()
        }
    }

    // each gym in the list with distance and directions btn
    private func gymRow(_ gym: MKMapItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(gym.name ?? "Unknown Gym")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let location = locationService.currentLocation {
                    let dist = gym.placemark.location?.distance(from: location) ?? 0
                    let km = dist / 1000
                    Text(String(format: "%.1f km away", km))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            Button {
                openDirections(to: gym)
            } label: {
                Text("Directions")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 4)
    }

    // uses MapKit local search
    private func searchGyms(near location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gym"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("search error: \(error)")
                isLoading = false
                return
            }
            guard let response = response else {
                isLoading = false
                return
            }

            gyms = response.mapItems
            isLoading = false

            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            ))
        }
    }

    // opens apple maps
    private func openDirections(to gym: MKMapItem) {
        gym.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

#Preview {
    NavigationStack {
        NearbyGymsView()
    }
}
