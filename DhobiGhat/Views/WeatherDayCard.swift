import SwiftUI

struct WeatherDayCard: View {
    let day: WeatherDay
    @Binding var selectedDate: String

    private var recommendationColor: Color {
        switch day.dryingRecommendation() {
        case .good:
            return .green
        case .risky:
            return .orange
        case .avoid:
            return .red
        case nil:
            return .secondary
        }
    }

    var body: some View {
        Button {
            selectedDate = day.date
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label(day.date, systemImage: "calendar")
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if selectedDate == day.date {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .font(.headline)

                WeatherValueRow(title: "Max temperature", symbol: "thermometer.medium", value: day.temperature, unit: "°C")
                WeatherValueRow(title: "Rain probability", symbol: "cloud.rain", value: day.rainProbability, unit: "%")
                WeatherValueRow(title: "Precipitation", symbol: "drop", value: day.precipitation, unit: "mm")
                WeatherValueRow(title: "Max wind speed", symbol: "wind", value: day.windSpeed, unit: "km/h")

                HStack {
                    Text("Drying outlook")
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Text(day.dryingRecommendation()?.rawValue ?? "Unavailable")
                        .fontWeight(.semibold)
                        .foregroundStyle(recommendationColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(recommendationColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedDate == day.date ? Color.blue : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedDate == day.date ? .isSelected : [])
        .accessibilityHint("Select this forecast date for your laundry plan.")
    }
}

private struct WeatherValueRow: View {
    let title: String
    let symbol: String
    let value: Double?
    let unit: String

    private var valueText: some View {
        Group {
            if let value {
                Text("\(value, specifier: "%.1f") \(unit)")
                    .monospacedDigit()
            } else {
                Text("Unavailable")
            }
        }
        .foregroundStyle(Color.primary)
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Label(title, systemImage: symbol)
                    .fixedSize()
                Spacer(minLength: 0)
                valueText.fixedSize()
            }
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: symbol)
                valueText
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
}
