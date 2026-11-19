# DhobiGhat Viva Notes

## Phase 0: what currently works

Two Swift source files describe a minimal welcome screen. There is no generated Xcode project or app target yet because this workspace runs on Windows without native Xcode tools. Compilation and launch are unverified. Authentication, weather, and plan storage have not been implemented.

## Current app flow and important code

1. `@main` marks `DhobiGhatApp` as the application's entry point. An app target should have only one such entry point.
2. `DhobiGhatApp` conforms to SwiftUI's `App` protocol. Its `body` describes a `Scene`, using `WindowGroup` to show `RootView`.
3. `RootView` is a small struct conforming to `View`. Its `body: some View` describes the screen. `some View` lets Swift keep the specific view type while exposing conformance to `View`.
4. `NavigationStack` provides a navigation container and title. It will support navigation when real screens are added.
5. `VStack` arranges the image and text vertically. `spacing` sets the distance between items.
6. `Image(systemName: "drop.fill")` uses an SF Symbol supplied by Apple; it is not a downloaded image.
7. View modifiers set the font, color, alignment, padding, frame, background, and navigation title. The background is a faint blue produced by `opacity(0.06)`.
8. `Color` and `.infinity` are native SwiftUI values. `frame(maxWidth:maxHeight:)` lets the content fill available space; `padding(24)` provides inner spacing.

There are no custom business functions or observable models yet because the welcome screen has no changing data. `body` is a computed property, not a stored screen image.

## SwiftUI state concepts planned for later phases

These explanations are study notes; the wrappers below are not yet used in Phase 0 source.

| Concept | Meaning | Planned meaningful use |
| --- | --- | --- |
| `@State` | View-owned local UI state that can trigger a refresh | Selected forecast date and sheet visibility |
| `@Binding` | Read/write access to state owned elsewhere | City and child date selection; `$value` passes a binding |
| `ObservableObject` | Protocol for reference types that notify SwiftUI about changes | Auth, weather, and plan ViewModels; import Combine |
| `@Published` | Publishes changes to properties of an observable object | Days, plans, authenticated state, loading, and errors |
| `@StateObject` | Creates and preserves an observable object for the owning view's lifetime | Root owns auth; main tabs own plans; weather screen owns weather |
| `@ObservedObject` | Observes an object supplied by another owner | My Plans receives the existing plan ViewModel |
| `@EnvironmentObject` | Reads a shared observable object injected by an ancestor | Profile reads auth after root injects it |
| `@AppStorage` | Connects a simple preference in UserDefaults to SwiftUI | Remember selected city across launches |

`@StateObject` owns a model's lifetime; `@ObservedObject` receives an existing model. Do not recreate a ViewModel every time a view's `body` runs. `@AppStorage` is for the city preference, not passwords or account-specific plans. The project requires `ObservableObject` and `@Published`, not the newer `@Observable` macro.

## Planned MVVM responsibilities

- **Model**: simple structs that describe cities, weather days, decoded API responses, and laundry plans.
- **View**: displays state and forwards button actions. It should not contain networking or database logic.
- **ViewModel**: owns screen state and small functions that load or change it.
- **Service**: performs a direct API or Firestore operation. No generic repository or extra architecture is needed.

## Firebase concepts for later phases

Firebase is not connected or tested. The official SDK and a real `GoogleService-Info.plist` will be added during the relevant phase.

Firebase Authentication handles email/password sign-in and provides an authenticated user's UID. Passwords must not be stored in Firestore or UserDefaults. Firestore stores the laundry plans under `users/{userUID}/plans/{planID}`. Authentication identifies the user; security rules determine whether the request may access a document. Hiding another user's plans in the UI alone is not access control.

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

**Why no AppDelegate yet?** The SwiftUI App lifecycle is sufficient for the static scaffold. Firebase startup can be introduced when integration is requested.

**Why no property wrappers in the welcome screen?** It has no mutable state. Wrappers will be added when real features need them.

**What does async/await do?** It lets asynchronous work suspend without blocking the calling thread. UI state changes must occur on the main actor; a later ViewModel can use `@MainActor`.

**Why use the UID rather than email for Firestore paths?** Firebase provides a stable user identifier for authenticated access checks. An email address can change and should not be the database identity.

**What should be tested on a Mac next?** Native project recognition, existence of the DhobiGhat iOS target, effective Swift/deployment settings, build success, and the welcome screen launching on a Simulator or iPhone.
