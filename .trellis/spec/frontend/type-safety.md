# Type Safety

> Type safety patterns in this project.

> **Scaffold note**: This is a personal Flutter scaffold/template for medium-small apps. The type-safety patterns below (sealed Result, JsonSerializable models, route param extensions) are the standard for all features built from this scaffold.

---

## Overview

This project is written in **Dart 3+** with full **null safety** enabled. Type safety is enforced through:

- **Sealed classes** (`sealed class`) for exhaustive pattern matching
- **`@JsonSerializable()`** for typed JSON serialization/deserialization
- **`freezed_annotation`** available for complex data classes
- **Strict linter rules** including `always_declare_return_types`, `type_annotate_public_apis`
- **Generic Result type** `Result<T, E>` for typed error handling

---

## Type Organization

### Models (per feature, in `data/models/`)

```dart
@JsonSerializable()
class Article {
  final int id;
  final String title;
  final String body;

  Article({required this.id, required this.title, required this.body});

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
```

**Rules**:

- Model files end with `.dart` and have a `.g.dart` companion (generated)
- All fields are `final` and non-nullable (unless explicitly nullable)
- Constructors use `required` named parameters
- `@JsonSerializable()` is the standard annotation
- For complex models (copyWith, equality), use `@freezed`

### Global types (`core/base/`)

```dart
sealed class Result<T, E> { ... }  // Generic result type
sealed class Failure { ... }        // Error hierarchy
```

### Generated types

- `*.g.dart` — JSON serialization, injectable, retrofit code generation
- `*.freezed.dart` — Freezed-generated copyWith / == / hashCode
- `*.config.dart` — injectable service locator
- `lib/gen/assets.gen.dart` — Asset references (flutter_gen)
- Never edit generated files manually

---

## Validation

Runtime validation follows **primitive validation at the boundary** pattern:

```dart
// Login validation in ViewModel
bool get canSubmit => email.value.isNotEmpty && password.value.length >= 6;

// API validation — handled by backend
@POST('/login')
Future<User> login(@Query('email') String email, @Query('pwd') String pwd);
```

- Client-side: Simple field validation in ViewModel computed getters
- Server-side: All complex validation delegated to the backend
- No schema validation library (no Zod equivalent) — use Dart type system

---

## Common Patterns

### Sealed class pattern matching

```dart
result.when(
  success: (user) => context.router.replace(const HomeRoute()),
  failure: (error) => _showError(context, error.message),
);
```

### Signal state checking

```dart
final async = useSignalValue(vm.articles);
if (async.isLoading) return const LoadingIndicator();
if (async.hasError) return ErrorText(error: async.error!);
final data = async.value!; // Safe after checking loading + error
```

### Exhaustive type preservation

- **Always** annotate return types on public methods (`always_declare_return_types`)
- **Always** annotate overrides (`annotate_overrides`)
- Use `final` for locals where the value doesn't change (`prefer_final_locals`)
- Let Dart infer local variable types where obvious (`omit_local_variable_types`)

---

## Forbidden Patterns

- ❌ **`dynamic` type** — Use typed generics or `Object?` instead
- ❌ **`as` casts without null checks** — Use pattern matching or `is` checks
- ❌ **Raw `Map<String, dynamic>` as API response** — Always deserialize into typed models
- ❌ **`print()` for debugging** — Use `Logging.debug()` or `Logging.error()`
- ❌ **Manually written `fromJson`/`toJson`** — Use `@JsonSerializable()` code generation
- ❌ **`!` null assertions without prior null check** — Use pattern matching or early returns
