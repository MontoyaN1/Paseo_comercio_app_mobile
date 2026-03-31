// lib/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _boxName = 'preferences_box';

  bool _isDarkMode = true;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final box = await Hive.openBox(_boxName);
      _isDarkMode = box.get(_themeKey, defaultValue: true);
    } catch (e) {
      _isDarkMode = true;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, _isDarkMode);
    } catch (e) {
      // Silent fail for persistence errors
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _saveTheme();
      notifyListeners();
    }
  }
}
