import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/app_config.dart';
import 'package:my_app/core/routing/app_router.dart';
import 'package:my_app/core/theme/app_theme.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final appRouter = useMemoized(
      () => AppRouter(isAuthenticated: config.isLoggedIn),
      [config.isLoggedIn],
    );

    return SignalBuilder(
      builder: (context) {
        return MaterialApp.router(
          routerConfig: appRouter.router,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: config.currentMode,
        );
      },
    );
  }
}
