import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/theme/app_theme.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../di/service_locator.dart';
import 'core/app_config.dart';
import 'core/routing/app_router.dart';

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = getIt<AppConfig>();
    return Watch.builder(
      builder: (context) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: appConfig.currentMode,
        );
      },
    );
  }
}
