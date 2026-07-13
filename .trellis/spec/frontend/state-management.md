# State Management

> How state is managed in this project.

---

## Overview

Uses **`signals_flutter`** for reactive state. Signals provide fine-grained reactivity without widget tree rebuilds.

No base ViewModel class — ViewModels are plain `@injectable` classes with public signals. A standalone `runAsync` helper handles the common async tri-state pattern.

**Signals are public, not private.** They don't need `ReadonlySignal` getter wrappers — the convention is that UI reads but does not write signal values directly. State changes go through ViewModel methods. This saves one line of boilerplate per signal with no real safety loss.

---

## State Categories

| Category | Where | Pattern |
| ---------- | ------- | --------- |
| **Async Data** (API results) | `logic/` ViewModels | `asyncSignal<T>(AsyncState.data([]))` |
| **Sync Data** (form inputs) | `logic/` ViewModels | `signal<T>(initialValue)` |
| **Derived State** | ViewModel getters/computed | `computed(() => ...)` or `bool get canSubmit => ...` |
| **Global Config** (theme, auth) | `core/config/` `core/data/storage/` | signal + SharedPreferences |
| **UI-Only State** (animation, scroll) | Local widget state | `setState()` or local `ValueNotifier` |

---

## Pattern: ViewModel + Signals

```dart
@injectable
class ArticleViewModel {
  final ArticleRepository _repo;

  ArticleViewModel(this._repo);

  // 信号直接公开，没有 ReadonlySignal 包装
  final articles = asyncSignal<List<Article>>(AsyncState.data([]));
  final selectedArticle = asyncSignal<Article?>(AsyncState.data(null));

  Future<void> loadArticles() async {
    await runAsync(articles, () => _repo.getArticles());
  }
}
```

### 为什么没有 BaseViewModel

早期版本有 `BaseViewModel`，后来发现：

- ViewModel 之间共享的行为只有 `runAsync` 这一个模式
- 一个顶层函数比一个抽象类更简单，而且不影响 ViewModel 的构造方式
- 不需要 dispose 机制——ViewModels 被 GetIt 管理为 lazysingleton，不存在创建/销毁生命周期

---

## runAsync 使用

```dart
// 旧：每个 ViewModel 手写 7 行样板
_articles.value = AsyncState.loading();
final result = await repo.getArticles();
result.when(
  success: (d) => _articles.value = AsyncState.data(d),
  failure: (f) => _articles.value = AsyncState.error(f.message),
);

// 新：一行
await runAsync(articles, () => repo.getArticles());
```

对于需要返回 Result 给调用方做分支处理的场景：

```dart
Future<Result<void, Failure>> loadDetail(int id) async {
  await runAsync(selectedArticle, () => _repo.getArticle(id));
  if (selectedArticle.value.hasError) {
    return Result.failure(Failure.unknown('加载失败'));
  }
  return const Result.success(null);
}
```

---

## 页面 ↔ ViewModel 生命周期

页面直接通过 `getIt` 获取 ViewModel（ViewModels 是 lazysingleton，无需手动 dispose）：

```dart
@RoutePage()
class ArticleListPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<ArticleViewModel>());

    useEffect(() {
      vm.loadArticles();
      return null;
    }, []);
  }
}
```

---

## 常见错误

| 错误 | 正确做法 |
| --- | --- |
| 在 `build()` 中 `var vm = ArticleViewModel()` | 使用 `getIt` + `useMemoized` |
| 用 `signal` 存 API 数据 | 用 `asyncSignal`（自带 loading/error/data 三态） |
| 在 widget 里直接 `vm.articles.value = x` | ViewModel 通过 method 封装状态变更 |
| 派生状态存成新 signal | 用 `computed()` 或 getter |
| 跨组件共享 feature 状态 | 放到 Global State（core/） |
