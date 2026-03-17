import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';

class AvatarPickerWidget extends ConsumerWidget {
  final String? currentAvatarUrl;
  final XFile? pickedImage;

  const AvatarPickerWidget({
    super.key,
    this.currentAvatarUrl,
    this.pickedImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: GestureDetector(
        onTap: () => ref.read(editProfileViewModelProvider.notifier).pickImage(),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.lightGrey,
              backgroundImage: _resolveImage(),
              child: _resolveImage() == null
                  ? const Icon(Icons.person, size: 52, color: Colors.grey)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _resolveImage() {
    if (pickedImage != null) {
      return FileImage(File(pickedImage!.path));
    }
    if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return NetworkImage(currentAvatarUrl!);
    }
    return null;
  }
}
