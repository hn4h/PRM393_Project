import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository responsible for Settings data operations:
/// - Clearing local app cache (SharedPreferences)
/// - Deleting the authenticated user's account via Edge Function
class SettingsRepository {
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  const SettingsRepository(this._client, this._prefs);

  // ── Clear Cache ────────────────────────────────────────────────────────────

  /// Clears all SharedPreferences keys EXCEPT theme_mode, so the user's
  /// display preference survives a cache clear.
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((k) => k != 'theme_mode').toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────

  /// Calls the `delete-user` Edge Function, which uses the Service Role key to
  /// remove all user data and the auth record from Supabase.
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> deleteAccount() async {
    try {
      // Edge Function requires a valid JWT — auth header is injected automatically
      // by the Supabase client when verify_jwt = true on the function.
      await _client.functions.invoke('delete-user', method: HttpMethod.post);
      return null;
    } on FunctionException catch (e) {
      return e.details?.toString() ?? 'Failed to delete account.';
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
