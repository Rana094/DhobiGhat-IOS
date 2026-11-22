import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var plans = PlanViewModel()
    @State private var selectedTab = "weather"
    @AppStorage("selectedCity") private var selectedCity = City.khulna.name

    var body: some View {
        TabView(selection: $selectedTab) {
            WeatherHomeView(selectedCity: $selectedCity, plans: plans) {
                selectedTab = "plans"
            }
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
                .tag("weather")

            MyPlansView(plans: plans)
                .tabItem {
                    Label("My Plans", systemImage: "calendar")
                }
                .tag("plans")

            ProfileView(selectedCity: selectedCity)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag("profile")
        }
        .onAppear {
            if !City.cities.contains(where: { $0.name == selectedCity }) {
                selectedCity = City.khulna.name
            }
        }
        .task(id: auth.currentUser?.uid) {
            guard !Task.isCancelled else { return }
            plans.setUser(auth.currentUser?.uid)
            await plans.fetchPlans()
        }
        .onChange(of: auth.currentUser?.uid) {
            plans.setUser(auth.currentUser?.uid)
        }
        .onDisappear {
            plans.setUser(nil)
        }
    }
}
