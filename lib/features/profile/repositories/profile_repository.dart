import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/providers/user_profile_provider.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(Supabase.instance.client);
}

class ProfileRepository {
  final SupabaseClient _client;

  const ProfileRepository(this._client);

  /// Lấy profile theo userId — trả về null nếu không tìm thấy
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from(SupabaseTables.profiles)
        .select('id, full_name, avatar_url, role, phone, address, date_of_birth, gender')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    final email = _client.auth.currentUser?.email;
    return UserProfile.fromMap(data, email: email);
  }

  /// Cập nhật thông tin profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _client.from(SupabaseTables.profiles).update(data).eq('id', userId);
  }

  /// Upload avatar lên Supabase Storage và trả về public URL
  Future<String> uploadAvatar(String userId, Uint8List bytes) async {
    const bucketName = SupabaseBuckets.avatars;
    final path = '$userId/avatar.jpg';

    await _client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true, // ghi đè nếu đã tồn tại
          ),
        );

    return _client.storage.from(bucketName).getPublicUrl(path);
  }
}
