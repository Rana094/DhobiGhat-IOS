import SwiftUI

struct WeatherHomeView: View {
    @Binding var selectedCity: String
    @StateObject private var weather = WeatherViewModel()
    @State private var retryCount = 0

    private var city: City {
        City.cities.first { $0.name == selectedCity } ?? City.khulna
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
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))

                    Text("Three-day forecast for \(city.name)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Dates follow Bangladesh time.")
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
                            WeatherDayCard(day: day)
                        }
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
        }
        .task(id: "\(selectedCity)-\(retryCount)") {
            await weather.loadWeather(for: city)
        }
    }
}
