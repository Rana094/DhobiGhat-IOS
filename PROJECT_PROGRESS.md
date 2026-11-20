# DhobiGhat Project Progress

## Current phase

**Phase 4 - Drying recommendations, forecast-date selection, and Add Plan sheet source implemented; native build, XCTest, and app checks pending on a Mac.** Updated 2026-11-20 (Asia/Dhaka).

## Project conventions

- The app name is **DhobiGhat**. Use this name for source folders, app types, display text, future Xcode product/target/scheme names, and documentation.
- Provide one meaningful commit message after every phase. Do not create a commit unless requested.
- Following Phase 0, the source folder, app entry file/type, welcome title, and setup documentation were renamed to DhobiGhat. This was a naming update only; no new phase or feature was started. Source/name and whitespace checks passed; build and launch remain unverified because Xcode and Swift are unavailable here.

The complete pasted master instructions were read before this phase. Initial workspace inspection showed no app files. Git diff review also identified a tracked one-line starter README headed `DhobiGhat-IOS`, which has been expanded for DhobiGhat. No existing `.xcodeproj`, `.xcworkspace`, Swift sources, project settings, progress file, or working functionality existed. No ancestor or workspace `AGENTS.md` instructions were found.

## Completed phases

- Phase 0 automated preparation: minimal source, understandable folders, README, progress record, and viva notes.
- Phase 0 native acceptance checks remain pending; do not treat this as a verified runnable Xcode project.
- The app was renamed to DhobiGhat after Phase 0.
- No Phase 1 implementation or completion record was present. The user explicitly requested Phase 2, so that scope was implemented directly without claiming Phase 1 completion.
- Phase 2 source: guarded Firebase startup, real registration/login/logout calls, session listener, validation, errors, login/register form, authenticated tab shell, and profile/logout.
- Phase 2 package attachment and live acceptance tests remain pending. No connected or tested Firebase deployment is claimed.
- Phase 3 source: three supported cities, direct Decodable models, safe daily-array conversion, native URLSession requests, observable weather state, picker/cards, loading/errors/retry/empty states, persisted city, and protection against old city responses.
- Phase 3 live endpoint checks: all three cities returned HTTP 200 with three days; an invalid-field request returned HTTP 400. These are external HTTP checks, not execution of the Swift app.
- Phase 4 source: small if/else recommendation function, Good/Risky/Avoid colors, Unavailable handling, selected forecast date, Plan Laundry, and a native AddPlanView sheet receiving city/date. Plan saving remains deferred.

## Current project structure and files created

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
      AddPlanView.swift
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
    DryingRecommendationTests.swift
```

Phase 0 created the original scaffold and expanded README. Phase 2 changes:

- Modified `App/DhobiGhatApp.swift`: register AppDelegate using `@UIApplicationDelegateAdaptor`.
- Created `App/AppDelegate.swift`: check the bundled real plist and bundle ID, then call `FirebaseApp.configure()` during application launch. Missing/invalid configuration is reported in the console and results in setup instructions in the UI.
- Created `ViewModels/AuthViewModel.swift`: `@MainActor ObservableObject` with `@Published` current user, email, loading, errors, initial session-check state, and setup errors. Uses actual Firebase Auth async APIs and a removable state listener.
- Modified `Views/RootView.swift`: owns one auth model with `@StateObject`, injects it using `.environmentObject()`, routes between setup/loading/login/main states, and keys the main tabs by authenticated UID. A stable `ZStack` keeps root listener lifetime separate from screen changes.
- Created `Views/LoginView.swift`: email/password and registration mode in local `@State`, native Form, SecureField, loading state, and useful errors.
- Created `Views/MainTabView.swift`: Weather/My Plans/Profile tabs. The original welcome content is preserved in Weather. Weather and plan management remain explicit placeholders.
- Created `Views/ProfileView.swift`: authenticated email and real logout through the shared `@EnvironmentObject`.
- Updated README with exact native Xcode/SPM/Console/plist setup and manual acceptance tests; updated VIVA_NOTES with the current code and concepts.
- Existing placeholder folders and `.gitkeep` files are preserved. No models, weather services, plan services, or extra architecture were introduced.

Phase 3 files created/modified:

- Created `Models/City.swift`: Khulna, Dhaka, Chattogram with the requested coordinates and predefined list.
- Created `Models/WeatherResponse.swift`: direct Decodable structs, CodingKeys, optional arrays, and optional elements.
- Created `Models/WeatherDay.swift`: a Bangladesh calendar date string and four optional measurements, with no fake defaults.
- Created `Services/WeatherService.swift`: URLComponents/query items, explicit units, async URLSession, HTTP validation, JSONDecoder, safe index-based conversion, and simple errors.
- Created `ViewModels/WeatherViewModel.swift`: ObservableObject with @Published days/loading/errors and city; clears old data and accepts only the current non-cancelled request's result/error.
- Created `Views/WeatherHomeView.swift`: city @Binding, owned @StateObject, menu picker, task-driven reloads, loading/retry/empty states, cards, and Open-Meteo credit.
- Created `Views/WeatherDayCard.swift`: date plus four measurements with units; missing values display Unavailable.
- Modified `Views/MainTabView.swift`: replaces the weather placeholder and owns selectedCity using @AppStorage. Invalid saved names fall back to Khulna.
- Modified `Views/ProfileView.swift`: displays the selected city while preserving authentication behavior.
- Created `Tests/WeatherServiceTests.swift`: seven XCTest methods with synthetic JSON for URL parameters, normal decoding, optional/unequal arrays, missing dates, date alignment, the three-day limit, and malformed/wrong-type JSON. Prepared, not run.
- Updated README with weather behavior, endpoint evidence, XCTest setup, and manual checks; updated VIVA_NOTES with networking/JSON/state explanations.
- Preserved Phase 2 auth and root routing. No fake login, weather package, artificial forecast values, drying rules, or plan storage was added.

Phase 4 files created/modified:

- Modified `Models/WeatherDay.swift`: added dryingRecommendation() and a three-case String enum in the same file. Missing, non-finite, or invalid rule inputs yield nil/Unavailable. Avoid is evaluated before Risky, then Good. Temperature is not part of the rules.
- Modified `Views/WeatherDayCard.swift`: recommendation text/colors, date selection through @Binding, selected outline/checkmark, and accessibility selection indication. Existing metric rows are preserved.
- Modified `Views/WeatherHomeView.swift`: @State selectedDate/sheet visibility, date bindings to cards/form, current-forecast validation for Plan Laundry, selection reset on city/new request, and the project-guideline disclaimer.
- Created `Views/AddPlanView.swift`: city, current forecast-date Picker using the parent's binding, optional local @State note, Close using the environment dismiss action, and an explicit no-saving message.
- Created `Tests/DryingRecommendationTests.swift`: seven methods/28 assertions for the requested five examples, exact boundaries, Avoid priority, missing inputs, and invalid/non-finite values. Prepared, not executed.
- Updated README with Phase 4 scope/setup/acceptance checks and VIVA_NOTES with every rule branch, expected outcomes, and the date/sheet state flow.
- No changes to Firebase, network requests, JSON conversion, or weather ViewModel behavior. No packages, scoring system, machine learning, fake forecasts, or plan persistence were added.

## Toolchain and project settings

| Check | Actual status |
| --- | --- |
| Host | Windows / PowerShell |
| Xcode / `xcodebuild` / `xcrun` | Not available on PATH; no native project creation or Apple SDK build possible here |
| Swift compiler | `swift` not found on PATH; version unknown |
| Existing Xcode project | None |
| Recognized Xcode project | Pending native creation on a Mac |
| DhobiGhat app target / scheme | Not created; pending Xcode's native iOS App template |
| Swift language setting | Unset; retain template default and record it after project creation |
| iOS deployment setting | Unset; intended minimum iOS 17.0 unless installed Xcode requires a newer supported target |
| Simulator / device launch | Not available / not verified |

No packages or project generators were installed. The required SDK cannot be attached without the native project; no dummy `.xcodeproj`, `Package.swift`, `Package.resolved`, or Firebase configuration was invented.

## Firebase setup status

- Real Auth integration source is implemented, using `FirebaseCore` and `FirebaseAuth` imports.
- `Auth.auth()` is created only in `startListening()`, after checking that `FirebaseApp.app()` exists. Constructing the ViewModel does not touch Firebase. Auth operations require the initialized Auth instance.
- Registration uses `createUser(withEmail:password:)`; login uses `signIn(withEmail:password:)`; logout uses `signOut()`. No fake login flag is stored.
- The state listener reads Firebase's current user and email and resolves the initial session-check state. It uses a weak reference, runs UI updates on the main actor, and is removed when RootView leaves the screen. The SDK handles persisted sessions; passwords and tokens are never saved by app code.
- Email is trimmed and checked for basic format; password is required and new registrations require at least six characters. Passwords are not trimmed. Firebase enforces final validity and its configured policy. Login does not impose a new registration policy on existing accounts.
- Friendly errors cover incorrect credentials (including enumeration-protection behavior), duplicate email, weak passwords, network failures, disabled accounts, disabled provider, rate limits, invalid configuration, keychain failures, and a visible fallback.
- Official SPM repository: `https://github.com/firebase/firebase-ios-sdk`. Required products: `FirebaseAuth` and `FirebaseFirestore`, attached to the DhobiGhat target. Attachment, package resolution, and SDK version selection are **pending** because no native project exists here.
- No real `GoogleService-Info.plist`, Firebase Console registration, provider enablement, or live connectivity has been verified. README provides precise steps, including target membership and app Info configuration.
- No Firestore reads/writes, database creation, or security rules are part of this phase. The future plan-storage phase still needs UID-scoped paths, owner-only rules, and listener/task cleanup.

## Weather API status

- Implemented Open-Meteo HTTPS forecasts for the three cities, `forecast_days=3`, `timezone=Asia/Dhaka`, all four required daily fields, and explicit Celsius/mm/km/h units.
- Native URLSession timeout is 30 seconds; local URL cache is bypassed. Non-HTTP and non-2xx responses fail before forecast decoding.
- Optional arrays/elements and unequal lengths are safe: conversion follows original date indexes and preserves missing measurements as nil. Null/empty dates are skipped; absent daily/time produces no days. Malformed/wrong-type JSON throws and becomes an error.
- Normal responses produce three cards; partial dates yield fewer cards with a note; no dates yields an empty state. Metrics never default to zero, and no sample forecasts are used by the app.
- City changes cancel the previous task. Request IDs and cancellation checks reject old results, errors, and loading changes. A screen-level city check hides old cards before the new task starts.
- MainTabView persists the city through @AppStorage, passes a @Binding to WeatherHomeView, and shows the city in Profile.
- Live checks on 2026-11-20 (Asia/Dhaka), from Python outside the restricted network sandbox: **Khulna HTTP 200; Dhaka HTTP 200; Chattogram HTTP 200**. Each returned `Asia/Dhaka`, dates **2026-11-20 through 2026-11-22**, three entries per required array, and the requested units. This does not prove Swift URLSession/JSONDecoder or UI behavior.
- Negative endpoint check: an intentionally invalid daily field returned **HTTP 400** with an error reason.
- Initial restricted probes failed DNS resolution; the same read-only requests succeeded outside that sandbox. This host restriction was not an iOS offline test.
- Phase 4 now computes recommendations from the fetched measurements and allows selection of a returned date. It requires all three rule inputs to be usable and never substitutes zero for unavailable data. Missing temperature alone does not prevent a recommendation because temperature is not in the rules.
- Avoid >=60% or >=3 mm is checked first; otherwise Risky >=30% or >=1 mm or >=30 km/h; otherwise Good. Labels use red/orange/green, with gray Unavailable. These are project-defined guidelines, not guaranteed drying predictions.
- City/retry/new-load changes clear the selection. Plan Laundry requires a selected date in the current city's successful loaded forecast, and opens the actual AddPlanView sheet. The form can select any returned forecast date and accepts an unsaved note. Firestore saving remains deferred.

## Compilation and test status

- Reviewed the seven Swift source files against official Firebase setup, Auth APIs, and error-code documentation. Reviewed startup order, observable state ownership, listener lifecycle, async loading cleanup, password handling, and root routing. These are source reviews, not compiler or runtime tests.
- Phase 2 local checks passed: one `@main` across seven Swift files; no trailing whitespace in the seven Swift files and three documentation files; `git diff --check` passed. Source searches found no custom credential persistence, suppressed `try` errors, forced casts, emulator calls, or premature Firestore operations. Only normal LF-to-CRLF notices were emitted by Git. These checks do not establish Swift syntax/type correctness or successful authentication.
- No Swift compiler, Apple SDK type checking, `xcodebuild`, automated iOS tests, Simulator, or device run was available. **Build and launch are not verified.** Source inspection is not compilation.
- Registration, login, incorrect credentials, logout, session restoration, UI reaction, validation/error behavior, and account switching: **all Firebase live tests pending**. Firestore is unimplemented and untested.
- Phase 3 endpoint checks above passed. Swift JSON decoding, prepared XCTest execution, city-switch/retry/offline UI, remembered city, and app build/launch are **pending**. No compiler or iOS test success is claimed.
- Phase 3 local checks passed: 14 app Swift files and one @main; seven XCTest methods prepared; no trailing whitespace or old app name across 18 source/test/documentation files; git diff --check passed. Nine syntactically valid synthetic JSON fixture payloads were checked with Python's JSON parser, including deliberately incompatible field types for Swift decoding tests. This was fixture syntax validation only, not Swift JSONDecoder or XCTest execution.
- Phase 4 review: traced the five requested outcomes (Good/Risky/Avoid/Avoid/Risky), inclusive thresholds and Avoid priority; reviewed missing-data handling, date bindings, button validity, selection reset, and sheet payload. These are source reviews, not executed Swift tests.
- Phase 4 XCTest and UI checks remain pending. Seven new XCTest methods are prepared in addition to Phase 3's seven. No test pass or Simulator run is claimed.
- Phase 4 final local checks passed: 15 app Swift files, two XCTest files, one @main, and seven new recommendation methods containing 28 assertions. Whitespace and app-name checks passed across 20 source/test/documentation files; git diff --check passed. These are file/content checks, not compilation or executed XCTest.

## Known bugs and limitations

- No runtime bugs can be assessed until the app builds and runs.
- The `.xcodeproj` and iOS app target do not exist yet. The scaffold cannot currently be opened as an app project or launched.
- Resources currently contain only a folder placeholder. The native template's asset catalog must be added during Mac setup.
- Auth source cannot compile until the official Firebase products are added to a real target. No `canImport` fallback or simulated login hides this missing dependency.
- Weather, recommendations, and date/form selection source now exist. The sheet explicitly cannot save; closing discards its local note and creates no plan. Firestore saving, My Plans, and remaining state wrappers are deferred. Phase 1 was not available and has not been silently re-created.
- Actual Firebase behavior, package compatibility, Swift concurrency compilation, and session restoration require a Mac build and configured runtime tests.

## Manual actions required

Follow README's native project, Firebase setup, and Phase 3/4 feature/test sections:

1. Create the native DhobiGhat iOS App project; include all 15 app Swift files under DhobiGhat and the template asset catalog in its app target. AddPlanView.swift is the only new Phase 4 app file. Keep Tests out of the app target.
2. Add the official Firebase SPM repository and attach only `FirebaseAuth` and `FirebaseFirestore`. Resolve a stable SDK compatible with your installed Xcode and keep the actual package resolution file.
3. Register the exact Xcode bundle ID as an iOS app in Firebase Console and enable Email/Password authentication.
4. Download the real `GoogleService-Info.plist`, add it to DhobiGhat/Resources with app target membership and bundle inclusion, and verify the bundle ID matches.
5. Add the Boolean app Info key `FirebaseAppDelegateProxyEnabled = NO` as described by official SwiftUI setup.
6. Create the DhobiGhatTests XCTest target with DhobiGhat as host; add both WeatherServiceTests.swift and DryingRecommendationTests.swift only to that target and run Product > Test.
7. Build/run README's auth/weather checks plus Phase 4 selection, colors, unavailable data, disabled-button behavior, city reset, sheet city/date, and changed sheet-date highlight. Confirm Close creates no saved plan. Record actual results rather than marking tests passed from source inspection.

Before marking native Phase 0 checks complete, record:

- Xcode version and Swift compiler version.
- Effective `SWIFT_VERSION` and `IPHONEOS_DEPLOYMENT_TARGET`.
- Confirmation that Xcode recognizes `DhobiGhat.xcodeproj` and its DhobiGhat iOS application target/scheme.
- Selected Simulator/device and OS version.
- Resolved Firebase SDK version and the two linked products.
- Build result, launch result, XCTest result, and each live auth/weather app test result, including errors.

## Next implementation steps

1. Finish the manual native/SPM/Firebase setup and verification above when a Mac is available.
2. Stop after Phase 4 and wait for the next explicit phase instruction.
3. Before the next phase, inspect existing files and reread this progress record. Keep code beginner-friendly, use the requested MVVM/state ownership, and preserve real working functionality.
