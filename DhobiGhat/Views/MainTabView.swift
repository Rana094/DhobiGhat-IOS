import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var plans = PlanViewModel()
    @AppStorage("selectedCity") private var selectedCity = City.khulna.name

    var body: some View {
        TabView {
            WeatherHomeView(selectedCity: $selectedCity, plans: plans)
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }

            MyPlansView(plans: plans)
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
