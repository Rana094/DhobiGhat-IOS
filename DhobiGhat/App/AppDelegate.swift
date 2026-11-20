import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() != nil {
            return true
        }

        guard let filePath = Bundle.main.path(
            forResource: "GoogleService-Info", ofType: "plist"
        ), let options = FirebaseOptions(contentsOfFile: filePath) else {
            print("Firebase setup: add a valid GoogleService-Info.plist to the DhobiGhat target.")
            return true
        }

        guard options.bundleID == Bundle.main.bundleIdentifier else {
            print("Firebase setup: the plist bundle ID must match the DhobiGhat target.")
            return true
        }

        FirebaseApp.configure()
        return true
    }
}
