import 'package:flutter/material.dart';

extension ThemeHelper on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  AppThemeExtension get appTheme {
    final ext = Theme.of(this).extension<AppThemeExtension>();
    assert(ext != null, 'AppThemeExtension not registered in theme');
    return ext!;
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryContainer;
  final Color secondaryContainer;
  final Color surfaceVariant;
  final BoxShadow shadow;

  const AppThemeExtension({
    this.primaryContainer = const Color(0xFFE8DEF8),
    this.secondaryContainer = const Color(0xFF625B71),
    this.surfaceVariant = const Color(0xFFF5F0F5),
    this.shadow = const BoxShadow(
      blurRadius: 8,
      color: Color(0x0F000000),
      offset: Offset(0, 2),
    ),
  });

  @override
  AppThemeExtension copyWith({
    Color? primaryContainer,
    Color? secondaryContainer,
    Color? surfaceVariant,
    BoxShadow? shadow,
  }) {
    return AppThemeExtension(
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondaryContainer:
          Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      shadow: BoxShadow.lerp(shadow, other.shadow, t)!,
    );
  }
}
