import SwiftUI

struct RootView: View {
    var body: some View {
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
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.06))
            .navigationTitle("DhobiGhat")
        }
    }
}
