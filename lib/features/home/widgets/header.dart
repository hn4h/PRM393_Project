import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/providers/user_profile_provider.dart';
import 'package:prm_project/core/utils/image_helper.dart';
import 'package:prm_project/features/notification/viewmodels/notification_viewmodel.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        profileAsync.when(
          loading: () => _buildSkeleton(context),
          error: (_, __) => _buildFallback(context),
          data: (profile) => _buildUserInfo(context, profile),
        ),
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: Icon(
                Icons.notifications_none,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic profile) {
    final name = profile?.displayName ?? 'User';
    final avatarUrl = profile?.avatarUrl;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.surfaceContainerHighest,
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
              : Icon(Icons.person, size: 24, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello 👋',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 60, height: 12, color: surfaceColor),
            const SizedBox(height: 4),
            Container(width: 100, height: 14, color: surfaceColor),
          ],
        ),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello 👋', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
            Text('User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}
