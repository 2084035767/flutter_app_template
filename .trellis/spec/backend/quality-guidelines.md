# Quality Guidelines

> Code quality standards for backend (data layer) development.

---

## Overview

These guidelines apply to the data layer — all code under `lib/core/`, `lib/features/*/data/`, `lib/features/*/domain/`, and `lib/shared/`.

---

## Forbidden Patterns

❌ **Never use these patterns**:

1. **Bare `try/catch` without `Result` type on public APIs** — All fallible repository/service methods must return `Result<T, Failure>`

   ```dart
   // BAD
   Future<List<Article>> getArticles() async { ... }

   // GOOD
   Future<Result<List<Article>, Failure>> getArticles() async { ... }
   ```

2. **`print()` in production code** — Use `Logging.info()`, `Logging.debug()`, etc. The linter enforces `avoid_print`.

3. **Raw `DioException` propagation to ViewModel** — Convert to typed `Failure` in the Service layer

   ```dart
   // BAD
   throw e;  // Letting DioException escape

   // GOOD
   return Result.failure(Failure.fromApiError(handleError(e)));
   ```

4. **Cyclic imports between features** — Features should never import from other features

   ```dart
   // BAD
   import 'package:my_app/features/auth/domain/models/user.dart';  // in article feature
   ```

5. **Business logic in data layer classes** — Services only convert API to domain; ViewModels handle business logic

   ```dart
   // BAD in Service
   if (articles.isEmpty) { /* business decision */ }

   // GOOD in ViewModel
   ```

6. **`getOrThrow` in production code** — Only use in tests; use `when()` for exhaustive matching

   ```dart
   // BAD
   final user = result.getOrThrow;  // throws StateError on failure
   ```

---

## Required Patterns

✅ **Always use these patterns**:

1. **`Result<T, Failure>`** for all fallible operations in Repository interfaces and Service implementations

2. **Service class annotation**: `@LazySingleton(as: SomeRepository)` — register as singleton via interface

3. **DI Modules** for providing third-party/API dependencies:

   ```dart
   @module
   abstract class ArticleModule {
     @LazySingleton()
     ArticleApi articleApi(Dio dio) => ArticleApi(dio);
   }
   ```

4. **Repository pattern**: Always define an abstract `{Feature}Repository` in `domain/` with `Future<Result<T, Failure>>` return types, then implement as `{Feature}Service` in `data/`

5. **Sealed Failure subtypes**: Use the factory constructors (`Failure.network()`, `.auth()`, `.server()`, `.unknown()`) — never instantiate subclasses directly

6. **Private fields prefixed with `_`**: Always prefix private class fields with `_`

7. **Documentation comments on public APIs**: Use `///` doc comments on all repository methods and public service methods — include what the method does, `Result` variants, and error conditions

---

## Testing Requirements

- **Unit tests required for**:
  - All Repository interfaces should have corresponding mock tests
  - ViewModel state transitions (loading → data, loading → error)
  - Failure path testing via `Result.failure()` mocks

- **Test file location**: `test/features/{feature}/`

- **Testing libraries**: `flutter_test` (included in `pubspec.yaml`)

---

## Code Review Checklist

When reviewing data layer code, check:

- [ ] Does the method return `Result<T, Failure>` instead of bare exceptions?
- [ ] Are all `DioException`s caught and converted via `handleError()`?
- [ ] Is the `catch` ordering correct? (Specific → Generic)
- [ ] Are DI annotations correct? (`@LazySingleton`, `@Singleton`, `@module`)
- [ ] Is the model properly annotated with `@JsonSerializable()`?
- [ ] Are generated files (`*.g.dart`) regenerated after model changes?
- [ ] Are there no imports from other features?
- [ ] Does the module class only provide dependencies (no business logic)?
- [ ] Are debug prints avoided in production paths?
