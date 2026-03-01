import 'package:flutter/material.dart';
import '../../shared/data/shared_pref_data.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = AppPref.getIsDarkTheme();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    AppPref.setIsDarkTheme(isDark);
    notifyListeners();
  }
}
