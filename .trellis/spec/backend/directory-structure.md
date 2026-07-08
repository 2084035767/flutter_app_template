# Directory Structure

> How backend (data layer) code is organized in this project.

> **Scaffold note**: This is a personal Flutter scaffold/template for medium-small apps. The Clean Architecture feature-first structure is lightweight — no UseCase layer (over-engineering for this scope). ViewModels communicate directly with Repository abstractions.

---

## Overview

This project follows **Clean Architecture** with a **feature-first** package structure. The `lib/` directory is organized into three top-level sections:

- **`core/`** — Shared infrastructure and utilities (theme, routing, network, DI, error handling, config)
- **`features/{feature}/`** — Feature modules following Clean Architecture layers
- **`shared/`** — Shared base classes and utilities

Each feature module is self-contained with its own layers:

```
lib/
├── core/
│   ├── config/               # App configuration, user preferences, network config
│   ├── error/                # Failure types, Result type
│   ├── local/                # File storage utilities
│   ├── network/              # Dio client, interceptors, retry logic
│   ├── presentation/
│   │   ├── pages/            # Shared pages (splash, 404)
│   │   └── widgets/          # Shared widgets (loading, empty, error)
│   ├── routing/              # GoRouter setup, route constants, navigation extensions
│   ├── storage/              # Auth storage (shared_preferences wrapper)
│   ├── theme/                # AppThemes, design tokens, theme extensions
│   └── utils/                # Utility classes (Logging)
├── di/                       # GetIt + injectable setup
├── features/
│   ├── {feature}/
│   │   ├── domain/           # Business logic layer (ABSTRACTIONS only)
│   │   │   ├── models/       # Data models (freezed/json_annotation)
│   │   │   ├── {feature}_repository.dart  # Abstract repository interface
│   │   │   └── ...
│   │   ├── data/             # Data layer (IMPLEMENTATIONS)
│   │   │   ├── {feature}_api.dart        # Retrofit API definitions
│   │   │   ├── {feature}_api.g.dart      # Generated (retrofit)
│   │   │   ├── {feature}_service.dart    # Repository implementation
│   │   │   └── {feature}_module.dart     # Injectable DI module
│   │   ├── application/      # ViewModels (Signals-based state)
│   │   │   └── {feature}_view_model.dart
│   │   └── page/             # Flutter UI pages
│   │       └── {feature}_page.dart
│   └── ...
├── gen/                      # Generated assets (flutter_gen)
├── shared/
│   └── view_models/
│       └── base_view_model.dart  # BaseViewModel with signals lifecycle
├── app.dart                  # MaterialApp.router setup
├── bootstrap.dart            # App initialization
└── main.dart                 # Entry point
```

---

## Module Organization

Each feature module follows strict Clean Architecture dependency rules:

| Layer | Dependencies | Purpose |
| ------- | ------------- | --------- |
| `domain/` | No framework dependencies | Business interfaces, domain models |
| `data/` | Depends on `domain/`, `core/error/`, `core/network/` | API calls, repository implementations |
| `application/` | Depends on `domain/`, `core/error/`, `shared/` | ViewModels, state management |
| `page/` | Depends on `application/` | Flutter UI pages |

**Data flow**: `Page → ViewModel → Repository (interface) → Service (implementation) → API`

- **Dependencies point inward**: outer layers depend on inner layers, never the reverse
- **No cyclic dependencies**: a domain model never imports from data or page layers
- **Generated code**: `.g.dart` files live alongside their source and are never edited manually

---

## Naming Conventions

| Element | Convention | Example |
| --------- | ----------- | --------- |
| Feature directories | snake_case | `auth/`, `article/` |
| Dart source files | snake_case | `auth_service.dart`, `article_repository.dart` |
| Repository interface | `{feature}_repository.dart` | `auth_repository.dart` |
| Repository impl | `{feature}_service.dart` | `auth_service.dart` |
| API definition | `{feature}_api.dart` | `auth_api.dart` |
| ViewModel | `{feature}_view_model.dart` | `auth_view_model.dart` |
| DI module | `{feature}_module.dart` | `auth_module.dart` |
| Page files | `{feature}_page.dart` | `login_page.dart` |
| Model classes | PascalCase | `Article`, `User` |
| Repository class | `{Feature}Repository` | `ArticleRepository` |
| Service class | `{Feature}Service` | `ArticleService` |
| API class | `{Feature}Api` | `AuthApi` |
| ViewModel class | `{Feature}ViewModel` | `AuthViewModel` |

---

## Examples

- **Feature module**: `lib/features/article/` — complete example with API, service, repository, ViewModel, and pages
- **Shared infrastructure**: `lib/core/` — contains `result.dart`, `failure.dart`, `dio_client.dart`, `app_theme.dart`
