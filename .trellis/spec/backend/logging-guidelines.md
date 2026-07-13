# Logging Guidelines

> How logging is done in this project.

---

## Overview

This project uses the **`logger`** package with a custom `Logging` facade class. All logging goes through `Logging.info()`, `Logging.error()`, `Logging.debug()`, and `Logging.warning()` — never call the `logger` package directly or use `print()`.

---

## Log Levels

### `Logging.info(String message)`

- **When to use**: Normal application flow events — user actions, page transitions, data loaded
- **Example**: `Logging.info('User logged in: ${user.name}')`

### `Logging.error(String message, {Object? exception, StackTrace? stackTrace})`

- **When to use**: Operations that failed unexpectedly — API errors, unhandled states
- **Example**: `Logging.error('Failed to load articles', exception: e, stackTrace: stackTrace)`

### `Logging.debug(String message)`

- **When to use**: Development-time debugging — state changes, computed values, temporary diagnostics
- **Example**: `Logging.debug('ViewModel state: ${state}')`

### `Logging.warning(String message)`

- **When to use**: Recoverable issues, deprecated usage, unusual conditions that aren't errors
- **Example**: `Logging.warning('API returned empty response, using cache')`

---

## Logger Configuration

Configured in `lib/core/utils/logging.dart`:

```dart
class Logging {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,       // Don't show method calls for info/warning
      errorMethodCount: 8,  // Show stack trace depth for errors
      lineLength: 120,       // Line width
      colors: true,          // Colored output
      printEmojis: true,     // Emoji prefixes
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  ...
}
```

---

## Structured Logging

- **Log format**: `[TIME] [EMOJI] [MESSAGE]`
- Error logs include exception and stack trace for debugging
- Not using JSON structured logging (this is a mobile/desktop client)

---

## What to Log

- **Data fetching results**: success/failure counts
- **User authentication**: login, logout events
- **ViewModel lifecycle**: `dispose()` calls
- **API errors**: captured via `DioException` → `Failure` conversion
- **Form input changes**: `Logging.debug()` in development only

### Examples from codebase

```dart
// ViewModel effects
addEffect(() {
  final state = articles.value;
  if (state.hasValue) {
    debugPrint('文章列表已加载：${state.value?.length} 篇');
  } else if (state.hasError) {
    debugPrint('文章列表加载错误：${state.error}');
  }
});

// ViewModel disposal
debugPrint('ArticleViewModel 已释放');
```

> **Note**: The codebase currently uses `debugPrint()` in ViewModel effects. For new code, prefer `Logging.debug()` for consistency.

---

## What NOT to Log

🚫 **Never log**:

- User passwords or authentication tokens
- Full API request/response bodies containing PII
- Credit card numbers, national IDs, or sensitive personal data
- Device-specific identifiers without anonymization

✅ **Do log**:

- User actions (without PII data)
- API endpoint paths (without request body)
- Error messages (without user credentials)
- Performance metrics
- Feature usage statistics (anonymized)
