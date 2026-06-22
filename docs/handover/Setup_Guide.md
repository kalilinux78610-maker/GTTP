# GTTP Setup Guide

This document is intended for onboarding new developers to the GTTP Mobile Application repository.

## 1. System Requirements
- **OS:** macOS (for iOS builds) or Windows/Linux (for Android builds)
- **Flutter SDK:** Version 3.10.8 or higher
- **Dart SDK:** Included with Flutter
- **IDEs:** VS Code, Android Studio, or IntelliJ IDEA

## 2. Environment Configuration
The project strictly isolates sensitive configuration variables. 

1. Create a file named `.env` in the root of the project.
2. Add the following lines:
   ```env
   API_BASE_URL=https://gttp.efsouls.com/api
   ```
*(Note: If you are setting up a local staging server, point `API_BASE_URL` to your local IP address, e.g., `http://192.168.1.5:8000/api`)*

## 3. Building and Running
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run the application on an emulator or connected device:
   ```bash
   flutter run
   ```

## 4. Code Generation
This project utilizes `Riverpod` (mostly without code-gen for simpler parts) and `Freezed`/`JsonSerializable` for robust data models. 
If you modify any model classes in `lib/features/**/data/models/`, run the build runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 5. Architectural Guidelines
If you are adding a new feature, please conform to the **Feature-First Architecture**:
1. Create a new folder under `lib/features/<new_feature>/`.
2. Inside, create three subfolders: `data/`, `domain/`, and `presentation/`.
3. Ensure UI widgets in `presentation/screens/` use `ConsumerWidget` or `ConsumerStatefulWidget` to interact with `providers`.
4. Never make API calls directly from the UI. Route them through the feature's repository located in the `data/` layer.
