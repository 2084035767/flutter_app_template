# Directory Structure

> How code is organized in this project.

---

## Overview

This project follows **Feature-Sliced Design (FSD) 简化版** — 按业务功能（auth, article, profile）划分目录，每个 feature 内部自包含三层：

```
lib/
├── core/                      # 共享基础设施（严格克制）
│   ├── base/                  #   基础抽象：Failure, Result
│   ├── config/                #   配置：AppConfig, 主题, 网络配置
│   ├── data/                  #   数据基础设施
│   │   ├── database/          #     Drift 数据库连接
│   │   ├── network/           #     Dio 客户端 + Mock
│   │   └── storage/           #     本地持久化
│   ├── logging/               #   日志
│   ├── presentation/          #   全局通用 UI 组件（少用）
│   └── routing/               #   路由
│
├── features/                  # 业务功能（主导航，每个自包含）
│   └── {feature}/
│       ├── logic/             # ViewModel / 状态管理（signals）
│       │   └── {feature}_view_model.dart
│       ├── data/              # 数据层：API、Service、Repository、Model
│       │   ├── models/        #   数据模型（freezed / json_serializable）
│       │   ├── {feature}_api.dart         # Retrofit API 定义
│       │   ├── {feature}_service.dart     # 业务逻辑实现
│       │   └── {feature}_repository.dart  # 仓库抽象（按需）
│       └── page/              # UI 页面
│           └── {feature}_list_page.dart
│
└── di/                        # 依赖注入注册
    └── service_locator.config.dart  # 自动生成
```

---

## 核心原则

### 1. 按功能切片，不按技术分层

✅ 好：修改「阅读」功能时，所有相关代码在同一个 `article/` 文件夹里
❌ 避免：`models/`、`services/`、`screens/` 这种跨功能的目录

### 2. Feature 内部三层职责

| 层 | 目录 | 职责 | 典型内容 |
| --- | ------ | --------- | ---------------- |
| UI | `page/` | 页面组件（hooks + widgets） | `article_list_page.dart` |
| Logic | `logic/` | ViewModel + 状态（signals） | `article_view_model.dart` |
| Data | `data/` | 网络、本地、模型 | `api/*.dart`, `service/*.dart`, `models/*.dart` |

### 3. 共享层（core/）严格克制

- 只放真正跨 feature 复用的基础设施（Dio 客户端、主题常量、路由）
- **过早抽象是个人项目的头号杀手** — 宁可重复写两次，也不要提前抽取不稳定的基类
- 一个文件被 2+ 个 feature 使用时才考虑提到 core/
- core/ 不包含业务逻辑、不包含状态管理

### 4. Repository 接口按需使用

- 有真实的多实现需求（mock / 线上切换）才写 repository 抽象
- 简单的 feature 直接调用 Service，不需要额外的接口层

### 5. Feature 间通信通过 core/ 信号

✅ **core/ 层全局信号** 是 feature 间通信的唯一方式。
❌ 不使用事件总线（调试黑盒，找不到谁在消费）。
❌ 不依赖路由重建（当前页面在栈中时无效）。

```dart
// core/data/storage/auth_storage.dart
final currentUser = signal<User?>(null);

// Feature A 写入
await authStorage.saveUser(updatedUser);

// Feature B 自动响应（通过 useSignalValue）
final name = useSignalValue(authStorage.currentUser)?.name;
```

关键约束：

- 共享信号必须是真正的跨 feature 数据。**如果一个状态只在一个 feature 内使用，留在 ViewModel 里。**
- core/ 里的信号跟 SharedPreferences / 数据库保持同步（如 `AuthStorage` 同时维护 `currentUser` 信号和持久化存储）。

---

## Feature 目录模板

创建一个新 feature 时的标准布局：

```
features/{feature}/
├── logic/
│   └── {feature}_view_model.dart
├── data/
│   ├── models/
│   │   └── {model}.dart
│   ├── {feature}_api.dart        # Retrofit（可选）
│   ├── {feature}_service.dart     # 业务实现
│   └── {feature}_repository.dart  # 抽象接口（按需）
└── page/
    └── {feature}_page.dart
```

---

## Naming Conventions

| 元素 | 规范 | 示例 |
| --------- | ----------- | ------- |
| Feature ViewModel | `{Feature}ViewModel` | `ArticleViewModel` |
| ViewModel 文件 | `{feature}_view_model.dart` | `article_view_model.dart` |
| 页面文件 | `{feature}_page.dart` | `article_list_page.dart` |
| 页面类 | `{Feature}Page` | `ArticleListPage` |
| 共享组件 | 描述性 PascalCase | `EmptyWidget`, `ErrorText` |
| 数据模型 | PascalCase | `Article`, `User` |
| Model 文件 | `{model}.dart` | `article.dart` |

---

## 与旧结构的区别

| 旧（Clean Architecture） | 新（FSD 简化版） |
| --- | --- |
| `application/` | `logic/` |
| `domain/` + `data/` | `data/`（合并） |
| `page/` | 不变 |
| 必须写 repository 接口 | 按需，简单 feature 可直接用 Service |
