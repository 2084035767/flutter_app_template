import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Configures leak tracking for all widget tests in this project.
///
/// Enables automatic detection of not-disposed objects (widgets, controllers,
/// signal subscriptions, etc.) during test execution.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings
      // Ignore objects created by test helpers (e.g., pumpWidget).
      .withIgnored(createdByTestHelpers: true);

  await testMain();
}
