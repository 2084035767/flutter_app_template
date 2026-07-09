import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:my_app/app/router.dart';
import 'package:my_app/core/app_config.dart';
import 'package:my_app/core/theme/theme_extension.dart';
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
      theme: FlexThemeData.light(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        appBarStyle: FlexAppBarStyle.background,
        extensions: [const AppThemeExtension()],
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        appBarStyle: FlexAppBarStyle.background,
        extensions: [const AppThemeExtension()],
      ),
      themeMode: config.currentMode,
    );
  }
}
