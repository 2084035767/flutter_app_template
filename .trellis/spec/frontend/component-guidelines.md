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

## Component Structure

### Standard page template

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
    _vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ... Watch.builder for reactive updates
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
```

### Stateless page template (when no mutable state needed)

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

**Design tokens** are defined in `lib/core/theme/theme_constants.dart` as `DesignTokens`:

- Use `DesignTokens.primary`, `DesignTokens.surface`, etc. for theme-level references
- Use `DesignTokens.radius(RadiusSize.sm)`, `DesignTokens.spacing(Spacing.md)` for consistent values
- `AppThemeExtension` for custom theme properties not covered by `ColorScheme`

---

## Shared Widgets

Three core shared widgets in `lib/core/presentation/widgets/`:

| Widget | Purpose | Props |
| -------- | --------- | ------- |
| `LoadingIndicator` | Full-screen loading | `size`, `color` (uses Lottie animation) |
| `ErrorText` | Error with retry | `error`, `onRetry?`, `icon?` |
| `EmptyWidget` | Empty state placeholder | `message`, `icon?`, `actionLabel?`, `onAction?` |

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
- ❌ **Not checking `mounted` after async operations** — Always guard `if (!mounted) return;`
- ❌ **Forgetting to dispose ViewModels** — Call `_vm.dispose()` in `State.dispose()`
