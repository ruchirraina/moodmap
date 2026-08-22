import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  static const String themeKey = 'app_theme_mode';

  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
    : _themeMode = initialThemeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.light) {
        await prefs.setString(themeKey, 'light');
      } else if (mode == ThemeMode.dark) {
        await prefs.setString(themeKey, 'dark');
      } else {
        await prefs.setString(themeKey, 'system');
      }
    }
  }
}
