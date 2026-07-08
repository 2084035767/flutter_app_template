# Refactor: Replace runAsync with futureSignal

Leverage signals v7's built-in `futureSignal` to eliminate hand-rolled async management.

## Changes

### BaseViewModel

- Remove `runAsync` helper (replaced by `futureSignal`)
- Remove imports of `Result`/`Failure` (only used by `runAsync`)

### ArticleViewModel

- `articles`: `asyncSignal + load()` → `futureSignal(() => ...)` (auto-loads)
- Remove `currentFailure` signal (AsyncState already carries errors)
- Remove `load()` / `refresh()` (futureSignal has `reload()` built-in)
- Simplify `loadDetail` with disposed guard

### AuthViewModel

- Keep as-is (login/logout are action-triggered, not reactive)
- Already has `disposed` guard

## Acceptance Criteria

- [x] `BaseViewModel.runAsync` removed
- [x] `ArticleViewModel.articles` is `futureSignal`, auto-loads
- [x] Pages updated to use `AsyncState.map()` or equivalent
- [x] `flutter analyze` zero issues
- [x] `flutter test` all pass
