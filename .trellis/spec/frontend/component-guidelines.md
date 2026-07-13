# Component Guidelines

> How components (widgets) are built in this project.

> **Scaffold note**: This is a personal Flutter scaffold/template. Component patterns below are examples to build upon — adapt them as needed for specific apps.

---

## Overview

This is a **Flutter project using Material Design 3** (Material You). Widgets follow standard Flutter patterns with a focus on:

- **Composition** over custom painting
- **const constructors** wherever possible
- **Theme-based styling** (no hardcoded colors/fonts)
- **Responsive layouts** with `LayoutBuilder`
- **Lottie animations** for loading states

---

## Page Structure

### 标准页面（带 ViewModel）

```dart
@RoutePage()
class ArticleListPage extends HookWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<ArticleViewModel>());
    final async = useSignalValue(vm.articles);

    useEffect(() {
      vm.loadArticles();
      return null;
    }, []);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('文章列表')),
      body: Switch(
        async,
        loading: () => const LoadingIndicator(),
        error: (e) => ErrorText(error: e, onRetry: vm.loadArticles),
        data: (items) => ListView.builder(/* ... */),
      ),
    );
  }
}
```

### 无状态页面（无需 ViewModel）

```dart
class ArticleDetailPage extends StatelessWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) { ... }
}
```

---

## Props Conventions

- **Data**: Pass via `required` named parameters in constructor
- **Callbacks**: Named params with `VoidCallback?` for optional actions
- **Options**: Named params with sensible defaults

```dart
class ErrorText extends StatelessWidget {
  const ErrorText({
    super.key,
    required this.error,          // Required data
    this.onRetry,                 // Optional callback
    this.icon,                    // Optional customization
  });

  final Object error;
  final VoidCallback? onRetry;
  final IconData? icon;
}
```

---

## Styling Patterns

**Never hardcode colors or typography**. Always use `Theme.of(context)`:

```dart
// GOOD
Text(
  article.title,
  style: theme.textTheme.titleLarge,
),
Text(
  '点击阅读更多...',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
  ),
),

// BAD
Text(article.title, style: TextStyle(fontSize: 18, color: Colors.black)),
```

**Theme extensions** are defined in `lib/core/config/theme_extension.dart`:

- Use `FlexThemeData.light/dark` for full MD3 theme building
- Use `AppThemeExtension` for custom theme properties not covered by `ColorScheme`
- Never reference hardcoded color values

---

## Shared Widgets

Three core shared widgets in `lib/core/presentation/widgets/`:

| Widget | Purpose | Props |
| -------- | --------- | ------- |
| `LoadingIndicator` | Full-screen loading | `size`, `color` (uses Lottie animation) |
| `ErrorText` | Error with retry | `error`, `onRetry?`, `icon?` |
| `EmptyWidget` | Empty state placeholder | `message`, `icon?`, `actionLabel?`, `onAction?` |

---

## Three-State Rendering

所有异步页面遵循统一的三态渲染模式：

```dart
// 使用 Switch 组件（推荐
Switch(
  async,
  loading: () => const LoadingIndicator(),
  error: (e) => ErrorText(error: e, onRetry: retry),
  data: (items) => ListView.builder(...),
)

// 或手动分支
if (async.isLoading) return const LoadingIndicator();
if (async.hasError) return ErrorText(error: ..., onRetry: ...);
if (async.value!.isEmpty) return const EmptyWidget(message: '暂无数据');
return ListView.builder(...);
```

---

## Accessibility

- Use `Semantics` widget or Material's built-in semantics for custom widgets
- Ensure touch targets are at least 48x48 dp
- Use `Theme.of(context)` colors — respects system high-contrast settings
- Prefer Material Design components for built-in accessibility

---

## Common Mistakes

- ❌ **Hardcoding colors/fonts** — Always use `Theme.of(context)` and `colorScheme`
- ❌ **Not using `const` constructors** — The linter enforces `prefer_const_constructors`
- ❌ **Missing `super.key`** — Always include `super.key` in widget constructors
- ❌ **Business logic in widgets** — Delegate to ViewModel for all state mutations
- ❌ **Creating ViewModel in `build()` without `useMemoized`** — Creates new instance per rebuild
- ❌ **Using `Watch.builder` / `Watch()`** — These are deprecated; use `SignalBuilder` or `useSignalValue`
