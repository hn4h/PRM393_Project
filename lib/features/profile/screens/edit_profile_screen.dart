import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/edit_profile_viewmodel.dart';
import 'widgets/avatar_picker_widget.dart';
import 'widgets/profile_form_widget.dart';
import 'widgets/worker_section_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shared Customer controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final ValueNotifier<DateTime?> _dateOfBirthNotifier;
  late final ValueNotifier<String?> _genderNotifier;

  // Worker-only controllers
  late final TextEditingController _bioController;
  late final TextEditingController _serviceAreaController;
  late final TextEditingController _yearsExpController;
  late final TextEditingController _skillsController;

  bool _controllersInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthNotifier.dispose();
    _genderNotifier.dispose();
    _bioController.dispose();
    _serviceAreaController.dispose();
    _yearsExpController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _initControllers(EditProfileState data) {
    if (_controllersInitialized) return;
    final p = data.profile;
    final w = data.workerInfo;

    _nameController = TextEditingController(text: p?.fullName ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _dateOfBirthNotifier = ValueNotifier(p?.dateOfBirth);
    _genderNotifier = ValueNotifier(p?.gender);

    _bioController = TextEditingController(text: w?['bio'] as String? ?? '');
    _serviceAreaController =
        TextEditingController(text: w?['service_area'] as String? ?? '');
    _yearsExpController = TextEditingController(
        text: (w?['years_experience'] as int?)?.toString() ?? '');
    _skillsController =
        TextEditingController(text: w?['skills'] as String? ?? '');

    _controllersInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(editProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Không tải được dữ liệu', style: AppTextStyles.body1),
              TextButton(
                onPressed: () =>
                    ref.invalidate(editProfileViewModelProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (data) {
          _initControllers(data);
          return Stack(
            children: [
              _buildBody(context, data),
              if (data.isSaving) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, EditProfileState data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar
          AvatarPickerWidget(
            currentAvatarUrl: data.profile?.avatarUrl,
            pickedImage: data.pickedImage,
          ),
          const SizedBox(height: 28),

          // 6 fields Customer + form validation
          ProfileFormWidget(
            initialProfile: data.profile,
            formKey: _formKey,
            nameController: _nameController,
            phoneController: _phoneController,
            addressController: _addressController,
            dateOfBirthNotifier: _dateOfBirthNotifier,
            genderNotifier: _genderNotifier,
          ),

          // Worker section (hiện khi isWorker)
          if (data.isWorker)
            WorkerSectionWidget(
              initialWorkerInfo: data.workerInfo,
              bioController: _bioController,
              serviceAreaController: _serviceAreaController,
              yearsExperienceController: _yearsExpController,
              skillsController: _skillsController,
            ),

          const SizedBox(height: 32),

          // Save button
          AppButton(
            text: 'Lưu thay đổi',
            onPressed: data.isSaving ? () {} : () => _onSaveTap(context, data),
          ),

          // Error message
          if (data.error != null) ...[
            const SizedBox(height: 12),
            Text(
              data.error!,
              style: AppTextStyles.body1.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _onSaveTap(BuildContext context, EditProfileState data) async {
    if (!_formKey.currentState!.validate()) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận lưu'),
        content: const Text('Bạn có chắc muốn lưu thay đổi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Xác nhận',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final yearsExp = int.tryParse(_yearsExpController.text.trim());
    final success =
        await ref.read(editProfileViewModelProvider.notifier).save(
              fullName: _nameController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              dateOfBirth: _dateOfBirthNotifier.value,
              gender: _genderNotifier.value,
              bio: data.isWorker ? _bioController.text : null,
              serviceArea: data.isWorker ? _serviceAreaController.text : null,
              yearsExperience: data.isWorker ? yearsExp : null,
              skills: data.isWorker ? _skillsController.text : null,
            );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }
}
