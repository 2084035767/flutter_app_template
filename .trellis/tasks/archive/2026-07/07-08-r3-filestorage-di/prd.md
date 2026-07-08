# R3: FileStorage — Fix DI Annotation

**Parent Task**: P0 Scaffold Quality Audit and Fix
**Priority**: P0

## Goal

Fix incorrect DI annotation on `FileStorage` where `@LazySingleton()` + `@PostConstruct()` doesn't await async initialization, causing `_appDir` / `_tempDir` to potentially be accessed before init completes.

## Problem

`@LazySingleton()` creates the instance lazily but its `@PostConstruct()` method is not awaited during GetIt's `init()` phase — the factory itself awaits init, but lazy resolution means it may be accessed synchronously before the factory fires.

## Fix

Change to `@Singleton(preResolve: true)` so the singleton is eagerly resolved during `getIt.init()` await. Regenerate `service_locator.config.dart` via build_runner.

## Files Changed

- `lib/core/local/file_storage.dart`
- `lib/di/service_locator.config.dart` (regenerated)

## Acceptance Criteria

- [x] `FileStorage` uses `@Singleton(preResolve: true)` instead of `@LazySingleton()`
- [x] `service_locator.config.dart` regenerated with correct annotation
- [x] `flutter analyze` passes with zero errors
