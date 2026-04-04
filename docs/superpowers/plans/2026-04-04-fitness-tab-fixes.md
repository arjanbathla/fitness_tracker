# Fitness Tab Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix three issues in the fitness tab: add nearby gyms map screen, seed exercises and fix search, make exercise detail description italic.

**Architecture:** LocationService wraps CLLocationManager following the lab guide pattern (NSObject + CLLocationManagerDelegate + ObservableObject). NearbyGymsView uses MapKit's native SwiftUI Map view with MKLocalSearch to find gyms. Exercise seeding adds a method to FirestoreService that writes 10 exercises if the collection is empty.

**Tech Stack:** MapKit, CoreLocation, SwiftUI, Firebase Firestore

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `FitnessTracker/Services/LocationService.swift` | Create | CLLocationManager wrapper, publishes user location |
| `FitnessTracker/Views/Fitness/NearbyGymsView.swift` | Create | Map + gym list with directions button |
| `FitnessTracker/Views/Fitness/FitnessView.swift` | Modify | Wire up nearby gyms button as NavigationLink |
| `FitnessTracker/Services/FirestoreService.swift` | Modify | Add seedExercises() method |
| `FitnessTracker/ViewModels/FitnessViewModel.swift` | Modify | Call seedExercises when exercises empty |
| `FitnessTracker/Views/Fitness/ExerciseDetailView.swift` | Modify | Make description italic |
| `FitnessTracker.xcodeproj/project.pbxproj` | Modify | Add NSLocationWhenInUseUsageDescription |

---

### Task 1: Exercise Detail Italic Fix

**Files:**
- Modify: `FitnessTracker/Views/Fitness/ExerciseDetailView.swift:43`

- [ ] **Step 1: Fix description font to italic**

In `ExerciseDetailView.swift`, change line 43 from:

```swift
                Text(exercise.description)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
```

to:

```swift
                Text(exercise.description)
                    .font(.body.italic())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Views/Fitness/ExerciseDetailView.swift
git commit -m "fix: make exercise detail description italic to match mockup"
```

---

### Task 2: Seed Exercises in Firestore

**Files:**
- Modify: `FitnessTracker/Services/FirestoreService.swift`
- Modify: `FitnessTracker/ViewModels/FitnessViewModel.swift`

- [ ] **Step 1: Add seedExercises method to FirestoreService**

Add this method to the end of the `FirestoreService` class in `FirestoreService.swift`, before the closing `}`:

```swift
    func seedExercises(completion: @escaping () -> Void) {
        db.collection("exercises").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let docs = snapshot?.documents, !docs.isEmpty {
                print("exercises already seeded (\(docs.count))")
                completion()
                return
            }

            let exercises: [[String: Any]] = [
                [
                    "name": "Squats",
                    "muscleGroup": "Legs",
                    "equipment": "Barbell",
                    "difficulty": "beginner",
                    "description": "Stand with feet shoulder-width apart, barbell on your upper back. Bend your knees and lower your hips until thighs are parallel to the floor, then push back up through your heels.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Squats"
                ],
                [
                    "name": "Deadlifts",
                    "muscleGroup": "Legs",
                    "equipment": "Barbell",
                    "difficulty": "intermediate",
                    "description": "Stand with feet hip-width apart, barbell over mid-foot. Hinge at the hips, grip the bar, and lift by driving your hips forward while keeping your back straight.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Deadlifts"
                ],
                [
                    "name": "Calf Raises",
                    "muscleGroup": "Legs",
                    "equipment": "Bodyweight",
                    "difficulty": "beginner",
                    "description": "Stand on the edge of a step with heels hanging off. Rise up onto your toes as high as possible, pause, then slowly lower back down below the step level.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Calf+Raises"
                ],
                [
                    "name": "Bench Press",
                    "muscleGroup": "Chest",
                    "equipment": "Barbell",
                    "difficulty": "intermediate",
                    "description": "Lie on a flat bench, grip the barbell slightly wider than shoulder-width. Lower the bar to your chest, then press it back up to full arm extension.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Bench+Press"
                ],
                [
                    "name": "Pec Flies",
                    "muscleGroup": "Chest",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Lie on a flat bench holding dumbbells above your chest with arms slightly bent. Open your arms wide in an arc until you feel a stretch, then squeeze them back together.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Pec+Flies"
                ],
                [
                    "name": "Push-ups",
                    "muscleGroup": "Chest",
                    "equipment": "Bodyweight",
                    "difficulty": "beginner",
                    "description": "Start in a plank position with hands shoulder-width apart. Lower your chest to the ground by bending your elbows, then push back up to the starting position.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Push-ups"
                ],
                [
                    "name": "Lateral Raises",
                    "muscleGroup": "Shoulders",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Stand with dumbbells at your sides, palms facing in. Raise your arms out to the sides until they reach shoulder height, then slowly lower them back down.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Lateral+Raises"
                ],
                [
                    "name": "Lat Pulldown",
                    "muscleGroup": "Back",
                    "equipment": "Cable Machine",
                    "difficulty": "beginner",
                    "description": "Sit at the lat pulldown machine and grip the bar wider than shoulder-width. Pull the bar down to your upper chest while squeezing your shoulder blades together, then slowly release.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Lat+Pulldown"
                ],
                [
                    "name": "Bicep Curls",
                    "muscleGroup": "Arms",
                    "equipment": "Dumbbells",
                    "difficulty": "beginner",
                    "description": "Stand holding dumbbells at your sides with palms facing forward. Curl the weights up towards your shoulders by bending at the elbow, then lower slowly.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Bicep+Curls"
                ],
                [
                    "name": "Tricep Dips",
                    "muscleGroup": "Arms",
                    "equipment": "Parallel Bars",
                    "difficulty": "intermediate",
                    "description": "Grip parallel bars and lift yourself up with arms straight. Lower your body by bending your elbows to about 90 degrees, then press back up to the starting position.",
                    "videoURL": "https://via.placeholder.com/400x220.png?text=Tricep+Dips"
                ]
            ]

            let batch = self.db.batch()
            for exercise in exercises {
                let ref = self.db.collection("exercises").document()
                batch.setData(exercise, forDocument: ref)
            }

            batch.commit { error in
                if let error = error {
                    print("seed failed: \(error)")
                } else {
                    print("seeded 10 exercises")
                }
                completion()
            }
        }
    }
```

- [ ] **Step 2: Call seedExercises from FitnessViewModel.loadData()**

In `FitnessViewModel.swift`, replace the `loadData()` method with:

```swift
    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in")
            return
        }

        isLoading = true

        firestoreService.getWorkoutPlan(userId: uid) { [weak self] plan in
            DispatchQueue.main.async {
                self?.workoutPlan = plan
                self?.isLoading = false
            }
        }

        // seed exercises if none exist, then load them
        firestoreService.seedExercises { [weak self] in
            self?.firestoreService.loadExercises()
        }

        firestoreService.$exercises
            .receive(on: DispatchQueue.main)
            .assign(to: &$exercises)
    }
```

The key change: instead of calling `loadExercises()` directly, we call `seedExercises()` first (which checks if exercises exist), then `loadExercises()` in the completion handler.

- [ ] **Step 3: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add FitnessTracker/Services/FirestoreService.swift FitnessTracker/ViewModels/FitnessViewModel.swift
git commit -m "feat: seed 10 exercises to Firestore and fix exercise loading"
```

---

### Task 3: LocationService

**Files:**
- Create: `FitnessTracker/Services/LocationService.swift`

- [ ] **Step 1: Create LocationService**

Create `FitnessTracker/Services/LocationService.swift` following the lab guide pattern:

```swift
import Foundation
import Combine
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager
    @Published var currentLocation: CLLocation?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        print("location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error: \(error.localizedDescription)")
    }
}
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Services/LocationService.swift
git commit -m "feat: add LocationService with CLLocationManager wrapper"
```

---

### Task 4: NearbyGymsView

**Files:**
- Create: `FitnessTracker/Views/Fitness/NearbyGymsView.swift`

- [ ] **Step 1: Create NearbyGymsView**

Create `FitnessTracker/Views/Fitness/NearbyGymsView.swift`:

```swift
import SwiftUI
import MapKit

struct NearbyGymsView: View {
    @StateObject private var locationService = LocationService()
    @State private var gyms: [MKMapItem] = []
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // map
            Map(position: $cameraPosition) {
                // user location dot
                UserAnnotation()

                // gym pins
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
                    .foregroundStyle(.white)
                Spacer()
            } else if gyms.isEmpty {
                Spacer()
                Text("No gyms found nearby")
                    .foregroundStyle(.gray)
                Spacer()
            } else {
                List(gyms, id: \.self) { gym in
                    gymRow(gym)
                        .listRowBackground(Color(white: 0.11))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.black)
        .navigationTitle("Nearest gym")
        .navigationBarTitleDisplayMode(.large)
        .onReceive(locationService.$currentLocation) { location in
            guard let location = location else { return }
            searchGyms(near: location)
            // stop updating once we have a location
            locationService.stopUpdatingLocation()
        }
    }

    private func gymRow(_ gym: MKMapItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(gym.name ?? "Unknown Gym")
                    .font(.headline)
                    .foregroundStyle(.white)

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

            // center map on user with results visible
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            ))
        }
    }

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
    .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add FitnessTracker/Views/Fitness/NearbyGymsView.swift
git commit -m "feat: add NearbyGymsView with map and gym list"
```

---

### Task 5: Wire Up Nearby Gyms Button + Location Permission

**Files:**
- Modify: `FitnessTracker/Views/Fitness/FitnessView.swift:152-167`
- Modify: `FitnessTracker.xcodeproj/project.pbxproj:276,311`

- [ ] **Step 1: Replace placeholder button with NavigationLink in FitnessView**

In `FitnessView.swift`, replace the `nearbyGymsButton` computed property (lines 152-167):

```swift
    private var nearbyGymsButton: some View {
        Button {
            // placeholder - nearby gyms not yet implemented
        } label: {
            Text("View nearby gyms")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
```

with:

```swift
    private var nearbyGymsButton: some View {
        NavigationLink(destination: NearbyGymsView()) {
            Text("View nearby gyms")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
```

- [ ] **Step 2: Add NSLocationWhenInUseUsageDescription to project.pbxproj**

In `FitnessTracker.xcodeproj/project.pbxproj`, find both occurrences of:

```
INFOPLIST_KEY_NSMotionUsageDescription = "This app uses motion data to count your steps and track your daily activity.";
```

After each one (there are two — one for Debug, one for Release), add:

```
INFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "This app needs your location to find nearby gyms.";
```

- [ ] **Step 3: Build to verify**

Run:
```bash
xcodebuild -scheme FitnessTracker -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add FitnessTracker/Views/Fitness/FitnessView.swift FitnessTracker.xcodeproj/project.pbxproj
git commit -m "feat: wire up nearby gyms button and add location permission"
```
