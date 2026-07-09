import 'package:flutter/material.dart';
import 'package:my_app/app/router.dart';
import 'package:my_app/core/app_config.dart';
import 'package:my_app/core/theme/app_theme.dart';
import 'package:my_app/di/service_locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final router = AppRouter(isAuthenticated: config.isLoggedIn);

    return MaterialApp.router(
      routerConfig: router.config(),
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: config.currentMode,
    );
  }
}
