import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/user_profile_provider.dart';
import '../repositories/profile_repository.dart';
import '../repositories/worker_repository.dart';

part 'edit_profile_viewmodel.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class EditProfileState {
  final UserProfile? profile;
  final Map<String, dynamic>? workerInfo; // null nếu Customer
  final bool isWorker;
  final bool isSaving;
  final String? error;
  final XFile? pickedImage; // ảnh mới chọn từ gallery, chưa upload

  const EditProfileState({
    this.profile,
    this.workerInfo,
    this.isWorker = false,
    this.isSaving = false,
    this.error,
    this.pickedImage,
  });

  EditProfileState copyWith({
    UserProfile? profile,
    Map<String, dynamic>? workerInfo,
    bool? isWorker,
    bool? isSaving,
    String? error,
    XFile? pickedImage,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      workerInfo: workerInfo ?? this.workerInfo,
      isWorker: isWorker ?? this.isWorker,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
      pickedImage: clearImage ? null : pickedImage ?? this.pickedImage,
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  @override
  Future<EditProfileState> build() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const EditProfileState();

    final profileRepo = ref.read(profileRepositoryProvider);
    final workerRepo = ref.read(workerRepositoryProvider);

    final profile = await profileRepo.getProfile(userId);
    final isWorker = profile?.role == 'worker';

    Map<String, dynamic>? workerInfo;
    if (isWorker) {
      workerInfo = await workerRepo.getWorkerInfo(userId);
    }

    return EditProfileState(
      profile: profile,
      workerInfo: workerInfo,
      isWorker: isWorker,
    );
  }

  /// Mở gallery để chọn ảnh avatar
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(pickedImage: picked));
  }

  /// Lưu profile — trả về true nếu thành công
  Future<bool> save({
    required String fullName,
    required String? phone,
    required String? address,
    required DateTime? dateOfBirth,
    required String? gender,
    // Worker-only
    String? bio,
    String? serviceArea,
    int? yearsExperience,
    String? skills,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final profileRepo = ref.read(profileRepositoryProvider);
      final workerRepo = ref.read(workerRepositoryProvider);

      // 1. Upload avatar nếu có ảnh mới
      String? newAvatarUrl;
      if (current.pickedImage != null) {
        final bytes = await current.pickedImage!.readAsBytes();
        newAvatarUrl = await profileRepo.uploadAvatar(userId, bytes);
      }

      // 2. Update profiles table
      final profileData = <String, dynamic>{
        'full_name': fullName.trim(),
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (address != null && address.isNotEmpty) 'address': address.trim(),
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
      };
      await profileRepo.updateProfile(userId, profileData);

      // 3. Upsert workers table nếu là Worker
      if (current.isWorker) {
        final workerData = <String, dynamic>{
          if (bio != null) 'bio': bio.trim(),
          if (serviceArea != null) 'service_area': serviceArea.trim(),
          if (yearsExperience != null) 'years_experience': yearsExperience,
          if (skills != null) 'skills': skills.trim(),
        };
        if (workerData.isNotEmpty) {
          await workerRepo.upsertWorkerInfo(userId, workerData);
        }
      }

      // 4. Invalidate userProfileProvider để Profile screen cập nhật lại
      ref.invalidate(userProfileProvider);

      state = AsyncData(current.copyWith(isSaving: false, clearImage: true));
      return true;
    } catch (e) {
      final curr = state.valueOrNull ?? current;
      state = AsyncData(
        curr.copyWith(isSaving: false, error: 'Lưu thất bại: ${e.toString()}'),
      );
      return false;
    }
  }
}
