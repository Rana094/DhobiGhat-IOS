import SwiftUI

struct AddPlanView: View {
    let city: String
    let forecastDates: [String]
    @Binding var selectedDate: String
    @ObservedObject var plans: PlanViewModel
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
                    .disabled(plans.isSaving)
                }

                Section("Optional note") {
                    TextField("For example, bedsheets and towels", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .disabled(plans.isSaving)
                }

                if let errorMessage = plans.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if plans.isSaving {
                    Section {
                        ProgressView("Waiting for server confirmation…")
                        Text("If offline, saving may wait until you reconnect. Cancel closes this form but cannot cancel a submitted write.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Save plan") {
                        Task {
                            guard forecastDates.contains(selectedDate) else { return }
                            let saved = await plans.addPlan(city: city, date: selectedDate, note: note)
                            if saved {
                                dismiss()
                            }
                        }
                    }
                    .disabled(plans.isLoading || !forecastDates.contains(selectedDate))
                }
            }
            .navigationTitle("Plan Laundry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                plans.errorMessage = nil
            }
        }
    }
}
