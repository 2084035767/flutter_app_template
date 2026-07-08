# Error Handling

> How errors are handled in this project.

> **Scaffold note**: This is a personal Flutter scaffold/template. The typed Result pattern is the standard for all fallible operations across data and application layers. The `Failure` hierarchy and `handleDioError()` utility are intended patterns for all new features.

---

## Overview

This project uses a **typed Result pattern** instead of bare exceptions for all fallible operations. Every operation that can fail returns `Result<T, Failure>` — a sealed class with `Ok(T data)` or `Err(E error)` variants. This ensures **type-safe error handling** at every layer.

---

## Error Types

### Result Type (`core/error/result.dart`)

```dart
sealed class Result<T, E> {
  const Result();

  const factory Result.success(T data) = Ok<T, E>;
  const factory Result.failure(E error) = Err<T, E>;

  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  });

  bool get isSuccess => this is Ok<T, E>;
  bool get isFailure => this is Err<T, E>;
}
```

**Always use `Result.when()`** for exhaustive pattern matching. Never check `isSuccess`/`isFailure` manually.

### Failure Hierarchy (`core/error/failure.dart`)

```dart
sealed class Failure implements Exception {
  final String message;

  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
```

| Failure Type | When to Use | Example |
| ------------- | ------------- | --------- |
| `NetworkFailure` | Connection issues, timeouts | "请求超时", "网络连接失败" |
| `AuthFailure` | Auth errors (401, 403) | "未授权，请登录", "禁止访问" |
| `ServerFailure` | Server-side errors (404, 500) | "资源不存在", "服务器错误" |
| `UnknownFailure` | Anything not covered above | Catch-all for unexpected errors |

### Dio Error Handling (`core/error/failure.dart`)

The `handleDioError()` function converts `DioException` to the appropriate `Failure` subtype automatically — used in every Service layer.

```dart
Failure handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const Failure.network('请求超时');
    case DioExceptionType.connectionError:
      return const Failure.network('网络连接失败');
    case DioExceptionType.badResponse:
      // Routes to auth/server errors based on status code
      ...
    case DioExceptionType.cancel:
      return const Failure.unknown('请求已取消');
    default:
      return Failure.unknown(e.message ?? '未知错误');
  }
}
```

---

## Error Handling Patterns

### Service layer (data → domain boundary)

```dart
@LazySingleton(as: ArticleRepository)
class ArticleService implements ArticleRepository {
  @override
  Future<Result<List<Article>, Failure>> getArticles() async {
    try {
      final articles = await _api.getArticles();
      return Result.success(articles);
    } on DioException catch (e) {
      final apiError = handleError(e); // Convert to Failure
      return Result.failure(Failure.fromApiError(apiError));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
```

**Pattern rules**:

1. Catch `DioException` first (most specific)
2. Convert via `handleError()` to typed `Failure`
3. Catch generic `Exception` as `Failure.unknown()`
4. Never re-throw; always return `Result.failure()`

### ViewModel layer (application → domain boundary)

```dart
Future<Result<void, Failure>> load() async {
  articles.value = AsyncState.loading();
  currentFailure.value = null;

  final result = await _repo.getArticles();

  return result.when(
    success: (data) {
      articles.value = AsyncState.data(data);
      return const Result.success(null);
    },
    failure: (failure) {
      articles.value = AsyncState.error(failure.message);
      currentFailure.value = failure;
      return Result.failure(failure);
    },
  );
}
```

**Always store the failure separately** (`currentFailure`) so the UI can display context-aware error states alongside the async state.

---

## API Error Responses

Not applicable — this is a Flutter client project. API error mapping is handled in `handleDioError()` based on HTTP status codes.

---

## Common Mistakes

- ❌ **Throwing exceptions from Service/Repository** — Always return `Result.failure()` instead
- ❌ **Using `getOrThrow` in production code** — Only use in tests; use `when()` in production
- ❌ **Catching only `Exception` without `DioException` first** — Catches `DioException` too, but loses typed error info
- ❌ **Not handling cancellation** — Always include `DioExceptionType.cancel` in switch
- ❌ **Returning `Failure.unknown()` without a meaningful message** — Always include context (`e.toString()` or specific description)
