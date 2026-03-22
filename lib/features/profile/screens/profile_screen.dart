import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/providers/user_profile_provider.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/utils/image_helper.dart';
import 'package:prm_project/core/widgets/app_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile header ────────────────────────────────────────────
          profileAsync.when(
            loading: () => _buildHeaderSkeleton(),
            error: (_, __) => _buildHeaderFallback(context),
            data: (profile) => _buildHeader(context, ref, profile),
          ),

          const SizedBox(height: 32),

          // ── Menu items ────────────────────────────────────────────────
          _buildMenuItem(
            icon: Icons.history,
            title: 'Booking History',
            onTap: () => context.push('/booking-history'),
          ),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Saved Services',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () => context.push('/settings'),
          ),

          const SizedBox(height: 16),

          // ── Logout ───────────────────────────────────────────────────
          AppOutlinedButton(
            text: 'Logout',
            onPressed: () => _confirmLogout(context, ref),
            borderColor: AppColors.error,
            textColor: AppColors.error,
            prefixIcon: Icons.logout,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Header widgets ──────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic profile) {
    final name = profile?.displayName ?? 'User';
    final email = profile?.email ?? '';
    final avatarUrl = profile?.avatarUrl;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.lightGrey,
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ImageHelper.loadNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorWidget: const Icon(Icons.person, size: 50),
                  )
                : const Icon(Icons.person, size: 50, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        Text(name.toUpperCase(), style: AppTextStyles.headline2),
        const SizedBox(height: 4),
        if (email.isNotEmpty)
          Text(
            email,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Edit Profile',
          onPressed: () => context.push('/edit-profile'),
          isFullWidth: false,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          textColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 16),
        Container(width: 160, height: 18, color: Colors.grey.shade200),
        const SizedBox(height: 8),
        Container(width: 120, height: 14, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildHeaderFallback(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 16),
        const Text('USER', style: AppTextStyles.headline2),
        const SizedBox(height: 16),
        AppButton(
          text: 'Edit Profile',
          onPressed: () => context.push('/edit-profile'),
          isFullWidth: false,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          textColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      ],
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
