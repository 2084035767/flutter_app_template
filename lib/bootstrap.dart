import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/app.dart';
import 'package:my_app/core/utils/logging.dart';

import 'di/service_locator.dart';

/// Required environment variables for the app.
const _requiredEnvKeys = ['BASE_URL'];

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file and validate required keys
  await dotenv.load(fileName: '.env');
  _validateEnv();

  await configureDependencies();
  runApp(const MyApp());
}

void _validateEnv() {
  for (final key in _requiredEnvKeys) {
    if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
      if (kReleaseMode) {
        throw Exception('Missing required env key: $key');
      } else {
        Logging.warning('⚠️ Missing env key: $key — using defaults');
      }
    }
  }
}
