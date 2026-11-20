# DhobiGhat Viva Notes

## Phase 3: what is implemented

Fourteen app Swift files now describe Firebase authentication and Open-Meteo weather. Native Xcode project creation, Firebase SPM/configuration, build, and app tests remain pending because this workspace runs on Windows without Xcode or Swift. Direct checks of all three city endpoints returned HTTP 200 with three days; these do not verify the Swift parser or UI. Seven XCTest methods are prepared but not run. Plan storage and drying recommendations are unimplemented. Phase 1 was not present; later phases were explicitly requested.

## Current app flow and important code

1. `@main` marks `DhobiGhatApp` as the application's entry point. An app target should have only one such entry point.
2. `DhobiGhatApp` conforms to SwiftUI's `App` protocol. Its `body` describes a `Scene`, using `WindowGroup` to show `RootView`. `@UIApplicationDelegateAdaptor` connects the UIKit app delegate to the SwiftUI lifecycle.
3. `AppDelegate.application(_:didFinishLaunchingWithOptions:)` checks for a readable Firebase plist and matching bundle ID, then calls `FirebaseApp.configure()`. When setup is incomplete, the console reports it and the root UI shows setup instructions instead of using Auth.
4. `RootView` owns one auth model with `@StateObject`. Its stable `ZStack` shows setup instructions, initial session loading, `LoginView`, or `MainTabView` according to the observed state. Its `.task` starts the listener after launch. `some View` describes a specific view type without naming its full nested type.
5. `VStack` arranges the image and text vertically. `spacing` sets the distance between items.
6. `Image(systemName: "drop.fill")` uses an SF Symbol supplied by Apple; it is not a downloaded image.
7. View modifiers set the font, color, alignment, padding, frame, background, and navigation title. The background is a faint blue produced by `opacity(0.06)`.
8. `Color` and `.infinity` are native SwiftUI values. `frame(maxWidth:maxHeight:)` lets the content fill available space; `padding(24)` provides inner spacing.

`NavigationStack` provides each screen's title. `Form` groups login/profile controls, `SecureField` masks the password, and `TabView` switches between Weather, My Plans, and Profile. Weather displays API results when configured and run; only plan management remains a placeholder. `body` is a computed property, not a stored screen image.

## SwiftUI state concepts

The table separates current uses from wrappers/features still planned.

| Concept | Meaning | Current or planned meaningful use |
| --- | --- | --- |
| `@State` | View-owned local UI state that can trigger a refresh | Login inputs/mode and WeatherHomeView's Retry count; forecast date and sheet later |
| `@Binding` | Read/write access to state owned elsewhere | WeatherHomeView reads/changes MainTabView's city; `$selectedCity` passes the binding; date selection later |
| `ObservableObject` | Protocol for reference types that notify SwiftUI about changes | AuthViewModel and WeatherViewModel import Combine; plan model later |
| `@Published` | Publishes changes to properties of an observable object | Auth properties plus weather days, loading, errors, and city name |
| `@StateObject` | Creates and preserves an observable object for the owning view's lifetime | Root owns auth; WeatherHomeView owns weather; main tabs will own plans later |
| `@ObservedObject` | Observes an object supplied by another owner | My Plans receives the existing plan ViewModel |
| `@EnvironmentObject` | Reads a shared observable object injected by an ancestor | Implemented: LoginView and ProfileView read auth after root injects it |
| `@AppStorage` | Connects a simple preference in UserDefaults to SwiftUI | MainTabView remembers selectedCity across launches and passes it to Profile |

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

## Phase 3 networking and JSON concepts

**URLSession** is Apple's networking API. `fetchWeather(for:)` uses `URLSession.shared.data(for:)` to get response bytes (`Data`) and response metadata. The service casts metadata to `HTTPURLResponse` and accepts only status codes 200...299. Transport failures throw; HTTP 400/500 must be checked separately because they do not automatically make URLSession throw.

**JSON** is text representing objects, arrays, numbers, strings, booleans, and null. Open-Meteo's `daily` object contains parallel arrays: index 0 of `time` and index 0 of each measurement refer to the same day.

**Decodable** lets a Swift type be constructed from encoded data. `WeatherResponse` contains the optional daily object; `DailyWeather` contains optional arrays. Swift synthesizes decoding for these simple structs. `CodingKeys` maps `temperature_2m_max` to the simpler Swift name `temperature`, and similarly for other fields.

**Codable** combines `Decodable` and `Encodable`. Decoding reads data into Swift values; encoding writes Swift values into data. These read-only API responses only need Decodable.

**JSONDecoder** does the conversion: `try JSONDecoder().decode(WeatherResponse.self, from: data)`. Malformed JSON or incompatible types throw. Unknown fields are ignored; optional properties permit missing/null values. A string such as `"warm"` cannot decode as a Double and produces an error rather than being silently accepted.

**async/await** lets a request suspend while waiting so the UI stays responsive. `async` marks asynchronous work; `await` waits without blocking the UI thread. `throws` and `try` handle failures. Cancellation is cooperative: URLSession can cancel its request, and the ViewModel also checks cancellation before publishing a result.

**@Published** makes weather days, loading, errors, and city changes observable through Combine. SwiftUI can refresh when they change. `@MainActor` keeps these UI state changes on the main actor; network waiting does not block it.

### Safe optional arrays and date alignment

`[Double?]?` has two optional levels: the array can be missing/null, and a present array can contain null elements. Each final WeatherDay measurement is `Double?`. `value(at:in:)` checks the array and its indexes before subscripting. Missing data stays nil and displays **Unavailable**; a real zero stays zero.

`decodeWeather(from:)` uses up to the first three original date positions and the same index for each measurement. It skips null/empty dates without shifting other measurements. Missing daily/time returns no days; short date arrays produce fewer cards with an availability note. Dates remain the API's `yyyy-MM-dd` Bangladesh calendar strings, avoiding UTC conversions that could change the date and matching future plan storage.

### Weather functions and state flow

1. MainTabView owns `@AppStorage("selectedCity")`; invalid names fall back to Khulna. This stores a preference, never credentials.
2. WeatherHomeView receives a `@Binding`, owns its ViewModel with `@StateObject`, and shows a Picker from City.cities.
3. `.task(id:)` loads on appearance. Its ID combines the selected city and Retry count; either change cancels the old task and starts another.
4. `makeURL(for:)` uses URLComponents/URLQueryItem to encode coordinates, four daily fields, three days, Asia/Dhaka, and explicit Celsius/mm/km/h units safely.
5. `fetchWeather(for:)` sends the request with a 30-second timeout, checks HTTP status, and calls `decodeWeather(from:)`.
6. `loadWeather(for:)` clears old data/errors and sets loading. Each request receives a UUID; only the current non-cancelled request may publish results/errors or end loading. Expected cancellation is not presented as a network failure.
7. The screen compares weather.cityName with the picker before showing cards, hiding old-city data before the new task begins. `defer` ends loading only for the current request.
8. WeatherDayCard shows the date and four measurements. A small private row view keeps formatting consistent. App source has no sample forecast values, and the screen credits Open-Meteo.

`Identifiable` supplies stable names/dates for ForEach. `Equatable` permits city comparisons. `Sendable` on City and WeatherDay declares their immutable values safe to pass across concurrency boundaries. A request UUID is a unique identifier for network work, not a Firebase user or document identifier.

### Verification limits

Direct Python HTTP/JSON checks on 2026-11-20 verified HTTP 200, Asia/Dhaka, and three complete daily entries for November 20-22 for each city. An invalid-field request returned HTTP 400. These checks did not execute Swift code. Restricted sandbox DNS initially failed; the read-only probes succeeded outside that sandbox.

Tests/WeatherServiceTests.swift contains seven XCTest methods with labelled synthetic fixtures. They cover query parameters, complete decoding, missing/null/unequal arrays, absent dates/daily data, date-index alignment, the three-day limit, and malformed/wrong-type JSON. They are not compiled or run. README explains creating the test target and Product > Test. City switching, saved-city restoration, offline/retry screens, JSONDecoder execution, and app build/launch remain pending on a Mac.

API reference: [Open-Meteo forecast documentation](https://open-meteo.com/en/docs).

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

**Why not use zero for missing rain data?** Zero predicts no precipitation. Missing data means we do not know; substituting zero could mislead the user and future recommendations.

**Why not zip every array?** A shorter array should not drop valid dates. Keeping the original date index preserves alignment and marks only missing measurements unavailable.

**Why both cancellation and a request ID?** Cancellation asks old work to stop. The ID additionally prevents a late old result/error from overwriting the newly selected city's state.

**What happens without internet?** URLSession throws a transport error. The ViewModel publishes a useful message, ends loading, and offers Retry without showing another city's old forecast.

**Why is rain probability Double?** Direct numerical decoding accepts integers and fractions without a custom parser; the card displays the value with a percent unit.

**What should be tested on a Mac next?** Create the native target, attach Firebase and real configuration, build/run, and run XCTest. Verify auth flows, three weather cities, rapid switching, offline/retry, missing values, and remembered city. README records expected results; app tests remain pending.

Official study references: [Firebase setup](https://firebase.google.com/docs/ios/setup), [email/password authentication](https://firebase.google.com/docs/auth/ios/password-auth), [session listeners](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Classes/Auth.html), and [error codes](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode).
