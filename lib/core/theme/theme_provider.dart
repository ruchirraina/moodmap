import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  static const String themeKey = 'app_theme_mode';
  static const String valueLight = 'light';
  static const String valueDark = 'dark';
  static const String valueSystem = 'system';

  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
    : _themeMode = initialThemeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.light) {
        await prefs.setString(themeKey, valueLight);
      } else if (mode == ThemeMode.dark) {
        await prefs.setString(themeKey, valueDark);
      } else {
        await prefs.setString(themeKey, valueSystem);
      }
    }
  }
}
