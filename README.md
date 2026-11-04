# Pocket Pals

Pocket Pals is a cozy, offline-first virtual companion app. Users choose one pet, care for it throughout the day, earn acorns, and customize its look and room.

## Problem and audience

Pocket Pals is designed for casual mobile users who want a low-pressure daily check-in. The product hypothesis is that a personal companion and small customization rewards make that ritual feel more engaging than a plain checklist. This hypothesis still needs validation with real testers; the app makes no health or wellbeing claims.

## Features

- Choose a capybara, cat, dog, bunny, or fox on first launch.
- Track hunger, happiness, energy, and in-game day. Feed, Play, and Sleep update the pet's needs.
- Needs change over elapsed time, including time spent with the app closed. The current state is restored from local storage.
- Earn 20 acorns on the first care action each day; new profiles start with 120 acorns.
- Buy headwear, neck accessories, and room themes in the in-game shop. Owned items can be equipped and are saved locally.
- Chat with the pet offline. Replies are preset, keyword-based responses; this is not generative AI. Recent chat messages are stored locally.
- Schedule local care reminders when the app goes to the background and cancel them when the app resumes.
- Rename the companion and toggle time-based need changes in Settings.

## Tech stack

- Flutter and Dart
- Riverpod (`AsyncNotifier`) for reactive app state
- `shared_preferences` for local persistence
- `flutter_local_notifications`, `flutter_timezone`, and `timezone` for local reminders
- Material widgets and Flutter animations

## Architecture

```text
lib/
├── main.dart
├── models/       # Pet state, species, cosmetic catalogue, chat messages
├── providers/    # PetNotifier and app lifecycle coordination
├── screens/      # Home, pet selection, shop, chat, settings
├── services/     # Storage, notifications, offline chat replies
├── themes/       # Colors and app theme
└── widgets/      # Companion avatar and reusable UI
```

The UI watches `petProvider` and sends user actions to `PetNotifier`. The notifier owns game rules and persistence calls; storage, reminder scheduling, and offline chat replies are isolated behind services.

## Requirements

- Flutter SDK with Dart `^3.13.4` compatibility
- Android Studio for Android development
- macOS with Xcode and CocoaPods for iOS development

## Run locally

```bash
git clone git@github.com:Num1s/Pocket-Pals.git
cd Pocket-Pals
flutter doctor -v
flutter pub get
flutter run
```

Choose a target device if more than one is connected:

```bash
flutter devices
flutter run -d <device-id>
```

The app may request notification permission on first launch. You can test the core pet, shop, and chat flows without an account or network connection.

## Build

Android release APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

iOS archive and IPA:

```bash
flutter build ipa --release
```

Before building for TestFlight, set a unique iOS Bundle Identifier and Apple Developer Team in Xcode, create the matching App Store Connect app record, and increment the build number in `pubspec.yaml`.

## Team

| Participant | Suggested role | Focus |
|---|---|---|
| Нурбол | Flutter Developer / Integration Lead | Flutter screens, Riverpod state, local game logic and persistence, cosmetics shop, offline chat, and notification integration |

The role is assigned from the current app stack and the participant list; confirm it against the team's actual contribution history.

## Scope and limitations

- A single pet profile is stored on the current device. There is no sign-in or cross-device cloud sync.
- Chat uses local preset replies, not an AI model or remote AI service.
- Acorns and cosmetics are demo game mechanics; there are no real-money purchases.
- The Android release configuration currently uses the debug signing key. Configure a private release keystore before publishing through Google Play.
- The existing widget test still targets the retired starter UI and should be updated before treating `flutter test` as a quality gate.

## Validation

User validation has not yet been documented in this repository. Add real participant counts, task outcomes, and consented anonymized quotes after running usability sessions; do not report placeholder numbers as results.
