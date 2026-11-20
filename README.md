# DhobiGhat - Smart Laundry Day Planner

A beginner-level SwiftUI mini-project for a Mobile Computing Lab. The planned app helps students choose laundry days using real weather forecasts.

## Phase 3 status

Phase 2 added real Firebase authentication source. Phase 3 replaces the Weather tab placeholder with a three-city picker, real three-day Open-Meteo requests, safe JSON decoding, forecast cards, and loading/error/retry/empty states. The selected city is remembered and shown in Profile. Plan management remains a clearly marked future feature.

This workspace is on Windows. `xcodebuild`, `xcrun`, and `swift` were not found on PATH. No native Xcode tools were available to create a project or app target. There is **no `.xcodeproj`, configured app target, verified build, or verified launch yet**. Follow the Mac setup below to create the project using Xcode's native App template.

No dependencies have been resolved or attached to a target here because there is no Xcode project. The code imports the actual Firebase SDK and needs the SPM setup below to compile. `GoogleService-Info.plist` has not been supplied. **Firebase is not connected or live-tested.** All three live weather endpoints were checked from this environment and returned HTTP 200 with three days; this does not verify the Swift parser or iOS UI. Firestore operations are not implemented. Phase 1 was not present in the workspace and has not been claimed complete.

## Requirements

- A Mac running a compatible Xcode, with an iOS Simulator runtime or a supported iPhone.
- Swift and SwiftUI; intended minimum deployment target: **iOS 17.0**. Use a newer supported minimum only if your installed Xcode requires it, and record the actual value in `PROJECT_PROGRESS.md`.
- Use Xcode's default Swift language version initially. No `SWIFT_VERSION` or deployment setting exists until the native project is created. Record both compiler version and target Swift language version afterward; these are different settings.
- Phase 2 requires the official Firebase Apple SDK (`FirebaseAuth` and `FirebaseFirestore`). Phase 3 uses Open-Meteo via native `URLSession`, `JSONDecoder`, and `Decodable`; no weather SDK or API key is added.
- Simple MVVM with `ObservableObject` and `@Published`; do not replace these with `@Observable`.
- No separate backend, third-party UI/networking libraries, dependency injection framework, or project generator.
- No location permission or GPS is needed.

## Source structure

```text
IOS project/
  .gitignore
  README.md
  PROJECT_PROGRESS.md
  VIVA_NOTES.md
  DhobiGhat/
    App/
      AppDelegate.swift
      DhobiGhatApp.swift
    Models/
      City.swift
      WeatherResponse.swift
      WeatherDay.swift
      .gitkeep
    Views/
      RootView.swift
      LoginView.swift
      MainTabView.swift
      ProfileView.swift
      WeatherHomeView.swift
      WeatherDayCard.swift
    ViewModels/
      AuthViewModel.swift
      WeatherViewModel.swift
      .gitkeep
    Services/
      WeatherService.swift
      .gitkeep
    Resources/
      .gitkeep
  Tests/
    WeatherServiceTests.swift
```

- `App`: SwiftUI entry point and Firebase startup in AppDelegate.
- `Models`: supported cities, optional decoded daily arrays, and individual weather days.
- `Views`: authentication, main tabs, weather picker/cards, and profile/logout.
- `ViewModels`: authentication state plus weather loading, results, errors, and request identity.
- `Services`: `WeatherService` builds the URL, requests data, checks HTTP status, and decodes forecasts. Firestore operations come later.
- `Tests`: XCTest coverage for request parameters and safe JSON parsing using clearly labelled synthetic fixtures. Add these files only to a unit test target, not the app.
- `Resources`: future asset catalog and Firebase configuration.
- `.gitkeep`: empty file that lets Git preserve an otherwise empty folder. It is not Swift code and does not need target membership.
- `.gitignore`: excludes local Xcode user state and build output.

## Create the native project on a Mac

These steps keep the prepared source files and use Xcode to generate its own project metadata.

1. Copy or clone this entire workspace onto the Mac. Call that folder the **repository root** below.
2. Open Xcode. Choose **File > New > Project**, then **iOS > App**.
3. Set **Product Name** to `DhobiGhat`, **Interface** to `SwiftUI`, and **Language** to `Swift`. Choose **Storage: None** and no tests for this scaffold if those options appear. Enter your own organization identifier. A team can remain unselected for a Simulator build.
4. Save this new template project in a separate temporary folder **outside the repository**. Do not overwrite the prepared `DhobiGhat` source folder. If offered, turn off creation of another Git repository.
5. Close the template project. In Finder, copy the generated `DhobiGhat.xcodeproj` into the repository root, alongside `README.md` and the existing `DhobiGhat` source folder.
6. Copy the template's `Assets.xcassets` into the repository's `DhobiGhat/Resources/` folder. Keep its generated `AppIcon` and `AccentColor` entries. Do not copy the template's `DhobiGhatApp.swift` or `ContentView.swift`; the scaffold already supplies the app entry point and root view.
7. Open **the repository's** `DhobiGhat.xcodeproj`. In recent Xcode versions, the `DhobiGhat` folder may automatically discover the prepared files. Confirm the navigator shows `App/DhobiGhatApp.swift`, `Views/RootView.swift`, and `Resources/Assets.xcassets`.
8. If the project instead shows red references to the original template files, remove **only the missing references** from the navigator using **Remove Reference**. Then use **File > Add Files to "DhobiGhat"** to add the existing `App`, `Models`, `Views`, `ViewModels`, `Services`, and `Resources` folders from the repository's `DhobiGhat` folder. Reference the existing files in place (do not copy them again); choose groups if asked, and select the **DhobiGhat** target. Do not add a folder twice if it is already discovered automatically.
9. Select the blue project icon, then **TARGETS > DhobiGhat**. Confirm it is an iOS application target. Under **General > Minimum Deployments**, set iOS to **17.0**, or the supported newer minimum required by your Xcode. Under **Build Settings**, search for **Swift Language Version** and record its default. The iOS deployment value also appears under **iOS Deployment Target**.
10. Check source membership. There must be exactly one app entry point, `DhobiGhatApp`, and `RootView` must belong to the same target. For traditional groups, check **Build Phases > Compile Sources**. With synchronized folders, Xcode can include files automatically; use the File inspector to confirm membership and avoid adding duplicate source entries. Resolve any remaining missing asset reference by referencing `DhobiGhat/Resources/Assets.xcassets`.
11. Select scheme **DhobiGhat** and an installed **iPhone Simulator** in the toolbar. Use a Simulator runtime at or above the minimum deployment version. If no runtime is installed, use Xcode's Settings component/platform downloads to install one.
12. Complete the Phase 2 Firebase setup below before building; the source now imports Firebase modules. Choose **Product > Build** (`Command-B`), then **Product > Run** (`Command-R`). With a valid configuration, expect a brief session check followed by the login/register screen or authenticated tabs. Without a bundled matching plist, expect the Firebase setup message, with no Auth calls made.
13. Record the actual Xcode version, Swift compiler version, Swift language setting, deployment target, Simulator/device, and build/run result in `PROJECT_PROGRESS.md`. Keep the generated `.xcodeproj`, asset catalog, and SPM resolution file in the repository for the next phase.

For an iPhone, select your own development team under **Signing & Capabilities**, use your own unique bundle identifier, connect the device, and select it as the run destination. Simulator validation is sufficient for Phase 0.

Apple's references: [creating an app project](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app), [building and running](https://help.apple.com/xcode/mac/current/en.lproj/devdc0193470.html), and [deployment versions](https://developer.apple.com/documentation/xcode/running-code-on-a-specific-version/).

### Optional command-line verification on the Mac

Run these from the repository root after creating the native project:

```sh
xcodebuild -version
xcrun swift --version
xcodebuild -list -project DhobiGhat.xcodeproj
xcodebuild -showBuildSettings -project DhobiGhat.xcodeproj -scheme DhobiGhat
xcodebuild -showdestinations -project DhobiGhat.xcodeproj -scheme DhobiGhat
xcodebuild -project DhobiGhat.xcodeproj -scheme DhobiGhat -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

Confirm `SWIFT_VERSION` and `IPHONEOS_DEPLOYMENT_TARGET` in the settings output. A command-line build alone does not verify launch; run the app in Xcode as described above.

## Phase 2 Firebase setup on a Mac

### Add the official SDK with Swift Package Manager

1. Create/open the native `DhobiGhat.xcodeproj` using the instructions above. Confirm all 14 app Swift files under `DhobiGhat/` belong to the **DhobiGhat** app target. `Tests/WeatherServiceTests.swift` belongs only to the optional test target described below.
2. Choose **File > Add Package Dependencies** (called **Add Packages** in some Xcode versions).
3. Enter the official repository: [firebase/firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk).
4. Select a stable release compatible with the installed Xcode, using **Up to Next Major Version** from that release. Check the SDK's current toolchain requirements in the [official setup guide](https://firebase.google.com/docs/ios/setup) before resolving it; do not select the development branch. Retain iOS 17.0 as the minimum unless the actual toolchain requires a higher supported minimum.
5. Add exactly **FirebaseAuth** and **FirebaseFirestore**, both to the **DhobiGhat** target. `FirebaseCore` is a transitive dependency used by initialization. Do not select Analytics, Google Sign-In, Storage, or other products.
6. Wait for package resolution to finish. Under the project **Package Dependencies**, confirm the Firebase SDK appears. Under the app target's **General > Frameworks, Libraries, and Embedded Content**, confirm both selected products are linked.
7. Keep the generated project changes and `Package.resolved` so the resolved version can be reproduced. Do not edit the Firebase SDK's own `Package.swift` and do not add a standalone Swift package to represent this iOS app.

These steps are pending: no target or package metadata exists here to edit, and this Windows environment cannot resolve or build the Apple SDK.

### Register DhobiGhat in Firebase Console

1. In Xcode, select **TARGETS > DhobiGhat > General** and copy the actual **Bundle Identifier**. Use your own identifier; no identifier is supplied or invented in this repository.
2. Open [Firebase Console](https://console.firebase.google.com/). Create a project named **DhobiGhat**, or select your existing project. Google Analytics is optional and is not needed for this phase.
3. In the project overview, choose **Add app > iOS+**. Paste the exact bundle identifier from Xcode, including its case. Set the optional app nickname to **DhobiGhat**. An App Store ID is not needed for a lab/Simulator app. Click **Register app**.
4. Download **GoogleService-Info.plist**. Use the downloaded configuration for this registered iOS app, not another Firebase project or platform. Keep the exact filename without a suffix such as `(1)`.
5. In Firebase Console, open **Build > Authentication** (some Console layouts use **Security > Authentication**), choose **Get started**, then **Sign-in method > Email/Password**. Enable **Email/Password**, leave email-link sign-in disabled, and save.
6. Use Firebase's default minimum six-character password policy for the initial lab tests. If you configure a stronger policy, registration errors from Firebase will explain that a stronger password is required. Keep email enumeration protection enabled; incorrect-email and incorrect-password errors share one user-facing message.

### Add the plist to the correct app target

1. In Xcode, use **File > Add Files to "DhobiGhat"** to add the downloaded file into **DhobiGhat/Resources/**. Choose to copy it into the repository if it is still in Downloads. Select **DhobiGhat** in **Add to targets**.
2. Select the plist in the navigator and confirm **Target Membership: DhobiGhat** in the File inspector. In a synchronized folder, membership may be automatic; confirm the file is included for this app target.
3. For traditional groups, check **TARGETS > DhobiGhat > Build Phases > Copy Bundle Resources**. The plist must appear once. For synchronized folders, resources may be included automatically. The result must be a bundled file named `GoogleService-Info.plist` accessible through `Bundle.main`, rather than a file merely visible in Finder.
4. Confirm the plist's `BUNDLE_ID` matches the target's bundle identifier. If it does not, register the correct iOS app and download its configuration; do not fabricate or patch project identifiers in the plist.
5. Following Firebase's SwiftUI setup instructions, add **FirebaseAppDelegateProxyEnabled** under the app target's **Info > Custom iOS Target Properties**, with type **Boolean** and value **NO**. This is an app Info setting, not a key in `GoogleService-Info.plist`. Email/password authentication needs no notification or redirect handlers.
6. Build and restart the app. `AppDelegate` checks the bundled file and bundle ID, then calls `FirebaseApp.configure()` during `didFinishLaunchingWithOptions`. Root's task starts the listener afterward; the ViewModel checks `FirebaseApp.app()` before creating `Auth.auth()`.

If the setup screen remains visible, check the Xcode console for the missing/invalid plist or bundle ID message, correct target membership, then stop and rerun the app. Configuration must be tested; adding a file alone does not prove that Firebase is connected.

### Phase 2 acceptance tests - all pending

After setup, run on a Simulator or iPhone with internet access. Use a real test email account you control. Do not record the password in this repository.

| Test | Steps and expected result | Status here |
| --- | --- | --- |
| Register | Choose Create account, enter an unused email and password of at least six characters; authenticated tabs appear and the user appears under Firebase Authentication > Users | Pending |
| Log out | Profile shows the signed-in email; Log out returns to the login screen | Pending |
| Log in | Enter the newly registered email/password; authenticated tabs appear with the matching profile email | Pending |
| Invalid credentials | Log out and try a wrong password or unregistered email; show the shared credential error and remain at login | Pending |
| Validation | Try blank/invalid email, empty password, and a registration password below six characters; show the corresponding input message | Pending |
| Duplicate email | Try registering the existing email; show a helpful Firebase error | Pending |
| Session restoration | Log in, terminate the app without signing out, relaunch on the same installation; wait for the initial listener and show authenticated tabs without retyping credentials | Pending |
| Persisted logout | Log out, terminate, relaunch; stay on the login screen | Pending |
| Account changes | Log out of A and log into B; profile must show B; tabs are recreated using B's UID | Pending |
| Failed request | From login, disconnect internet and submit valid-format credentials; when the SDK request fails, show the network error and allow retry | Pending |
| Missing config | Temporarily exclude the plist from the target, rebuild and run; show setup instructions without calling Auth; restore membership afterward | Pending |

The SDK maintains its session securely; the app does not store passwords, tokens, or a fake login flag in UserDefaults or Firestore. The listener's initial callback handles restored state. An offline cached session is not a guarantee that the server will authorize every future request.

Official references: [password authentication](https://firebase.google.com/docs/auth/ios/password-auth), [user/session observation](https://firebase.google.com/docs/auth/ios/manage-users), [Auth API](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Classes/Auth.html), and [auth error codes](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode).

## Phase 3 weather behavior and verification

Weather uses [Open-Meteo's forecast API](https://open-meteo.com/en/docs) with the three predefined coordinates below. `URLComponents` and `URLQueryItem` build the request. It requests `forecast_days=3`, `timezone=Asia/Dhaka`, all four required daily fields, and explicit units: Celsius, millimetres, and km/h. The request uses HTTPS, a 30-second timeout, and bypasses the local URL cache. No GPS or API key is used.

`WeatherResponse` and `DailyWeather` directly conform to `Decodable`. `CodingKeys` maps API names to simple Swift property names. Both the measurement arrays and their individual elements are optional. Conversion follows the original date indexes; a missing array, a short array, or a null element becomes `nil`, displayed as **Unavailable**, rather than zero. Missing/null/empty dates produce fewer cards or the empty state; a wrong JSON type or malformed JSON becomes a visible error. Dates remain the API's `yyyy-MM-dd` Bangladesh calendar dates.

`MainTabView` owns `@AppStorage("selectedCity")`; `WeatherHomeView` receives a `@Binding` and owns its weather model with `@StateObject`. `.task(id:)` fetches on appearance, city changes, and Retry. The ViewModel clears old results, ignores cancelled work, and accepts results/errors only from the current request ID. The screen also checks that the ViewModel's city matches the picker before displaying cards. Profile displays the same remembered city.

### Verification performed here

- On 2026-11-20 (Asia/Dhaka), direct read-only requests for Khulna, Dhaka, and Chattogram returned **HTTP 200**, `Asia/Dhaka`, dates **2026-11-20 through 2026-11-22**, and three entries for each requested measurement. These were Python HTTP/JSON checks outside the restricted network sandbox; no downloaded values were added to app source.
- An intentionally invalid daily-field request returned **HTTP 400** and an API error reason. The app service rejects non-2xx responses before decoding a forecast.
- Initial sandboxed HTTP probes failed DNS resolution. This was an environment restriction, not evidence of an iOS network error. Network checks succeeded after the read-only requests were allowed outside that sandbox.
- The app's Swift build, `JSONDecoder`, XCTest, cancellation/city-switch UI, persistence, and offline error screens remain **unverified**. Xcode and Swift are unavailable here. Firebase setup is also still required to reach the authenticated Weather tab normally; no bypass login was added.

### Run the JSON tests in Xcode

1. Complete native project and Firebase setup above. Confirm the seven new Phase 3 app files are included: `City.swift`, `WeatherResponse.swift`, `WeatherDay.swift`, `WeatherService.swift`, `WeatherViewModel.swift`, `WeatherHomeView.swift`, and `WeatherDayCard.swift`.
2. Choose **File > New > Target > iOS Unit Testing Bundle**. Name it **DhobiGhatTests** and choose **DhobiGhat** as its app/host target. Use XCTest; if an option is offered, do not choose the Swift Testing template for this XCTest file.
3. Add the existing `Tests/WeatherServiceTests.swift` to **DhobiGhatTests** target membership only. Keep the app module/product name **DhobiGhat** so `@testable import DhobiGhat` resolves. Ensure the app Debug configuration has **Enable Testability = Yes** (the normal default).
4. Select an iPhone Simulator and choose **Product > Test** (`Command-U`). Record the actual result in PROJECT_PROGRESS. The seven prepared tests cover required query parameters, complete JSON, missing/null/short arrays, absent daily/dates, skipped unavailable dates without shifted indexes, limiting to three dates, and malformed/wrong-type JSON. All fixtures are synthetic and used only by tests.

### Remaining manual acceptance tests

| Test | Expected result | Status here |
| --- | --- | --- |
| Each city in the app | Correct city, three actual forecast cards with °C, %, mm, and km/h | App pending; all three endpoints verified |
| Rapid city switching | Select Khulna, Dhaka, Chattogram quickly on a slow connection; old cards disappear and only the last city's response is accepted | Pending |
| Retry after failure | Fail a request, restore access, tap Retry; loading finishes with actual results | Pending |
| Offline | From an online launch, disconnect the device/Simulator's network, switch city; show an error and Retry, with no old cards labelled as the new city | Pending |
| Persisted city | Choose Dhaka, terminate, relaunch; the picker and Profile retain Dhaka | Pending |
| Missing values | Run the JSON tests; missing measurements remain nil, real zero remains zero, date indexes stay aligned | XCTest pending |
| Empty forecast | Run the absent daily/dates fixture tests; zero days lets the screen show its empty state | XCTest/UI pending |
| Cancellation/loading | Switch away during a request, return, and switch cities; no stale error or response should overwrite the current request | Pending |

Drying recommendation rules and laundry plan creation are intentionally deferred to the requested later phases. No artificial forecast data appears in the app.

## Full project requirements

This is the full project scope. Authentication source, main tabs, and Weather Home have been added through Phase 3; native build and app acceptance remain pending.

- Email/password registration, login, restored sessions, useful authentication errors, and logout.
- Authentication before the main **Weather**, **My Plans**, and **Profile** tabs.
- Weather: remembered city, real three-day forecast, temperature/rain/wind details, loading/failure/unavailable states, and a date selection component using `@Binding`.
- Add Plan: sheet with the selected city, one forecast date, optional short note, and save action.
- My Plans: date, city, note, completion status, mark completed, and delete.
- Profile: authenticated email, selected city, and logout.
- Native UI with a light background, blue accents, white rounded cards, SF Symbols, readable spacing, and green/orange/red recommendation labels. Use basic SwiftUI controls and simple, explainable code.

### Required state ownership

| Owner / screen | Required state |
| --- | --- |
| `RootView` | Own `AuthViewModel` with `@StateObject`; share with `.environmentObject()` |
| `AuthViewModel` | `ObservableObject`; `@Published` authentication, loading, and error state |
| `MainTabView` | Own `PlanViewModel` with `@StateObject`; remember city with `@AppStorage` |
| `WeatherHomeView` | Own `WeatherViewModel` with `@StateObject`; city `@Binding`; date and sheet `@State` |
| `WeatherViewModel` | `ObservableObject`; `@Published` days, loading, and errors |
| `PlanViewModel` | `ObservableObject`; `@Published` plans, loading, and errors |
| `MyPlansView` | Receive the existing plan model with `@ObservedObject` |
| `ProfileView` | Read authentication with `@EnvironmentObject` |

Sign-out and account switching must clear account-specific plan state. Introduce property wrappers when their real features are added, not solely for demonstration.

### Firestore requirements for later phases

Use only Authentication and Cloud Firestore. Store plans at `users/{userUID}/plans/{planID}`, using the authenticated UID rather than email. Fields: `city: String`, `date: String` in `yyyy-MM-dd`, `note: String`, `isCompleted: Bool`, and `createdAt: Timestamp`. Security rules must restrict access to the matching authenticated UID.

The Phase 2 package setup includes the Firestore product as requested, but there are no Firestore calls or plan data yet. Create Firestore and deploy owner-only security rules when the plan-storage phase is requested. Authentication alone does not secure future Firestore data.

### Open-Meteo cities and later drying rules

| City | Latitude | Longitude |
| --- | --- | --- |
| Khulna | 22.8456 | 89.5403 |
| Dhaka | 23.8103 | 90.4125 |
| Chattogram | 22.3569 | 91.7832 |

Request daily maximum temperature, maximum precipitation probability, precipitation amount, and maximum wind speed for three forecast days, with `Asia/Dhaka` timezone and wind in km/h. Fetch using `URLSession` with `async/await`; decode real JSON with `JSONDecoder` and `Decodable` models. Do not label hardcoded values as live data.

Evaluate these project-defined heuristics in order:

1. **Avoid**: rain probability >= 60% OR precipitation >= 3 mm.
2. **Risky**: rain probability >= 30% OR precipitation >= 1 mm OR maximum wind >= 30 km/h.
3. **Good**: none of the above.

These rules are not scientific guarantees.

## Continuing development

Always use **DhobiGhat** as the app name. Before each phase, inspect the workspace and read `PROJECT_PROGRESS.md`. Preserve working code, modify only what that phase needs, review source, run available checks, and report limitations honestly. Update `PROJECT_PROGRESS.md` and `VIVA_NOTES.md` after each phase, explain manual steps and concepts, provide one meaningful commit message, then stop for the next instruction.

Stop after Phase 3 and await the next explicit phase instruction. Native project/SPM/Firebase setup, Swift tests, and app acceptance checks remain pending.
