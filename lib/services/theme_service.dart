import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Simple getter that doesn't access platform brightness during build
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isSystemTheme => _themeMode == ThemeMode.system;

  ThemeService() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // If there's an error, use system theme
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      // If system theme, switch to light
      await setThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      // If light, switch to dark
      await setThemeMode(ThemeMode.dark);
    } else {
      // If dark, switch to system
      await setThemeMode(ThemeMode.system);
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    if (isDark) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Get the current effective theme mode for display purposes
  String get currentThemeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
