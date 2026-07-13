// ignore_for_file: avoid_print

import 'dart:io';

/// Interactive script to initialize this scaffold for a new project.
///
/// Usage: `dart run tool/init_project.dart`
///
/// Prompts for the new project name, then updates all scaffold-specific
/// identifiers (app name, applicationId, bundle display name, etc.).
void main() async {
  print('🚀 Flutter Scaffold — Init New Project');
  print('');

  final oldName = _readPubspecName();
  print('Current project name: $oldName');
  print('');

  // ── 1. Dart package name ──
  final dartName = _prompt('New Dart package name', oldName);
  if (dartName.isEmpty) {
    print('❌ Aborted.');
    exit(1);
  }

  // ── 2. Android applicationId ──
  final defaultId = 'com.example.$dartName';
  final applicationId = _prompt('Android applicationId', defaultId);

  // ── 3. iOS display name ──
  final displayName = _prompt(
    'iOS display name (CFBundleDisplayName)',
    dartName,
  );

  print('');
  print('This will update:');
  print('  • pubspec.yaml → name: $dartName');
  print('  • build.gradle.kts → applicationId: $applicationId');
  print('  • AndroidManifest.xml → android:label: $displayName');
  print('  • Info.plist → CFBundleDisplayName: $displayName');
  print('  • lib/app.dart, lib/bootstrap.dart → class name');
  print('');

  final confirm = _prompt('Continue? (y/N)', 'n');
  if (confirm.toLowerCase() != 'y') {
    print('❌ Aborted.');
    exit(1);
  }

  final oldClassName = _pascalCase(oldName);
  final newClassName = _pascalCase(dartName);

  _replaceInFile('pubspec.yaml', "name: $oldName", "name: $dartName");

  // Try multiple patterns for applicationId (pubspec name may differ from old package)
  _replaceInFile(
    'android/app/build.gradle.kts',
    'applicationId = "com.example.flutter_app"',
    'applicationId = "$applicationId"',
  );
  _replaceInFile(
    'android/app/build.gradle.kts',
    'applicationId = "com.example.$oldName"',
    'applicationId = "$applicationId"',
  );
  _replaceInFile(
    'android/app/build.gradle.kts',
    'applicationId = "$oldName"',
    'applicationId = "$applicationId"',
  );

  _replaceInFile(
    'android/app/src/main/AndroidManifest.xml',
    'android:label="flutter_app"',
    'android:label="$displayName"',
  );
  _replaceInFile(
    'android/app/src/main/AndroidManifest.xml',
    'android:label="$oldName"',
    'android:label="$displayName"',
  );

  _replaceInFile(
    'ios/Runner/Info.plist',
    '<string>flutter_app</string>',
    '<string>$displayName</string>',
  );
  _replaceInFile(
    'ios/Runner/Info.plist',
    '<string>$oldName</string>',
    '<string>$displayName</string>',
  );

  _replaceInFile('lib/app.dart', 'class $oldClassName', 'class $newClassName');
  _replaceInFile(
    'lib/bootstrap.dart',
    'class $oldClassName',
    'class $newClassName',
  );

  print('');
  print('✅ Project initialized!');
  print('');
  print('Next steps:');
  print('  1. Review changes with: git diff');
  print(
    '  2. Regenerate code: dart run build_runner build --delete-conflicting-outputs',
  );
  print('  3. Verify with: flutter analyze');
  print(
    '  4. Commit: git add -A && git commit -m "chore: init project as $dartName"',
  );
}

/// Read the current `name` field from pubspec.yaml.
String _readPubspecName() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspec);
  if (match == null) {
    print('❌ Could not read name from pubspec.yaml');
    exit(1);
  }
  return match.group(1)!;
}

/// Prompt the user for input with a default value.
String _prompt(String label, String defaultValue) {
  stdout.write('$label [$defaultValue]: ');
  final input = stdin.readLineSync()?.trim() ?? '';
  return input.isEmpty ? defaultValue : input;
}

/// Convert a snake_case or kebab-case name to PascalCase.
String _pascalCase(String name) {
  return name
      .split(RegExp(r'[-_.\s]+'))
      .map(
        (part) => part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1),
      )
      .join();
}

/// Replace [oldText] with [newText] in the file at [path].
/// Prints a warning if the pattern was not found.
void _replaceInFile(String path, String oldText, String newText) {
  final file = File(path);
  if (!file.existsSync()) {
    print('⚠️  Skipped (not found): $path');
    return;
  }
  var content = file.readAsStringSync();
  if (!content.contains(oldText)) {
    print('⚠️  Pattern not found in $path: "$oldText"');
    return;
  }
  content = content.replaceAll(oldText, newText);
  file.writeAsStringSync(content);
  print('  ✓ Updated: $path');
}
