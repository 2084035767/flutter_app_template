import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/config/app_config.dart';
import 'package:my_app/core/config/theme_extension.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:signals_hooks/signals_hooks.dart';

// ═══════════════════════════════════════════
//  Warm Minimalist — Theme Definition
// ═══════════════════════════════════════════

const _colorScheme = FlexSchemeColor(
  primary: Color(0xFF0D7377),
  primaryContainer: Color(0xFFB8E6DC),
  secondary: Color(0xFFCF7A5A),
  secondaryContainer: Color(0xFFF8DED5),
  tertiary: Color(0xFF8B6A3E),
  tertiaryContainer: Color(0xFFF0DDBE),
);

final _textTheme = GoogleFonts.notoSansScTextTheme(
  GoogleFonts.dmSansTextTheme().copyWith(
    displayLarge: GoogleFonts.dmSans(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.dmSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
  ),
);

ThemeData _buildLightTheme() {
  final base = FlexThemeData.light(
    colors: _colorScheme,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 25,
    appBarStyle: FlexAppBarStyle.background,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3ErrorColors: true,
    tabBarStyle: FlexTabBarStyle.forBackground,
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,
  );
  return base.copyWith(
    extensions: const [AppThemeExtension.light],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppThemeExtension.light.radiusMd,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final base = FlexThemeData.dark(
    colors: _colorScheme,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 25,
    appBarStyle: FlexAppBarStyle.background,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3ErrorColors: true,
    tabBarStyle: FlexTabBarStyle.forBackground,
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,
  );
  return base.copyWith(
    extensions: const [AppThemeExtension.dark],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppThemeExtension.dark.radiusMd,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ═══════════════════════════════════════════
//  App Entry
// ═══════════════════════════════════════════

/// 应用根组件
class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();

    final bool isLoggedIn = useSignalValue(config.isLoggedInSignal);
    final router = useMemoized(() => AppRouter(isAuthenticated: isLoggedIn), [
      isLoggedIn,
    ]);

    final themeLight = useMemoized(_buildLightTheme);
    final themeDark = useMemoized(_buildDarkTheme);

    return MaterialApp.router(
      routerConfig: router.config(),
      debugShowCheckedModeBanner: false,
      theme: themeLight,
      darkTheme: themeDark,
      themeMode: config.currentMode,
    );
  }
}
