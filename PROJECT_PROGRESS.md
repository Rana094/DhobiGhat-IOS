# DhobiGhat Project Progress

## Current phase

**Phase 0 - source scaffold and documentation prepared; native Xcode setup and build/run verification pending on a Mac.** Updated 2026-11-20 (Asia/Dhaka).

## Project conventions

- The app name is **DhobiGhat**. Use this name for source folders, app types, display text, future Xcode product/target/scheme names, and documentation.
- Provide one meaningful commit message after every phase. Do not create a commit unless requested.
- Following Phase 0, the source folder, app entry file/type, welcome title, and setup documentation were renamed to DhobiGhat. This was a naming update only; no new phase or feature was started. Source/name and whitespace checks passed; build and launch remain unverified because Xcode and Swift are unavailable here.

The complete pasted master instructions were read before this phase. Initial workspace inspection showed no app files. Git diff review also identified a tracked one-line starter README headed `DhobiGhat-IOS`, which has been expanded for DhobiGhat. No existing `.xcodeproj`, `.xcworkspace`, Swift sources, project settings, progress file, or working functionality existed. No ancestor or workspace `AGENTS.md` instructions were found.

## Completed phases

- Phase 0 automated preparation: minimal source, understandable folders, README, progress record, and viva notes.
- Phase 0 native acceptance checks remain pending; do not treat this as a verified runnable Xcode project.
- No feature phases have started. Await the user's Phase 1 instruction.

## Current project structure and files created

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

README was expanded from Git's starter heading; all other listed files were created in Phase 0. No pre-existing app code was changed or deleted. `.gitkeep` files preserve empty folders in Git. `DhobiGhatApp.swift` contains the single app entry point and shows `RootView`. `RootView.swift` contains a static, native SwiftUI welcome screen. Other source folders are reserved for later phases. No AppDelegate, models, ViewModels, or services are necessary yet.

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

No packages or project generators were installed. No project metadata or Firebase configuration was invented.

## Firebase setup status

- Not implemented, configured, connected, or tested.
- No Firebase SDK packages installed.
- No `GoogleService-Info.plist` supplied.
- No authentication, Firestore access, or security rules deployed.
- Future setup must use the real bundle ID and Console download, official SDK, UID-scoped plan paths, and owner-only rules. README contains the setup outline; perform it only in the relevant phase.

## Weather API status

- Not implemented or called.
- No weather data is shown, including no hardcoded data posing as live weather.
- Later implementation must follow the three supported cities, requested daily fields, Asia/Dhaka timezone, three days, and ordered recommendation thresholds recorded in README.

## Compilation and test status

- Reviewed the two Swift source files for a single `@main`, correct root view name, native SwiftUI imports, and straightforward view structure.
- Local checks passed: all 10 expected scaffold/documentation files exist; there are exactly two Swift files and one `@main` entry point; no trailing whitespace was found in the 10 files. `git diff --check` passed for tracked changes. Git emitted only an LF-to-CRLF conversion notice for README. These are file/content checks, not compiler or runtime tests.
- No Swift compiler, Apple SDK type checking, `xcodebuild`, automated iOS tests, Simulator, or device run was available. **Build and launch are not verified.** Source inspection is not compilation.
- No runtime behavior, Firebase integration, weather requests, or persistence has been tested.

## Known bugs and limitations

- No runtime bugs can be assessed until the app builds and runs.
- The `.xcodeproj` and iOS app target do not exist yet. The scaffold cannot currently be opened as an app project or launched.
- Resources currently contain only a folder placeholder. The native template's asset catalog must be added during Mac setup.
- Authentication, weather, plans, tabs, sheets, and state wrappers are intentionally deferred; there are no working features to remove.

## Manual actions required

Follow README's **Create the native project on a Mac** section. It gives the full sequence for creating an iOS SwiftUI App named DhobiGhat in a temporary directory, bringing its native `.xcodeproj` and generated asset catalog into this repository, checking source membership, setting the deployment target, and building/running the welcome screen.

Before marking native Phase 0 checks complete, record:

- Xcode version and Swift compiler version.
- Effective `SWIFT_VERSION` and `IPHONEOS_DEPLOYMENT_TARGET`.
- Confirmation that Xcode recognizes `DhobiGhat.xcodeproj` and its DhobiGhat iOS application target/scheme.
- Selected Simulator/device and OS version.
- Build result and launch result, including any actual errors.

## Next implementation steps

1. Finish the manual native setup and verification above when a Mac is available.
2. Stop and wait for Phase 1 instructions.
3. Before the next phase, inspect existing files and reread this progress record. Keep code beginner-friendly, use the requested MVVM/state ownership, and preserve real working functionality.
