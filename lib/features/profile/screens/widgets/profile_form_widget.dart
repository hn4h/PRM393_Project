import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/user_profile_provider.dart';

class ProfileFormWidget extends StatefulWidget {
  final UserProfile? initialProfile;
  final GlobalKey<FormState> formKey;

  // Controllers exposed để EditProfileScreen đọc giá trị khi Save
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final ValueNotifier<DateTime?> dateOfBirthNotifier;
  final ValueNotifier<String?> genderNotifier;

  const ProfileFormWidget({
    super.key,
    required this.initialProfile,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.dateOfBirthNotifier,
    required this.genderNotifier,
  });

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  static const _genders = ['Nam', 'Nữ', 'Khác'];
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin cá nhân'),
          const SizedBox(height: 12),

          // Tên
          _buildField(
            label: 'Họ và tên *',
            controller: widget.nameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
          ),
          const SizedBox(height: 12),

          // Số điện thoại
          _buildField(
            label: 'Số điện thoại',
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Địa chỉ
          _buildField(
            label: 'Địa chỉ',
            controller: widget.addressController,
          ),
          const SizedBox(height: 12),

          // Ngày sinh
          _buildDateField(context),
          const SizedBox(height: 12),

          // Giới tính
          _buildGenderDropdown(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: AppTextStyles.headline2.copyWith(fontSize: 16)),
      );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: widget.dateOfBirthNotifier,
      builder: (context, date, _) {
        return GestureDetector(
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Ngày sinh',
                hintText: 'dd/MM/yyyy',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              controller: TextEditingController(
                text: date != null ? _dateFormat.format(date) : '',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderDropdown() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.genderNotifier,
      builder: (context, gender, _) {
        return DropdownButtonFormField<String>(
          value: _genders.contains(gender) ? gender : null,
          decoration: InputDecoration(
            labelText: 'Giới tính',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => widget.genderNotifier.value = v,
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.dateOfBirthNotifier.value ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      widget.dateOfBirthNotifier.value = picked;
    }
  }
}
