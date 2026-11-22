import SwiftUI

struct WeatherHomeView: View {
    @Binding var selectedCity: String
    @ObservedObject var plans: PlanViewModel
    let onPlanSaved: () -> Void
    @StateObject private var weather = WeatherViewModel()
    @State private var retryCount = 0
    @State private var selectedDate = ""
    @State private var showAddPlan = false
    @State private var didSavePlan = false

    private var city: City {
        City.cities.first { $0.name == selectedCity } ?? City.khulna
    }

    private var canPlanLaundry: Bool {
        !weather.isLoading && !plans.isLoading && weather.errorMessage == nil && weather.cityName == city.name
            && LaundryPlan.isValidDate(selectedDate)
            && weather.days.contains(where: { $0.date == selectedDate })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("City", selection: $selectedCity) {
                        ForEach(City.cities) { city in
                            Text(city.name).tag(city.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

                    Text("Three-day forecast for \(city.name)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Dates follow Bangladesh time.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text("Drying recommendations are basic project-defined guidelines, not guaranteed drying predictions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    // Hide old cards immediately, even before the new task starts.
                    if weather.isLoading || weather.cityName != city.name {
                        ProgressView("Loading forecast…")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let errorMessage = weather.errorMessage {
                        ContentUnavailableView {
                            Label("Weather unavailable", systemImage: "wifi.exclamationmark")
                        } description: {
                            Text(errorMessage)
                        } actions: {
                            Button("Retry") { retryCount += 1 }
                                .buttonStyle(.borderedProminent)
                        }
                    } else if weather.days.isEmpty {
                        ContentUnavailableView(
                            "No forecast available",
                            systemImage: "cloud",
                            description: Text("The weather service did not return forecast dates for this city.")
                        )
                        Button("Retry") { retryCount += 1 }
                            .buttonStyle(.borderedProminent)
                    } else {
                        if weather.days.count < 3 {
                            Text("Some forecast days are unavailable.")
                                .foregroundStyle(.secondary)
                        }

                        ForEach(weather.days) { day in
                            WeatherDayCard(day: day, selectedDate: $selectedDate)
                        }
                    }

                    if selectedDate.isEmpty {
                        Text("Select a forecast date to plan your laundry.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        didSavePlan = false
                        showAddPlan = true
                    } label: {
                        Label("Plan Laundry", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canPlanLaundry)
                    .controlSize(.large)

                    if plans.isLoading {
                        ProgressView("Updating your laundry plans…")
                    }

                    if let url = URL(string: "https://open-meteo.com/") {
                        Link("Weather data: Open-Meteo", destination: url)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            .background(Color.blue.opacity(0.06))
            .navigationTitle("DhobiGhat")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        retryCount += 1
                    } label: {
                        Label("Refresh forecast", systemImage: "arrow.clockwise")
                    }
                    .disabled(weather.isLoading)
                }
            }
        }
        .task(id: "\(selectedCity)-\(retryCount)") {
            guard !Task.isCancelled else { return }
            selectedDate = ""
            showAddPlan = false
            await weather.loadWeather(for: city)
        }
        .onChange(of: selectedCity) {
            selectedDate = ""
            showAddPlan = false
        }
        .sheet(isPresented: $showAddPlan, onDismiss: {
            if didSavePlan {
                didSavePlan = false
                onPlanSaved()
            }
        }) {
            AddPlanView(
                city: city.name,
                forecastDates: weather.days.map { $0.date },
                selectedDate: $selectedDate,
                plans: plans,
                onSaved: { didSavePlan = true }
            )
        }
    }
}
