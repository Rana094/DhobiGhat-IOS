# DhobiGhat Viva Notes

## Phase 2: what is implemented

Seven Swift source files now describe real Firebase email/password authentication and its UI. Native Xcode project creation, SPM attachment, a real Firebase plist, and live tests remain pending because this workspace runs on Windows without Xcode or Swift. Authentication source is implemented; connectivity, compilation, session restoration, and launch are unverified. Weather and plan storage are not implemented. Phase 1 was not present; Phase 2 was explicitly requested next.

## Current app flow and important code

1. `@main` marks `DhobiGhatApp` as the application's entry point. An app target should have only one such entry point.
2. `DhobiGhatApp` conforms to SwiftUI's `App` protocol. Its `body` describes a `Scene`, using `WindowGroup` to show `RootView`. `@UIApplicationDelegateAdaptor` connects the UIKit app delegate to the SwiftUI lifecycle.
3. `AppDelegate.application(_:didFinishLaunchingWithOptions:)` checks for a readable Firebase plist and matching bundle ID, then calls `FirebaseApp.configure()`. When setup is incomplete, the console reports it and the root UI shows setup instructions instead of using Auth.
4. `RootView` owns one auth model with `@StateObject`. Its stable `ZStack` shows setup instructions, initial session loading, `LoginView`, or `MainTabView` according to the observed state. Its `.task` starts the listener after launch. `some View` describes a specific view type without naming its full nested type.
5. `VStack` arranges the image and text vertically. `spacing` sets the distance between items.
6. `Image(systemName: "drop.fill")` uses an SF Symbol supplied by Apple; it is not a downloaded image.
7. View modifiers set the font, color, alignment, padding, frame, background, and navigation title. The background is a faint blue produced by `opacity(0.06)`.
8. `Color` and `.infinity` are native SwiftUI values. `frame(maxWidth:maxHeight:)` lets the content fill available space; `padding(24)` provides inner spacing.

The original welcome content now appears in the authenticated Weather tab. `NavigationStack` provides each screen's title. `Form` groups login and profile controls, `SecureField` masks the password, and `TabView` switches between Weather, My Plans, and Profile. Weather and plan management show explicit placeholders. `body` is a computed property, not a stored screen image.

## SwiftUI state concepts

Some concepts are implemented in Phase 2; the remaining required wrappers will be introduced when their real features are added.

| Concept | Meaning | Current or planned meaningful use |
| --- | --- | --- |
| `@State` | View-owned local UI state that can trigger a refresh | Implemented: LoginView email, password, and register/login mode; later: forecast date and sheet |
| `@Binding` | Read/write access to state owned elsewhere | City and child date selection; `$value` passes a binding |
| `ObservableObject` | Protocol for reference types that notify SwiftUI about changes | Implemented: AuthViewModel imports Combine; weather/plan models later |
| `@Published` | Publishes changes to properties of an observable object | Implemented: current user, email, loading, errors, session check, and setup error |
| `@StateObject` | Creates and preserves an observable object for the owning view's lifetime | Implemented: Root owns auth; later: main tabs own plans and weather screen owns weather |
| `@ObservedObject` | Observes an object supplied by another owner | My Plans receives the existing plan ViewModel |
| `@EnvironmentObject` | Reads a shared observable object injected by an ancestor | Implemented: LoginView and ProfileView read auth after root injects it |
| `@AppStorage` | Connects a simple preference in UserDefaults to SwiftUI | Remember selected city across launches |

`@StateObject` owns a model's lifetime; `@ObservedObject` receives an existing model. Do not recreate a ViewModel every time a view's `body` runs. `@AppStorage` is for the city preference, not passwords or account-specific plans. The project requires `ObservableObject` and `@Published`, not the newer `@Observable` macro.

## Planned MVVM responsibilities

- **Model**: simple structs that describe cities, weather days, decoded API responses, and laundry plans.
- **View**: displays state and forwards button actions. It should not contain networking or database logic.
- **ViewModel**: owns screen state and small functions that load or change it.
- **Service**: performs a direct API or Firestore operation. No generic repository or extra architecture is needed.

## Important authentication functions

- `startListening()`: first checks whether Firebase was configured. Only then does it create `Auth.auth()` and add a state listener. It avoids duplicate listeners. The initial callback ends the session-loading screen and reads the SDK's restored user.
- `stopListening()`: removes the listener and clears local user/email references when RootView disappears. Root's stable container prevents login/main screen changes from ending the root listener.
- `register(email:password:)`: trims email, validates input, awaits Firebase `createUser`, and displays a caught error. Firebase signs a newly created account in automatically.
- `login(email:password:)`: validates input, awaits Firebase `signIn`, and lets the listener drive the authenticated UI.
- `logout()`: calls Firebase `signOut()` in `do/catch`. Clears user/email only after success; failures leave the current session visible with an error.
- `validate(...)`: rejects blank/malformed email and an empty password; registration additionally requires at least six characters. The small regular expression checks a basic `local@domain.suffix` shape and excludes spaces. Firebase is the final authority on validity and project policy. Passwords are never trimmed or saved by app code.
- `message(for:)`: turns Firebase's `AuthErrorCode` into a useful message. Incorrect password, missing user, and invalid credentials share one message, so the UI works with email enumeration protection.

`isLoading` prevents duplicate submissions. `defer` restores it when a request finishes, whether it succeeds or throws. `@MainActor` keeps published UI state changes on the main actor. A `Task { @MainActor ... }` brings the listener's update into that isolation context. `[weak self]` prevents the long-lived listener from retaining the ViewModel. `private(set)` lets views read state while only the ViewModel changes it.

## Firebase integration and session restoration

Firebase is not connected or tested here. README gives exact steps for adding the official `FirebaseAuth` and `FirebaseFirestore` SPM products to a native target, registering the bundle ID in Firebase Console, enabling Email/Password, and bundling a real `GoogleService-Info.plist`. These manual steps are pending. `FirebaseCore` comes through the official SDK dependencies.

The ViewModel's stored properties do not call Firebase during initialization. `startListening()` runs from root's task and checks `FirebaseApp.app()` before calling Auth. This matters because calling `Auth.auth()` without a configured default app can fail. A missing/invalid or wrong-bundle plist leaves Firebase unconfigured and displays setup instructions. Restart the app after correcting configuration.

The SDK persists the secure authenticated session, not our own Boolean flag. On relaunch, root waits for the first state-listener callback before choosing a login or main screen. The main tabs use `.id(user.uid)`, giving a different account a new view identity. This prepares the view boundary for future account-specific state; future plan listeners still need their own cleanup. A cached session does not prove every future server request will be accepted.

Firebase Authentication handles email/password sign-in and provides an authenticated user's UID. `currentUser` is the actual SDK User, and `userEmail` is a UI copy of its email. Passwords remain local to the form/request and must not be stored in Firestore or UserDefaults. The future Firestore phase will store laundry plans under `users/{userUID}/plans/{planID}`. Authentication identifies the user; security rules determine whether the request may access a document. Hiding another user's plans in the UI alone is not access control.

Rules must require a signed-in user whose UID matches the path's UID. The plan model must clear old plans and stop old account listeners/tasks on sign-out or account changes so one account's state cannot appear in another session. Session restoration and actual rule behavior will need runtime verification later.

## JSON and networking concepts for later phases

JSON is a text format for structured data. `URLSession` will request Open-Meteo data using `async/await`. The service must check the HTTP response and handle failures. `JSONDecoder` will convert response bytes into `Decodable` structs; `CodingKeys` can map JSON names to simple Swift property names. `Codable` combines decoding and encoding; an API response that is only read can use `Decodable`.

The daily response contains dates and related measurements. Later code must handle missing values and inconsistent arrays without force unwraps or out-of-range indexing. Three daily forecasts use `Asia/Dhaka` dates. No network request or JSON parser exists yet.

## Planned drying recommendation function

Apply Avoid first: rain probability >= 60% or precipitation >= 3 mm. Otherwise apply Risky: probability >= 30%, precipitation >= 1 mm, or wind >= 30 km/h. Otherwise return Good. A windy day with heavy rain still returns Avoid because that condition is checked first. These are project heuristics, not scientific guarantees. This function is not implemented yet.

## Common viva questions

**Why use SwiftUI structs for screens?** They describe the interface as values. SwiftUI uses state changes to update what is shown.

**Why is a ViewModel a class?** Its shared reference identity and observable properties allow multiple views to observe the same changing state.

**What is the difference between an Xcode project and Swift files?** Source files contain code. The `.xcodeproj` defines targets, source membership, resources, and build settings. The source scaffold alone is not a configured iOS app target.

**What is a target?** The product and instructions Xcode builds, including its sources, resources, bundle identifier, and supported platform.

**What is a deployment target?** The oldest OS version the app supports. The intended minimum is iOS 17.0, but it has not yet been set in an Xcode project. It differs from the installed SDK and the Simulator runtime used to test the app.

**Is Swift installed and has this app compiled?** Swift was not found on PATH here. Xcode and an iOS Simulator are unavailable in this Windows environment. No compilation or launch success has been verified.

**Why use AppDelegate with SwiftUI?** `@UIApplicationDelegateAdaptor` receives native launch events so Firebase can be configured in `didFinishLaunchingWithOptions` before Auth is used.

**Why both StateObject and EnvironmentObject?** Root owns one auth model with `@StateObject`; `.environmentObject(auth)` supplies that same instance to child screens, which read it with `@EnvironmentObject`.

**What does async/await do?** It lets registration/login wait for Firebase without blocking the UI. AuthViewModel is marked `@MainActor` so UI state updates stay on the main actor.

**Why use the UID rather than email for Firestore paths?** Firebase provides a stable user identifier for authenticated access checks. An email address can change and should not be the database identity.

**What restores the logged-in session?** The Firebase SDK maintains it. The listener reports the restored current user after initialization. The app does not store a password or `isLoggedIn` preference.

**Does a successful account creation require a separate login?** No. Firebase signs in the newly created user, which triggers the listener and switches root to the main tabs.

**What happens when login fails?** The request throws, the ViewModel publishes a helpful message, loading ends through `defer`, and the login form remains visible. Main tabs require an actual Firebase user.

**Is FirebaseFirestore used already?** It is a required package product to attach during setup, but this phase makes no Firestore calls. Database operations and security rules remain for the plan-storage phase.

**What should be tested on a Mac next?** Create the native target, attach the SDK, add real configuration, build/run, then verify registration, valid/invalid login, logout, restart restoration, persisted logout, and UI reaction. README includes every test with its expected result; all are pending here.

Official study references: [Firebase setup](https://firebase.google.com/docs/ios/setup), [email/password authentication](https://firebase.google.com/docs/auth/ios/password-auth), [session listeners](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Classes/Auth.html), and [error codes](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode).
