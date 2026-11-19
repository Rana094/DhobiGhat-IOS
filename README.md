# DhobiGhat - Smart Laundry Day Planner

A beginner-level SwiftUI mini-project for a Mobile Computing Lab. The planned app helps students choose laundry days using real weather forecasts.

## Phase 0 status

Only the source scaffold and documentation are prepared. No working app or Xcode project existed to preserve. Git's baseline contained a one-line starter README headed `DhobiGhat-IOS`; this README expands it for the requested DhobiGhat project.

This workspace is on Windows. `xcodebuild`, `xcrun`, and `swift` were not found on PATH. No native Xcode tools were available to create a project or app target. There is **no `.xcodeproj`, configured app target, verified build, or verified launch yet**. Follow the Mac setup below to create the project using Xcode's native App template.

No dependencies have been installed. Authentication, Firestore, and weather requests are not implemented. The initial screen contains no sample weather or saved plans.

## Requirements

- A Mac running a compatible Xcode, with an iOS Simulator runtime or a supported iPhone.
- Swift and SwiftUI; intended minimum deployment target: **iOS 17.0**. Use a newer supported minimum only if your installed Xcode requires it, and record the actual value in `PROJECT_PROGRESS.md`.
- Use Xcode's default Swift language version initially. No `SWIFT_VERSION` or deployment setting exists until the native project is created. Record both compiler version and target Swift language version afterward; these are different settings.
- Later phases require the official Firebase Apple SDK (Authentication and Cloud Firestore) and Open-Meteo via native `URLSession`, `JSONDecoder`, and `Decodable`/`Codable`.
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
      DhobiGhatApp.swift
    Models/
      .gitkeep
    Views/
      RootView.swift
    ViewModels/
      .gitkeep
    Services/
      .gitkeep
    Resources/
      .gitkeep
```

- `App`: SwiftUI entry point and, when needed later, Firebase startup.
- `Models`: simple data structs, added in later phases.
- `Views`: SwiftUI screens. `RootView` is currently a static welcome screen.
- `ViewModels`: future observable state and screen logic.
- `Services`: future API and Firestore operations.
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
12. Choose **Product > Build** (`Command-B`), then **Product > Run** (`Command-R`). Expected screen: the title `DhobiGhat`, a blue water drop, and the laundry planner introduction. This is a static scaffold only.
13. Record the actual Xcode version, Swift compiler version, Swift language setting, deployment target, Simulator/device, and build/run result in `PROJECT_PROGRESS.md`. Keep the generated `.xcodeproj` and asset catalog in the repository for the next phase.

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

## Planned functionality and constraints

These are requirements for later phases, not completed features.

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

### Firebase requirements for later phases

Use only Authentication and Cloud Firestore. Store plans at `users/{userUID}/plans/{planID}`, using the authenticated UID rather than email. Fields: `city: String`, `date: String` in `yyyy-MM-dd`, `note: String`, `isCompleted: Bool`, and `createdAt: Timestamp`. Security rules must restrict access to the matching authenticated UID.

`GoogleService-Info.plist` is absent and Firebase is not configured. When the Firebase phase is requested, create/select your Firebase Console project, register an iOS app with the actual Xcode bundle identifier, and download its real `GoogleService-Info.plist`. Add it through Xcode with DhobiGhat target membership and bundle resource inclusion. Add only the official Firebase Authentication and Firestore SDK products, enable email/password sign-in, create Firestore, and deploy owner-only rules in that phase. No invented configuration values and no Firebase packages or setup are needed for Phase 0.

### Open-Meteo requirements for later phases

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

Phase 0 stops here. Await Phase 1 before implementing any feature or integration.
