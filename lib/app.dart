import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/config/app_config.dart';
import 'package:my_app/core/config/theme_extension.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:signals_hooks/signals_hooks.dart';

/// 应用根组件
///
/// 监听登录状态变化，动态重建路由实现鉴权。
class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();

    // 登录状态变化时自动重建路由
    final bool isLoggedIn = useSignalValue(config.isLoggedInSignal);
    final router = useMemoized(() => AppRouter(isAuthenticated: isLoggedIn), [
      isLoggedIn,
    ]);

    return MaterialApp.router(
      routerConfig: router.config(),
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        appBarStyle: FlexAppBarStyle.background,
        extensions: const [AppThemeExtension()],
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        appBarStyle: FlexAppBarStyle.background,
        extensions: const [AppThemeExtension()],
      ),
      themeMode: config.currentMode,
    );
  }
}
