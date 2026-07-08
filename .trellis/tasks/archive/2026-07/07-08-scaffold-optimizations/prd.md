# P0/P1 Scaffold Optimizations

## Goal

Complete remaining code quality optimizations identified after the P0 audit, prioritized by impact.

## P0 Items

### P0-1: Add Testing Infrastructure (Scaffold Reference)

- Add `dart_add_test` / `flutter_add_widget_test` pattern as reference tests
- 1 unit test for `BaseViewModel.runAsync` helper
- 1 widget test for `LoginPage` (basic rendering + lifecycle verification)
- Provide `test/` directory structure and `pubspec.yaml` test dependencies example
- Update spec with testing patterns

### P0-2: ArticleDetailPage mounted Guard

- Add `if (!mounted) return;` after `_vm.loadDetail(widget.articleId)` in `_ArticleDetailPageState`

### P0-3: ArticleListPage unused return value

- `refresh()` returns `Result<void, Failure>` but caller ignores it
- Change `refresh()` to `Future<void>` or suppress unused-result warning

## P1 Items (after P0)

### P1-1: route_constants.dart missing article-detail path

- Add `static const articleDetail = '/articles/:id';` to `RoutePaths`
- Add `static const articleDetail = 'article-detail';` to `RouteNames`
- Update `app_router.dart` to use constants

## Files Changed

- `test/` (new)
- `lib/features/article/page/article_detail_page.dart`
- `lib/features/article/page/article_list_page.dart`
- `lib/core/routing/route_constants.dart`
- `lib/core/routing/app_router.dart`
