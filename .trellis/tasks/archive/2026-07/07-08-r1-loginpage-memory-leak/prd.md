# R1: LoginPage — Fix Memory Leak

**Parent Task**: P0 Scaffold Quality Audit and Fix
**Priority**: P0

## Goal

Fix a memory leak in `LoginPage` where `AuthViewModel` is re-created on every build.

## Problem

`lib/features/auth/page/login_page.dart` is a `StatelessWidget` calling `getIt<AuthViewModel>()` in `build()`. Since `AuthViewModel` is `@injectable` (transient), each rebuild creates a new instance and the old one leaks (effects never disposed).

## Fix

- Convert to `StatefulWidget`
- Create `AuthViewModel` once in `initState()` via `getIt<AuthViewModel>()`
- Call `_vm.dispose()` in `dispose()`
- Keep the same UI with `Watch.builder`

## Files Changed

- `lib/features/auth/page/login_page.dart`

## Acceptance Criteria

- [x] LoginPage is a `StatefulWidget` (not `StatelessWidget`)
- [x] `AuthViewModel` created once in `initState()`, not in `build()`
- [x] `_vm.dispose()` called in `dispose()`
- [x] UI behavior unchanged (same fields, buttons, loading states)
- [x] `flutter analyze` passes with zero errors
