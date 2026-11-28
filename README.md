# DhobiGhat

**A smart laundry-day planner for iOS, built with SwiftUI.**

DhobiGhat helps you choose when to wash and dry clothes using three-day weather forecasts. Sign in, select a city, compare drying recommendations, and manage your personal laundry schedule.

## Features

- Email and password registration, login, and logout with Firebase Authentication.
- Three-day Open-Meteo forecasts for Khulna, Dhaka, and Chattogram.
- Maximum temperature, rain probability, precipitation, and maximum wind speed.
- Color-coded drying recommendations: Good, Risky, Avoid, or Unavailable.
- Laundry plans with a selected date and optional note.
- Saved plans with Pending/Completed status, completion actions, and deletion.
- Remembered city selection and user-specific Firestore storage.
- Loading indicators, retry controls, and useful error messages.

## Requirements

- A Mac with Xcode compatible with the selected Firebase Apple SDK release.
- An iOS 17 or later deployment target and a supported Simulator or iPhone.
- A Firebase project with Email/Password Authentication and Cloud Firestore.
- Internet access for forecasts and server reads/writes.

This repository contains Swift source files and tests. An Xcode project and your own Firebase configuration must be added before running the app. An Xcode build and live Firebase integration have not yet been verified.

## Installation

### 1. Create the Xcode project

1. Clone or download this repository onto a Mac.
2. In Xcode, select **File > New > Project > iOS > App**. Use product name **DhobiGhat**, interface **SwiftUI**, language **Swift**, and storage **None**. Enter your own organization identifier.
3. Create the template in a temporary location outside this repository to avoid overwriting the existing source folder. Close the template project.
4. Copy the generated `DhobiGhat.xcodeproj` into this repository's root. Copy the generated `Assets.xcassets` into `DhobiGhat/Resources/`. Keep the repository's existing app source instead of the template's `DhobiGhatApp.swift` and `ContentView.swift`.
5. Open the copied project. Confirm Xcode discovers all Swift files under `DhobiGhat/`. For traditional groups, remove missing template references using **Remove Reference**, then use **Add Files to DhobiGhat** to reference the existing source folders in place and select the app target. Avoid duplicate source entries.
6. Set the app target's minimum deployment to **iOS 17.0**, or a newer supported minimum required by your toolchain. There must be one app entry point: `DhobiGhatApp`.

### 2. Add Firebase dependencies

In Xcode, select **File > Add Package Dependencies** and enter the official repository:

[Firebase Apple SDK](https://github.com/firebase/firebase-ios-sdk)

Choose a compatible stable release and add these products to the **DhobiGhat** app target:

- `FirebaseAuth`
- `FirebaseFirestore`

`FirebaseCore`, used for initialization, is included through the SDK dependencies. Keep the generated package resolution file with the Xcode project.

### 3. Configure Firebase

1. Open [Firebase Console](https://console.firebase.google.com/) and create or select your project.
2. Register an **iOS app** using the exact Bundle Identifier from the DhobiGhat Xcode target.
3. Download the real `GoogleService-Info.plist`. Keep its filename unchanged and add it to `DhobiGhat/Resources/` through Xcode, with **DhobiGhat target membership** and bundle resource inclusion.
4. Under **Authentication > Sign-in method**, enable **Email/Password**.
5. Create a **Cloud Firestore Native/Standard database** with the default database ID.
6. Open the database's **Rules** tab, install the policy in [firestore.rules](firestore.rules), and select **Publish**. If the Firebase project serves other applications, integrate the policy with their existing rules. Remove any overlapping allow-all rule that would bypass ownership checks.
7. Following the Firebase SwiftUI setup, add the Boolean `FirebaseAppDelegateProxyEnabled` property with value **NO** to the app target's **Info** settings. This belongs in app configuration, not the Firebase plist.

The app configures Firebase through `AppDelegate` before using Authentication. A missing or mismatched plist displays setup instructions.

### 4. Run

Select the **DhobiGhat** scheme and an iPhone Simulator, then choose **Product > Build** and **Product > Run**. For a physical iPhone, configure your development team and signing in Xcode.

See the official [Firebase setup guide](https://firebase.google.com/docs/ios/setup) for SDK/toolchain compatibility and configuration details.

## Using the app

1. **Create an account or log in** with your email and password.
2. In **Weather**, select a city and wait for its forecast. Check the displayed dates and measurements; use Refresh or Retry when needed.
3. Tap a forecast card to select a laundry date. **Plan Laundry** opens the form with that city and date.
4. Add an optional note and select **Save plan**. After server confirmation, the app opens **My Plans**.
5. In **My Plans**, mark a plan completed or delete it after confirmation. Use Refresh to retrieve the latest list.
6. In **Profile**, view your email and selected city, or log out.

The selected city is remembered across launches. Saved plans are scoped to the authenticated user's Firebase UID.

## Drying recommendations

Rules are evaluated in the following order:

| Recommendation | Conditions |
| --- | --- |
| **Avoid** — red | Rain probability at least 60%, or precipitation at least 3 mm |
| **Risky** — orange | If Avoid does not apply: rain probability at least 30%, precipitation at least 1 mm, or wind at least 30 km/h |
| **Good** — green | None of the above conditions applies |
| **Unavailable** | A required measurement is missing or invalid |

These are basic project-defined guidelines, not guaranteed drying predictions. Forecast dates use `Asia/Dhaka`; measurement units are °C, %, mm, and km/h.

## Data storage and connectivity

Firestore documents use this structure:

```text
users/{userUID}/plans/{planID}
  city: String
  date: String (yyyy-MM-dd)
  note: String
  isCompleted: Bool
  createdAt: Timestamp
```

The supplied rules require the authenticated UID to match the document path. Reads are one-time server fetches; successful writes refresh the displayed list. Passwords are not stored by the app in Firestore or UserDefaults.

Firestore writes can remain pending while offline. **Cancel closes the form but cannot retract an already-submitted write.** Reconnect and check the saved list before submitting another plan. Verify current forecast dates and the complete authentication/storage flow on your configured device before relying on the app.

## Project structure

```text
DhobiGhat/
  App/          App entry point and Firebase initialization
  Models/       City, forecast, recommendation, and laundry-plan data
  ViewModels/   Observable authentication, weather, and plan state
  Views/        SwiftUI screens and reusable weather cards
  Services/     Open-Meteo requests and Firestore operations
  Resources/    Asset catalog and Firebase configuration
Tests/          XCTest coverage for parsing, rules, and model validation
firestore.rules Firestore access policy
```

The app uses simple MVVM with `ObservableObject` and `@Published`, native SwiftUI controls, `URLSession`, and `JSONDecoder`. It does not require a separate backend or location permissions.

## Testing

Create an **iOS Unit Testing Bundle** named **DhobiGhatTests** with DhobiGhat as its host application. Add the three Swift files under `Tests/` to the test target only. Link the existing `FirebaseFirestore` package product to the test target if needed for its Timestamp fixtures.

Run **Product > Test** to execute the 21 prepared XCTest methods covering:

- Request parameters and safe weather JSON decoding.
- Drying examples, exact thresholds, and unavailable inputs.
- Firestore dictionary mapping and strict calendar dates.

These fixture tests do not verify live Firebase access rules. Separately test registration/login/logout, session restoration, each city, save/retrieve/complete/delete, account separation, permission errors, offline states, and small-screen layouts on a configured Simulator or device. In Firebase Rules Playground, confirm that another UID and an unauthenticated request cannot access a user's plan path. The tests have not yet been executed in Xcode.

## Weather data

Forecasts are provided by [Open-Meteo](https://open-meteo.com/). See its [forecast API documentation](https://open-meteo.com/en/docs) for the requested daily measurements.
