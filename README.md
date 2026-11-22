# DhobiGhat - Smart Laundry Day Planner

A beginner-level SwiftUI mini-project for a Mobile Computing Lab. The planned app helps students choose laundry days using real weather forecasts.

## Phase 6 status

Source includes authentication, real weather, drying recommendations, and Firestore plan CRUD. Phase 6 connects acknowledged saves to the My Plans tab after sheet dismissal, improves native small-screen layouts and loading/refresh feedback, adds earlier date validation, and trims note edges before storage. Existing MVVM, UID isolation, property-wrapper ownership, and real integrations are preserved. No packages, major features, sample forecasts, or styling framework were added.

This workspace is on Windows. `xcodebuild`, `xcrun`, and `swift` were not found on PATH. No native Xcode tools were available to create a project or app target. There is **no `.xcodeproj`, configured app target, verified build, or verified launch yet**. Follow the Mac setup below to create the project using Xcode's native App template.

No dependencies have been resolved or attached to a target here because there is no Xcode project. The code imports the actual Firebase SDK and needs the SPM setup below to compile. `GoogleService-Info.plist` has not been supplied. **Firebase and Firestore are not configured, connected, or live-tested here; the rules have not been published or run.** Earlier weather endpoint probes succeeded, but no Swift build or app test is verified. Phase 1 was not present and has not been claimed complete.

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
  firestore.rules
  DhobiGhat/
    App/
      AppDelegate.swift
      DhobiGhatApp.swift
    Models/
      City.swift
      WeatherResponse.swift
      WeatherDay.swift
      LaundryPlan.swift
      .gitkeep
    Views/
      RootView.swift
      LoginView.swift
      MainTabView.swift
      ProfileView.swift
      WeatherHomeView.swift
      WeatherDayCard.swift
      AddPlanView.swift
      MyPlansView.swift
    ViewModels/
      AuthViewModel.swift
      WeatherViewModel.swift
      PlanViewModel.swift
      .gitkeep
    Services/
      WeatherService.swift
      PlanService.swift
      .gitkeep
    Resources/
      .gitkeep
  Tests/
    WeatherServiceTests.swift
    DryingRecommendationTests.swift
    LaundryPlanTests.swift
```

- `App`: SwiftUI entry point and Firebase startup in AppDelegate.
- `Models`: supported cities, optional decoded daily arrays, weather days, and the small recommendation function/enum in WeatherDay.swift.
- `Views`: authentication, tabs, weather cards, profile/logout, Add Plan, and My Plans.
- `ViewModels`: observable authentication/weather/plan state; MainTabView owns the single shared PlanViewModel.
- `Services`: WeatherService performs API requests; PlanService performs UID-scoped Firestore dictionary operations.
- `Tests`: XCTest for weather JSON, drying rules, plan dictionary mapping, and strict dates. Fixtures are synthetic and these tests do not contact Firebase. Add test files only to a unit test target.
- `firestore.rules`: publish this server-side policy in the intended Firebase database; including it in the repository does not deploy it.
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

1. Create/open the native `DhobiGhat.xcodeproj` using the instructions above. Confirm all 19 app Swift files under `DhobiGhat/` belong to the **DhobiGhat** app target. The three Swift files under `Tests/` belong only to the test target described below.
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

Phase 4 added recommendations/date selection; Phase 5 extends that same form with real Firestore saving below. No artificial forecast data appears in the app.

## Phase 4 recommendations and laundry-date selection

`WeatherDay.dryingRecommendation()` uses the already-fetched data and a short if/else function. It first requires usable rain probability, precipitation, and wind inputs. Missing values, NaN/infinity, probabilities outside 0...100, and negative precipitation/wind return nil, shown as **Unavailable**. Temperature does not participate in these project rules.

1. **Avoid (red)**: probability >= 60% OR precipitation >= 3 mm.
2. **Risky (orange)**: if Avoid did not apply, probability >= 30% OR precipitation >= 1 mm OR wind >= 30 km/h.
3. **Good (green)**: otherwise.

The screen states: **Drying recommendations are basic project-defined guidelines, not guaranteed drying predictions.** There is no machine learning, score, or extra network request.

Tap any forecast card to select its date. A blue outline and checkmark identify the selection. WeatherHomeView owns selectedDate in @State; the child card receives @Binding. Plan Laundry is enabled only when the selected date belongs to the current city's loaded forecast. City changes, retry, and a new load clear the selection, preventing an old date from being used.

The button opens AddPlanView as a native sheet. It displays the city and selected date, allows choosing another returned forecast date using the same binding, and provides an optional local note. All returned dates remain selectable regardless of recommendation. Phase 5 now adds Save plan and Cancel; the note becomes persisted only after an actual successful Firestore write.

### Phase 4 tests and Mac steps

- Include the new `DhobiGhat/Views/AddPlanView.swift` in the **DhobiGhat app target**, alongside the modified WeatherDay, WeatherDayCard, and WeatherHomeView files. No new SDK, package, permission, or Firebase configuration is required by these changes.
- Add `Tests/DryingRecommendationTests.swift` to the existing **DhobiGhatTests XCTest target only**, alongside WeatherServiceTests.swift. If no target exists, follow the unit-test target steps above. Choose an iPhone Simulator, then **Product > Test** (`Command-U`).
- Seven new test methods contain 28 assertions covering the five requested examples (Good, Risky, Avoid, Avoid, Risky); rain boundaries 29.99/30 and 59.99/60; precipitation boundaries 0.99/1 and 2.99/3; wind boundary 29.99/30; Avoid priority; missing inputs; and invalid/non-finite values.
- The tests exercise the real Swift recommendation method using labelled synthetic inputs. They are prepared and source-reviewed, **not compiled or executed** here. Xcode/Swift and the iOS Simulator remain unavailable.

| Manual check | Expected behavior | Status here |
| --- | --- | --- |
| Recommendation labels | Text and green/orange/red colors match the actual forecast's rule result; missing required values show gray Unavailable | Pending |
| Select each date | Any returned date can be selected; only one card has the blue outline/checkmark | Pending |
| No selection / failed forecast | Plan Laundry stays disabled | Pending |
| Sheet opens | City and the selected forecast date match the Weather screen | Pending |
| Change date in sheet | Picker offers current forecast dates; closing highlights the newly chosen date | Pending |
| Change city or retry | Selection clears; an old city's date cannot be used while loading | Pending |
| Cancel before Save | Discard the local note and create no plan; if Save was already submitted, closing cannot cancel that write | Pending |

Every recommendation branch and the state/binding flow are explained in VIVA_NOTES.md. Existing Firebase and weather checks remain pending as previously recorded; no app build or launch is claimed.

## Phase 5 Firestore setup and verification

### Create the database and publish the rules

1. Finish the Xcode/Firebase setup above using the real `GoogleService-Info.plist`. Confirm **FirebaseFirestore** and **FirebaseAuth** are linked to the DhobiGhat target. No extra SDK products, backend, Storage, Realtime Database, or CLI installation are needed.
2. In [Firebase Console](https://console.firebase.google.com/), select the same project as the plist. Open **Build > Firestore Database** (or **Databases & Storage > Firestore**).
3. If no database exists, choose **Create database**, select **Standard edition / Native mode** if prompted, and the **(default)** database. Choose the location appropriate for your project, then start with production/locked rules. This app uses the default Firestore instance.
4. Open the database's **Rules** tab. For this dedicated DhobiGhat project, replace the editor contents with the entire repository `firestore.rules` file. Review it and click **Publish**. If your project already serves another app, integrate the DhobiGhat match block into that existing policy instead of deleting its unrelated rules.
5. Check the editor for errors and confirm publication completes. The repository file alone does not configure Firestore. A broad allow rule elsewhere in the same policy can still grant access, so do not leave an overlapping test-mode allow-all rule.
6. In Xcode, include `LaundryPlan.swift`, `PlanService.swift`, `PlanViewModel.swift`, and `MyPlansView.swift` in the app target, along with the updated MainTabView, WeatherHomeView, and AddPlanView. Do not bundle firestore.rules as an app resource; it is a server policy.
7. Build/run on an iPhone Simulator or supported phone. Log in with a test account you control. Record the UID from Firebase Authentication > Users for later data/rule checks.

Official references: [Firestore setup](https://firebase.google.com/docs/firestore/quickstart), [rules publication](https://firebase.google.com/docs/firestore/security/get-started), and [owner checks](https://firebase.google.com/docs/firestore/security/rules-conditions).

### Data and application behavior

Plans are stored at `users/{Firebase UID}/plans/{auto-generated document ID}`. A parent users/{UID} document does not need to contain fields for the plans subcollection to exist. Email is not used in the path.

| Field | Stored value |
| --- | --- |
| city | Supported city name, String |
| date | Actual forecast calendar date as yyyy-MM-dd, String |
| note | String; an optional empty note is stored as `""` |
| isCompleted | Bool, false on creation and true after completion |
| createdAt | Firestore Timestamp assigned with FieldValue.serverTimestamp() |

The document ID is read separately into LaundryPlan.id. Mapping uses ordinary dictionaries and checked casts; there is no Firestore Codable mapper. Invalid/missing fields produce an error instead of silently dropping a plan or inventing values. Dates are strictly validated with a Gregorian DateFormatter in Asia/Dhaka; the existing forecast strings are preserved. createdAt is an absolute server timestamp, separate from the laundry calendar date.

PlanService uses `addDocument(data:)`, one-time `getDocuments(source: .server)`, `updateData(["isCompleted": true])`, and `delete()`. Results are sorted newest-first by createdAt in memory, so no custom query index is required. Server-only reads make network/rule failures visible rather than silently falling back to cached data.

MainTabView owns one PlanViewModel with @StateObject; MyPlansView, WeatherHomeView, and AddPlanView observe that instance. UID changes clear plans/loading/errors and replace an account token. Requests capture their starting UID/token and verify both the current Firebase user and token before publishing a result/error. Root also recreates main tabs by UID. These source safeguards complement server rules; account isolation still requires live verification.

Save disables duplicate submissions while the operation is active. The form dismisses only after the write is acknowledged; each successful write triggers a server fetch. If the write succeeds but that fetch fails, the list shows a specific **saved/completed/deleted, but refresh failed** message. It does not treat an acknowledged save as failed and encourage another Save. Completion/deletion also update the confirmed local item before refreshing.

My Plans shows city/date/note, Pending or Completed, Mark completed, and Delete with confirmation. Pull to refresh or Retry refresh performs another one-time read. An empty state appears only after loading finishes without an error. Plan actions and new form entry are disabled during an active plan operation.

### Offline and cancellation behavior

Firestore can queue a write while offline; its async completion may wait until the server can acknowledge or reject it. The app shows this waiting state and does not claim the plan was saved early. **Cancel closes the form; it cannot retract an already-submitted write.** Shared busy state still blocks repeated Save while that operation is active. An already-submitted SDK write can outlive the screen or process; after reconnect/relaunch, check My Plans and Console before making another plan. This is not an exactly-once system across restarts.

Server reads show permission/unavailable errors when returned by the SDK. Cached pending writes are not proof of a committed server result. No custom timeout reports a queued write as failed, and no automatic retry creates another document. Details are in the [official document API](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/DocumentReference).

### Rule checks and tests - all pending

Rules require a signed-in UID matching the path. Creation requires exactly the five typed fields, a supported city, yyyy-MM-dd text, Pending status, and a server timestamp equal to request.time. Updates can change only isCompleted to true; city/date/note/createdAt cannot be edited through this phase's client. Read/delete require the owner. Everything outside the matched path is denied by default.

The rules check the date's text shape; the app additionally checks whether it is a real Gregorian date. Rules are not a weather service and do not independently prove a date came from Open-Meteo. Console administrator edits bypass client rules and therefore cannot demonstrate owner authorization.

Use the Console **Rules Playground** with a known saved plan path `/users/UID_A/plans/PLAN_ID`. Select a get/read operation and authenticated UID_A: expect Allowed. Repeat with UID_B and with authentication disabled: expect Denied. Also simulate update/delete under UID_B: expect Denied. Run actual owner create/complete/delete actions in the app to verify valid writes and server timestamp transforms.

| Test | Steps and expected evidence | Status here |
| --- | --- | --- |
| Save | In Weather select a date, Plan Laundry, optional note, Save; sheet closes after server acknowledgment and My Plans shows Pending | Pending |
| Console data | Open users > UID_A > plans > document; verify all five fields and Timestamp type, with no email-based path | Pending |
| Reopen/retrieve | Close and reopen the app after acknowledged save; restored account fetches the same plan from the server | Pending |
| Complete | Mark completed; list and Console both show isCompleted true | Pending |
| Delete | Confirm Delete; list and Console both remove the document | Pending |
| Empty list | Delete the last plan; show the empty state after refresh | Pending |
| Account separation | Save under A, log out, log into B; A's list must disappear immediately, including during a slow in-flight fetch/write; B sees only B's plans | Pending |
| Rule isolation | Rules Playground owner/non-owner/anonymous get plus non-owner update/delete checks above | Pending |
| Permission denied | In a dedicated test project, temporarily replace the policy with deny-all rules and Publish; refresh/Save must show permission denied. Replace the editor with the entire repository firestore.rules file and Publish again afterward; adding a deny beside an allow does not override that allow | Pending |
| Network unavailable | Disconnect network, refresh: show a read error when the SDK returns it. Submit a write offline: show pending confirmation with repeated Save disabled; reconnect and inspect the final server result | Pending |
| Cancel | Cancel before Save creates nothing. Cancel after submission closes the form with the visible warning; the outstanding write may still complete | Pending |
| Mapping/date tests | Add Tests/LaundryPlanTests.swift only to DhobiGhatTests, alongside the other two test files; run Product > Test | Pending |

The seven new unit tests cover dictionary fields/types, optional empty note, completion status, missing data, supported city/ID, and strict dates including leap-day boundaries. They do not contact Firebase or verify rules. No Xcode build, XCTest run, Console deployment, CRUD action, account isolation, or offline app test has been verified here.

The fixture tests need a native Xcode project and linked Firebase products, but no live database or plist configuration. Add the existing **FirebaseFirestore** package product to the **DhobiGhatTests** target as well if needed for its direct `import FirebaseFirestore` and Timestamp fixtures; reuse the same package/version, without installing another SDK. Live app tests require all Console/configuration steps above. For the permission test, this temporary complete policy denies every client read/write:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Restore the actual repository policy after that test. Console administrator access is unaffected by client security rules and cannot substitute for an app permission test.

## Phase 6 integration review and UI improvements

### Changes made

- MainTabView owns a simple selectedTab @State with matching string tags for Weather, My Plans, and Profile. AddPlanView notifies WeatherHomeView only after an acknowledged save while the form is still visible. WeatherHomeView waits for the sheet's onDismiss before asking MainTabView to select My Plans. Cancelling a pending form does not cause a later automatic tab change.
- Weather metrics use native ViewThatFits: show a horizontal label/value row when it fits, otherwise stack vertically. Values use primary text color; cards use the native grouped-card background so they remain readable in light/dark appearances. Rounded selection outlines and recommendation colors are preserved.
- My Plans uses separate inset-grouped plan sections, wrapping notes, and vertically stacked bordered actions. This avoids crowding Mark completed and Delete on a narrow screen. Profile email wraps; forms use the same soft blue background.
- Weather and My Plans have explicit native refresh controls using existing request functions. Authentication loading names the action; password Return submits through the same guarded handler as the login/register button. Login and plan forms dismiss the keyboard interactively while scrolling.
- Plan Laundry and Save reject a date unless it is both in the loaded forecast and a valid yyyy-MM-dd calendar date. The plan form shows a date error before sending an invalid request. PlanService trims leading/trailing note whitespace; internal text/newlines remain intact.
- Existing root auth environment injection, three ViewModel owners, observed shared plan model, @AppStorage city preference, logout/account clearing, server-acknowledged writes, and old-city request guards were traced in source. No production weather/plan fixture data was found to remove; synthetic values remain only in Tests.

Apple references for the native layout/keyboard APIs: [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits), [scrollDismissesKeyboard](https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:)).

### Flow review and remaining runtime checks

| Flow / check | Source path reviewed | Runtime status |
| --- | --- | --- |
| Login -> main -> logout -> login | Root owns/injects auth; actual Firebase currentUser controls routing; successful signOut removes main UI | Pending |
| City -> JSON -> cards | AppStorage binding -> task ID -> URLSession/JSONDecoder -> @Published days -> cards | Pending; prior HTTP probes only |
| Date -> form -> Save -> My Plans | Shared date binding -> calendar validation -> shared PlanViewModel -> actual server write/refresh -> callback -> sheet dismissal -> selected tab | Pending |
| View -> complete -> delete | Observed plans -> real updateData -> refresh; Delete alert -> real delete -> refresh | Pending |
| State ownership | One @StateObject each for auth, weather, plans; three child views observe the single plan instance | Source-reviewed; UI pending |
| Environment | Root provides auth to Login, MainTab, and Profile; sheet receives plans explicitly | Source-reviewed; UI pending |
| Logout and account switch | UID-based root identity, setUser(nil), account tokens, and current Firebase UID checks | Pending live A/B test |
| No stale city data | Old days cleared; task cancellation/request ID and city-name checks reject obsolete responses/errors | Pending slow-network UI test |
| Cancel during pending save | Closing keeps the SDK operation pending but suppresses a later automatic navigation callback | Pending |
| Invalid/empty input | Auth validation, actual forecast membership, strict plan date, trimmed note, duplicate-save guards | Pending |

### Small-iPhone acceptance procedure

1. Complete the existing native Xcode/SPM/Firebase/database/rules setup and run Product > Build and Product > Test. No new target files or packages are needed for Phase 6.
2. Run on the smallest iPhone Simulator supported by the installed runtime, in portrait and landscape. Use both default text size and a large accessibility Dynamic Type size.
3. Confirm that city selection, every weather measurement/unit, Good/Risky/Avoid/Unavailable labels, selection checkmarks, and Plan Laundry are readable without horizontal clipping. Narrow weather rows should stack vertically.
4. Show the software keyboard in Login and Add Plan. Scroll to every input/action; test password Go, interactive keyboard dismissal, Save/Cancel, and the inline modal title.
5. Use a long email and a multiline note. Profile and My Plans should grow vertically. Completion/Delete buttons must remain reachable and independent, with no accidental second action.
6. Execute the four flows in the table using real services. Confirm a successful visible Save selects My Plans only after dismissal; failed Save stays in the form; Cancel before submission creates nothing; Cancel during a pending write does not later change tabs.
7. Check light and dark appearances, busy/disabled buttons, refresh/retry, offline/permission errors, city persistence after restart, and logout/login with two accounts. Record the actual device/runtime/results in PROJECT_PROGRESS.

**None of these simulator/layout/live checks has run here.** Windows still has no Xcode, Swift compiler, Simulator, native project, linked Firebase packages, real plist, or deployed rules. Source review is not proof that every button or layout works at runtime. The 21 existing XCTest methods remain unexecuted; no UI-only tests or new dependencies were introduced for reversible presentation changes.

## Full project requirements

This is the full project scope. Source implementations through Phase 6 include authentication, weather, recommendations, date selection, Firestore plan CRUD, rules, integrated navigation, and native UI refinements. Native setup, build, deployed rules, and all Firebase/app acceptance checks remain pending.

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

### Firestore data requirements

Use only Authentication and Cloud Firestore. Store plans at `users/{userUID}/plans/{planID}`, using the authenticated UID rather than email. Fields: `city: String`, `date: String` in `yyyy-MM-dd`, `note: String`, `isCompleted: Bool`, and `createdAt: Timestamp`. Security rules must restrict access to the matching authenticated UID.

Phase 5 implements these calls and supplies owner-only rules. Complete the database/rules setup and live verification above. Authentication alone does not secure Firestore data.

### Open-Meteo cities and drying rules

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

Stop after Phase 6 and await the next explicit phase instruction. Native project/SPM/Firebase setup, rule deployment, Swift tests, and app acceptance checks remain pending.
