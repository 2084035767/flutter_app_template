# Flutter 通用脚手架

一个基于 Flutter 的中小型项目脚手架，采用 **Feature-Sliced Design (FSD)** 架构 + **Signals** 响应式状态管理，集成现代化技术栈，开箱即用。

## ✨ 特性

- **FSD 功能切片** — 按业务模块组织代码（page/logic/data），高内聚低耦合
- **Signals 响应式状态** — 细粒度响应式更新，无需 BuildContext，无 widget 树级重建
- **声明式路由** — `auto_route` 类型安全路由，支持 auth 守卫和参数解析
- **依赖注入** — `injectable` + `GetIt`，注解驱动自动注册
- **网络层封装** — `Dio` + `Retrofit` + 智能重试 + Mock 拦截
- **错误处理** — 统一的 `Result<T, E>` + `Failure` 密封类，`runZonedGuarded` 兜底
- **MD3 主题** — `flex_color_scheme`，亮/暗主题完整支持
- **通用组件** — Loading / Error / Empty 三态组件，`shimmer` 骨架屏
- **代码生成** — `freezed` / `json_serializable` / `retrofit_generator` / `flutter_gen`
- **自定义 lint 规则** — `avoid_getit_in_view_model` + `avoid_feature_cross_import`（FSD 约束）
- **数据库** — `Drift`（SQLite ORM，可选按需使用）
- **测试基础设施** — `mocktail` 模拟，已含 ViewModel / Widget / 数据库测试

## 🛠️ 技术栈

| 类别 | 技术 |
| ------ | ------ |
| 状态管理 | `signals_flutter` `signals_hooks` `flutter_hooks` |
| 路由 | `auto_route` |
| 依赖注入 | `get_it` `injectable` |
| 网络 | `dio` `dio_smart_retry` `retrofit` `pretty_dio_logger` |
| Mock API | `msw_dio_interceptor` |
| 数据库 | `drift` `sqlite3_flutter_libs` |
| 本地存储 | `shared_preferences` `path_provider` |
| 代码生成 | `freezed` `json_serializable` `build_runner` `flutter_gen` |
| 主题 | `flex_color_scheme` |
| UI 辅助 | `lottie` `flutter_svg` `shimmer` |
| 日志 | `logger` |
| 静态分析 | `flutter_lints` `signals_lint` + 自定义 `my_app_lint` |
| 测试 | `flutter_test` `mocktail` |

## 📁 目录结构

```
lib/
├── main.dart                               # 程序入口
├── bootstrap.dart                          # 启动初始化（zone + DI）
├── app.dart                                # 应用根组件（路由 + 主题）
│
├── core/                                   # 共享基础设施（精简克制）
│   ├── base/                               # 基础抽象
│   │   ├── result.dart                     # Result<T, E> 统一结果类型
│   │   ├── failure.dart                    # Failure 密封类
│   │   └── run_async.dart                  # runAsync 三态助手
│   ├── config/                             # 应用配置
│   │   └── app_config.dart                 # AppConfig（主题模式等）
│   ├── data/
│   │   ├── database/                       # Drift 数据库连接
│   │   ├── network/                        # Dio 客户端 + 拦截器
│   │   └── storage/                        # 本地持久化信号
│   ├── logging/                            # 日志封装
│   ├── presentation/                       # 通用 UI 组件
│   │   └── widgets/
│   │       ├── loading_indicator.dart      # Lottie 加载动画
│   │       ├── error_text.dart             # 错误 + 重试
│   │       └── empty_widget.dart           # 空状态
│   └── routing/                            # auto_route 配置
│
├── features/                               # 业务功能模块
│   ├── auth/                               # 认证（示例模块）
│   │   ├── logic/                          # ViewModel（信号 + 业务逻辑）
│   │   ├── data/                           # API + Service + Models
│   │   └── page/                           # UI 页面
│   ├── article/                            # 文章（示例模块）
│   ├── home/                               # 首页
│   └── profile/                            # 个人中心
│
└── di/                                     # 依赖注入注册
    └── service_locator.config.dart          # injectable 自动生成
```

模块内部每层职责：

| 层 | 目录 | 职责 |
| ---- | ------ | ------ |
| **UI** | `page/` | 页面组件，获取 ViewModel，绑定信号 |
| **Logic** | `logic/` | ViewModel，信号管理，业务编排 |
| **Data** | `data/` | API (Retrofit)，Service，Models (freezed) |

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.38.0
- Dart SDK >= 3.9.2

```bash
# 安装依赖
flutter pub get

# 代码生成（首次运行必须执行）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run

# 代码分析
flutter analyze

# 运行测试
flutter test
```

### 从脚手架创建新项目

```bash
# 交互式初始化
dart run tool/init_project.dart
```

也可参照 [AGENTS.md](AGENTS.md) 手动操作。

## 📖 示例代码说明

脚手架自带两个完整示例模块，开箱即用（无需后端）：

| 模块 | 路径 | 演示内容 |
|------|------|----------|
| 认证 | `lib/features/auth/` | 登录 → 存储 token → 个人中心读取用户信息 |
| 文章 | `lib/features/article/` | 列表页 → 详情页，Retrofit API + 加载三态 |

- **开箱即用**：`NetworkConfig.isMock` 默认 `true`，由 `msw_dio_interceptor` 拦截请求（Mock 规则见 `lib/core/data/network/dio_client.dart` 的 `_registerMockRules()`），无需后端即可跑通完整数据流。接入真实后端时改为 `false` 即可
- **学习路径**：`flutter run` 跑起来 → 从 `page/`（UI）→ `logic/`（ViewModel）→ `data/`（API / Service / Model）逐层阅读，新功能模块照此结构复制
- **删除示例**：确认了解结构后，删除 `lib/features/auth/` 与 `lib/features/article/` 两个目录，并同步清理：
  1. `lib/core/routing/router.dart` 中的对应路由与 `@RoutePage` 注解
  2. `lib/core/data/network/dio_client.dart` 中 `_registerMockRules()` 的对应 Mock 规则
  3. `lib/features/home/page/main_page.dart` 底部导航中的文章 Tab
  4. `lib/features/profile/page/profile_page.dart` 中对 `AuthViewModel` / `User` 的引用
  5. 最后执行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 DI 注册

## 📐 如何添加新功能模块

### 目录模板

```
features/your_feature/
├── logic/
│   └── your_view_model.dart           # ViewModel（信号 + runAsync）
├── data/
│   ├── models/                        # 数据模型（freezed/json_serializable）
│   ├── your_api.dart                  # Retrofit API 接口（可选）
│   ├── your_service.dart              # 业务实现
│   └── your_repository.dart           # 仓库抽象接口（按需）
└── page/
    └── your_page.dart                 # UI 页面
```

### ViewModel 模板

```dart
@injectable
class YourViewModel {
  final YourService _service;

  YourViewModel(this._service);

  final items = asyncSignal<List<Item>>(AsyncState.data([]));

  Future<void> load() async {
    await runAsync(items, () => _service.getItems());
  }
}
```

### 页面模板

```dart
@RoutePage()
class YourPage extends HookWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<YourViewModel>());
    final async = useSignalValue(vm.items);

    useEffect(() {
      vm.load();
      return null;
    }, []);

    return Scaffold(
      body: Switch(
        async,
        loading: () => const LoadingIndicator(),
        error: (e) => ErrorText(error: e, onRetry: vm.load),
        data: (items) => ListView.builder(/* ... */),
      ),
    );
  }
}
```

## 🧪 测试

```bash
# 全部测试
flutter test

# 特定测试文件
flutter test test/features/article/logic/article_view_model_test.dart

# 覆盖率（需要安装 coverage 包）
dart run coverage:test_with_coverage
```

测试原则：

- ViewModel 测试直接构造，无需 DI：`ArticleViewModel(mockRepo)`
- 使用 `mocktail` 模拟外部依赖
- widget 测试使用 `tester.pumpWidget` + `SignalBuilder`

## 🔍 自定义 lint 规则

两条自定义规则，在 IDE 中实时生效：

| 规则 | 说明 |
|------|------|
| `avoid_getit_in_view_model` | 禁止 ViewModel 中使用 `getIt()`，强制构造器注入 |
| `avoid_feature_cross_import` | 禁止 feature 引用其他 feature 的 `page/` / `logic/` |

> 规则通过 `analysis_server_plugin` 框架加载（与 `signals_lint` 相同机制），在 VS Code / IntelliJ 中生效。CLI `flutter analyze` 暂不覆盖。

## 🔧 开发工具

- **`tool/init_project.dart`** — 交互式项目初始化（改名字、包名等）
- **`.githooks/pre-commit`** — 提交前自动运行 `flutter analyze` + `flutter test`。安装：`git config core.hooksPath .githooks`
- **`msw_dio_interceptor`** — 开发期 API Mock 拦截器

## 🎨 架构原则

### 数据流

```
Page (UI) → ViewModel → Service → API (Retrofit)
                ↕              ↕
            signals         Result<T, Failure>
                ↕
          Widget rebuild
```

- **View Model**：通过构造器注入依赖，管理信号，调用 `runAsync` 处理异步三态
- **Service**：业务逻辑实现，返回 `Result<T, Failure>`
- **Page**：通过 `getIt` 获取 ViewModel，用 `useSignalValue` 绑定信号，不写业务逻辑

### Feature 间通信

- 跨 feature 数据共享通过 `core/data/storage/` 中的全局信号
- 不使用事件总线（调试困难）
- 不引用其他 feature 的 `page/` 或 `logic/`（lint 规则强制）

## 📄 许可证

MIT
