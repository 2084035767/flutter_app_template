# Flutter快速开发模板

这是一个基于Flutter的现代化快速开发模板项目，旨在帮助开发者快速构建高质量的Flutter应用程序。该项目集成了最佳实践、常用的架构模式以及精选的技术栈，让你专注于业务逻辑而不是基础设施。

## ✨ 特性

- **清晰的架构**: 采用功能模块化设计，分层清晰（core、features、shared、di）
- **状态管理**: 使用 signals 进行高效的状态管理
- **路由管理**: 集成 go_router 实现声明式导航
- **依赖注入**: 使用 get_it 和 injectable 实现依赖注入
- **网络请求**: 基于 dio 的网络层封装
- **本地存储**: 使用 shared_preferences 处理本地数据
- **错误处理**: 统一的错误处理机制
- **主题系统**: 支持亮色/暗色主题切换
- **代码生成**: 支持 json_serializable 自动序列化

## 🛠️ 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: signals
- **路由管理**: go_router
- **依赖注入**: get_it, injectable
- **网络请求**: dio
- **本地存储**: shared_preferences
- **代码生成**: json_serializable, build_runner
- **测试框架**: flutter_test, mocktail
- **国际化**: 支持多语言（待实现）
- **主题**: Material Design 3

## 📁 目录结构

```
lib/
├── app.dart                    # 应用根组件
├── main.dart                   # 程序入口
├── core/                       # 核心模块
│   ├── error/                  # 错误处理
│   ├── local/                  # 本地存储
│   ├── network/                # 网络模块
│   ├── routing/                # 路由配置
│   ├── theme/                  # 主题配置
│   └── app_config.dart         # 应用配置
├── di/                         # 依赖注入配置
│   ├── app_module.dart         # 依赖注入模块
│   └── service_locator.dart    # 服务定位器
├── features/                   # 功能模块
│   ├── auth/                   # 认证模块
│   │   ├── application/        # ViewModel层
│   │   ├── data/               # 数据层
│   │   ├── domain/             # 业务逻辑层
│   │   └── page/               # UI层
│   ├── article/                # 文章模块（示例）
│   ├── home/                   # 首页模块
│   └── profile/                # 个人资料模块
├── shared/                     # 共享组件
│   ├── utils/                  # 工具类
│   └── widget/                 # 通用组件
└── gen/                        # 代码生成文件
    └── assets.gen.dart         # 资源文件生成
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.x
- Dart SDK (随Flutter SDK一起安装)

### 安装步骤

1. **克隆项目**

```bash
git clone https://github.com/2084035767/flutter-app-template.git
cd flutter-app-template
```

2. **安装依赖**

```bash
flutter pub get
```

3. **生成代码（首次运行必须执行）**

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **运行项目**

```bash
flutter run
```

### 开发命令

- **生成代码**（在修改模型类后执行）:

```bash
dart run build_runner build
```

- **清理并重新生成代码**:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- **运行测试**:

```bash
flutter test
```

- **格式化代码**:

```bash
flutter format .
```

- **检查代码问题**:

```bash
flutter analyze
```

## 🔧 项目配置

### 添加新功能模块

1. 在 [features](file:///f:/App/flutter_app/lib/features) 目录下创建新模块文件夹
2. 创建子目录结构：[application](file:///f:/App/flutter_app/lib/features/article/application/article_view_model.dart)、[data](file:///f:/App/flutter_app/lib/features/article/data/article_api.dart)、[domain](file:///f:/App/flutter_app/lib/features/article/domain/article_repository.dart)、[page](file:///f:/App/flutter_app/lib/features/article/page/article_list_page.dart)
3. 在 [di/app_module.dart](file:///f:/App/flutter_app/lib/di/app_module.dart) 中注册依赖
4. 在 [routes](file:///f:/App/flutter_app/lib/core/routing/app_router.dart) 中添加路由

### 修改主题

修改 [core/theme](file:///f:/App/flutter_app/lib/core) 下的相关文件来自定义应用主题。

### 网络配置

修改 [core/network/network_module.dart](file:///f:/App/flutter_app/lib/core/network/network_module.dart) 来配置网络请求相关设置。

## 🧪 测试

项目支持单元测试、集成测试和小部件测试：

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/unit_test.dart

# 运行集成测试
flutter test integration_test/
```

## 📦 构建发布版本

### Android

```bash
flutter build apk --release
# 或构建分架构版本
flutter build apk --split-per-abi
```

### iOS

```bash
flutter build ios --release
```

## 🤝 贡献

欢迎提交Issue和Pull Request来帮助我们改进这个项目！

## 📄 许可证

MIT License

## 👨‍💻 作者

[子十](https://github.com/2084035767)

---

如果你觉得这个项目对你有帮助，请给它一个 ⭐！
