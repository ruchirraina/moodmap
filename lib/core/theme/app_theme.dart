import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = ThemeData(brightness: brightness, useMaterial3: true);
    final baseTextTheme = baseTheme.textTheme.apply(
      fontFamily: AppFonts.primary,
    );

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.secondary,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
      borderSide: BorderSide.none,
    );
    final activeBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: AppConstants.inputBorderWidth,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: AppConstants.inputBorderWidth,
      ),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.inputHorizontalPadding,
        vertical: AppConstants.inputVerticalPadding,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: activeBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
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
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _buildTextTheme(Brightness.light),
      colorScheme: colorScheme,
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coreWisteria,
        foregroundColor: AppColors.lightOnTertiary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.corePetal,
        selectionColor: AppColors.petalLight.withValues(
          alpha: AppConstants.selectionAlpha,
        ),
        selectionHandleColor: AppColors.corePetal,
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
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
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _buildTextTheme(Brightness.dark),
      colorScheme: colorScheme,
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coreWisteria,
        foregroundColor: AppColors.darkOnTertiary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.corePetal,
        selectionColor: AppColors.petalDeep.withValues(
          alpha: AppConstants.selectionAlpha,
        ),
        selectionHandleColor: AppColors.corePetal,
      ),
    );
  }
}
