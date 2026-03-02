import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/utils/image_helper.dart';
import 'package:prm_project/core/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.lightGrey,
                child: ClipOval(
                  child: ImageHelper.loadNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorWidget: const Icon(Icons.person, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'NGUYEN LE HAI ANH',
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: 4),
              Text(
                'anhnlh@gmail.com',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Edit Profile',
                onPressed: () {},
                isFullWidth: false,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                textColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Menu items
          _buildMenuItem(
            icon: Icons.history,
            title: 'Booking History',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Saved Services',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Address Management',
            onTap: () {
              context.push('/addresses');
            },
          ),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {},
          ),
          
          const SizedBox(height: 16),
          
          // Logout button
          AppOutlinedButton(
            text: 'Logout',
            onPressed: () {},
            borderColor: AppColors.error,
            textColor: AppColors.error,
            prefixIcon: Icons.logout,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
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
}
