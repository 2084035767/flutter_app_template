# R4: Systematic Code Review & Audit

**Parent Task**: P0 Scaffold Quality Audit and Fix
**Priority**: P0

## Goal

Audit all `lib/` files for quality issues: ViewModel lifecycle, unsafe casts, DI correctness, `mounted` checks, placeholder content, error handling, UI language. Plus: rename audit and ViewModel pattern standardization.

## Sub-Requirements

### R4a: Profile Page — Replace Placeholder Content

- Replace "John Doe", "JD", "UI/UX Designer", English settings/logout with generic Chinese
- Keep English for code identifiers

### R4b: Verify ArticleListPage ViewModel lifecycle

- Already confirmed good (StatefulWidget with proper initState/dispose). No change needed.

### R4c: Verify HomePage

- StatelessWidget, no ViewModel usage. Already good.

### R4d: Easy Rename/Rebrand Check

- Verify app name, package name, application ID are centralized
- Check platform-level config files

### R4e: signals ViewModel Pattern Standardization

- Add `runAsync` helper to `BaseViewModel`
- Refactor `ArticleViewModel.load()` and `AuthViewModel.login()` to use it
- Check `disposed` guard after all awaits

## Files Changed

- `lib/features/profile/page/profile_page.dart` (R4a)
- `lib/shared/view_models/base_view_model.dart` (R4e)
- `lib/features/article/application/article_view_model.dart` (R4e)
- `lib/features/auth/application/auth_view_model.dart` (R4e)

## Acceptance Criteria

- [x] No `state.extra as dynamic` or other unsafe casts
- [x] No Lorem ipsum, John Doe, hardcoded dates
- [x] Profile page uses generic Chinese template ("用户名" / "个人简介")
- [x] UI strings are Chinese; code identifiers/comments/errors are English
- [x] All ViewModel pages are StatefulWidget with proper lifecycle
- [x] BaseViewModel has `runAsync` helper + `isDisposed` guard
- [x] ViewModels refactored to use `runAsync`
- [x] Rename checklist documented in spec
- [x] `flutter analyze` passes with zero errors
