import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/widgets/app_button.dart';
import 'package:prm_project/core/widgets/app_text_field.dart';
import 'package:prm_project/features/auth/viewmodels/auth_viewmodel.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String email;

  const CompleteProfileScreen({super.key, required this.email});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Gửi OTP mới tới email
    final error = await ref
        .read(authViewModelProvider.notifier)
        .resendOtp(widget.email);

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

    // Navigate sang OTP screen, truyền data qua extra
    context.go('/otp-verify', extra: {
      'email': widget.email,
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // Không có nút Back
        title: const Text('Hoàn tất đăng ký'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_pin_outlined,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Thêm thông tin',
                  style: AppTextStyles.display1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng điền thêm thông tin để hoàn tất đăng ký',
                  style: AppTextStyles.body1.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Số điện thoại
                AppTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại *',
                  hint: 'Nhập số điện thoại',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Số điện thoại là bắt buộc';
                    }
                    final phoneRegex = RegExp(r'^(0|\+84)\d{9,10}$');
                    if (!phoneRegex.hasMatch(v.trim())) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Địa chỉ
                AppTextField(
                  controller: _addressController,
                  label: 'Địa chỉ *',
                  hint: 'Nhập địa chỉ của bạn',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Địa chỉ là bắt buộc';
                    }
                    if (v.trim().length < 5) {
                      return 'Địa chỉ phải có ít nhất 5 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Nút Tiếp tục
                AppButton(
                  text: 'Tiếp tục',
                  onPressed: _onContinue,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
