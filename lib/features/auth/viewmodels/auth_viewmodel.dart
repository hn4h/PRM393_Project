import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/features/auth/models/auth_state_model.dart';
import 'package:prm_project/features/auth/repositories/auth_repository.dart';

class AuthViewModel extends AsyncNotifier<AuthStateModel> {
  late AuthRepository _repo;

  @override
  Future<AuthStateModel> build() async {
    _repo = ref.read(authRepositoryProvider);

    // Listen to Supabase auth changes and update state reactively
    ref.listen(authRepositoryProvider, (_, next) {});

    final session = _repo.currentSession;
    if (session == null) {
      return const AuthStateModel(status: AuthStatus.unauthenticated);
    }

    final user = session.user;
    if (!_isEmailConfirmed(user)) {
      return AuthStateModel(
        status: AuthStatus.emailNotConfirmed,
        email: user.email,
        userId: user.id,
      );
    }

    final role = await _repo.getUserRole(user.id);
    return AuthStateModel(
      status: AuthStatus.authenticated,
      userId: user.id,
      email: user.email,
      role: role,
    );
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (res.user != null) {
        state = AsyncData(
          AuthStateModel(
            status: AuthStatus.emailNotConfirmed,
            email: email,
            userId: res.user!.id,
          ),
        );
        return null; // success
      }
      return 'Registration failed. Please try again.';
    } on AuthException catch (e) {
      state = AsyncData(
        AuthStateModel(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
      return e.message;
    } catch (_) {
      state = AsyncData(
        const AuthStateModel(
          status: AuthStatus.unauthenticated,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
      return 'An unexpected error occurred.';
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.signIn(email: email, password: password);
      final user = res.user;
      if (user == null) {
        state = const AsyncData(
          AuthStateModel(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Login failed.',
          ),
        );
        return 'Login failed.';
      }

      if (!_isEmailConfirmed(user)) {
        state = AsyncData(
          AuthStateModel(
            status: AuthStatus.emailNotConfirmed,
            email: user.email,
            userId: user.id,
          ),
        );
        return null; // let router redirect to /complete-profile
      }

      final role = await _repo.getUserRole(user.id);
      final mustChange = await _repo.checkMustChangePassword(user.id);
      state = AsyncData(
        AuthStateModel(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          role: role,
          mustChangePassword: mustChange,
        ),
      );
      return null; // success
    } on AuthException catch (e) {
      state = AsyncData(
        AuthStateModel(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
      return e.message;
    } catch (e) {
      state = AsyncData(
        const AuthStateModel(
          status: AuthStatus.unauthenticated,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
      return 'An unexpected error occurred.';
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(
      AuthStateModel(status: AuthStatus.unauthenticated),
    );
  }

  // ── Forgot Password (Edge Function) ────────────────────────────────────────

  /// Calls Edge Function to generate random password and send via Gmail SMTP.
  /// Returns null on success, error message on failure.
  Future<String?> sendPasswordReset(String email) async {
    return _repo.requestPasswordReset(email);
  }

  /// Clears the mustChangePassword flag in the in-memory auth state.
  /// Called after the user successfully changes their password.
  void clearMustChangePasswordFlag() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(mustChangePassword: false));
    }
  }

  // ── OTP Registration Flow ──────────────────────────────────────────────────

  /// Gửi lại OTP tới email. Returns null on success, error message on failure.
  Future<String?> resendOtp(String email) async {
    try {
      await _repo.resendOtp(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to send OTP. Please try again.';
    }
  }

  /// Xác nhận OTP + lưu phone/address vào DB.
  /// Returns null on success, error message on failure.
  Future<String?> verifyOtpAndSaveProfile({
    required String email,
    required String otpCode,
    required String phone,
    required String address,
  }) async {
    try {
      // 1. Verify OTP → Supabase confirms email + returns session
      final res = await _repo.verifyOtp(email, otpCode);
      final user = res.user;
      if (user == null) return 'Verification failed.';

      // 2. Save phone + address to profiles table
      try {
        await _repo.updateProfileInfo(
          user.id,
          phone: phone,
          address: address,
        );
      } catch (e) {
        // Profile update failed (e.g. RLS, network) — still authenticated
        // Log but don't block login, user can update profile later
        // ignore: avoid_print
        print('Profile update failed: $e');
      }

      // 3. Update auth state to authenticated
      final role = await _repo.getUserRole(user.id);
      state = AsyncData(
        AuthStateModel(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          role: role,
        ),
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // ── OTP Registration Flow ──────────────────────────────────────────────────

  /// Gửi lại OTP tới email. Returns null on success, error message on failure.
  Future<String?> resendOtp(String email) async {
    try {
      await _repo.resendOtp(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to send OTP. Please try again.';
    }
  }

  /// Xác nhận OTP + lưu phone/address vào DB.
  /// Returns null on success, error message on failure.
  Future<String?> verifyOtpAndSaveProfile({
    required String email,
    required String otpCode,
    required String phone,
    required String address,
  }) async {
    try {
      // 1. Verify OTP → Supabase confirms email + returns session
      final res = await _repo.verifyOtp(email, otpCode);
      final user = res.user;
      if (user == null) return 'Verification failed.';

      // 2. Save phone + address to profiles table
      await _repo.updateProfileInfo(
        user.id,
        phone: phone,
        address: address,
      );

      // 3. Update auth state to authenticated
      final role = await _repo.getUserRole(user.id);
      state = AsyncData(
        AuthStateModel(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          role: role,
        ),
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isEmailConfirmed(User user) {
    final confirmedAt = user.emailConfirmedAt;
    return confirmedAt != null && confirmedAt.isNotEmpty;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<dynamic>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final authViewModelProvider =
    AsyncNotifierProvider<AuthViewModel, AuthStateModel>(() {
  return AuthViewModel();
});
