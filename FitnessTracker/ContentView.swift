import SwiftUI

// main tab bar - home, fitness, meals, settings
struct ContentView: View {
    @EnvironmentObject var authViewModel: LoginViewModel
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                tab.view
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(Color(red: 1, green: 0.84, blue: 0)) // yellow from the design
    }
}

// each tab with its icon and view
enum Tab: String, CaseIterable, Identifiable {
    case home
    case fitness
    case addMeal
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .fitness: "Fitness"
        case .addMeal: "Add Meal"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .fitness: "figure.run"
        case .addMeal: "plus.circle.fill"
        case .settings: "gearshape.fill"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomeView()
        case .fitness: FitnessView()
        case .addMeal: MealTrackerView()
        case .settings: SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
}
