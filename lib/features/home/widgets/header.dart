import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/providers/user_profile_provider.dart';
import 'package:prm_project/core/utils/image_helper.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        profileAsync.when(
          loading: () => _buildSkeleton(),
          error: (_, __) => _buildFallback(),
          data: (profile) => _buildUserInfo(profile),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildUserInfo(dynamic profile) {
    final name = profile?.displayName ?? 'User';
    final avatarUrl = profile?.avatarUrl;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? ClipOval(
                  child: ImageHelper.loadNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                    errorWidget: const Icon(Icons.person, size: 24),
                  ),
                )
              : const Icon(Icons.person, size: 24, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello 👋',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 60, height: 12, color: Colors.grey.shade200),
            const SizedBox(height: 4),
            Container(width: 100, height: 14, color: Colors.grey.shade200),
          ],
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Row(
      children: [
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Hello 👋', style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text('User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
