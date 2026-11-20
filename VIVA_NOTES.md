# DhobiGhat Viva Notes

## Phase 5: what is implemented

Nineteen app Swift files now describe authentication, weather, recommendations, and Firestore laundry schedules. MainTabView owns a shared PlanViewModel; AddPlanView saves; MyPlansView fetches, completes, and deletes plans. A firestore.rules policy is supplied. Native Xcode/SPM/Firebase setup, rule publication, build, and live app tests remain pending on a Mac. The earlier weather probes do not verify Swift code. Twenty-one XCTest methods across three files are prepared but unexecuted. Phase 1 was not present; later phases were explicitly requested.

## Current app flow and important code

1. `@main` marks `DhobiGhatApp` as the application's entry point. An app target should have only one such entry point.
2. `DhobiGhatApp` conforms to SwiftUI's `App` protocol. Its `body` describes a `Scene`, using `WindowGroup` to show `RootView`. `@UIApplicationDelegateAdaptor` connects the UIKit app delegate to the SwiftUI lifecycle.
3. `AppDelegate.application(_:didFinishLaunchingWithOptions:)` checks for a readable Firebase plist and matching bundle ID, then calls `FirebaseApp.configure()`. When setup is incomplete, the console reports it and the root UI shows setup instructions instead of using Auth.
4. `RootView` owns one auth model with `@StateObject`. Its stable `ZStack` shows setup instructions, initial session loading, `LoginView`, or `MainTabView` according to the observed state. Its `.task` starts the listener after launch. `some View` describes a specific view type without naming its full nested type.
5. `VStack` arranges the image and text vertically. `spacing` sets the distance between items.
6. `Image(systemName: "drop.fill")` uses an SF Symbol supplied by Apple; it is not a downloaded image.
7. View modifiers set the font, color, alignment, padding, frame, background, and navigation title. The background is a faint blue produced by `opacity(0.06)`.
8. `Color` and `.infinity` are native SwiftUI values. `frame(maxWidth:maxHeight:)` lets the content fill available space; `padding(24)` provides inner spacing.

`NavigationStack` provides screen titles. `Form` groups login/profile/plan inputs, `SecureField` masks the password, and `TabView` switches between Weather, My Plans, and Profile. Plan management is now backed by real SDK calls, with live behavior still unverified. `body` is a computed property, not a stored screen image.

## SwiftUI state concepts

The table separates current uses from wrappers/features still planned.

| Concept | Meaning | Current or planned meaningful use |
| --- | --- | --- |
| `@State` | View-owned local UI state that can trigger a refresh | Login inputs/mode; WeatherHomeView's Retry count, selectedDate, and sheet visibility; AddPlanView's unsaved note |
| `@Binding` | Read/write access to state owned elsewhere | WeatherHomeView changes its parent's city; WeatherDayCard and AddPlanView change WeatherHomeView's selectedDate |
| `ObservableObject` | Protocol for reference types that notify SwiftUI about changes | AuthViewModel, WeatherViewModel, and PlanViewModel import Combine |
| `@Published` | Publishes changes to properties of an observable object | Auth/weather properties plus plans, loading, saving, and plan errors |
| `@StateObject` | Creates and preserves an observable object for the owning view's lifetime | Root owns auth, WeatherHomeView owns weather, MainTabView owns plans |
| `@ObservedObject` | Observes an object supplied by another owner | MyPlansView, WeatherHomeView, and AddPlanView observe the same shared PlanViewModel |
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

The SDK persists the secure authenticated session, not our own Boolean flag. On relaunch, root waits for the first state-listener callback before choosing a login or main screen. The main tabs use `.id(user.uid)`, giving a different account a new view identity and PlanViewModel. Plans use one-time requests with account checks, so no Firestore snapshot listeners need cleanup. A cached session does not prove every future server request will be accepted.

Firebase Authentication handles email/password sign-in and provides an authenticated user's UID. `currentUser` is the actual SDK User, and `userEmail` is a UI copy of its email. Passwords remain local to the form/request and must not be stored in Firestore or UserDefaults. PlanService now targets `users/{userUID}/plans/{planID}`. Authentication identifies the user; security rules determine whether a request may access a document. Hiding another user's plans in the UI alone is not access control.

The supplied rules require a signed-in UID matching the path. The plan model clears old state and rejects old async results on account changes. Session restoration, these state transitions, and rule behavior still need runtime verification.

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

## Phase 4 drying recommendation function: every branch

`WeatherDay.dryingRecommendation()` is a short model function. It returns `DryingRecommendation?`, where the enum has exactly three named cases: Good, Risky, Avoid. A nil result means **Unavailable**, rather than a fourth weather rating. The enum's String raw values provide the readable labels. No API call, machine learning, score, or temperature rule is involved.

1. **Missing-input guard:** `guard let rainProbability, let precipitation, let windSpeed else { return nil }`. All three rule inputs must exist. If any is missing, the function stops with Unavailable, even if another known value is high. This deliberately avoids presenting a complete assessment from incomplete inputs. Temperature is not a rule input, so missing temperature alone does not prevent a recommendation.
2. **Non-finite check:** if any input is NaN or infinity, return nil. `isFinite` checks that a Double is an ordinary finite number. `!` means not; `||` means at least one condition is true.
3. **Valid-range check:** if rain probability is below 0 or above 100, or precipitation/wind is negative, return nil. Such values are unusable for these rules. Zero is valid and is never treated as missing.
4. **Avoid branch:** if rain probability **>= 60** OR precipitation **>= 3**, return Avoid immediately. Either condition is sufficient; wind does not override this result. The `>=` operator includes the exact threshold.
5. **Risky branch:** the `else if` is reached only when Avoid was false. If probability **>= 30** OR precipitation **>= 1** OR wind **>= 30**, return Risky. Any one of these conditions is sufficient. A day meeting both Avoid and Risky conditions still returns Avoid because the first branch already returned.
6. **Good branch:** the final `else` means all input checks passed and neither earlier rule matched. Return Good. This means probability is below 30%, precipitation below 1 mm, and wind below 30 km/h; it does not guarantee clothes will dry.

The function stays with the simple WeatherDay model so the view only displays the result. WeatherDayCard's color switch returns green for Good, orange for Risky, red for Avoid, and secondary gray for nil. The readable text remains visible so the label does not depend on color alone.

These are **basic project-defined guidelines, not guaranteed drying predictions**. The Weather screen states this explicitly. The thresholds are the project's rules, not scientific advice.

### Required examples and exact boundaries

| Rain probability (%) | Precipitation (mm) | Wind (km/h) | Expected |
| --- | --- | --- | --- |
| 10 | 0 | 12 | Good |
| 40 | 0 | 15 | Risky |
| 70 | 0 | 10 | Avoid |
| 10 | 5 | 10 | Avoid |
| 10 | 0 | 35 | Risky |

- Rain probability: 29.99 -> Good; 30 -> Risky; 59.99 -> Risky; 60 -> Avoid, with precipitation 0 and wind 12.
- Precipitation: 0.99 -> Good; 1 -> Risky; 2.99 -> Risky; 3 -> Avoid, with rain probability 10 and wind 12.
- Wind: 29.99 -> Good; 30 -> Risky, with rain probability 10 and precipitation 0.
- Priority: probability 60 with wind 35 is Avoid; probability 40 with precipitation 3 and wind 35 is also Avoid.

`Tests/DryingRecommendationTests.swift` has seven methods and 28 assertions for the five examples, boundaries, Avoid priority, missing inputs, invalid ranges, NaN, and infinity. These use synthetic rule inputs, not live forecasts. The helper creates a WeatherDay and calls the actual Swift function. Tests are prepared and source-reviewed, not executed; Swift/Xcode are unavailable here.

### Date selection and the Add Plan sheet

- WeatherHomeView owns `selectedDate` as @State. An empty string means no date is selected yet. It also owns `showAddPlan` as @State to control presentation.
- Each WeatherDayCard receives `$selectedDate` as @Binding. Tapping a card sets the parent's value to that day's actual forecast date. A matching date gets a blue outline, checkmark, and selected accessibility trait. The other cards lose their highlight, so exactly one date is selected.
- Any returned date can be chosen, including Avoid or Unavailable days. The recommendation informs the choice rather than blocking it. No missing or invented date is offered.
- `canPlanLaundry` requires no active loading, no weather error, a match between the loaded city and picker city, and a selectedDate that exists in the current forecast. If any condition is false, Plan Laundry is disabled.
- New city/retry loads clear selectedDate and close the sheet. The city-change handler also clears selection immediately, so a previous city's date cannot open the form while the next request begins.
- `.sheet(isPresented: $showAddPlan)` opens AddPlanView, passing the selected city, current forecast dates, and a binding to selectedDate. Its Picker can change the parent date; the matching weather card is highlighted after closing.
- The optional note is local @State until Save submits its value. `@Environment(\.dismiss)` supplies the native action used by Cancel and by successful saving. The form observes the PlanViewModel owned by MainTabView rather than making another one.
- Phase 5 adds Save plan and Cancel. Before Save, Cancel discards the local note without a write. Once Save submits a Firestore write, Cancel only closes the sheet; it cannot retract that already-submitted operation. The pending-state text explains this.

## Phase 5 Firestore data mapping

Firestore stores collections of documents. The path `users/{userUID}/plans/{planID}` uses Firebase Authentication's actual UID as the owner and an auto-generated document ID as the plan ID. Email is not the path key. A parent user document may have no fields while its plans subcollection exists.

LaundryPlan is a simple struct. Its initializer receives the document ID and `[String: Any]` data. Checked `as?` casts read city/date/note as String, isCompleted as Bool, and createdAt as Timestamp. Missing or invalid values throw PlanError.invalidData; they are not silently skipped or replaced with defaults. id is document metadata, not an extra stored field. isCompleted is var so a server-confirmed completion can update the displayed item.

No Firestore Codable mapper is used. Dictionary keys are the literal field names in the requirements, which makes the mapping easy to explain. The ordinary Decodable API models remain specific to weather JSON.

`LaundryPlan.isValidDate` configures DateFormatter with en_US_POSIX locale, Gregorian calendar, Asia/Dhaka timezone, `yyyy-MM-dd`, and non-lenient parsing. It requires ten characters and a successful round trip so invalid dates or alternate formatting are rejected. Dates copied from the weather API are kept as calendar strings. createdAt is an absolute Timestamp supplied by the server; it is not the laundry date and is not a timezone-formatted String.

### PlanService functions

- `plansCollection(userUID:)` first verifies Firebase initialization and that the current authenticated UID matches the supplied owner. It then creates the exact nested collection reference. No Firestore singleton is accessed in a ViewModel constructor before Firebase is configured.
- `addPlan(...)` validates supported city/date and builds the five-field dictionary. isCompleted starts false. FieldValue.serverTimestamp() asks the server to fill createdAt; it is a transform placeholder, not a hardcoded local Timestamp. `try await addDocument(data:)` waits for acknowledgment or rejection.
- `fetchPlans(...)` performs `getDocuments(source: .server)` once, maps each document using the model initializer, and sorts newest-first by createdAt. There is no real-time snapshot listener, custom repository, or composite index. A malformed document produces a visible error rather than silently disappearing from the list.
- `completePlan(...)` validates the document ID, then awaits `updateData(["isCompleted": true])`. It changes only status; it does not recreate the plan or its creation time.
- `deletePlan(...)` validates the ID and awaits document.delete(). The UI asks for confirmation first.

### PlanViewModel and account isolation

MainTabView owns one PlanViewModel using @StateObject. MyPlansView and the add form use @ObservedObject, so saving and listing share the same observable plans/loading/errors. Main tabs load when authenticated, and My Plans can fetch on appearance or pull-to-refresh.

`setUser` clears plans and operation/error state whenever the UID changes or the main UI disappears. It also changes accountID, a local UUID that represents this instance's account session. Each async operation captures both UID and accountID. After awaiting, `isCurrentAccount` checks the captured token, the model's UID, and Firebase's current user before accepting data or errors. Old results cannot populate the new account's list. `finishLoading` also checks the captured token so an old operation cannot reset a new account's spinner. Root's `.id(user.uid)` independently gives each account a fresh MainTabView/PlanViewModel.

The service UID check prevents ordinary accidental cross-account calls; server rules enforce access even if a modified client bypasses that check. These are implementation safeguards, not a claimed verified isolation test. Real A/B account and rule tests are pending.

`isLoading` serializes reads/writes; `isSaving` identifies an active add operation. Guards run before the first await, so repeated Save tasks do not create multiple active writes in the same model. Disabled buttons reflect this state. The sheet also verifies that the chosen date is in its actual forecast-date list.

After an acknowledged write, the ViewModel fetches plans again. Completion/deletion also update the confirmed local item. `refreshAfterWrite` handles the follow-up read separately: a failed refresh says the write succeeded but the list could not refresh. The form treats an acknowledged save as success even if the later read fails, so it does not invite an accidental duplicate Save.

Errors use FirestoreErrorCode.Code for permission denied, unavailable/deadline exceeded, unauthenticated, not found, and setup failures, plus a visible fallback. My Plans displays a retry action, an empty state only when not loading/erroring, and Pending/Completed labels. New plan entry and list actions are disabled while a plan operation is active.

### Offline writes and Cancel

Server-only reads do not fall back to cached data, so offline reads surface an SDK error. An offline Firestore write can instead remain queued: its async completion is not server success until acknowledged. The UI says it is waiting, and the shared busy state blocks another Save. Cancel closes the form and does not cancel the submitted SDK write. The operation may finish later or after the SDK resumes it following an app restart; users should inspect My Plans/Console before creating another plan. No custom timeout pretends that a still-queued write failed, and no exactly-once guarantee across restarts is claimed.

### Every security-rule condition

- `request.auth != null`: the request must be authenticated.
- `request.auth.uid == userUID`: the caller must own the UID appearing in the path. A different user and an anonymous request fail before accessing plan data.
- `hasAll` and `hasOnly`: creation/updated documents must contain exactly city, date, note, isCompleted, and createdAt. The ID remains in the path.
- Type checks require String/String/String/Bool/Timestamp. City must be one of the three supported names; date must have yyyy-MM-dd text shape. The app additionally checks that it is a real calendar date.
- Creation requires isCompleted false and createdAt equal to request.time; the server timestamp transform satisfies the latter condition when committed.
- Updates require affectedKeys().hasOnly(['isCompleted']) and the resulting status true. Other fields stay unchanged; this phase does not support editing notes/dates or undoing completion. A repeat true status is harmless.
- Read/delete only need the owner condition, so the owner can delete a document even if its other fields are malformed. Unmatched paths have no allow rule and are denied. A broad overlapping allow-all policy must not remain alongside these rules.

Firebase Console administrator editing bypasses these client rules; seeing a document in Console alone does not prove security. README explains publishing the exact file, checking own/different/anonymous requests in Rules Playground, and testing actual CRUD with two accounts. No rules were published or executed here.

### Phase 5 verification status

Tests/LaundryPlanTests.swift adds seven non-network XCTest methods covering all five data fields plus ID, empty note/completed status, missing fields, wrong types, strict dates/leap years, unsupported city/empty ID, and invalid stored date. All three test files are prepared but unexecuted. Live Save/reopen/retrieve/complete/delete, Console verification, account isolation, permission denial, and network states are all pending. No database action is reported successful from source inspection.

Official references: [Firestore writes](https://firebase.google.com/docs/firestore/manage-data/add-data), [one-time queries](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/Query), [document write completion](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/DocumentReference), and [rule field validation](https://firebase.google.com/docs/firestore/security/rules-fields).

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

**Is FirebaseFirestore used already?** The source now uses the official SDK for add, server fetch, completion, and deletion. The SDK still needs to be linked in Xcode, and real database/rules setup and live tests are pending.

**Why not use zero for missing rain data?** Zero predicts no precipitation. Missing data means we do not know; substituting zero could mislead the user and future recommendations.

**Why not zip every array?** A shorter array should not drop valid dates. Keeping the original date index preserves alignment and marks only missing measurements unavailable.

**Why both cancellation and a request ID?** Cancellation asks old work to stop. The ID additionally prevents a late old result/error from overwriting the newly selected city's state.

**What happens without internet?** URLSession throws a transport error. The ViewModel publishes a useful message, ends loading, and offers Retry without showing another city's old forecast.

**Why is rain probability Double?** Direct numerical decoding accepts integers and fractions without a custom parser; the card displays the value with a percent unit.

**Why check Avoid before Risky?** A high-rain day also satisfies the lower Risky threshold. Checking Avoid first prevents it from being misclassified as Risky.

**Does Good promise dry clothes?** No. These rules use three forecast measurements and are only project-defined guidelines. The UI states that drying predictions are not guaranteed.

**What is shared through the date binding?** The same String state owned by WeatherHomeView. Cards and the sheet can read and update it; they do not create separate selected dates.

**Does Plan Laundry save anything in this phase?** It opens the form. Save plan submits the actual Firestore write and automatically closes only after acknowledgment. Cancel before submission creates nothing; after submission it cannot retract the write.

**Why not store the user's email in the path?** The authenticated UID is stable and matches request.auth.uid in security rules. Email may change.

**Why use a server timestamp?** It records when Firestore commits creation using server time, and avoids trusting the device clock for createdAt.

**Why no real-time plan listener?** The project needs straightforward one-time reads and explicit refresh after writes. That is enough for this phase and keeps cleanup easy.

**What should be tested on a Mac next?** Create the target, link Firebase, add real configuration, create the database and publish rules, build/run, and run all three XCTest files. Verify every CRUD action and restart retrieval in Console, two-account isolation, denied rules, network loss, pending writes, and the existing auth/weather/recommendation UI. All app/security tests remain pending.

Official study references: [Firebase setup](https://firebase.google.com/docs/ios/setup), [email/password authentication](https://firebase.google.com/docs/auth/ios/password-auth), [session listeners](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Classes/Auth.html), and [error codes](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode).
