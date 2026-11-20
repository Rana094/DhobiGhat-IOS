# DhobiGhat Project Progress

## Current phase

**Phase 2 - Firebase Authentication source implemented; native project, SPM attachment, real Firebase configuration, and live verification pending on a Mac.** Updated 2026-11-20 (Asia/Dhaka).

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
      .gitkeep
    Views/
      RootView.swift
      LoginView.swift
      MainTabView.swift
      ProfileView.swift
    ViewModels/
      AuthViewModel.swift
      .gitkeep
    Services/
      .gitkeep
    Resources/
      .gitkeep
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

- Not implemented or called.
- No weather data is shown, including no hardcoded data posing as live weather.
- Later implementation must follow the three supported cities, requested daily fields, Asia/Dhaka timezone, three days, and ordered recommendation thresholds recorded in README.

## Compilation and test status

- Reviewed the seven Swift source files against official Firebase setup, Auth APIs, and error-code documentation. Reviewed startup order, observable state ownership, listener lifecycle, async loading cleanup, password handling, and root routing. These are source reviews, not compiler or runtime tests.
- Phase 2 local checks passed: one `@main` across seven Swift files; no trailing whitespace in the seven Swift files and three documentation files; `git diff --check` passed. Source searches found no custom credential persistence, suppressed `try` errors, forced casts, emulator calls, or premature Firestore operations. Only normal LF-to-CRLF notices were emitted by Git. These checks do not establish Swift syntax/type correctness or successful authentication.
- No Swift compiler, Apple SDK type checking, `xcodebuild`, automated iOS tests, Simulator, or device run was available. **Build and launch are not verified.** Source inspection is not compilation.
- Registration, login, incorrect credentials, logout, restart/session restoration, UI reaction, validation/error behavior, and account switching: **all live tests pending**. README includes steps and expected results for each. Weather requests and Firestore remain unimplemented and untested.

## Known bugs and limitations

- No runtime bugs can be assessed until the app builds and runs.
- The `.xcodeproj` and iOS app target do not exist yet. The scaffold cannot currently be opened as an app project or launched.
- Resources currently contain only a folder placeholder. The native template's asset catalog must be added during Mac setup.
- Auth source cannot compile until the official Firebase products are added to a real target. No `canImport` fallback or simulated login hides this missing dependency.
- Weather, plan management, city selection, and remaining state wrappers are deferred. Phase 1 was not available and has not been silently re-created.
- Actual Firebase behavior, package compatibility, Swift concurrency compilation, and session restoration require a Mac build and configured runtime tests.

## Manual actions required

Follow README's **Create the native project on a Mac** and **Phase 2 Firebase setup on a Mac** sections:

1. Create the native DhobiGhat iOS App project; include all seven Swift files and the template asset catalog in its app target.
2. Add the official Firebase SPM repository and attach only `FirebaseAuth` and `FirebaseFirestore`. Resolve a stable SDK compatible with your installed Xcode and keep the actual package resolution file.
3. Register the exact Xcode bundle ID as an iOS app in Firebase Console and enable Email/Password authentication.
4. Download the real `GoogleService-Info.plist`, add it to DhobiGhat/Resources with app target membership and bundle inclusion, and verify the bundle ID matches.
5. Add the Boolean app Info key `FirebaseAppDelegateProxyEnabled = NO` as described by official SwiftUI setup.
6. Build/run and execute all README acceptance tests. Record actual results rather than marking tests passed based on source inspection.

Before marking native Phase 0 checks complete, record:

- Xcode version and Swift compiler version.
- Effective `SWIFT_VERSION` and `IPHONEOS_DEPLOYMENT_TARGET`.
- Confirmation that Xcode recognizes `DhobiGhat.xcodeproj` and its DhobiGhat iOS application target/scheme.
- Selected Simulator/device and OS version.
- Resolved Firebase SDK version and the two linked products.
- Build result, launch result, and each live authentication test result, including actual errors.

## Next implementation steps

1. Finish the manual native/SPM/Firebase setup and verification above when a Mac is available.
2. Stop after Phase 2 and wait for the next explicit phase instruction.
3. Before the next phase, inspect existing files and reread this progress record. Keep code beginner-friendly, use the requested MVVM/state ownership, and preserve real working functionality.
