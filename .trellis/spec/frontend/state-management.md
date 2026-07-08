# State Management

> How state is managed in this project (as a personal Flutter scaffold).

---

## Overview

This project uses **`signals_flutter`** as the primary state management solution. Signals provide a reactive, fine-grained reactivity model that integrates naturally with Flutter's widget tree via `Watch.builder`.

This is a **personal scaffold/template** for medium-small apps. The patterns below are the intended way to write features; they do not require a use-case layer (over-engineering for this scope).

---

## Scaffold: State Categories

| Category | Where | Pattern |
| ---------- | ------- | --------- |
| **Async Data** (API results) | `application/` ViewModels | `asyncSignal<T>(AsyncState.loading())` |
| **Sync Data** (form inputs, flags) | `application/` ViewModels | `signal<T>(initialValue)` |
| **Derived State** (computed) | ViewModel getters | `bool get canSubmit => email.isNotEmpty && password.length >= 6` |
| **Global Config** (theme, auth) | `core/` services | `signal<T>()` with persistent backing (`SharedPreferences`) |
| **UI-Only State** (animation, scroll pos) | Local StatefulWidget state | `setState()` or local `ValueNotifier` |

---

## Pattern: ViewModel + Signals

Every feature has a ViewModel extending `BaseViewModel`:

```dart
@injectable
class ArticleViewModel extends BaseViewModel {
  final ArticleRepository _repo;

  ArticleViewModel(this._repo) { _initEffects(); }

  // Async state
  final articles = asyncSignal<List<Article>>(AsyncState.loading());

  // Sync state
  final currentFailure = signal<Failure?>(null);

  // Computed getters
  bool get isLoadingList => articles.value.isLoading;
  bool get hasListError => articles.value.hasError || currentFailure.value != null;

  // Actions using runAsync helper
  Future<Result<void, Failure>> load() async {
    final failure = await runAsync(
      () => _repo.getArticles(),
      into: articles,
      failInto: currentFailure,
    );
    if (failure != null) return Result.failure(failure);
    return const Result.success(null);
  }

  // Effects (auto-disposed)
  void _initEffects() {
    addEffect(() {
      final state = articles.value;
      if (state.hasValue) debugPrint('Loaded: ${state.value?.length} items');
    });
  }
}
```

### BaseViewModel lifecycle (with runAsync)

```dart
abstract class BaseViewModel {
  final List<VoidCallback> _disposables = [];
  bool _disposed = false;

  bool get disposed => _disposed;
  bool get isDisposed => _disposed;

  @protected
  void addEffect(void Function() effectFn, {void Function()? onDispose}) {
    _disposables.add(effect(effectFn, onDispose: onDispose));
  }

  /// Standard loading → data/error flow helper.
  /// Sets [into] to loading, awaits [call], checks disposed guard,
  /// then updates [into] and [failInto] based on Result.
  @protected
  Future<Failure?> runAsync<T>(
    Future<Result<T, Failure>> Function() call, {
    required Signal<AsyncState<T>> into,
    Signal<Failure?>? failInto,
  }) async {
    if (disposed) return Failure.unknown('ViewModel已释放');
    into.value = AsyncState.loading();
    failInto?.value = null;

    final result = await call();
    if (disposed) return Failure.unknown('ViewModel已释放');

    return result.when(
      success: (data) {
        into.value = AsyncState.data(data);
        return null;
      },
      failure: (failure) {
        into.value = AsyncState.error(failure.message);
        failInto?.value = failure;
        return failure;
      },
    );
  }

  @mustCallSuper
  void dispose() {
    if (_disposed) return;
    for (final disposable in _disposables) disposable();
    _disposables.clear();
    _disposed = true;
  }
}
```

### Page ↔ ViewModel lifecycle contract

Pages that use ViewModels **must** be `StatefulWidget` with proper lifecycle:

```dart
class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});
  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late final ArticleViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<ArticleViewModel>();
    _vm.load(); // trigger initial data fetch
  }

  @override
  Widget build(BuildContext context) {
    // Watch.builder for reactivity
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
```

**Do NOT** create ViewModels in `build()` — that causes memory leaks (each rebuild creates a new instance, old effects never dispose). This was a resolved issue from the P0 audit (July 2026).

---

## When to Use Global State

Use global signals (in `core/` services) for:

| State | Service | Example |
| ------- | --------- | --------- |
| Theme mode | `UserPreferences` | `themeMode.value` |
| Auth status | `AuthStorage` | `currentUser.value` |
| API timeout | `UserPreferences` | `apiTimeout.value` |
| Debug logging | `UserPreferences` | `enableDebugLogging.value` |
| App config | `AppConfig` | Facade combining preferences + auth |

**Keep global state minimal**. Feature-specific state stays in the ViewModel.

---

## Server State

Server state is managed through the **Repository pattern**:

1. **ViewModel** calls `repo.getArticles()`
2. **Service** calls the API via Retrofit
3. **Result** is returned as `Result<T, Failure>`
4. **ViewModel** updates the signal (loading → data or error)

No client-side cache layer is implemented yet. For new features:

- Use the same ViewModel pattern for direct API access
- Add pagination via `defaultPageSize` from `UserPreferences`

---

## Common Mistakes

- ❌ **Creating ViewModel in `build()` method** — Creates new instance per rebuild, old one leaks
- ❌ **Putting async state in plain `signal`** — Use `asyncSignal` for API data (handles loading/error/data states)
- ❌ **Mutating state directly outside ViewModel** — Never do `vm.articles.value = ...` from a widget
- ❌ **Not calling `addEffect()` for side effects** — Effects must be registered via ViewModel, not in widget build methods
- ❌ **Forgetting to call `vm.dispose()` in page's `dispose()`** — Causes memory leaks (P0 fix applied)
- ❌ **Using `setState()` for async data** — Use Signals; `setState()` is for truly local UI state only
- ❌ **Storing derived state in signals** — Use computed getters instead: `bool get canSubmit => ...`
- ❌ **Not checking `disposed` after await** — Always guard mutable state access after async gaps
