import SwiftUI

struct AddPlanView: View {
    let city: String
    let forecastDates: [String]
    @Binding var selectedDate: String
    @State private var note = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("City") {
                    Text(city)
                }

                Section("Forecast date") {
                    Picker("Laundry date", selection: $selectedDate) {
                        ForEach(forecastDates, id: \.self) { date in
                            Text(date).tag(date)
                        }
                    }
                }

                Section("Optional note") {
                    TextField("For example, bedsheets and towels", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section {
                    Text("Saving plans is not available yet. Closing this form does not save your note or create a plan.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Plan Laundry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
