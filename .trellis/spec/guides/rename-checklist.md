# Rename Checklist

> How to rename this scaffold when starting a new project.

## Overview

This scaffold has several names spread across configuration files. When creating a new project from this template, update all of the following:

---

## Files to Update

| # | File | Field | Example Change |
| --- | ------ | ------- | ---------------- |
| 1 | `pubspec.yaml` | `name:` | `my_app` → `your_app` |
| 2 | `lib/app.dart` | Class `MyApp` | Rename class + constructor |
| 3 | `lib/bootstrap.dart` | `runApp(const MyApp())` | Update class reference |
| 4 | `android/app/build.gradle.kts` | `applicationId` | `com.example.flutter_app` → `com.yourcompany.yourapp` |
| 5 | `android/app/src/main/AndroidManifest.xml` | `android:label` | `flutter_app` → `Your App` |
| 6 | `ios/Runner/Info.plist` | `CFBundleDisplayName` | `Flutter App` → `Your App` |

---

## After Renaming

1. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate DI configs and model serializers (package name changes affect import paths in generated code)
2. Run `flutter clean` then `flutter pub get`
3. Run `flutter analyze` to verify no import path issues
4. Update app icons if needed (already configured via `flutter_launcher_icons` in pubspec.yaml)

---

## Notes

- The **application ID** (`com.example.flutter_app`) uniquely identifies your app on the device and in stores. Change it before the first release.
- The **package name** in `pubspec.yaml` affects Dart import paths. Generated files (`*.g.dart`, `service_locator.config.dart`) auto-update via build_runner.
- The **display name** (`CFBundleDisplayName` / `android:label`) is what users see under the app icon.
- App class name (`MyApp`) appears only in `lib/app.dart` and `lib/bootstrap.dart` — 2 locations.
