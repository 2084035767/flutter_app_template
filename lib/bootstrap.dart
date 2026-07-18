import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:my_app/app.dart';
import 'package:my_app/core/logging/logging.dart';

import 'di/service_locator.dart';

/// Required environment variables for the app.
const _requiredEnvKeys = ['BASE_URL'];

/// 当前环境（通过 --dart-define=env=xxx 传入）
/// 默认值根据构建模式决定：debug → development, release → production
const String _activeEnv = String.fromEnvironment(
  'env',
  defaultValue: 'development',
);

/// 对应的 .env 文件名
String get _envFileName => '.env.$_activeEnv';

Future<void> bootstrap() async {
  // 全局异常兜底：未捕获的异步异常不会导致静默失败
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Flutter 框架层错误
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Logging.error(
          details.exceptionAsString(),
          exception: details.exception,
          stackTrace: details.stack ?? StackTrace.current,
        );
      };

      // Platform 层异步错误
      PlatformDispatcher.instance.onError = (exception, stackTrace) {
        Logging.error(
          'Unhandled platform error',
          exception: exception,
          stackTrace: stackTrace,
        );
        return true; // 已处理，不继续传播
      };

      // 加载环境配置（默认 .env.development）
      await dotenv.load(fileName: _envFileName);
      Logging.info('Environment: $_activeEnv ($_envFileName)');
      _validateEnv();

      // 内存泄漏检测（仅在 debug 模式生效）
      _initLeakTracker();

      await configureDependencies();
      runApp(const MyApp());
    },
    (error, stack) {
      // runZonedGuarded 兜底：捕获所有 zone 内未捕获的异常
      Logging.error(
        'Unhandled zone error: $error',
        exception: error,
        stackTrace: stack,
      );
    },
  );
}

void _validateEnv() {
  for (final key in _requiredEnvKeys) {
    if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
      throw Exception('Missing required env key: $key');
    }
  }
}

void _initLeakTracker() {
  // 仅在 debug 模式下跟踪内存泄漏
  assert(() {
    FlutterMemoryAllocations.instance.addListener(
      (ObjectEvent event) => LeakTracking.dispatchObjectEvent(event.toMap()),
    );
    LeakTracking.start();
    Logging.info('leak_tracker started — memory leaks will be reported');
    return true;
  }());
}
