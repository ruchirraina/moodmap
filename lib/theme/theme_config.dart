import 'package:flutter/material.dart';
import 'package:moodmap/theme/theme_extension.dart';

class ThemeConfig {
  // core colors (same in both modes)
  static const Color coreMulberry = Color(0xFFC084B8);
  static const Color corePetal = Color(0xFFE8A0BF);
  static const Color coreWisteria = Color(0xFFA89FD8);

  // supporting variants
  static const Color _mulberryLight = Color(0xFFEDD6EA);
  static const Color _mulberryDeep = Color(0xFF7A4470);
  static const Color _petalLight = Color(0xFFF7D5E4);
  static const Color _petalDeep = Color(0xFFB5547A);
  static const Color _wisteriaLight = Color(0xFFDDD9F3);
  static const Color _wisteriaDeep = Color(0xFF5E57A8);

  // light surfaces
  static const Color _lightBg = Color(0xFFF2F0F4);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF8F7F9);
  static const Color _lightSurfaceContainer = Color(0xFFF2F0F4);
  static const Color _lightSurfaceContainerHigh = Color(0xFFECEAF0);
  static const Color _lightSurfaceContainerHighest = Color(0xFFE5E3EB);
  static const Color _lightSurfaceDim = Color(0xFFDFDCE6);
  static const Color _lightSurfaceBright = Color(0xFFF8F7F9);
  static const Color _lightOnSurface = Color(0xFF1A1820);
  static const Color _lightOnSurfaceVariant = Color(0xFF4A4758);
  static const Color _lightOutline = Color(0xFF9A97A8);
  static const Color _lightOutlineVariant = Color(0xFFCECBD8);

  // dark surfaces
  static const Color _darkBg = Color(0xFF131118);
  static const Color _darkSurfaceContainerLowest = Color(0xFF0D0C10);
  static const Color _darkSurfaceContainerLow = Color(0xFF18161C);
  static const Color _darkSurfaceContainer = Color(0xFF1E1C22);
  static const Color _darkSurfaceContainerHigh = Color(0xFF252229);
  static const Color _darkSurfaceContainerHighest = Color(0xFF2D2A34);
  static const Color _darkSurfaceDim = Color(0xFF0D0C10);
  static const Color _darkSurfaceBright = Color(0xFF2D2A34);
  static const Color _darkOnSurface = Color(0xFFEEECF5);
  static const Color _darkOnSurfaceVariant = Color(0xFFADA9BE);
  static const Color _darkOutline = Color(0xFF6A6778);
  static const Color _darkOutlineVariant = Color(0xFF38353F);

  // error
  static const Color _lightError = Color(0xFF8C2A35);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFC96070);
  static const Color _lightOnErrorContainer = Color(0xFF1A0508);
  static const Color _darkError = Color(0xFFD26478);
  static const Color _darkOnError = Color(0xFF1A0508);
  static const Color _darkErrorContainer = Color(0xFF8C2A35);
  static const Color _darkOnErrorContainer = Color(0xFFFCEEF0);

  // light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: _lightBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: coreMulberry,
      onPrimary: Color(0xFFFAF0F8),
      primaryContainer: _mulberryLight,
      onPrimaryContainer: Color(0xFF2A0D20),

      secondary: corePetal,
      onSecondary: Color(0xFFFDF2F6),
      secondaryContainer: _petalLight,
      onSecondaryContainer: Color(0xFF330D1E),

      tertiary: coreWisteria,
      onTertiary: Color(0xFFF4F2FC),
      tertiaryContainer: _wisteriaLight,
      onTertiaryContainer: Color(0xFF1A1838),

      surface: _lightBg,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      surfaceDim: _lightSurfaceDim,
      surfaceBright: _lightSurfaceBright,
      surfaceContainerLowest: _lightSurfaceContainerLowest,
      surfaceContainerLow: _lightSurfaceContainerLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceContainerHigh,
      surfaceContainerHighest: _lightSurfaceContainerHighest,
      surfaceTint: Colors.transparent,

      error: _lightError,
      onError: _lightOnError,
      errorContainer: _lightErrorContainer,
      onErrorContainer: _lightOnErrorContainer,

      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,

      inverseSurface: Color(0xFF2D2A34),
      onInverseSurface: Color(0xFFEEECF5),
      inversePrimary: _mulberryLight,

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    ),
  );

  // dark theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: _darkBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: coreMulberry,
      onPrimary: Color(0xFF1A0A17),
      primaryContainer: _mulberryDeep,
      onPrimaryContainer: _mulberryLight,

      secondary: corePetal,
      onSecondary: Color(0xFF2A0D1A),
      secondaryContainer: _petalDeep,
      onSecondaryContainer: _petalLight,

      tertiary: coreWisteria,
      onTertiary: Color(0xFF100E2A),
      tertiaryContainer: _wisteriaDeep,
      onTertiaryContainer: _wisteriaLight,

      surface: _darkBg,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      surfaceDim: _darkSurfaceDim,
      surfaceBright: _darkSurfaceBright,
      surfaceContainerLowest: _darkSurfaceContainerLowest,
      surfaceContainerLow: _darkSurfaceContainerLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
      surfaceTint: Colors.transparent,

      error: _darkError,
      onError: _darkOnError,
      errorContainer: _darkErrorContainer,
      onErrorContainer: _darkOnErrorContainer,

      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,

      inverseSurface: Color(0xFFE5E3EB),
      onInverseSurface: Color(0xFF1A1820),
      inversePrimary: _mulberryDeep,

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    ),
  );

  static TextStyle buttonTextTheme(BuildContext context) {
    return context.textTheme.titleMedium!.copyWith(
      color: context.colorScheme.onPrimary,
      fontWeight: .w500,
    );
  }
}
