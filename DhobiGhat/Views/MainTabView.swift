import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)

                    Text("Smart Laundry Day Planner")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose a suitable day to wash and dry your clothes.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Weather forecasts will appear here in a later phase.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.06))
                .navigationTitle("DhobiGhat")
            }
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

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
