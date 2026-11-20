import SwiftUI

struct WeatherDayCard: View {
    let day: WeatherDay

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(day.date, systemImage: "calendar")
                .font(.headline)

            WeatherValueRow(title: "Max temperature", symbol: "thermometer.medium", value: day.temperature, unit: "°C")
            WeatherValueRow(title: "Rain probability", symbol: "cloud.rain", value: day.rainProbability, unit: "%")
            WeatherValueRow(title: "Precipitation", symbol: "drop", value: day.precipitation, unit: "mm")
            WeatherValueRow(title: "Max wind speed", symbol: "wind", value: day.windSpeed, unit: "km/h")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct WeatherValueRow: View {
    let title: String
    let symbol: String
    let value: Double?
    let unit: String

    var body: some View {
        HStack {
            Label(title, systemImage: symbol)
            Spacer()

            if let value {
                Text("\(value, specifier: "%.1f") \(unit)")
                    .monospacedDigit()
            } else {
                Text("Unavailable")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
