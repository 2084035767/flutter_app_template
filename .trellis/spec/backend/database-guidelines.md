# Database Guidelines

> Database patterns and conventions for this project.

> **Scaffold note**: This is a personal Flutter scaffold/template for medium-small apps. There is no SQLite/ORM layer. Local persistence is intentionally lightweight: SharedPreferences for key-value data, FileStorage for binary/text data. Add a database layer only when the target app clearly needs it.

---

## Overview

This project uses **local storage** rather than a relational database. Data persistence is handled via:

- **`shared_preferences`** — Key-value store for user preferences, settings, auth tokens
- **`flutter_secure_storage`** — Secure storage for sensitive data (available in pubspec, not yet used in code)
- **`FileStorage`** (`lib/core/local/file_storage.dart`) — File-based storage for documents, cached data, images

There is **no SQLite/ORM layer** currently. If database access is needed in the future, prefer a non-blocking solution compatible with Flutter's architecture.

---

## Storage Patterns

### SharedPreferences (Key-Value)

Used via `UserPreferences` and `AuthStorage` classes that wrap `SharedPreferences` with reactive signals.

```dart
@Singleton()
class UserPreferences {
  late final SharedPreferences _prefs;

  final themeMode = signal<ThemeMode>(ThemeMode.system);
  final apiTimeout = signal<int>(30);

  @PostConstruct()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
  }
  ...
}
```

**Key naming convention**: `app.{domain}.{key}` — e.g., `app.theme.mode`, `app.api.timeout`, `auth.token`

- Always use constants for key strings (`static const String _keyX = '...'`)
- Prefer `@PostConstruct` for async initialization over constructor work

### FileStorage

For larger binary or text data:

```dart
@LazySingleton()
class FileStorage {
  Future<bool> saveString(String filename, String content, {bool useTemp = false});
  Future<String?> readString(String filename, {bool useTemp = false});
  Future<bool> saveBytes(String filename, Uint8List bytes, {bool useTemp = false});
  Future<bool> delete(String filename, {bool useTemp = false});
  Future<bool> clearTemp();
  Future<int> getUsage({bool includeTemp = false});
}
```

- Use `appDirectory` for persistent data, `tempDirectory` for temporary cache
- All operations catch errors and return `bool` success/failure

### AuthStorage

Wraps `SharedPreferences` for authentication data:

```dart
@Singleton()
class AuthStorage {
  final currentUser = signal<User?>(null);

  Future<void> saveUser(User? user);
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> clearAuth();
  bool get isLoggedIn;
}
```

---

## Query Patterns

Not applicable — no database/ORM in current architecture. API queries go through Retrofit (`@GET`, `@POST`, etc.) defined in feature-level `*_api.dart` files.

---

## Migrations

Not applicable — no local database schema. Data format changes in `SharedPreferences` are handled with version-safe migration logic (checking for key existence) or by clearing old keys.

---

## Naming Conventions

| Element | Convention | Example |
| --------- | ----------- | --------- |
| SharedPrefs key | `app.{domain}.{key}` | `auth.token`, `app.theme.mode` |
| FileStorage filename | Any valid filename string | `'user_avatar.png'` |
| Secure storage key | Same pattern as SharedPrefs | (future use) |

---

## Common Mistakes

- ❌ **Calling `SharedPreferences.getInstance()` in multiple places** — Use the pre-resolved singleton from `CoreModule`
- ❌ **Blocking the UI thread with synchronous file I/O** — `FileStorage` uses `await` for all operations
- ❌ **Storing sensitive data in `SharedPreferences`** — Use `flutter_secure_storage` for tokens and credentials
- ❌ **Not handling `SharedPreferences` init failures** — The `@preResolve` pattern in `CoreModule` handles this; always use it
