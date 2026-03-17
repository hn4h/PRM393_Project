import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for reading/writing user settings to SharedPreferences.
class SettingsService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // ===== Theme Mode =====

  /// Get saved theme mode. Default: ThemeMode.system
  ThemeMode getThemeMode() {
    final value = _prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Save theme mode to SharedPreferences.
  Future<void> saveThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_themeKey, value);
  }
}
