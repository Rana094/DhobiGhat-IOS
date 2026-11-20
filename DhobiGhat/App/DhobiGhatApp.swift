import SwiftUI

@main
struct DhobiGhatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(.blue)
        }
    }
}
