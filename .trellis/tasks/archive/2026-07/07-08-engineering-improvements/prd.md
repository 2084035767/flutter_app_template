# Engineering Improvements

Bring scaffold up to 2026 mainstream engineering standards.

## R1: FVM — Pin Flutter SDK

- Create `.fvmrc` with current Flutter version
- Add `.fvm/` to `.gitignore`

## R2: Strict Lint

- Enable `strict-casts: true` and `strict-inference: true` in `analysis_options.yaml`
- Fix any new issues that surface

## R3: Freezed for Article model

- Add `freezed` + `freezed_annotation` + `freezed_generator` dependencies
- Convert `Article` to `@freezed` model
- Remove manual equality / copyWith (generated)

## Acceptance Criteria

- [x] `.fvmrc` committed with pinned version
- [x] `flutter analyze` passes with strict lint
- [x] `Article` model uses freezed
- [x] `flutter test` passes
