import 'package:flutter/material.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_app_colors.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_text_styles.dart';

class RiseAppThemeConfig {
  final RiseAppColors colors;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  RiseAppThemeConfig({
    required this.colors,
    required this.textTheme,
    required this.colorScheme,
  });

  static ColorScheme _createColorScheme(
    RiseAppColors colors,
    Brightness brightness,
  ) {
    return ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      onSurfaceVariant: colors.onSurfaceVariant,
      surfaceDim: colors.surfaceDim,
      surfaceBright: colors.surfaceBright,
      surfaceContainerLowest: colors.surfaceContainerLowest,
      surfaceContainerLow: colors.surfaceContainerLow,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceContainerHigh,
      surfaceContainerHighest: colors.surfaceContainerHighest,
      inversePrimary: colors.inversePrimary,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.inverseOnSurface,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      shadow: colors.shadow,
      scrim: colors.scrim,
      surfaceTint: colors.surface,
      // Fixed colors
      primaryFixed: colors.primaryFixed,
      onPrimaryFixed: colors.onPrimaryFixed,
      primaryFixedDim: colors.primaryFixedDim,
      onPrimaryFixedVariant: colors.onPrimaryFixedVariant,
      secondaryFixed: colors.secondaryFixed,
      onSecondaryFixed: colors.onSecondaryFixed,
      secondaryFixedDim: colors.secondaryFixedDim,
      onSecondaryFixedVariant: colors.onSecondaryFixedVariant,
      tertiaryFixed: colors.tertiaryFixed,
      onTertiaryFixed: colors.onTertiaryFixed,
      tertiaryFixedDim: colors.tertiaryFixedDim,
      onTertiaryFixedVariant: colors.onTertiaryFixedVariant,
    );
  }

  static RiseAppThemeConfig light() {
    final colors = RiseAppColors.light();
    return RiseAppThemeConfig(
      colors: colors,
      textTheme: interTextTheme.apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
        decorationColor: colors.onSurfaceVariant,
      ),
      colorScheme: _createColorScheme(colors, Brightness.light),
    );
  }

  static RiseAppThemeConfig dark() {
    final colors = RiseAppColors.dark();
    return RiseAppThemeConfig(
      colors: colors,
      textTheme: interTextTheme.apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
        decorationColor: colors.onSurfaceVariant,
      ),
      colorScheme: _createColorScheme(colors, Brightness.dark),
    );
  }
}

class RiseAppThemeExtension extends ThemeExtension<RiseAppThemeExtension> {
  final RiseAppThemeConfig config;

  const RiseAppThemeExtension(this.config);

  @override
  RiseAppThemeExtension copyWith({RiseAppThemeConfig? config}) =>
      RiseAppThemeExtension(config ?? this.config);

  @override
  RiseAppThemeExtension lerp(
    ThemeExtension<RiseAppThemeExtension>? other,
    double t,
  ) {
    if (other is! RiseAppThemeExtension) {
      return this;
    }
    return RiseAppThemeExtension(
      RiseAppThemeConfig(
        colors: config.colors,
        textTheme: config.textTheme,
        colorScheme: config.colorScheme,
      ),
    );
  }
}

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: RiseAppThemeConfig.light().colorScheme,
    textTheme: RiseAppThemeConfig.light().textTheme,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
    ),
    extensions: [RiseAppThemeExtension(RiseAppThemeConfig.light())],
  );
  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: RiseAppThemeConfig.dark().colorScheme,
    textTheme: RiseAppThemeConfig.dark().textTheme,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
    ),
    extensions: [RiseAppThemeExtension(RiseAppThemeConfig.dark())],
  );
}
