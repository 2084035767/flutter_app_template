<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

## Project Nature: Personal Flutter Scaffold

This project is a **personal Flutter scaffold/template** for medium-small apps, not a production application. It provides a clean starting point with:

- **Clean Architecture** feature-first structure
- **Signals + ViewModel** state management
- **GoRouter** declarative routing
- **Injectable + GetIt** dependency injection
- **Material Design 3** theming
- **Retrofit + Dio** API client pattern
- **Chinese UI** (user-facing strings) + **English code** (identifiers, comments)

### Starting a New Project From This Scaffold

#### Quick way (automated)

```bash
dart run tool/init_project.dart
```

This interactive script updates the following files:

- `pubspec.yaml` → `name`
- `android/app/build.gradle.kts` → `applicationId`
- `android/app/src/main/AndroidManifest.xml` → `android:label`
- `ios/Runner/Info.plist` → `CFBundleDisplayName`
- `lib/app.dart`, `lib/bootstrap.dart` → class name

After the script:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

#### Manual way

1. Update `pubspec.yaml` → `name` field
2. Update `android/app/build.gradle.kts` → `applicationId`
3. Update `android/app/src/main/AndroidManifest.xml` → `android:label`
4. Update `ios/Runner/Info.plist` → `CFBundleDisplayName`
5. Replace `MyApp` class name in `lib/app.dart` and `lib/bootstrap.dart`
6. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate configs

### Pre-commit Hooks

This scaffold includes a pre-commit hook in `.githooks/pre-commit` that runs:

- `flutter analyze lib/ test/`
- `flutter test`

To activate:

```bash
git config core.hooksPath .githooks
```

To skip (emergency only): `git commit --no-verify`

### Resolved Quality Issues

The following issues have been fixed in this scaffold (P0 audit, July 2026):

- **LoginPage memory leak**: Converted from StatelessWidget (recreating ViewModel on every build) to StatefulWidget with proper initState/dispose lifecycle
- **ArticleDetailPage type safety**: Replaced `state.extra as dynamic` with type-safe path parameter parsing via `GoRouterStateX.getInt()`
- **Article body field**: Added `body` field to Article model for full article content display
- **FileStorage DI annotation**: Changed from `@LazySingleton()` to `@Singleton()` for eager DI registration
- **Profile page placeholders**: Replaced "John Doe" / "UI/UX Designer" with generic Chinese template
- **ViewModel disposed guards**: Added `disposed`/`isDisposed` checks after all async operations
- **`runAsync` helper**: Added to BaseViewModel to reduce boilerplate in ViewModel methods

### Working Knowledge

The working knowledge you need lives under `.trellis/`:

- `.trellis/workflow.md` — development phases, when to create tasks, skill routing
- `.trellis/spec/` — package- and layer-scoped coding guidelines (read before writing code in a given layer)
- `.trellis/workspace/` — per-developer journals and session traces
- `.trellis/tasks/` — active and archived tasks (PRDs, research, jsonl context)

If a Trellis command is available on your platform (e.g. `/trellis:finish-work`, `/trellis:continue`), prefer it over manual steps. Not every platform exposes every command.

If you're using Codex or another agent-capable tool, additional project-scoped helpers may live in:

- `.agents/skills/` — reusable Trellis skills
- `.codex/agents/` — optional custom subagents

Managed by Trellis. Edits outside this block are preserved; edits inside may be overwritten by a future `trellis update`.

<!-- TRELLIS:END -->
