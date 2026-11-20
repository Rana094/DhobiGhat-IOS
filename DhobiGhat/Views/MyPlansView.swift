import SwiftUI

struct MyPlansView: View {
    @ObservedObject var plans: PlanViewModel
    @State private var planToDelete: LaundryPlan?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = plans.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                        Button("Retry refresh") {
                            Task { await plans.fetchPlans() }
                        }
                        .disabled(plans.isLoading)
                    }
                }

                if plans.isLoading {
                    Section {
                        ProgressView("Loading or updating plans…")
                        Text("A submitted write may wait for internet access and server confirmation.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if plans.plans.isEmpty && plans.errorMessage == nil {
                    ContentUnavailableView(
                        "No laundry plans yet",
                        systemImage: "basket",
                        description: Text("Choose a forecast date in Weather and tap Plan Laundry.")
                    )
                }

                ForEach(plans.plans) { plan in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(plan.city)
                            .font(.headline)
                        Label(plan.date, systemImage: "calendar")
                        if !plan.note.isEmpty {
                            Text(plan.note)
                                .foregroundStyle(.secondary)
                        }

                        if plan.isCompleted {
                            Label("Completed", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Pending", systemImage: "clock")
                                .foregroundStyle(.orange)
                        }

                        HStack {
                            if !plan.isCompleted {
                                Button("Mark completed") {
                                    Task { await plans.completePlan(plan) }
                                }
                            }
                            Spacer()
                            Button("Delete", role: .destructive) {
                                planToDelete = plan
                                showDeleteAlert = true
                            }
                        }
                        .buttonStyle(.borderless)
                        .disabled(plans.isLoading)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("My Plans")
            .refreshable {
                await plans.fetchPlans()
            }
            .task {
                await plans.fetchPlans()
            }
            .alert("Delete laundry plan?", isPresented: $showDeleteAlert, presenting: planToDelete) { plan in
                Button("Delete", role: .destructive) {
                    Task { await plans.deletePlan(plan) }
                }
                Button("Cancel", role: .cancel) { }
            } message: { plan in
                Text("Delete the plan for \(plan.city) on \(plan.date)?")
            }
        }
    }
}
