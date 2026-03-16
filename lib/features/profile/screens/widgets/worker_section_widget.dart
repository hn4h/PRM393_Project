import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_text_styles.dart';

class WorkerSectionWidget extends StatelessWidget {
  final Map<String, dynamic>? initialWorkerInfo;

  final TextEditingController bioController;
  final TextEditingController serviceAreaController;
  final TextEditingController yearsExperienceController;
  final TextEditingController skillsController;

  const WorkerSectionWidget({
    super.key,
    required this.initialWorkerInfo,
    required this.bioController,
    required this.serviceAreaController,
    required this.yearsExperienceController,
    required this.skillsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 16),

        Text(
          'Thông tin chuyên môn',
          style: AppTextStyles.headline2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Bio
        TextFormField(
          controller: bioController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Giới thiệu bản thân',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Khu vực phục vụ
        TextFormField(
          controller: serviceAreaController,
          decoration: InputDecoration(
            labelText: 'Khu vực phục vụ',
            hintText: 'VD: Quận 1, Quận 3, TP.HCM',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Kinh nghiệm (năm)
        TextFormField(
          controller: yearsExperienceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Số năm kinh nghiệm',
            hintText: 'VD: 3',
            suffixText: 'năm',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Kỹ năng
        TextFormField(
          controller: skillsController,
          decoration: InputDecoration(
            labelText: 'Kỹ năng / Dịch vụ cung cấp',
            hintText: 'VD: Dọn dẹp, Nấu ăn, Giặt ủi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
