# Scaffold Remaining Optimizations

## Items

### R1: .trae/ cleanup

- Add `.trae/` to `.gitignore` to suppress deleted `trae/` files from git status

### R2: SignalsObserver debug registration

- Register `SignalsObserver` in bootstrap.dart for signals v7 devtool support (debug only)

### R3: flutter_secure_storage dependency cleanup

- Package in pubspec.yaml but never imported in lib/. Add comment to pubspec.yaml noting it's reserved for future use, or remove if not needed.

### R4: CI config

- Add `.github/workflows/ci.yml` with flutter test + analyze workflow

### R5: .env validation

- Add missing-key check in bootstrap.dart for `BASE_URL`
