import 'package:flutter/material.dart';
import 'package:moodmap/extensions/theme_extension.dart';

class ThemeConfig {
  // Light Palette
  static const Color _lightPrimary = Color(0xFFECA3B4);
  static const Color _lightSecondary = Color(0xFFF6C344);
  static const Color _lightTertiary = Color(0xFFB5A3DF);
  static const Color _lightError = Color(0xFF8C273B);
  static const Color _lightBg = Color(0xFFF9F9F9);

  // Dark Palette
  static const Color _darkPrimary = Color(0xFFECA3B4);
  static const Color _darkSecondary = Color(0xFFE5C973);
  static const Color _darkTertiary = Color(0xFFA391C6);
  static const Color _darkError = Color(0xFFD96C7A);
  static const Color _darkBg = Color(0xFF121212);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: _lightBg,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: _lightPrimary,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      tertiary: _lightTertiary,
      error: _lightError,
      surface: _lightBg,
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF3F3F3),
      surfaceContainer: const Color(0xFFEDEDED),
      surfaceContainerHigh: const Color(0xFFE7E7E7),
      surfaceContainerHighest: const Color(0xFFE0E0E0),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: _darkBg,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: _darkPrimary,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      tertiary: _darkTertiary,
      error: _darkError,
      surface: _darkBg,
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF1E1E1E),
      surfaceContainer: const Color(0xFF242424),
      surfaceContainerHigh: const Color(0xFF2A2A2A),
      surfaceContainerHighest: const Color(0xFF323232),
    ),
  );

  static TextStyle smallButtonTextTheme(BuildContext context) {
    return context.textTheme.titleMedium!.copyWith(
      color: context.colorScheme.onPrimary,
      fontWeight: .bold,
    );
  }
}
