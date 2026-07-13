# Hook Guidelines

> How hooks (`flutter_hooks`) are used in this project.

---

## Overview

This project uses **`flutter_hooks`** (for lifecycle management in `HookWidget`) and **`signals_hooks`** (for signals integration with hooks).

The primary hook usage is:

- **`useSignalValue`** — Read signal values reactively in widget tree
- **`useMemoized`** — Memoize ViewModel instances across rebuilds
- **`useEffect`** — Trigger data loading on mount

---

## Page Template

All feature pages use the same pattern:

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
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => Text(items[index].title),
        ),
      ),
    );
  }
}
```

**关键点**：

- `useMemoized` 确保 ViewModel 只创建一次（不是每次 build 都重新创建）
- `useSignalValue` 在 Widget 销毁时自动取消订阅（无需手动 dispose）
- `useEffect` 在首次挂载时触发数据加载
- 使用 `Switch()` 三态组件简化 loading / error / data 分支

---

## App Root (MyApp)

```dart
class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final bool isLoggedIn = useSignalValue(config.isLoggedInSignal);
    final router = useMemoized(() => AppRouter(isAuthenticated: isLoggedIn), [
      isLoggedIn,
    ]);

    return MaterialApp.router(
      routerConfig: router.config(),
      theme: FlexThemeData.light(...),
      darkTheme: FlexThemeData.dark(...),
      themeMode: config.currentMode,
    );
  }
}
```

---

## Data Fetching

Data fetching 由 ViewModel 负责，**不在 hook 里执行**：

```
Page (useEffect → vm.load()) → ViewModel (runAsync) → Service → API
```

- **ViewModel** (`logic/`) 调用 `runAsync` 管理 asyncSignal 三态
- **Page** (`HookWidget`) 通过 `useEffect` 触发加载
- **`useSignalValue`** 响应式更新 UI

```dart
// ViewModel
Future<void> load() async {
  await runAsync(articles, () => _repo.getArticles());
}

// Page
useEffect(() {
  vm.load();
  return null;
}, []);
```

---

## Naming Conventions

- **HookWidgets** follow the same naming as regular widgets (PascalCase)
- **Custom hooks** (if needed) follow the `use` prefix convention from `flutter_hooks`
- Signal variables use descriptive names: `articles`, `selectedArticle`, `isLoggedIn`

---

## Common Mistakes

- ❌ **Overusing hooks** — ViewModels handle business logic, hooks only handle widget lifecycle
- ❌ **Missing dependency arrays in `useMemoized`/`useEffect`** — Causes stale closure bugs
- ❌ **Calling hooks conditionally** — All hooks must be called in the same order every build
- ❌ **Creating ViewModel in `build()` without `useMemoized`** — Creates new instance per rebuild, old one leaks
