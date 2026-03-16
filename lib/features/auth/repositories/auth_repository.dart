import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository wrapping Supabase Auth operations.
/// All methods throw [AuthException] on failure — viewmodel handles errors.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Registers a new customer account. Returns [AuthResponse].
  /// On success, Supabase sends a confirmation email.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': 'customer'},
      emailRedirectTo: null, // Use Supabase default redirect
    );
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  /// Signs in with email and password. Returns [AuthResponse].
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async => _client.auth.signOut();

  // ── Forgot Password ───────────────────────────────────────────────────────

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── Change Password ─────────────────────────────────────────────────────

  /// Verifies the user's current password by re-authenticating.
  /// Returns null on success, error message on failure.
  Future<String?> verifyCurrentPassword(
      String email, String password) async {
    try {
      await _client.auth
          .signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Updates the signed-in user's password.
  Future<void> updatePassword(String newPassword) async {
    await _client.auth
        .updateUser(UserAttributes(password: newPassword));
  }

  // ── Current Session ───────────────────────────────────────────────────────

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  /// Returns the role from public.profiles for the signed-in user.
  /// Defaults to 'customer' if not found.
  Future<String> getUserRole(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return (data?['role'] as String?) ?? 'customer';
    } catch (_) {
      return 'customer';
    }
  }

  // ── Auth state stream ─────────────────────────────────────────────────────

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
