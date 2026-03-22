import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/config/supabase_config.dart';

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

  // ── Forgot Password (Edge Function) ───────────────────────────────────────

  /// Calls the `reset-password` Edge Function to generate a random password
  /// and send it to the user's email via Gmail SMTP.
  /// Returns null on success, error message on failure.
  Future<String?> requestPasswordReset(String email) async {
    try {
      final url = '${SupabaseConfig.url}/functions/v1/reset-password';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.anonKey,
        },
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return null; // success
      } else {
        return body['error'] as String? ?? 'Failed to reset password';
      }
    } catch (e) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  // ── Must Change Password ──────────────────────────────────────────────────

  /// Checks if the user must change their password.
  Future<bool> checkMustChangePassword(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('must_change_password')
          .eq('id', userId)
          .maybeSingle();
      return (data?['must_change_password'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Clears the must_change_password flag after user changes their password.
  Future<void> clearMustChangePassword(String userId) async {
    await _client
        .from('profiles')
        .update({'must_change_password': false})
        .eq('id', userId);
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

  // ── OTP (Registration flow) ────────────────────────────────────────────────

  /// Gửi lại OTP cho user chưa confirmed (signup flow).
  Future<void> resendOtp(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  /// Xác nhận OTP — nếu đúng, Supabase auto confirm email + trả session.
  Future<AuthResponse> verifyOtp(String email, String otpCode) async {
    return _client.auth.verifyOTP(
      email: email,
      token: otpCode,
      type: OtpType.signup,
    );
  }

  /// Cập nhật phone + address vào profiles table.
  Future<void> updateProfileInfo(
    String userId, {
    required String phone,
    required String address,
  }) async {
    await _client.from('profiles').update({
      'phone': phone,
      'address': address,
    }).eq('id', userId);
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
