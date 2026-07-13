import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
//  Warm Minimalist — Design Tokens
// ═══════════════════════════════════════════

/// 自定义设计令牌——通过 ThemeExtension 注入
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color textSubtle;
  final Color dividerSubtle;
  final BoxShadow shadowSm;
  final BoxShadow shadowMd;
  final BoxShadow shadowLg;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  const AppThemeExtension({
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.textSubtle,
    required this.dividerSubtle,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
  });

  /// Light mode tokens
  static const light = AppThemeExtension(
    surfaceCard: Color(0xFFFFFCF7),
    surfaceElevated: Color(0xFFFFFEF9),
    textSubtle: Color(0x99201B17),
    dividerSubtle: Color(0x1A201B17),
    shadowSm: BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    shadowMd: BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
    shadowLg: BoxShadow(
      color: Color(0x12000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    radiusSm: 8,
    radiusMd: 16,
    radiusLg: 24,
  );

  /// Dark mode tokens
  static const dark = AppThemeExtension(
    surfaceCard: Color(0xFF26221E),
    surfaceElevated: Color(0xFF302C28),
    textSubtle: Color(0x99E6E0DA),
    dividerSubtle: Color(0x1AE6E0DA),
    shadowSm: BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    shadowMd: BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    shadowLg: BoxShadow(
      color: Color(0x40000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    radiusSm: 8,
    radiusMd: 16,
    radiusLg: 24,
  );

  // ═══ Convenience helpers ═══

  static AppThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!;

  @override
  AppThemeExtension copyWith({
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? textSubtle,
    Color? dividerSubtle,
    BoxShadow? shadowSm,
    BoxShadow? shadowMd,
    BoxShadow? shadowLg,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
  }) {
    return AppThemeExtension(
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textSubtle: textSubtle ?? this.textSubtle,
      dividerSubtle: dividerSubtle ?? this.dividerSubtle,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      dividerSubtle: Color.lerp(dividerSubtle, other.dividerSubtle, t)!,
      shadowSm: BoxShadow.lerp(shadowSm, other.shadowSm, t)!,
      shadowMd: BoxShadow.lerp(shadowMd, other.shadowMd, t)!,
      shadowLg: BoxShadow.lerp(shadowLg, other.shadowLg, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
    );
  }
}

// ═══ Context extensions ═══

extension ThemeHelper on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get surfaceContainer => Theme.of(this).colorScheme.surfaceContainer;
  Color get surfaceContainerHigh =>
      Theme.of(this).colorScheme.surfaceContainerHigh;

  AppThemeExtension get appTheme => AppThemeExtension.of(this);
}
