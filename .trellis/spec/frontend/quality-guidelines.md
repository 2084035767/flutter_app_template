# Quality Guidelines

> Code quality standards for this project.

---

## Resolved Quality Issues

- ✅ **LoginPage ViewModel lifetime** — Converted from StatelessWidget to StatefulWidget/HookWidget with proper `getIt<AuthViewModel>()` in `initState`.
- ✅ **`runAsync` helper** — Added to core/base for standardizing loading → data/error flow.
- ✅ **Disposed guards** — `runAsync` accepts optional `disposed` signal to avoid updating after dispose.
- ✅ **Global error boundary** — `bootstrap.dart` wraps app in `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError`.
- ✅ **Auth lifecycle** — `AuthStorage` now properly initialized via DI. `AuthInterceptor` handles 401 auto-logout.
- ✅ **Dynamic route guard** — `AppRouter` rebuilds on auth state change via signal listener.

---

## Forbidden Patterns

❌ **Never use these patterns**:

1. **`print()` in production code** — Use `Logging.info()` / `Logging.error()` instead.

2. **Hardcoded colors/fonts/padding** — Always use `Theme.of(context)` or `colorScheme`.

3. **Business logic in widgets** — All async operations belong in ViewModels or Services.

4. **Direct ViewModel instantiation** — Always `getIt<ArticleViewModel>()`.

5. **ViewModel creation in `build()`** — Creates new instance per rebuild, old one leaks. Use `getIt` + `useMemoized`.

6. **`setState()` for async/API data** — Use `asyncSignal` for data fetching.

7. **Unguarded async callbacks** — Button `onPressed` callbacks must be wrapped (use `Future.microtask` or try-catch).

8. **`withOpacity()`** — Use `Color.withValues(alpha: X)` (Dart 3+).

9. **`getIt()` in ViewModels** — ViewModels must use constructor injection. The `avoid_getit_in_view_model` lint rule enforces this.

10. **Feature imports another feature's page/ or logic/** — Only core/ and other feature's data/ are allowed. The `avoid_feature_cross_import` lint rule enforces this.

---

## Required Patterns

✅ **Always use these patterns**:

1. **Three-state rendering in every async page**:

   ```dart
   if (async.isLoading) return const LoadingIndicator();
   if (async.hasError) return ErrorText(error: ..., onRetry: ...);
   if (data.isEmpty) return EmptyWidget(message: '暂无数据');
   return ListView.builder(...); // Data view
   ```

2. **`runAsync` for async operations**:

   ```dart
   await runAsync(_articles, () => _repo.getArticles());
   ```

3. **`Theme.of(context)` at start of build**:

   ```dart
   final theme = Theme.of(context);
   ```

4. **`const` constructors** for all widgets.

5. **`useSignalValue` for hook-based signal consumption**:

   ```dart
   final async = useSignalValue(vm.articles);
   ```

---

## Error Handling Hierarchy

```
runZonedGuarded         → 未捕获的 zone 异常（兜底）
  └─ FlutterError.onError       → Flutter 框架错误
  └─ PlatformDispatcher         → 平台层异步错误
  └─ AuthInterceptor.onError    → 401 自动登出
  └─ Result<_, Failure>         → 业务层错误（类型安全）
  └─ runAsync                   → ViewModel 层错误统一处理
```

- 所有 API 调用返回 `Result<T, Failure>`（业务层不抛异常）
- 所有 ViewModel 用 `runAsync` 处理 async 三态
- 401 由 `AuthInterceptor` 自动处理（清除 auth + 触发 UI 重建）
- 以上都漏掉的由 `runZonedGuarded` 兜底并记日志

---

---

## Custom Lint Rules (`my_app_lint`)

该项目有两条自定义 lint 规则，通过 `analysis_server_plugin` 加载。

| 规则 | 效果 | 配置位置 |
|------|------|----------|
| `avoid_getit_in_view_model` | 禁止在 `features/*/logic/` 中使用 `getIt()`，强制构造器注入 | `analysis_options.yaml` → `plugins.my_app_lint.diagnostics` |
| `avoid_feature_cross_import` | 禁止 feature 引用其他 feature 的 `page/` 或 `logic/`，强制 FSD 层约束 | 同上 |

### 工作原理

- 规则通过 `analysis_server_plugin` 框架加载（与 `signals_lint` 相同机制）
- **IDE 中生效**（VS Code / IntelliJ 等使用 analysis server 的编辑器）
- CLI `flutter analyze` / `dart analyze` **不会触发**这些规则（这是 `analysis_server_plugin` 架构的限制，与 `signals_lint` 一致）
- 规则定义在 `packages/my_app_lint/` 独立包中

### 禁止模式

```dart
// ❌ avoid_getit_in_view_model — ViewModel 里不能用 getIt()
class ArticleViewModel {
  final repo = getIt<ArticleRepository>();
}

// ✅ 正确：构造器注入
class ArticleViewModel {
  final ArticleRepository repo;
  ArticleViewModel(this.repo);
}
```

```dart
// ❌ avoid_feature_cross_import — 不能引用其他 feature 的 page/logic
import 'package:my_app/features/auth/page/login_page.dart';
import 'package:my_app/features/auth/logic/auth_view_model.dart';

// ✅ 允许：引用 core 或其他 feature 的 data 层
import 'package:my_app/features/auth/data/models/user.dart';
import 'package:my_app/core/routing/app_router.dart';
```

---

---

## Memory Leak Detection (`leak_tracker`)

`leak_tracker` 已集成到脚手架中，用于开发期自动检测内存泄漏。

### 运行期检测（debug 模式）

在 `bootstrap.dart` 中通过 `_initLeakTracker()` 初始化，debug 模式下自动启用：

- 监听 `FlutterMemoryAllocations` 事件（Flutter 框架对象的创建/销毁）
- 在控制台输出未释放的对象信息
- release 模式下不生效（`assert` 块仅在 debug 模式执行）

### 测试检测

`test/flutter_test_config.dart` 配置了全局泄漏检测：

- 所有 `testWidgets` 自动启用 `LeakTesting`
- 测试中未 dispose 的 Widget、Controller、信号订阅等会被报告
- 通过 `withIgnored(createdByTestHelpers: true)` 过滤测试辅助创建的对象

### 检测范围

`leak_tracker` 只能检测到**已接入埋点**的类。好消息是：

- Flutter Framework 的所有 disposable 类都已接入（`FocusNode`、`AnimationController` 等）
- `SignalBuilder` 等 signals_flutter 组件在 `dispose` 时会自动取消订阅
- 如果一个泄漏链中包含至少一个已埋点的对象，整个链都会被捕获

---

## Integration Testing

`integration_test/app_test.dart` 包含基础的端到端冒烟测试。

### 本地运行

```bash
flutter test integration_test/
```

### CI 运行

CI 使用 `xvfb-run`（虚拟显示）运行集成测试。

### 测试内容

当前集成测试覆盖：

- 应用正常启动并显示登录页面
- 输入邮箱和密码后登录按钮启用
- 空字段时登录按钮禁用

> 注意：集成测试依赖 `msw_dio_interceptor`（`NetworkConfig.isMock = true`）提供的 mock API。

---

## Testing Requirements

- 测试文件路径跟随源码结构：`test/features/{feature}/{subdir}/` 对应 `lib/features/{feature}/{subdir}/`
- ViewModel 测试直接构造，无需 DI（`ArticleViewModel(mockRepo)`）
- 需要 DI 的 widget 测试：`setUp`/`tearDown` 中注册/清理 mock
- Integration tests: `integration_test/` 目录
- 新增 widget 测试时确保 `flutter_test_config.dart` 中的 `LeakTesting` 配置合适
