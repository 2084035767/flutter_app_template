# R2: ArticleDetailPage — Type-Safe Routing & Real Content

**Parent Task**: P0 Scaffold Quality Audit and Fix
**Priority**: P0

## Goal

Fix type-unsafe routing, add `body` field to Article model, and replace Lorem ipsum with real article data.

## Problems

1. Router passes `Article` via `state.extra as dynamic` (unsafe)
2. `ArticleDetailPage` takes `Article` parameter instead of route ID
3. `:id` route parameter ignored (no deep-link support)
4. Page displays Lorem ipsum and hardcoded date instead of real content
5. `Article` model has no `body` field

## Fix

- Add `String body` field to `Article` model
- Regenerate `article.g.dart` via build_runner
- Change `ArticleDetailPage` to receive `int articleId` from route path
- Convert to `StatefulWidget` with `ArticleViewModel` created in `initState()`
- Watch `_vm.selectedArticle` and render real article data (title + body)
- Update router: extract `state.pathParameters['id']` via `GoRouterStateX.getInt()`
- Update `ArticleListPage` to navigate via path params instead of extra

## Files Changed

- `lib/features/article/domain/models/article.dart`
- `lib/features/article/page/article_detail_page.dart`
- `lib/core/routing/app_router.dart`
- `lib/features/article/page/article_list_page.dart` (navigation fix)

## Acceptance Criteria

- [x] Article model has `body` field + regenerated `.g.dart`
- [x] ArticleDetailPage receives article ID from route path
- [x] ArticleDetailPage uses `ArticleViewModel.loadDetail(id)` in `initState()`
- [x] Page renders real article body (no Lorem ipsum)
- [x] No `state.extra as dynamic` cast in router
- [x] ArticleListPage navigates with path params only
- [x] `flutter analyze` passes with zero errors
- [x] build_runner regenerates cleanly
