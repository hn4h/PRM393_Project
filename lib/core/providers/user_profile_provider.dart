import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';

/// Data class cho user profile từ Supabase profiles table
class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? role;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;

  const UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.role,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? email}) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      email: email ?? map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'] as String)
          : null,
      gender: map['gender'] as String?,
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  /// Display name: dùng full_name nếu có, fallback về email prefix
  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    return 'User';
  }
}

/// Provider fetch profile từ Supabase cho user đang đăng nhập
/// Tự động re-fetch khi user thay đổi (listen auth state)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) return null;

  final data = await client
      .from(SupabaseTables.profiles)
      .select('id, full_name, avatar_url, role, phone, address, date_of_birth, gender')
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) {
    // Fallback: trả về profile tối thiểu từ auth user
    return UserProfile(id: user.id, email: user.email);
  }

  return UserProfile.fromMap(data, email: user.email);
});
