import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedCity") private var selectedCity = City.khulna.name

    var body: some View {
        TabView {
            WeatherHomeView(selectedCity: $selectedCity)
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }

            NavigationStack {
                ContentUnavailableView(
                    "Laundry planning",
                    systemImage: "basket",
                    description: Text("Saving and managing plans will be available in a later phase.")
                )
                .navigationTitle("My Plans")
            }
            .tabItem {
                Label("My Plans", systemImage: "calendar")
            }

            ProfileView(selectedCity: selectedCity)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            if !City.cities.contains(where: { $0.name == selectedCity }) {
                selectedCity = City.khulna.name
            }
        }
    }
}
