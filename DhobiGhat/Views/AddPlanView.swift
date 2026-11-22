import SwiftUI

struct AddPlanView: View {
    let city: String
    let forecastDates: [String]
    @Binding var selectedDate: String
    @ObservedObject var plans: PlanViewModel
    let onSaved: () -> Void
    @State private var note = ""
    @State private var isVisible = true
    @Environment(\.dismiss) private var dismiss

    private var hasValidDate: Bool {
        forecastDates.contains(selectedDate) && LaundryPlan.isValidDate(selectedDate)
    }

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

                    if !hasValidDate {
                        Text("Choose a valid date from the current forecast.")
                            .foregroundStyle(.red)
                    }
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
                    Button {
                        Task {
                            guard hasValidDate else { return }
                            let saved = await plans.addPlan(city: city, date: selectedDate, note: note)
                            if saved && isVisible {
                                onSaved()
                                dismiss()
                            }
                        }
                    } label: {
                        Label(plans.isSaving ? "Saving plan…" : "Save plan", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(plans.isLoading || !hasValidDate)
                }
            }
            .navigationTitle("Plan Laundry")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(Color.blue.opacity(0.06))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isVisible = false
                        dismiss()
                    }
                }
            }
            .onAppear {
                isVisible = true
                plans.errorMessage = nil
            }
            .onDisappear {
                isVisible = false
            }
        }
    }
}
