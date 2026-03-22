import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/widgets/app_button.dart';
import 'package:prm_project/core/widgets/app_text_field.dart';
import 'package:prm_project/features/settings/viewmodels/change_password_viewmodel.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({Key? key, this.forceMode = false}) : super(key: key);

  /// When true, user was redirected here after a password reset.
  /// Back button is hidden, success navigates to /shell.
  final bool forceMode;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;

  @override
  void dispose() {
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ref
        .read(changePasswordViewModelProvider.notifier)
        .changePassword(
          currentPassword: _currentPwController.text,
          newPassword: _newPwController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _success = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: widget.forceMode
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
        automaticallyImplyLeading: !widget.forceMode,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _success ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  // ── Form View ─────────────────────────────────────────────────────────────

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Change Password',
            style: AppTextStyles.display1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.forceMode
                ? 'Your password was reset. Please set a new password to continue.'
                : 'Enter your current password and choose a new one.',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 36),

          // ── Current Password ──────────────────────────────────────────
          AppTextField(
            controller: _currentPwController,
            label: widget.forceMode ? 'Temporary Password' : 'Current Password',
            hint: widget.forceMode ? 'Enter temporary password' : 'Enter current password',
            obscureText: _obscureCurrent,
            prefixIcon: const Icon(Icons.key_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrent
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Current password is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ── New Password ──────────────────────────────────────────────
          AppTextField(
            controller: _newPwController,
            label: 'New Password',
            hint: 'Enter new password',
            obscureText: _obscureNew,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureNew = !_obscureNew),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'New password is required';
              }
              if (v.trim().length < 5) {
                return 'Password must be at least 5 characters';
              }
              if (v.trim() == _currentPwController.text.trim()) {
                return 'New password must be different from current';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ── Confirm Password ──────────────────────────────────────────
          AppTextField(
            controller: _confirmPwController,
            label: 'Confirm New Password',
            hint: 'Re-enter new password',
            obscureText: _obscureConfirm,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please confirm your new password';
              }
              if (v.trim() != _newPwController.text.trim()) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          AppButton(
            text: 'Update Password',
            onPressed: _submit,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Success View ──────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 56),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Password Updated!',
          style: AppTextStyles.display1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your password has been changed successfully.',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AppButton(
          text: widget.forceMode ? 'Continue to App' : 'Back to Settings',
          onPressed: () {
            if (widget.forceMode) {
              context.go('/shell');
            } else {
              context.pop();
            }
          },
        ),
      ],
    );
  }
}
