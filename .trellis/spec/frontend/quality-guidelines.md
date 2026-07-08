# Quality Guidelines

> Code quality standards for frontend (UI layer) development.

---

## Overview

These guidelines apply to the UI layer — all code under `lib/features/*/page/`, `lib/core/presentation/`, `lib/app.dart`, etc.

This is a **personal Flutter scaffold/template** for medium-small apps. Quality standards here reflect what you'd want in a reliable starting point.

---

## Scaffold: Resolved Quality Issues (P0 Audit, July 2026)

The following issues were identified and fixed during the initial quality audit.
**Do not reintroduce them in new features built from this scaffold:**

- ✅ **LoginPage ViewModel lifetime** — Previously a StatelessWidget calling `getIt<AuthViewModel>()` in `build()`. Fixed: StatefulWidget with `initState`/`dispose`.
- ✅ **ArticleDetailPage unsafe casting** — Previously used `state.extra as dynamic`. Fixed: path parameter parsing via `GoRouterStateX.getInt()`.
- ✅ **Article model missing body field** — Added `String body` for full article content.
- ✅ **FileStorage DI annotation** — Changed from `@LazySingleton()` to `@Singleton()` for eager registration.
- ✅ **Profile page placeholders** — Replaced English placeholders with generic Chinese template.
- ✅ **Missing `disposed` guards** — All async ViewModel methods now check `isDisposed` after await.
- ✅ **ViewModel boilerplate** — Added `runAsync` helper to BaseViewModel to standardize loading/data/error flow.

---

## Forbidden Patterns

❌ **Never use these patterns**:

1. **`print()` in production code** — Linter enforces `avoid_print`. Use `Logging` class or `debugPrint()` for debug info.

2. **Hardcoded colors, fonts, or padding values** — Always use `Theme.of(context)`, `colorScheme`, or `DesignTokens`

   ```dart
   // BAD
   Text('hello', style: TextStyle(fontSize: 18, color: Colors.blue));

   // GOOD
   Text('hello', style: theme.textTheme.titleLarge?.copyWith(
     color: theme.colorScheme.primary,
   ));
   ```

3. **Business logic in widgets** — All async operations and state mutations belong in ViewModels

   ```dart
   // BAD
   ElevatedButton(
     onPressed: () async {
       final result = await api.login(email, password);  // ❌ API call in widget
     },
   )

   // GOOD
   ElevatedButton(
     onPressed: () => vm.login().then(...)  // ViewModel handles the call
   )
   ```

4. **Direct ViewModel instantiation** — Always use `getIt<ArticleViewModel>()` from DI

   ```dart
   // BAD
   final vm = ArticleViewModel(repo);

   // GOOD
   final vm = getIt<ArticleViewModel>();
   ```

5. **ViewModel creation in `build()` method** — Creates new instance on every rebuild, old one leaks. Create in `initState()`.

6. **`setState()` for API/async data** — Use Signals (`asyncSignal`) for async state; `setState()` is for truly local UI state only

7. **Missing `const` constructors** — Linter enforces `prefer_const_constructors`; always use `const` for widgets

8. **`state.extra as dynamic` in routing** — Always extract route params via `GoRouterStateX.getInt()` / `getString()` from pathParameters

9. **`withOpacity()`/`Opacity` widget** — Use `Color.withValues(alpha: X)` instead (Dart 3+ API)

---

## Required Patterns

✅ **Always use these patterns**:

1. **`Watch.builder` for signals reactivity**:

   ```dart
   Watch.builder(
     builder: (context) {
       final async = _vm.articles.value;
       if (async.isLoading) return const LoadingIndicator();
       ...
     },
   )
   ```

2. **ViewModel lifecycle management**:

   ```dart
   @override
   void initState() {
     super.initState();
     _vm = getIt<ArticleViewModel>();
     _vm.load();
   }

   @override
   void dispose() {
     _vm.dispose();
     super.dispose();
   }
   ```

3. **Three-state rendering pattern** in every page with async data:

   ```dart
   if (async.isLoading) return const LoadingIndicator();
   if (_vm.hasError) return ErrorText(error: ..., onRetry: ...);
   if (data.isEmpty) return EmptyWidget(message: '暂无数据');
   return ListView.builder(...); // Data view
   ```

4. **`mounted` check after async gaps** in StatefulWidget methods:

   ```dart
   final result = await someAsyncOp();
   if (!mounted) return;
   // safe to use context / setState here
   ```

5. **`disposed` guard after async gaps** in ViewModel methods:

   ```dart
   final result = await _repo.getArticles();
   if (disposed) return;
   // safe to update signals here
   ```

6. **`runAsync` helper** for standard loading → data/error flow in ViewModels:

   ```dart
   final failure = await runAsync(
     () => _repo.getArticles(),
     into: articles,
     failInto: currentFailure,
   );
   ```

7. **`const` for childless constructors** and `const` for stateless widgets

8. **`Theme.of(context)` at the start of build methods**:

   ```dart
   @override
   Widget build(BuildContext context) {
     final theme = Theme.of(context);
     // use theme throughout
   }
   ```

9. **Type-safe routing** — Always use `GoRouterStateX.getInt('id')` for route params, never `state.extra as dynamic`

---

## Code Review Checklist

When reviewing frontend code, check:

- [ ] Are ViewModels created in `initState()` (not `build()`)?
- [ ] Are ViewModels properly disposed in `dispose()`?
- [ ] Is `disposed` checked after async operations in ViewModels?
- [ ] Is `mounted` checked after async operations in StatefulWidgets?
- [ ] Are colors/fonts using `Theme.of(context)` instead of hardcoded values?
- [ ] Is the three-state pattern followed (loading → error/empty → data)?
- [ ] Is business logic in ViewModel, not in widget build methods?
- [ ] Are `const` constructors used where possible?
- [ ] Are DI services accessed via `getIt<>()` not direct instantiation?
- [ ] Are route params type-safe (no `as dynamic` casts)?
- [ ] Are assets referenced via `Assets.xxx` (generated) not string paths?
- [ ] Are imports clean (no unused imports)?
- [ ] Is `print()` avoided (using `Logging` or `debugPrint` instead)?
