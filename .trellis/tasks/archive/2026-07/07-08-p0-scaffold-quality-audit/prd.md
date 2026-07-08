# P0 Scaffold Quality Audit and Fix

**Priority**: P0 — Template-readiness blocker
**Status**: planning

## Goal

Transform this project from a work-in-progress scaffold into a high-quality personal Flutter scaffold/template for medium-small apps. Fix known quality issues, establish consistent patterns, and adjust specs to reflect the "personal scaffold" vision so every future AI session follows correct patterns.

---

## Background

This project was bootstrapped as a Flutter Clean Architecture app. The user wants it to serve as a **personal scaffold/template** — a clean starting point for their own medium-small Flutter projects. Current code has quality issues (memory leaks, unsafe casts, placeholder content, incorrect DI annotations) that must be fixed before it can serve as a reliable template.

| Decision | Choice |
| ---------- | -------- |
| Demo code | Keep as reference examples, fix quality |
| Extension style | Progressive enhancement — minimal core + docs for adding features |
| Easy rename | Check project name/package name is centralized, not hardcoded everywhere |
| signals ViewModel | Standardize pattern: add `isDisposed` guard + `runAsync` helper to reduce boilerplate |
| UI language | Chinese (UI strings), English (code/comments) — no i18n framework |
| Article body field | Add `body` to Article model |
| Profile placeholder | Generic Chinese template ("用户名" / "个人简介") |
| Existing specs | Adjust (not rewrite) with scaffold vision and known issues |

---

## Requirements

### R1: LoginPage — Fix Memory Leak

**Problem**: `lib/features/auth/page/login_page.dart` is a `StatelessWidget` calling `getIt<AuthViewModel>()` in `build()`. Since `AuthViewModel` is `@injectable` (transient), each rebuild creates a new instance and the old one leaks (effects never disposed).

**File**: `lib/features/auth/page/login_page.dart`

**Fix**:

- Convert to `StatefulWidget`
- Create `AuthViewModel` once in `initState()` via `getIt<AuthViewModel>()`
- Call `_vm.dispose()` in `dispose()`
- Keep the same UI with `Watch.builder`

### R2: ArticleDetailPage — Type-Safe Routing & Real Content

**Problems**:

- `lib/core/routing/app_router.dart` passes `Article` object via `state.extra as dynamic` (unsafe, line ~30)
- `lib/features/article/page/article_detail_page.dart` takes `Article` parameter instead of route ID
- `:id` route parameter is ignored (no deep-link support)
- Page displays Lorem ipsum and hardcoded date instead of real article content
- `Article` model has no `body` field

**Files**: `lib/core/routing/app_router.dart`, `lib/features/article/page/article_detail_page.dart`, `lib/features/article/domain/models/article.dart`

**Fix**:

- Add `String body` field to `Article` model with `@JsonSerializable()` (regenerate `.g.dart`)
- Change `ArticleDetailPage` to receive `int articleId` from route path
- Create `ArticleViewModel` in `initState()`, call `_vm.loadDetail(id)`
- Watch `_vm.selectedArticle` and render real article data (title + body)
- Update router: extract `state.pathParameters['id']` as int, remove `state.extra as dynamic`
- Use `GoRouterStateX.getInt()` ext method from `router_extension.dart` for type-safe parsing

### R3: FileStorage — Fix DI Annotation

**Problem**: `@LazySingleton()` + `@PostConstruct()` — LazySingleton creates the instance lazily but does **not** await PostConstruct, so `_appDir` / `_tempDir` may be accessed before init completes.

**File**: `lib/core/local/file_storage.dart`

**Fix**: Change to `@Singleton(preResolve: true)` so the singleton is eagerly resolved during `getIt.init()` await. Regenerate `lib/di/service_locator.config.dart` via build_runner.

### R4: Systematic Code Review — Audit All `lib/` Files

| Check | Definition |
| ------- | ----------- |
| **ViewModel lifecycle** | Pages using ViewModels must be `StatefulWidget` with `initState` creation + `dispose` cleanup. `StatelessWidget` + `getIt<ViewModel>()` in build = leak. |
| **Unsafe `dynamic` casts** | No `state.extra as dynamic` or any unchecked cast. Route params via `pathParameters` with typed parsing. |
| **DI annotation correctness** | `@injectable` = transient, `@Singleton` = lazy, `@LazySingleton` = lazy, `@Singleton(preResolve: true)` = eager. Must match lifecycle need. |
| **`mounted` checks** | After any `await` in StatefulWidget methods, check `mounted` before accessing `context`/`setState`. |
| **Placeholder content → Chinese** | Replace Lorem ipsum, "John Doe", "UI/UX Designer", hardcoded dates with real content. Profile page → generic Chinese ("用户名" / "个人简介"). |
| **Error handling consistency** | ViewModels use `Result<Success, Failure>` uniformly. Pages handle loading/error/data with unified three-state pattern. |
| **UI language** | All UI strings → Chinese. Code identifiers, comments, error messages → English. No i18n framework. |

Specific audit scope:

| File | Expected issue | Action |
| ------ | --------------- | -------- |
| `lib/shared/view_models/base_view_model.dart` | Missing `isDisposed` guard + boilerplate helper | Add `runAsync` helper + guard |
| `lib/features/auth/page/login_page.dart` | ViewModel lifecycle (R1) | Convert to StatefulWidget |
| `lib/features/article/page/article_detail_page.dart` | Placeholder + type safety (R2) | ViewModel + body field |
| `lib/core/routing/app_router.dart` | Unsafe cast (R2) | Use `pathParameters` |
| `lib/features/profile/page/profile_page.dart` | Placeholder text | Generic Chinese |
| `lib/features/home/page/home_page.dart` | Chinese strings fine | Verify (no change) |
| `lib/features/article/page/article_list_page.dart` | ViewModel lifecycle | Verify (known good) |

**Rename audit**: Also check `pubspec.yaml`, `android/app/build.gradle.kts`, `android/.../AndroidManifest.xml`, `ios/.../Info.plist` for hardcoded app name/package/display name.

### R4d: Easy Rename/Rebrand Check

When starting a new project from this scaffold, the developer should be able to rename the app by changing a minimal set of files. Audit what's currently hardcoded:

| Config | Current location | Status |
| -------- | ----------------- | -------- |
| App class name (`MyApp`) | `lib/main.dart`, `lib/app.dart`, `lib/bootstrap.dart` | 1 place to rename |
| Package name (`my_app`) | `pubspec.yaml` (name field) | Centralized, but import paths auto-generated |
| Application ID | `android/app/build.gradle.kts` (`applicationId`) | 1 place |
| App icon | `pubspec.yaml` (`flutter_launcher_icons`) ✅ | Already configured |
| Display name | `android/.../AndroidManifest.xml`, `ios/.../Info.plist` | Platform-level, need docs |

**Action**: Verify these are indeed centralized. Update spec to include a rename checklist.

### R4e: signals ViewModel Pattern Standardization

Current ViewModel pattern is good but missing two practical helpers:

| Missing | Why | Fix |
|---------|-----|-----|
| `isDisposed` guard | After `await` in a ViewModel method, signal writes should check `disposed` first | Add `bool get isDisposed` (already exists) + make it consistently checked |
| `runAsync` helper | Every ViewModel repeats `loading → await → when(success/failure)` boilerplate | Add lightweight `runAsync<T>(Future<T> Function() call, Signal<AsyncState<T>> into)` helper to `BaseViewModel` |

**Action**:

- Add `runAsync` helper to `BaseViewModel`
- Refactor `ArticleViewModel.load()` and `AuthViewModel.login()` to use it
- Check `disposed` guard after all awaits
- No use case layer added (would be over-engineering)

### R5: Update Spec to "Personal Scaffold" Vision

**Problem**: `.trellis/spec/` files were filled generically based on current code. `AGENTS.md` is bootstrapped Trellis template.

**Action**: Adjust (not rewrite) existing spec files to:

- State the project is a **personal Flutter scaffold/template** for medium-small apps
- Document **intended patterns** (the ideal way to write code in this template), not just current reality
- Call out the **issues fixed by this task** as resolved problems
- Ensure patterns already documented (state management, DI, routing, page lifecycle) reflect the scaffold perspective

**Files**: `.trellis/spec/backend/`, `.trellis/spec/frontend/`, `AGENTS.md`

---

## Acceptance Criteria

- [ ] **R1 — LoginPage**: `StatefulWidget`, VM created in `initState()`, disposed in `dispose()`, UI behavior unchanged
- [ ] **R2 — ArticleDetailPage**: Receives article ID from route path, uses `ArticleViewModel.loadDetail(id)`, renders real article body, no Lorem ipsum. Article model has `body` field.
- [ ] **R2 — Router**: No `state.extra as dynamic` casts, type-safe article ID extraction via `GoRouterStateX.getInt()`
- [ ] **R3 — FileStorage**: Uses `@Singleton(preResolve: true)`, `service_locator.config.dart` regenerated
- [ ] **R4 — No unsafe casts**: Zero `as dynamic` or `as!` without type safety guard
- [ ] **R4 — No placeholder content**: Zero Lorem ipsum, John Doe, hardcoded dates in content. Profile page uses generic Chinese template.
- [ ] **R4 — All ViewModel pages**: All `StatefulWidget` with proper `initState`/`dispose` lifecycle
- [ ] **R4 — `mounted` checks**: Present after async gaps in StatefulWidget methods
- [ ] **R4 — Consistent error handling**: All data flows use `Result<Success, Failure>` uniformly
- [ ] **R4 — Chinese UI**: UI strings are Chinese; code identifiers/comments/errors are English
- [ ] **R4d — Easy rename**: App name, package name, application ID all confirmed centralized; rename checklist in spec
- [ ] **R4e — ViewModel pattern standardized**: `BaseViewModel` has `runAsync` helper + `isDisposed` guard; ViewModels refactored to use them
- [ ] **R5 — Spec files adjusted**: `.trellis/spec/` describes the personal scaffold vision with resolved issues called out
- [ ] **R5 — AGENTS.md**: Reflects the personal scaffold nature of the project
- [ ] **All changes compile**: `flutter analyze` passes with zero errors
- [ ] **build_runner**: Regenerated cleanly after DI/Article model annotation changes

---

## Non-Goals

- Adding new features or screens beyond what exists
- Changing the architecture (signals, ViewModel pattern, go_router stays)
- Production API integration (mock/stub data is fine for a scaffold)
- Full test coverage (there are no existing tests; adding tests is out of scope)
- Adding i18n framework (flutter_localizations / intl)
- Rewriting spec files from scratch (existing content is adjusted in place)
- Adding a use case / UseCase layer (over-engineering for medium-small apps)
- Adding clean_signals package as a dependency (the pattern is informative, but not a dependency)
- Renaming the project itself (just verifying the rename path exists)
