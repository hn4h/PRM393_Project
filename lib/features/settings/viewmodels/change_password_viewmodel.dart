import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/features/auth/viewmodels/auth_viewmodel.dart';

/// Possible states for the change-password flow.
enum ChangePasswordStatus { idle, loading, success }

class ChangePasswordViewModel extends Notifier<ChangePasswordStatus> {
  @override
  ChangePasswordStatus build() => ChangePasswordStatus.idle;

  /// Attempts to change the user's password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = ChangePasswordStatus.loading;

    final repo = ref.read(authRepositoryProvider);
    final email = Supabase.instance.client.auth.currentUser?.email;

    if (email == null) {
      state = ChangePasswordStatus.idle;
      return 'Session expired. Please login again.';
    }

    // 1️⃣ Verify current password by re-authenticating
    final verifyError =
        await repo.verifyCurrentPassword(email, currentPassword);
    if (verifyError != null) {
      state = ChangePasswordStatus.idle;
      return 'Current password is incorrect';
    }

    // 2️⃣ Update to new password
    try {
      await repo.updatePassword(newPassword);

      // 3️⃣ Clear must_change_password flag if it was set (from reset flow)
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await repo.clearMustChangePassword(userId);
      }

      // 4️⃣ Update auth state to clear mustChangePassword
      final authState =
          ref.read(authViewModelProvider).valueOrNull;
      if (authState != null && authState.mustChangePassword) {
        ref.read(authViewModelProvider.notifier).clearMustChangePasswordFlag();
      }

      state = ChangePasswordStatus.success;
      return null; // success
    } on AuthException catch (e) {
      state = ChangePasswordStatus.idle;
      return e.message;
    } catch (_) {
      state = ChangePasswordStatus.idle;
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Resets the state back to idle (e.g. when navigating away).
  void reset() => state = ChangePasswordStatus.idle;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final changePasswordViewModelProvider =
    NotifierProvider<ChangePasswordViewModel, ChangePasswordStatus>(() {
  return ChangePasswordViewModel();
});
