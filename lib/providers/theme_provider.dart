import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    _saveThemeMode(themeMode);
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(themeModeKey);

    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (element) => element.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }

  void _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(themeModeKey, themeMode.toString());
  }
}
