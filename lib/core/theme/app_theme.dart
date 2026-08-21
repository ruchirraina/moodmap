import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = ThemeData(brightness: brightness, useMaterial3: true);
    final baseTextTheme = baseTheme.textTheme.apply(fontFamily: 'Lato');

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: 'Playfair Display',
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: 'Playfair Display',
      ),
    );
  }

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: _buildTextTheme(Brightness.light),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.coreMulberry,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.mulberryLight,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.corePetal,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.petalLight,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.coreWisteria,
      onTertiary: AppColors.lightOnTertiary,
      tertiaryContainer: AppColors.wisteriaLight,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,
      surface: AppColors.lightBg,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.lightSurfaceBright,
      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      surfaceTint: Colors.transparent,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      inverseSurface: AppColors.lightInverseSurface,
      onInverseSurface: AppColors.lightOnInverseSurface,
      inversePrimary: AppColors.mulberryLight,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _buildTextTheme(Brightness.dark),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.coreMulberry,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.mulberryDeep,
      onPrimaryContainer: AppColors.mulberryLight,
      secondary: AppColors.corePetal,
      onSecondary: AppColors.darkOnSecondary,
      secondaryContainer: AppColors.petalDeep,
      onSecondaryContainer: AppColors.petalLight,
      tertiary: AppColors.coreWisteria,
      onTertiary: AppColors.darkOnTertiary,
      tertiaryContainer: AppColors.wisteriaDeep,
      onTertiaryContainer: AppColors.wisteriaLight,
      surface: AppColors.darkBg,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      surfaceDim: AppColors.darkSurfaceDim,
      surfaceBright: AppColors.darkSurfaceBright,
      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      surfaceTint: Colors.transparent,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      inverseSurface: AppColors.darkInverseSurface,
      onInverseSurface: AppColors.darkOnInverseSurface,
      inversePrimary: AppColors.mulberryDeep,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
    ),
  );
}
