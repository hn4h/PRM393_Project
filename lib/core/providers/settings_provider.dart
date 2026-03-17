import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/core/services/settings_service.dart';

/// Provider for SharedPreferences instance.
/// Must be overridden in ProviderScope with actual instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Provider for SettingsService.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsService(prefs);
});

// ===== Theme Mode =====

/// Notifier for managing ThemeMode state.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _service;

  ThemeModeNotifier(this._service) : super(_service.getThemeMode());

  /// Update theme mode and persist to SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _service.saveThemeMode(mode);
  }
}

/// Provider for ThemeMode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final service = ref.read(settingsServiceProvider);
    return ThemeModeNotifier(service);
  },
);
